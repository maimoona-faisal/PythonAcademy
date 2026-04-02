using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    // this page shows lecturer registrations waiting to be approved or rejected
    public partial class Verification : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindPendingUsers(0);
            LogEvent("Verification.View", "Opened verification queue.");
        }

        protected void gvPendingUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            BindPendingUsers(e.NewPageIndex);
        }

        private void BindPendingUsers(int requestedPageIndex)
        {
            ClearStatusMessage(lblMessage);

            if (!TableExists("Users"))
            {
                gvPendingUsers.PageIndex = 0;
                gvPendingUsers.DataSource = CreatePendingUsersTable();
                gvPendingUsers.DataBind();
                lblQueueSummary.Text = "Verification queue is unavailable.";
                SetStatusMessage(lblMessage, "Users table was not found. Verification requests cannot be loaded.", true);
                return;
            }

            // check if optional columns exist before including them — prevents crashing on older DB schemas
            string cvColumn = ColumnExists("Users", "CVFilePath")
                ? "CVFilePath"
                : "CAST(NULL AS NVARCHAR(500)) AS CVFilePath";

            string linkedInColumn = ColumnExists("Users", "LinkedInUrl")
                ? "LinkedInUrl"
                : "CAST(NULL AS NVARCHAR(500)) AS LinkedInUrl";

            DataTable pendingUsers = ExecuteTable(
                @"SELECT UserID, Username, Email, CreatedAt, " + cvColumn + ", " + linkedInColumn + @"
                  FROM Users
                  WHERE Role = @Role AND Status = @Status
                  ORDER BY CreatedAt ASC, UserID ASC",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Pending"));

            int totalPending = pendingUsers.Rows.Count;
            int pageCount = totalPending == 0 ? 1 : (int)Math.Ceiling(totalPending / (double)gvPendingUsers.PageSize);
            int pageIndex = requestedPageIndex < 0 ? 0 : requestedPageIndex;
            if (pageIndex >= pageCount)
            {
                pageIndex = pageCount - 1;
            }

            gvPendingUsers.PageIndex = pageIndex;
            gvPendingUsers.DataSource = pendingUsers;
            gvPendingUsers.DataBind();

            lblQueueSummary.Text = totalPending == 0
                ? "There are no pending lecturer applications right now."
                : string.Format(CultureInfo.InvariantCulture, "{0} pending lecturer request(s) awaiting review.", totalPending);
        }

        protected void gvPendingUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // ignore any other button commands that arent approve/reject
            if (e.CommandName != "ApproveUser" && e.CommandName != "RejectUser")
            {
                return;
            }

            int userId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out userId) || userId <= 0)
            {
                SetStatusMessage(lblMessage, "Invalid request data.", true);
                return;
            }

            // walk up the control tree from the button to find its parent GridViewRow
            GridViewRow row = GetSourceRow(e.CommandSource);
            string rejectionReason = row == null ? string.Empty : ((TextBox)row.FindControl("txtRejectReason")).Text.Trim();
            bool isApprove = e.CommandName == "ApproveUser";

            // rejection requires a reason — don't allow a blank rejection
            if (!isApprove && rejectionReason.Length == 0)
            {
                SetStatusMessage(lblMessage, "Please provide a rejection reason before rejecting this request.", true);
                return;
            }

            if (rejectionReason.Length > 250)
            {
                rejectionReason = rejectionReason.Substring(0, 250);
            }

            try
            {
                ProcessVerificationRequest(userId, isApprove, rejectionReason);
            }
            catch
            {
                SetStatusMessage(lblMessage, "Unable to process this request right now.", true);
            }
        }

        private void ProcessVerificationRequest(int userId, bool isApprove, string rejectionReason)
        {
            string newStatus = isApprove ? "Active" : "Rejected";
            string verificationStatus = isApprove ? "Approved" : "Rejected";
            string username = string.Empty;
            string email = string.Empty; 
            bool requestProcessed = false;

            // using a transaction so the status update and verification log insert either both succeed or both roll back
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                using (SqlTransaction tx = con.BeginTransaction())
                {
                    using (SqlCommand selectCmd = new SqlCommand(
                        @"SELECT Username, Email, Status 
                          FROM Users
                          WHERE UserID = @UserID AND Role = @Role",
                        con,
                        tx))
                    {
                        selectCmd.Parameters.AddWithValue("@UserID", userId);
                        selectCmd.Parameters.AddWithValue("@Role", "Lecturer");

                        using (SqlDataReader reader = selectCmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                tx.Rollback();
                                SetStatusMessage(lblMessage, "The selected verification request could not be found.", true);
                                BindPendingUsers(gvPendingUsers.PageIndex);
                                return;
                            }

                            username = Convert.ToString(reader["Username"], CultureInfo.InvariantCulture);
                            email = Convert.ToString(reader["Email"], CultureInfo.InvariantCulture); 
                            string currentStatus = Convert.ToString(reader["Status"], CultureInfo.InvariantCulture);

                            if (!string.Equals(currentStatus, "Pending", StringComparison.OrdinalIgnoreCase))
                            {
                                tx.Rollback();
                                SetStatusMessage(lblMessage, "This request was already processed.", true);
                                BindPendingUsers(gvPendingUsers.PageIndex);
                                return;
                            }
                        }
                    }

                    using (SqlCommand updateCmd = new SqlCommand(
                        @"UPDATE Users
                          SET Status = @NewStatus
                          WHERE UserID = @UserID
                            AND Role = @Role
                            AND Status = @CurrentStatus",
                        con,
                        tx))
                    {
                        updateCmd.Parameters.AddWithValue("@NewStatus", newStatus);
                        updateCmd.Parameters.AddWithValue("@UserID", userId);
                        updateCmd.Parameters.AddWithValue("@Role", "Lecturer");
                        updateCmd.Parameters.AddWithValue("@CurrentStatus", "Pending");

                        // ExecuteNonQuery returns rows affected — if 0, someone else processed it between our read and update
                        requestProcessed = updateCmd.ExecuteNonQuery() == 1;
                    }

                    if (!requestProcessed)
                    {
                        tx.Rollback();
                        SetStatusMessage(lblMessage, "This request was already processed.", true);
                        BindPendingUsers(gvPendingUsers.PageIndex);
                        return;
                    }

                    // log to VerificationLog if the table exists — wrapped in its own try so it doesn't block the main update
                    if (TableExists("VerificationLog"))
                    {
                        try
                        {
                            using (SqlCommand logCmd = new SqlCommand(
                                @"INSERT INTO VerificationLog (TargetID, TargetType, AdminID, Status, Comments)
                                  VALUES (@TargetID, @TargetType, @AdminID, @Status, @Comments)",
                                con,
                                tx))
                            {
                                logCmd.Parameters.AddWithValue("@TargetID", userId);
                                logCmd.Parameters.AddWithValue("@TargetType", "InstructorRegistration");
                                logCmd.Parameters.AddWithValue("@AdminID", (object)AdminUserId ?? DBNull.Value);
                                logCmd.Parameters.AddWithValue("@Status", verificationStatus);
                                logCmd.Parameters.AddWithValue("@Comments", (object)BuildVerificationComment(isApprove, rejectionReason) ?? DBNull.Value);
                                logCmd.ExecuteNonQuery();
                            }
                        }
                        catch
                        {
                            // keep the verification workflow successful even if the optional audit table is unavailable
                        }
                    }

                    tx.Commit();
                }
            }

             System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(async token =>
             {
                 if (isApprove)
                 {
                     await EmailManager.SendLecturerApprovalAsync(email, username);
                 }
                 else
                 {
                    await EmailManager.SendLecturerRejectionAsync(email, username, rejectionReason);
                 }
            });



            string actionName = isApprove ? "Verification.Approve" : "Verification.Reject";
            string details = isApprove
                ? string.Format(CultureInfo.InvariantCulture, "Approved lecturer verification for user '{0}' (UserID={1}).", username, userId)
                : string.Format(CultureInfo.InvariantCulture, "Rejected lecturer verification for user '{0}' (UserID={1}). A rejection reason was recorded.", username, userId);

            LogEvent(actionName, details);

            SetStatusMessage(
                lblMessage,
                isApprove
                    ? string.Format(CultureInfo.InvariantCulture, "Instructor '{0}' was approved successfully.", username)
                    : string.Format(CultureInfo.InvariantCulture, "Instructor '{0}' was rejected and the reason was recorded.", username),
                false);

            BindPendingUsers(gvPendingUsers.PageIndex);
        }

        // returns an empty table with the right columns — used when the Users table doesn't exist
        private static DataTable CreatePendingUsersTable()
        {
            DataTable table = new DataTable();
            table.Columns.Add("UserID", typeof(int));
            table.Columns.Add("Username", typeof(string));
            table.Columns.Add("Email", typeof(string));
            table.Columns.Add("CreatedAt", typeof(DateTime));
            table.Columns.Add("CVFilePath", typeof(string));
            table.Columns.Add("LinkedInUrl", typeof(string));
            return table;
        }

        // walks up the control tree from the clicked button to find the GridViewRow it lives in
        private static GridViewRow GetSourceRow(object commandSource)
        {
            Control sourceControl = commandSource as Control;
            return sourceControl == null ? null : sourceControl.NamingContainer as GridViewRow;
        }

        private static string BuildVerificationComment(bool isApprove, string rejectionReason)
        {
            if (isApprove)
            {
                return "Approved by admin.";
            }

            string safeReason = (rejectionReason ?? string.Empty).Trim();
            return safeReason.Length == 0 ? "Rejected by admin." : "Rejected by admin. Reason: " + safeReason;
        }

        // CV links must point to our own CvFile.aspx handler — we don't allow arbitrary file paths
        protected bool HasSafeCvUrl(object cvPathValue)
        {
            return !string.IsNullOrWhiteSpace(GetSafeCvUrl(cvPathValue));
        }

        protected string GetSafeCvUrl(object cvPathValue)
        {
            string cvPath = Convert.ToString(cvPathValue, CultureInfo.InvariantCulture);
            if (string.IsNullOrWhiteSpace(cvPath))
            {
                return string.Empty;
            }

            string safePath = cvPath.Trim();
            if (safePath.StartsWith("~/Admin/CvFile.aspx", StringComparison.OrdinalIgnoreCase) ||
                safePath.StartsWith("Admin/CvFile.aspx", StringComparison.OrdinalIgnoreCase))
            {
                return ResolveUrl(safePath);
            }

            return string.Empty;
        }

        // LinkedIn URLs must actually be on linkedin.com — prevents open redirect attacks
        protected bool HasSafeLinkedInUrl(object linkedInValue)
        {
            return !string.IsNullOrWhiteSpace(GetSafeLinkedInUrl(linkedInValue));
        }

        protected string GetSafeLinkedInUrl(object linkedInValue)
        {
            string rawUrl = Convert.ToString(linkedInValue, CultureInfo.InvariantCulture);
            if (string.IsNullOrWhiteSpace(rawUrl))
            {
                return string.Empty;
            }

            Uri parsedUri;
            if (!Uri.TryCreate(rawUrl.Trim(), UriKind.Absolute, out parsedUri))
            {
                return string.Empty;
            }

            bool isHttp = parsedUri.Scheme == Uri.UriSchemeHttp || parsedUri.Scheme == Uri.UriSchemeHttps;
            bool isLinkedInHost = parsedUri.Host.IndexOf("linkedin.com", StringComparison.OrdinalIgnoreCase) >= 0;
            return isHttp && isLinkedInHost ? parsedUri.AbsoluteUri : string.Empty;
        }
    }
}
