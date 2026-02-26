using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    public partial class Verification : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindPendingUsers();
            LogEvent("Verification.View", "Opened verification queue.");
        }

        private void BindPendingUsers()
        {
            DataTable pendingUsers = ExecuteTable(
                @"SELECT UserID, Username, Email, CreatedAt
                  FROM Users
                  WHERE Role = @Role AND Status = @Status
                  ORDER BY CreatedAt ASC",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Pending"));

            gvPendingUsers.DataSource = pendingUsers;
            gvPendingUsers.DataBind();
        }

        protected void gvPendingUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ApproveUser" && e.CommandName != "RejectUser")
            {
                return;
            }

            int userId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out userId) || userId <= 0)
            {
                ShowMessage("Invalid request data.", true);
                return;
            }

            try
            {
                bool isApprove = e.CommandName == "ApproveUser";
                string newStatus = isApprove ? "Active" : "Rejected";
                int affected = ExecuteNonQuery(
                    @"UPDATE Users
                      SET Status = @NewStatus
                      WHERE UserID = @UserID
                        AND Role = @Role
                        AND Status = @CurrentStatus",
                    new SqlParameter("@NewStatus", newStatus),
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Role", "Lecturer"),
                    new SqlParameter("@CurrentStatus", "Pending"));

                if (affected == 0)
                {
                    ShowMessage("This request was already processed.", true);
                    BindPendingUsers();
                    return;
                }

                try
                {
                    object adminId = AdminUserId.HasValue ? (object)AdminUserId.Value : DBNull.Value;
                    ExecuteNonQuery(
                        @"INSERT INTO VerificationLog (TargetID, TargetType, AdminID, Status, Comments)
                          VALUES (@TargetID, @TargetType, @AdminID, @Status, @Comments)",
                        new SqlParameter("@TargetID", userId),
                        new SqlParameter("@TargetType", "InstructorRegistration"),
                        new SqlParameter("@AdminID", adminId),
                        new SqlParameter("@Status", newStatus),
                        new SqlParameter("@Comments", isApprove ? "Approved by admin." : "Rejected by admin."));
                }
                catch
                {
                    // Keep request workflow successful even if optional audit table is unavailable.
                }

                string actionName = isApprove ? "Verification.Approve" : "Verification.Reject";
                LogEvent(actionName, "Processed lecturer registration for UserID=" + userId + ".");

                ShowMessage(isApprove ? "Instructor approved successfully." : "Instructor rejected successfully.", false);
                BindPendingUsers();
            }
            catch
            {
                ShowMessage("Unable to process this request right now.", true);
            }
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }
    }
}
