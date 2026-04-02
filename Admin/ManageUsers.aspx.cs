using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    // this page lets the admin view, search, suspend, and delete users
    public partial class ManageUsers : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // skip reloading on postback so button clicks dont reset the table
            if (IsPostBack)
            {
                return;
            }

            // load all users by default when the page first opens
            BindUsersToTable(string.Empty, "All");
            LogEvent("Users.View", "Opened manage users page.");
        }

        // fires when the admin types a keyword or picks a role and clicks Search
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string keyword = (txtSearch.Text ?? string.Empty).Trim();
            string role = ddlRoleFilter.SelectedValue;

            // basic length check to avoid huge search strings
            if (keyword.Length > 100)
            {
                ShowMessage("Search text is too long. Keep it under 100 characters.", true);
                return;
            }

            BindUsersToTable(keyword, role);
            LogEvent("Users.Search", "Filtered users by keyword and role.");
        }

        // handles the Suspend/Activate and Delete buttons inside the repeater rows
        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // make sure the id that came back is actually a valid number
            int userId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out userId) || userId <= 0)
            {
                ShowMessage("Invalid user selection.", true);
                return;
            }

            try
            {
                // fetch the user's current info before doing anything
                DataTable targetUser = ExecuteTable(
                    @"SELECT UserID, Username, Role, Status
                      FROM Users
                      WHERE UserID = @UserID",
                    new SqlParameter("@UserID", userId));

                if (targetUser.Rows.Count == 0)
                {
                    ShowMessage("User record was not found.", true);
                    BindUsersToTable((txtSearch.Text ?? string.Empty).Trim(), ddlRoleFilter.SelectedValue);
                    return;
                }

                DataRow row = targetUser.Rows[0];
                string role = Convert.ToString(row["Role"]);
                string status = Convert.ToString(row["Status"]);
                string username = Convert.ToString(row["Username"]);

                // admins should never be modified from this page
                if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    ShowMessage("Admin accounts cannot be modified here.", true);
                    return;
                }

                // prevent the admin from accidentally locking out their own account
                if (AdminUserId.HasValue && userId == AdminUserId.Value)
                {
                    ShowMessage("You cannot modify your own account here.", true);
                    return;
                }

                if (e.CommandName == "ToggleStatus")
                {
                    if (!CanToggleStatus(status))
                    {
                        string message = string.Equals(role, "Lecturer", StringComparison.OrdinalIgnoreCase) &&
                                         (string.Equals(status, "Pending", StringComparison.OrdinalIgnoreCase) ||
                                          string.Equals(status, "Rejected", StringComparison.OrdinalIgnoreCase))
                            ? "Pending or rejected lecturer accounts must be handled from the verification queue."
                            : "Only Active and Suspended accounts can be toggled from this page.";

                        ShowMessage(message, true);
                        BindUsersToTable((txtSearch.Text ?? string.Empty).Trim(), ddlRoleFilter.SelectedValue);
                        return;
                    }

                    string newStatus = string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase) ? "Suspended" : "Active";

                    // the WHERE clause double-checks the status in SQL so we don't accidentally flip a Pending/Rejected account
                    int affected = ExecuteNonQuery(
                        @"UPDATE Users
                          SET Status = @Status
                          WHERE UserID = @UserID
                            AND Status IN ('Active', 'Suspended')",
                        new SqlParameter("@Status", newStatus),
                        new SqlParameter("@UserID", userId));

                    if (affected == 0)
                    {
                        ShowMessage("This account can no longer be toggled from Manage Users.", true);
                        BindUsersToTable((txtSearch.Text ?? string.Empty).Trim(), ddlRoleFilter.SelectedValue);
                        return;
                    }

                    LogEvent("Users.StatusUpdate", "Updated status for user '" + username + "' to '" + newStatus + "'.");
                    ShowMessage("User status updated to " + newStatus + ".", false);
                }
                else if (e.CommandName == "DeleteUser")
                {
                    // separate method handles the delete logic
                    DeleteUser(userId, username, status, role);
                }

                // refresh the table after any action
                BindUsersToTable((txtSearch.Text ?? string.Empty).Trim(), ddlRoleFilter.SelectedValue);
            }
            catch
            {
                ShowMessage("Unable to update user right now.", true);
            }
        }

        // tries to delete the user, falls back to suspending if there are related records
        private void DeleteUser(int userId, string username, string status, string role)
        {
            try
            {
                int affected = ExecuteNonQuery(
                    "DELETE FROM Users WHERE UserID = @UserID",
                    new SqlParameter("@UserID", userId));

                if (affected == 0)
                {
                    // user was probably already deleted by someone else
                    ShowMessage("User was already removed.", true);
                    return;
                }

                LogEvent("Users.Delete", "Deleted user '" + username + "' (UserID=" + userId + ").");
                ShowMessage("User deleted successfully.", false);
            }
            catch (SqlException ex)
            {
                // error 547 = FK violation, meaning this user has related rows (progress, submissions, etc.)
                // so instead of crashing, just suspend them
                if (ex.Number == 547)
                {
                    if (!CanToggleStatus(status))
                    {
                        string message = string.Equals(role, "Lecturer", StringComparison.OrdinalIgnoreCase) &&
                                         (string.Equals(status, "Pending", StringComparison.OrdinalIgnoreCase) ||
                                          string.Equals(status, "Rejected", StringComparison.OrdinalIgnoreCase))
                            ? "This lecturer record has related data and cannot be deleted here. Use the verification queue for approval decisions."
                            : "This user has related records and cannot be deleted unless the account is already Active or Suspended.";

                        ShowMessage(message, true);
                        return;
                    }

                    // Foreign key constraints can block hard deletes. Suspend account as fallback.
                    ExecuteNonQuery(
                        @"UPDATE Users
                          SET Status = @Status
                          WHERE UserID = @UserID",
                        new SqlParameter("@Status", "Suspended"),
                        new SqlParameter("@UserID", userId));

                    LogEvent("Users.Suspend", "Deletion blocked by related data; suspended user '" + username + "' instead.");
                    ShowMessage("User has related records and was suspended instead of deleted.", false);
                    return;
                }

                throw; // re-throw anything that isn't a FK violation so the outer catch can handle it
            }
        }

        // builds the user table based on the current search keyword and role filter
        private void BindUsersToTable(string searchQuery, string roleFilter)
        {
            StringBuilder sql = new StringBuilder();
            sql.AppendLine("SELECT UserID, Username, Email, Role, Status, CreatedAt");
            sql.AppendLine("FROM Users");

            // admin will not be here
            sql.AppendLine("WHERE Role != 'Admin'");

            List<SqlParameter> parameters = new List<SqlParameter>();

            // add keyword filter only if the search box is not empty
            if (!string.IsNullOrWhiteSpace(searchQuery))
            {
                sql.AppendLine("AND (Username LIKE @Search OR Email LIKE @Search)");
                parameters.Add(new SqlParameter("@Search", "%" + searchQuery + "%"));
            }

            // add role filter only if a specific role is selected (not "All")
            if (!string.IsNullOrWhiteSpace(roleFilter) && !roleFilter.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                sql.AppendLine("AND Role = @Role");
                parameters.Add(new SqlParameter("@Role", roleFilter));
            }

            // show newest accounts at the top
            sql.AppendLine("ORDER BY CreatedAt DESC");

            DataTable users = ExecuteTable(sql.ToString(), parameters.ToArray());
            rptUsers.DataSource = users;
            rptUsers.DataBind();

            // Updated to use the new rowEmpty ID
            // show the "no users found" row only if the result is empty
            rowEmpty.Visible = (users.Rows.Count == 0);
        }

        // only Active and Suspended accounts can be toggled — Pending/Rejected go through the verification queue
        protected bool CanToggleStatus(object statusValue)
        {
            string status = Convert.ToString(statusValue);
            return string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(status, "Suspended", StringComparison.OrdinalIgnoreCase);
        }

        // returns the first letter of the username for the avatar circle in the UI
        protected string GetAvatarInitial(object usernameValue)
        {
            string username = Convert.ToString(usernameValue);
            if (string.IsNullOrWhiteSpace(username))
            {
                return "?";
            }

            return username.Trim().Substring(0, 1).ToUpperInvariant();
        }

        protected string GetRoleBadgeCssClass(object roleValue)
        {
            string role = Convert.ToString(roleValue);
            if (string.Equals(role, "Lecturer", StringComparison.OrdinalIgnoreCase))
            {
                return "badge badge-lecturer";
            }

            return "badge badge-student";
        }

        protected string GetStatusCssClass(object statusValue)
        {
            string status = Convert.ToString(statusValue);

            if (string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase))
            {
                return "status-pill status-active";
            }

            if (string.Equals(status, "Suspended", StringComparison.OrdinalIgnoreCase))
            {
                return "status-pill status-suspended";
            }

            if (string.Equals(status, "Rejected", StringComparison.OrdinalIgnoreCase))
            {
                return "status-pill status-rejected";
            }

            return "status-pill status-pending";
        }

        protected string GetFormattedJoinedDate(object createdAtValue)
        {
            if (createdAtValue == null || createdAtValue == DBNull.Value)
            {
                return "Unknown";
            }

            DateTime createdAt;
            if (!DateTime.TryParse(Convert.ToString(createdAtValue, CultureInfo.InvariantCulture), CultureInfo.InvariantCulture, DateTimeStyles.None, out createdAt))
            {
                return "Unknown";
            }

            return createdAt.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
        }

        protected string GetToggleButtonCssClass(object statusValue)
        {
            return CanToggleStatus(statusValue)
                ? "action-btn btn-ban"
                : "action-btn btn-ban action-btn-disabled";
        }

        protected string GetToggleButtonOnClick(object statusValue)
        {
            return CanToggleStatus(statusValue)
                ? "return confirm('Update account status?');"
                : "return false;";
        }

        protected string GetToggleButtonText(object roleValue, object statusValue)
        {
            string role = Convert.ToString(roleValue);
            string status = Convert.ToString(statusValue);

            if (string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase))
            {
                return "Suspend";
            }

            if (string.Equals(status, "Suspended", StringComparison.OrdinalIgnoreCase))
            {
                return "Activate";
            }

            // pending/rejected lecturers should go through the verification page, not here
            if (string.Equals(role, "Lecturer", StringComparison.OrdinalIgnoreCase) &&
                (string.Equals(status, "Pending", StringComparison.OrdinalIgnoreCase) ||
                 string.Equals(status, "Rejected", StringComparison.OrdinalIgnoreCase)))
            {
                return "Verification Queue";
            }

            return "Status Locked";
        }

        // shows a green or red message at the top of the page depending on success or error
        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }

    }
}
