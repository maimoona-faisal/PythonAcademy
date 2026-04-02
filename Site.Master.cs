using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (Request.AppRelativeCurrentExecutionFilePath.ToLower().Contains("maintenance.aspx") ||
                Request.AppRelativeCurrentExecutionFilePath.ToLower().Contains("loginpage.aspx") ||
                Request.AppRelativeCurrentExecutionFilePath.ToLower().Contains("Default.aspx"))
                return;

            string role = Convert.ToString(Session["Role"] ?? "");
            bool isLoggedIn = Session["UserId"] != null;
            bool isAdmin = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);

            if (isLoggedIn && !isAdmin)
            {
                if (IsMaintenanceMode())
                {
                    // 1. Change 'true' to 'false'
                    Response.Redirect("~/Admin/maintenance.aspx", false);

                    // 2. Gracefully tell the server to stop loading this page
                    Context.ApplicationInstance.CompleteRequest();

                    // 3. Exit the method so it doesn't try to load unread badges below!
                    return;
                }
            }

            if (isLoggedIn)
            {
                UpdateUnreadMessageBadge();
            }
        }

        private bool IsMaintenanceMode()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT SettingValue FROM PlatformSettings WHERE SettingKey = 'MaintenanceMode'", con))
                {
                    con.Open();
                    object val = cmd.ExecuteScalar();
                    return val != null && val.ToString() == "1";
                }
            }
            catch
            {
                return false;
            }
        }

        protected void Logout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();

            Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);

            Context.ApplicationInstance.CompleteRequest();
        }

        private void UpdateUnreadMessageBadge()
        {
            try
            {
                int currentUserId = Convert.ToInt32(Session["UserId"]);
                string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = "SELECT COUNT(*) FROM Messages WHERE ReceiverID = @MyID AND IsRead = 0";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@MyID", currentUserId);
                        con.Open();

                        int unreadCount = (int)cmd.ExecuteScalar();

                        if (unreadCount > 0)
                        {
                            lblUnreadBadge.Text = unreadCount.ToString();
                            lblUnreadBadge.Visible = true;
                        }
                        else
                        {
                            lblUnreadBadge.Visible = false;
                        }
                    }
                }
            }
            catch
            {
                lblUnreadBadge.Visible = false;
            }
        }
    }
}
