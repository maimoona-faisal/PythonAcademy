using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using PythonAcademy.Helpers;

namespace PythonAcademy
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string username = (txtUsername.Text ?? "").Trim();
            string name = (txtName.Text ?? "").Trim();
            string email = (txtEmail.Text ?? "").Trim();
            string role = ddlRole.SelectedValue;
            string password = (txtPassword.Text ?? "").Trim();
            string verifyPass = (txtVerifyPassword.Text ?? "").Trim();

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                ShowMessage("Please fill out all required fields.", true);
                return;
            }

            if (password != verifyPass)
            {
                ShowMessage("Passwords do not match. Please retype them.", true);
                return;
            }

            try
            {
                int existingUsers = Convert.ToInt32(Db.Scalar(
                    "SELECT COUNT(*) FROM Users WHERE Email = @Email OR Username = @Username",
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Username", username)));

                if (existingUsers > 0)
                {
                    ShowMessage("An account with this Email or Username already exists.", true);
                    return;
                }

                string passwordHash = HashPasswordSha256Base64(password);

                string initialStatus = (role == "Lecturer") ? "Pending" : "Active";

                Db.NonQuery(@"
                    INSERT INTO Users (Username, Email, PasswordHash, Role, Status, CreatedAt)
                    VALUES (@Username, @Email, @PasswordHash, @Role, @Status, GETDATE())",
                    new SqlParameter("@Username", username),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@PasswordHash", passwordHash),
                    new SqlParameter("@Role", role),
                    new SqlParameter("@Status", initialStatus));

                if (initialStatus == "Pending")
                {
                    ShowMessage("Application submitted! An administrator will review your Instructor account shortly.", false);
                }
                else
                {
                    ShowMessage("Account created successfully! You can now log in.", false);
                }

                txtUsername.Text = ""; txtName.Text = ""; txtEmail.Text = "";
            }
            catch
            {
                ShowMessage("A system error occurred. Please try again later.", true);
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

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;

            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 77, 77) : System.Drawing.Color.FromArgb(0, 255, 136);
            lblMessage.BackColor = isError ? System.Drawing.Color.FromArgb(40, 10, 10) : System.Drawing.Color.FromArgb(10, 40, 20);
            lblMessage.Visible = true;
        }
    }
}