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

        // Load user data from database
        private void LoadUserData(int userId)
        {
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["UserDBConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT UserId, Username, Email, Password, Role FROM Users WHERE UserId = @UserId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserId", userId);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    TextBox1.Text = reader["UserId"].ToString();
                    TextBox2.Text = reader["Username"].ToString();
                    TextBox4.Text = reader["Email"].ToString();
                    TextBox5.Text = reader["Password"].ToString(); // In real apps, use hashed password
                    TextBox6.Text = reader["Role"].ToString();
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

        // Confirm button: save changes
        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            int userId;
            if (!int.TryParse(TextBox1.Text, out userId)) return;

            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["UserDBConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "UPDATE Users SET Username=@Username, Email=@Email, Password=@Password WHERE UserId=@UserId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Username", TextBox2.Text);
                cmd.Parameters.AddWithValue("@Email", TextBox4.Text);
                cmd.Parameters.AddWithValue("@Password", TextBox5.Text);
                cmd.Parameters.AddWithValue("@UserId", userId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            LockTextBoxes();

            Button1.Enabled = true;
            Button2.Enabled = false;

            Response.Write("<script>alert('Profile updated successfully!');</script>");
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
            // Redirect to TrackProgress.aspx
            Response.Redirect("~/TrackProgress.aspx");
        }
        protected void btnFeedback_Click(object sender, EventArgs e)
        {
            // Redirect to Feedback.aspx
            Response.Redirect("~/Feedback.aspx");
        }


    }
}