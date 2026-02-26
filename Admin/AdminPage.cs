using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace PythonAcademy.Admin
{
    public class AdminPage : Page
    {
        protected string ConnStr
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["PythonAcademyDb"];
                if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
                {
                    throw new ConfigurationErrorsException("Missing connection string 'PythonAcademyDb' in Web.config.");
                }

                return settings.ConnectionString;
            }
        }

        protected int? AdminUserId
        {
            get
            {
                object userId = Session["UserId"] ?? Session["UserID"];
                if (userId == null)
                {
                    return null;
                }

                int parsed;
                return int.TryParse(Convert.ToString(userId), out parsed) ? (int?)parsed : null;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            string role = Convert.ToString(Session["Role"] ?? Session["UserRole"]);
            if (AdminUserId == null || !string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Session.Clear();
                string returnUrl = Server.UrlEncode(Request.RawUrl);
                Response.Redirect("~/LoginPage.aspx?returnUrl=" + returnUrl, true);
            }
        }

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
                return dt;
            }
        }

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
                return cmd.ExecuteNonQuery();
            }
        }

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
                return cmd.ExecuteScalar();
            }
        }

        protected void LogEvent(string action, string details)
        {
            if (string.IsNullOrWhiteSpace(action))
            {
                return;
            }

            try
            {
                object adminId = AdminUserId.HasValue ? (object)AdminUserId.Value : DBNull.Value;
                ExecuteNonQuery(
                    @"INSERT INTO ActivityLogs (UserID, Action, Details)
                      VALUES (@UserID, @Action, @Details)",
                    new SqlParameter("@UserID", adminId),
                    new SqlParameter("@Action", action.Trim()),
                    new SqlParameter("@Details", string.IsNullOrWhiteSpace(details) ? (object)DBNull.Value : details.Trim())
                );
            }
            catch
            {
                // Do not block admin operations if logging fails.
            }
        }
    }
}
