using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    // this is the base class that all admin pages inherit from
    // instead of copy-pasting the same db code everywhere, i put it all here
    public class AdminPage : Page
    {
        private const int MaxLogActionLength = 100;
        private const int MaxLogDetailsLength = 1000;

        // grabs the connection string from Web.config so i dont hardcode it
        protected string ConnStr
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["PythonAcademyDb"];
                if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
                {
                    // if the connection string is missing, throw an error right away
                    throw new ConfigurationErrorsException("Missing connection string 'PythonAcademyDb' in Web.config.");
                }

                return settings.ConnectionString;
            }
        }

        // gets the logged-in admin's user id from the session
        // returns null if no one is logged in
        protected int? AdminUserId
        {
            get
            {
                // checking both "UserId" and "UserID" just in case the session key differs
                object userId = Session["UserId"] ?? Session["UserID"];
                if (userId == null)
                {
                    return null;
                }

                int parsed;
                return int.TryParse(Convert.ToString(userId), out parsed) ? (int?)parsed : null;
            }
        }

        // this runs before every page loads — it's the access guard for all admin pages
        // if the user is not an admin, kick them back to the login page
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Only redirect if the user is NOT logged in OR is NOT an Admin
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Admin")
            {
                // redirect to login and remember where they were trying to go
                string returnUrl = Server.UrlEncode(Request.RawUrl);

                // Change 'true' to 'false' here
                Response.Redirect("~/LoginandRegister/LoginPage.aspx?returnUrl=" + returnUrl, false);

                // CompleteRequest() cleanly stops the rest of the page from running after redirect
                Context.ApplicationInstance.CompleteRequest();
            }
        }


        // runs a SELECT query and gives back the results as a DataTable
        // i use this all over the place to show data in grids and repeaters
        protected DataTable ExecuteTable(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                DataTable dt = new DataTable();
                da.Fill(dt); 
                cmd.Parameters.Clear();

                return dt;
            }
        }

        // runs INSERT, UPDATE, or DELETE queries
        // returns how many rows were affected so i can check if it worked
        protected int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                con.Open();
                int result = cmd.ExecuteNonQuery();
                cmd.Parameters.Clear();

                return result;
            }
        }

        // runs a query that returns a single value, like COUNT(*) or MAX(id)
        protected object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                con.Open();
                object result = cmd.ExecuteScalar();
                cmd.Parameters.Clear();

                return result;
            }
        }

        // wraps ExecuteScalar and safely converts the result to int
        // returns fallbackValue (default 0) when the result is NULL or DBNull
        protected int ExecuteScalarInt(string sql, params SqlParameter[] parameters)
        {
            object value = ExecuteScalar(sql, parameters);
            return ToInt(value);
        }

        // checks if a table exists before we query it directly
        // uses INFORMATION_SCHEMA which is a built-in SQL Server view of all tables/columns
        protected bool TableExists(string tableName)
        {
            if (string.IsNullOrWhiteSpace(tableName))
            {
                return false;
            }

            return ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = @TableName",
                new SqlParameter("@TableName", tableName.Trim())) > 0;
        }

        // same idea as TableExists but checks for a specific column inside a table
        protected bool ColumnExists(string tableName, string columnName)
        {
            if (string.IsNullOrWhiteSpace(tableName) || string.IsNullOrWhiteSpace(columnName))
            {
                return false;
            }

            return ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM INFORMATION_SCHEMA.COLUMNS
                  WHERE TABLE_NAME = @TableName AND COLUMN_NAME = @ColumnName",
                new SqlParameter("@TableName", tableName.Trim()),
                new SqlParameter("@ColumnName", columnName.Trim())) > 0;
        }

        // standardises the success/error banner styling used across admin pages
        protected void SetStatusMessage(Label label, string message, bool isError)
        {
            if (label == null)
            {
                return;
            }

            label.Text = message ?? string.Empty;
            // red-ish for errors, green-ish for success
            label.ForeColor = isError
                ? Color.FromArgb(255, 185, 185)
                : Color.FromArgb(130, 255, 190);
            label.Visible = !string.IsNullOrWhiteSpace(message);
        }

        protected void ClearStatusMessage(Label label)
        {
            SetStatusMessage(label, string.Empty, false);
        }

        // safely converts a DB value to int — handles NULL and DBNull without crashing
        protected int ToInt(object value, int fallbackValue = 0)
        {
            if (value == null || value == DBNull.Value)
            {
                return fallbackValue;
            }

            int parsed;
            return int.TryParse(Convert.ToString(value), out parsed) ? parsed : fallbackValue;
        }

        // extracts the category prefix from an action string, e.g. "Logs" from "Logs.View"
        protected string GetActionCategory(string action)
        {
            string safeAction = (action ?? string.Empty).Trim();
            if (safeAction.Length == 0)
            {
                return "General";
            }

            int separatorIndex = safeAction.IndexOf('.');
            if (separatorIndex <= 0)
            {
                separatorIndex = safeAction.IndexOf(':');
            }

            return separatorIndex > 0 ? safeAction.Substring(0, separatorIndex) : safeAction;
        }

        // writes what the admin did into the ActivityLogs table
        // wrapped in try-catch so a logging failure never breaks the main action
        protected void LogEvent(string action, string details)
        {
            string safeAction = (action ?? string.Empty).Trim();
            if (safeAction.Length == 0)
            {
                return;
            }

            try
            {
                if (!TableExists("ActivityLogs"))
                {
                    return;
                }

                if (safeAction.Length > MaxLogActionLength)
                {
                    safeAction = safeAction.Substring(0, MaxLogActionLength);
                }

                // if no admin is logged in, store NULL instead of crashing
                object adminId = AdminUserId.HasValue ? (object)AdminUserId.Value : DBNull.Value;
                ExecuteNonQuery(
                    @"INSERT INTO ActivityLogs (UserID, Action, Details)
                      VALUES (@UserID, @Action, @Details)",
                    new SqlParameter("@UserID", adminId),
                    new SqlParameter("@Action", safeAction),
                    new SqlParameter("@Details", (object)SanitizeLogDetails(details) ?? DBNull.Value)
                );
            }
            catch
            {
                // Do not block admin operations if logging fails.
            }
        }

        // strips sensitive info (passwords, tokens, etc.) from log details before saving
        // uses regex to find patterns like "password=abc123" and replaces the value with [redacted]
        private string SanitizeLogDetails(string details)
        {
            if (string.IsNullOrWhiteSpace(details))
            {
                return null;
            }

            string sanitized = details.Trim();

            sanitized = Regex.Replace(
                sanitized,
                @"(?i)\b(password|pwd|passcode|token|secret|api[-_ ]?key|authorization)\b\s*[:=]\s*[^,;\r\n]+",
                "$1=[redacted]");

            if (sanitized.Length > MaxLogDetailsLength)
            {
                sanitized = sanitized.Substring(0, MaxLogDetailsLength);
            }

            return sanitized;
        }
    }
}
