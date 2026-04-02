using System;
using System.Configuration;
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
            if (!IsPostBack)
            {
                // check the PlatformSettings table - if registrations are turned off, block the form
                if (!IsRegistrationAllowed())
                {
                    btnRegister.Enabled = false;
                    ShowMessage("Registrations are currently closed. Please check back later.", true);
                }
            }
        }

        // reads the AllowRegistrations setting from the database
        // returns true by default if the row doesnt exist yet
        private bool IsRegistrationAllowed()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT SettingValue FROM PlatformSettings WHERE SettingKey = 'AllowRegistrations'", con))
                {
                    con.Open();
                    object val = cmd.ExecuteScalar();
                    // if the row doesnt exist yet, default to allowed
                    return val == null || val.ToString() == "1";
                }
            }
            catch
            {
                // if the table doesnt exist yet, dont crash - just allow registration
                return true;
            }
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

                // Handle CV and LinkedIn logic
                string linkedInUrl = (txtLinkedIn.Text ?? "").Trim();
                string cvFilePath = null;

                if (role == "Lecturer")
                {
                    if (!fuCV.HasFile && string.IsNullOrWhiteSpace(linkedInUrl))
                    {
                        ShowMessage("Instructors must provide either a CV or a LinkedIn URL.", true);
                        return;
                    }

                    if (fuCV.HasFile)
                    {
                        // --- NEW: Dynamic Upload Limit Check for CVs ---
                        int maxUploadSizeMB = 50;
                        try
                        {
                            using (SqlConnection limitCon = new SqlConnection(ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString))
                            using (SqlCommand limitCmd = new SqlCommand("SELECT SettingValue FROM PlatformSettings WHERE SettingKey = 'MaxUploadSizeMB'", limitCon))
                            {
                                limitCon.Open();
                                object limitResult = limitCmd.ExecuteScalar();
                                if (limitResult != null && int.TryParse(limitResult.ToString(), out int parsedSize))
                                {
                                    maxUploadSizeMB = parsedSize;
                                }
                            }
                        }
                        catch { /* Ignore DB errors and use the 50MB fallback */ }

                        long maxBytes = maxUploadSizeMB * 1024L * 1024L;
                        if (fuCV.PostedFile.ContentLength > maxBytes)
                        {
                            ShowMessage("Your CV file exceeds the platform limit of " + maxUploadSizeMB + "MB.", true);
                            return; // Stop the registration
                        }
                        // -----------------------------------------------

                        string ext = System.IO.Path.GetExtension(fuCV.FileName).ToLower();
                        // ... rest of your existing CV saving logic ...

                        string uniqueName = Guid.NewGuid().ToString("N") + ext;
                        string physicalPath = CvFileStorage.GetPhysicalPath(Server, uniqueName);
                        fuCV.SaveAs(physicalPath);
                        cvFilePath = CvFileStorage.BuildPublicPath(uniqueName);
                    }
                }

                string passwordHash = HashPasswordSha256Base64(password);
                string initialStatus = (role == "Lecturer") ? "Pending" : "Active";

                // Insert statement includes CV and LinkedIn
                Db.NonQuery(@"
                    INSERT INTO Users (Username, FullName, Email, Password, PasswordHash, Role, Status, CreatedAt, CVFilePath, LinkedInUrl)
                    VALUES (@Username, @FullName, @Email, @Password, @PasswordHash, @Role, @Status, GETDATE(), @CV, @LinkedIn)",
                    new SqlParameter("@Username", username),
                    new SqlParameter("@FullName", name), 
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Password", password),
                    new SqlParameter("@PasswordHash", passwordHash),
                    new SqlParameter("@Role", role),
                    new SqlParameter("@Status", initialStatus),
                    new SqlParameter("@CV", (object)cvFilePath ?? DBNull.Value),
                    new SqlParameter("@LinkedIn", (object)linkedInUrl ?? DBNull.Value));

                if (initialStatus == "Pending")
                {
                    ShowMessage("Application submitted! An administrator will review your Instructor account shortly.", false);
                }
                else
                {
                    ShowMessage("Account created successfully! You can now log in.", false);
                }

                txtUsername.Text = ""; txtName.Text = ""; txtEmail.Text = ""; txtLinkedIn.Text = "";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, true);
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
