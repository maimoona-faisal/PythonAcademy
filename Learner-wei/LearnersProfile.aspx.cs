using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Policy;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Ajax.Utilities;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;

namespace WAPPAssignment
{
    public partial class LearnersProfile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load user from session
                if (Session["UserId"] != null)
                {
                    int userId = Convert.ToInt32(Session["UserId"]);
                    LoadUserData(userId);
                }
                LockTextBoxes();
            }
        }

        // Load user data from database (now includes ProfilePic)
        private void LoadUserData(int userId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT UserId, Username, Email, Password, Role, ProfilePic FROM Users WHERE UserId = @UserId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserId", userId);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    TextBox1.Text = reader["UserId"].ToString();
                    TextBox2.Text = reader["Username"].ToString();
                    TextBox4.Text = reader["Email"].ToString();
                    TextBox5.Text = reader["Password"].ToString();
                    TextBox6.Text = reader["Role"].ToString();

                    // Load profile picture
                    string profilePic = reader["ProfilePic"] as string;
                    string username = reader["Username"].ToString();

                    if (!string.IsNullOrWhiteSpace(profilePic))
                    {
                        // Show the image they manually uploaded
                        imgProfilePic.ImageUrl = ResolveUrl(profilePic);
                    }
                    else
                    {
                        // Auto-generate a unique pixel-art avatar based on their username!
                        imgProfilePic.ImageUrl = "https://api.dicebear.com/7.x/pixel-art/svg?seed=" + Server.UrlEncode(username);
                    }
                }
            }
        }

        // Event: Lookup user by ID manually
        protected void TextBox1_TextChanged(object sender, EventArgs e)
        {
            int userId;
            if (int.TryParse(TextBox1.Text, out userId))
            {
                LoadUserData(userId);
            }
        }

        // Edit button: unlock fields
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            TextBox2.ReadOnly = false; // Username
            TextBox4.ReadOnly = false; // Email
            TextBox5.Attributes.Remove("readonly"); // Password
            TextBox5.TextMode = System.Web.UI.WebControls.TextBoxMode.SingleLine;

            Button1.Enabled = false; // Disable Edit
            Button2.Enabled = true;  // Enable Confirm
        }

        // Confirm button: save changes + profile picture
        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            int userId;
            if (!int.TryParse(TextBox1.Text, out userId)) return;

            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            // Handle profile picture upload
            string profilePicPath = null;
            if (fuProfilePic.HasFile)
            {
                profilePicPath = SaveProfilePicture(userId);
                if (profilePicPath == null)
                {
                    // Validation failed — message already shown
                    return;
                }
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query;
                if (profilePicPath != null)
                {
                    query = "UPDATE Users SET Username=@Username, Email=@Email, Password=@Password, ProfilePic=@ProfilePic WHERE UserId=@UserId";
                }
                else
                {
                    query = "UPDATE Users SET Username=@Username, Email=@Email, Password=@Password WHERE UserId=@UserId";
                }

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Username", TextBox2.Text);
                cmd.Parameters.AddWithValue("@Email", TextBox4.Text);
                cmd.Parameters.AddWithValue("@Password", TextBox5.Text);
                cmd.Parameters.AddWithValue("@UserId", userId);

                if (profilePicPath != null)
                {
                    cmd.Parameters.AddWithValue("@ProfilePic", profilePicPath);
                }

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            LockTextBoxes();

            Button1.Enabled = true;
            Button2.Enabled = false;

            // Refresh the profile picture display
            LoadUserData(userId);

            ShowPicMessage("Profile updated successfully!", false);
        }
        private string SaveProfilePicture(int userId)
        {
            // Validate file type
            string fileName = fuProfilePic.FileName;
            string extension = Path.GetExtension(fileName).ToLowerInvariant();
            string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

            bool isAllowed = false;
            foreach (string ext in allowedExtensions)
            {
                if (ext == extension)
                {
                    isAllowed = true;
                    break;
                }
            }

            if (!isAllowed)
            {
                ShowPicMessage("Only JPG, PNG, and GIF files are allowed.", true);
                return null;
            }

            // Validate file size (2 MB max)
            if (fuProfilePic.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                ShowPicMessage("Image must be under 2 MB.", true);
                return null;
            }

            // Ensure the upload directory exists
            string uploadDir = Server.MapPath("~/Uploads/ProfilePics/");
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            // Generate a unique filename: UserID_timestamp.ext
            string uniqueName = userId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + extension;
            string physicalPath = Path.Combine(uploadDir, uniqueName);

            // Save the file
            fuProfilePic.SaveAs(physicalPath);

            // Return the app-relative path for DB storage
            return "~/Uploads/ProfilePics/" + uniqueName;
        }

        private void ShowPicMessage(string message, bool isError)
        {
            lblPicMessage.Text = message;
            lblPicMessage.CssClass = isError ? "upload-error" : "upload-success";
            lblPicMessage.Visible = true;
        }

        // Helper: lock textboxes
        private void LockTextBoxes()
        {
            TextBox2.ReadOnly = true;
            TextBox4.ReadOnly = true;
            TextBox5.Attributes["readonly"] = "readonly";
            TextBox5.TextMode = System.Web.UI.WebControls.TextBoxMode.Password;
            TextBox6.ReadOnly = true;
        }
        protected void btnProgressCheck_Click(object sender, EventArgs e)
        {
            // Redirect to TrackProgress.aspx safely
            Response.Redirect("~/Learner-wei/TrackProgress.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnFeedback_Click(object sender, EventArgs e)
        {
            // Redirect to Feedback.aspx safely
            Response.Redirect("~/Learner-wei/Feedback.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }


    }
}