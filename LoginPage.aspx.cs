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

            // 7) Redirect by role
            if (role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Admin/AdminDashboard.aspx");
            }
            else if (role.Equals("Lecturer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Instructor/InstructorDashboard.aspx"); // adjust when ready
            }
            else
            {
                Response.Redirect("~/Learners/LearnerDashboard.aspx"); // adjust when ready
            }
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