using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    public partial class ManageUsers : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindUsersToTable(string.Empty, "All");
            LogEvent("Users.View", "Opened manage users page.");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string keyword = (txtSearch.Text ?? string.Empty).Trim();
            string role = ddlRoleFilter.SelectedValue;

            if (keyword.Length > 100)
            {
                ShowMessage("Search text is too long. Keep it under 100 characters.", true);
                return;
            }

            BindUsersToTable(keyword, role);
            LogEvent("Users.Search", "Filtered users by keyword and role.");
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int userId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out userId) || userId <= 0)
            {
                ShowMessage("Invalid user selection.", true);
                return;
            }

            try
            {
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

                if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    ShowMessage("Admin accounts cannot be modified here.", true);
                    return;
                }

                if (AdminUserId.HasValue && userId == AdminUserId.Value)
                {
                    ShowMessage("You cannot modify your own account here.", true);
                    return;
                }

                if (e.CommandName == "ToggleStatus")
                {
                    string newStatus = string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase) ? "Suspended" : "Active";
                    ExecuteNonQuery(
                        @"UPDATE Users
                          SET Status = @Status
                          WHERE UserID = @UserID",
                        new SqlParameter("@Status", newStatus),
                        new SqlParameter("@UserID", userId));

                    LogEvent("Users.StatusUpdate", "Updated status for user '" + username + "' to '" + newStatus + "'.");
                    ShowMessage("User status updated to " + newStatus + ".", false);
                }
                else if (e.CommandName == "DeleteUser")
                {
                    DeleteUser(userId, username);
                }

                BindUsersToTable((txtSearch.Text ?? string.Empty).Trim(), ddlRoleFilter.SelectedValue);
            }
            catch
            {
                ShowMessage("Unable to update user right now.", true);
            }
        }

        private void DeleteUser(int userId, string username)
        {
            try
            {
                int affected = ExecuteNonQuery(
                    "DELETE FROM Users WHERE UserID = @UserID",
                    new SqlParameter("@UserID", userId));

                if (affected == 0)
                {
                    ShowMessage("User was already removed.", true);
                    return;
                }

                LogEvent("Users.Delete", "Deleted user '" + username + "' (UserID=" + userId + ").");
                ShowMessage("User deleted successfully.", false);
            }
            catch (SqlException ex)
            {
                // Foreign key constraints can block hard deletes. Suspend account as fallback.
                if (ex.Number == 547)
                {
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

                throw;
            }
        }

        private void BindUsersToTable(string searchQuery, string roleFilter)
        {
            StringBuilder sql = new StringBuilder();
            sql.AppendLine("SELECT UserID, Username, Email, Role, Status, CreatedAt");
            sql.AppendLine("FROM Users");
            sql.AppendLine("WHERE 1 = 1");

            List<SqlParameter> parameters = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(searchQuery))
            {
                sql.AppendLine("AND (Username LIKE @Search OR Email LIKE @Search)");
                parameters.Add(new SqlParameter("@Search", "%" + searchQuery + "%"));
            }

            if (!string.IsNullOrWhiteSpace(roleFilter) && !roleFilter.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                sql.AppendLine("AND Role = @Role");
                parameters.Add(new SqlParameter("@Role", roleFilter));
            }

            sql.AppendLine("ORDER BY CreatedAt DESC");

            DataTable users = ExecuteTable(sql.ToString(), parameters.ToArray());
            rptUsers.DataSource = users;
            rptUsers.DataBind();
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }

    }
}
