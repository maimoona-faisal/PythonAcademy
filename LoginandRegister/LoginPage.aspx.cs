using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using PythonAcademy.Helpers;

namespace PythonAcademy
{
    public partial class LoginPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // if already logged in, skip the login page and go straight to their dashboard
            if (Session["UserId"] != null && Session["Role"] != null)
            {
                string role = Session["Role"].ToString();
                if (role == "Admin")
                    Response.Redirect("~/Admin/AdminDashboard.aspx", false);
                else if (role == "Lecturer")
                    Response.Redirect("~/Lecture/l_dashboard.aspx", false);
                else
                    Response.Redirect("~/Learner-jo/MemberDashboard.aspx", false);

                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // 1) Read inputs
            string email = (txtEmail.Text ?? "").Trim();
            string password = (txtPassword.Text ?? "").Trim();

            // 2) Basic validation
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                lblMsg.Text = "Please enter email and password.";
                return;
            }

            // 3) Hash password (must match SeedAdmin hashing)
            string passwordHash = HashPasswordSha256Base64(password);

            // 4) Check user in DB
            DataTable dt = Db.Table(@"
SELECT UserID, Username, Role, Status
FROM Users
WHERE Email = @e AND PasswordHash = @p",
                new SqlParameter("@e", email),
                new SqlParameter("@p", passwordHash)
            );

            if (dt.Rows.Count == 0)
            {
                lblMsg.Text = "Invalid email or password.";
                return;
            }

            // 5) Status check
            string status = dt.Rows[0]["Status"].ToString();
            if (!status.Equals("Active", StringComparison.OrdinalIgnoreCase))
            {
                lblMsg.Text = "Your account is not active. Status: " + status;
                return;
            }

            // 6) Save session
            int userId = Convert.ToInt32(dt.Rows[0]["UserID"]);
            string username = dt.Rows[0]["Username"].ToString();
            string role = dt.Rows[0]["Role"].ToString();

            Session["UserId"] = userId;
            Session["Username"] = username;
            Session["Role"] = role;

            // --- NEW: MAINTENANCE MODE CHECK ---
            // If the user is not an Admin, check if the site is locked down
            if (role != "Admin")
            {
                // Note: Assuming you are using your Db helper class here!
                object maintenanceSetting = Db.Scalar("SELECT SettingValue FROM PlatformSettings WHERE SettingKey = 'MaintenanceMode'");

                if (maintenanceSetting != null && maintenanceSetting.ToString() == "1")
                {
                    // Site is in maintenance! Boot them to the maintenance page.
                    Response.Redirect("~/Admin/maintenance.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }
            // ------------------------------------

            // 7) Redirect by role
            if (role == "Admin") // Assuming you have an Admin check here
            {
                Response.Redirect("~/Admin/AdminDashboard.aspx", false);
            }
            else if (role.Equals("Lecturer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Lecture/l_dashboard.aspx", false);
            }
            else
            {
                Response.Redirect("~/Learner-jo/MemberDashboard.aspx", false);
            }

            Context.ApplicationInstance.CompleteRequest();
        }

        private string HashPasswordSha256Base64(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hash = sha.ComputeHash(bytes);
                return Convert.ToBase64String(hash);
            }
        }
    }
}
