<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <style>
      :root {
          --accent-cyan: #00d8ff;
          --panel-bg: rgba(13, 25, 48, 0.85);
          --panel-border: rgba(255, 255, 255, 0.1);
          --muted-text: #8fa4c4;
      }

      .auth-shell { max-width: 500px; margin: 60px auto; padding: 20px; }
      .page-title { font-size: 2.2rem; font-weight: bold; color: white; margin: 0; text-align: center; }
      .page-subtitle { color: var(--muted-text); margin-top: 5px; margin-bottom: 30px; text-align: center; }

      .glass-panel { 
          background: var(--panel-bg); backdrop-filter: blur(12px); 
          border: 1px solid var(--panel-border); border-radius: 20px; 
          padding: 40px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); 
      }

      .form-label { display: block; margin-bottom: 8px; color: var(--muted-text); font-size: 0.85rem; font-weight: bold; text-transform: uppercase; letter-spacing: 0.05em; }
      
      .neon-input { 
          width: 100%; padding: 14px; border-radius: 12px; 
          border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0, 0, 0, 0.2); 
          color: white; font-size: 1rem; outline: none; transition: 0.3s; 
          margin-bottom: 25px; box-sizing: border-box;
      }
      .neon-input:focus { border-color: var(--accent-cyan); box-shadow: 0 0 10px rgba(0, 216, 255, 0.15); }

      .btn-cyan { 
          background: linear-gradient(90deg, var(--accent-cyan), #0a67ff); 
          color: #ffffff; border: none; padding: 14px 28px; font-size: 1rem; font-weight: 800; 
          border-radius: 50px; cursor: pointer; transition: 0.3s; width: 100%;
          box-shadow: 0 6px 15px rgba(0, 216, 255, 0.25); 
      }
      .btn-cyan:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 216, 255, 0.4); }

      .msg-banner { display: block; margin-top: 20px; font-weight: 600; font-size: 0.95rem; text-align: center;}
  </style>

  <div class="auth-shell">
      <h2 class="page-title">Reset Password</h2>
      <p class="page-subtitle">Enter your exact username and email to verify your identity.</p>

      <div class="glass-panel">
          
          <label class="form-label">Username</label>
          <asp:TextBox ID="txtUsername" runat="server" CssClass="neon-input" Placeholder="Enter your username..." />

          <label class="form-label">Registered Email</label>
          <asp:TextBox ID="txtEmail" runat="server" CssClass="neon-input" Placeholder="Enter your email address..." />

          <label class="form-label">New Password</label>
          <asp:TextBox ID="txtNewPassword" runat="server" CssClass="neon-input" TextMode="Password" Placeholder="Enter a new password..." />

          <asp:Button ID="btnReset" runat="server" Text="Reset Password" CssClass="btn-cyan" OnClick="ResetPassword_Click" />

          <div style="text-align: center; margin-top: 20px;">
              <a href="LoginPage.aspx" style="color: var(--accent-cyan); text-decoration: none; font-size: 0.9rem;">Back to Login</a>
          </div>

          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />

      </div>
  </div>

</asp:Content>

<script runat="server">
    protected void ResetPassword_Click(object sender, EventArgs e)
    {
        string username = txtUsername.Text.Trim();
        string email = txtEmail.Text.Trim();
        string newPassword = txtNewPassword.Text.Trim();

        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(newPassword))
        {
            lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
            lblMsg.Text = "Please fill in all fields.";
            return;
        }

        string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            // 1. Verify the user exists with this exact Username AND Email combination
            string checkQuery = "SELECT UserID FROM Users WHERE Username = @Username AND Email = @Email";
            SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
            checkCmd.Parameters.AddWithValue("@Username", username);
            checkCmd.Parameters.AddWithValue("@Email", email);

            conn.Open();
            object userIdObj = checkCmd.ExecuteScalar();

            if (userIdObj != null)
            {
                // Identity verified! Proceed to update password
                int userId = Convert.ToInt32(userIdObj);
                string hashedPassword = HashPasswordSha256Base64(newPassword);

                string updateQuery = "UPDATE Users SET Password = @Password, PasswordHash = @PasswordHash WHERE UserID = @UserID";
                SqlCommand updateCmd = new SqlCommand(updateQuery, conn);
                updateCmd.Parameters.AddWithValue("@Password", newPassword); // Still saving plain text to match your DB schema
                updateCmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
                updateCmd.Parameters.AddWithValue("@UserID", userId);

                updateCmd.ExecuteNonQuery();

                lblMsg.ForeColor = System.Drawing.Color.LightGreen;
                lblMsg.Text = "Password reset successfully! You can now log in.";
                
                // Clear fields
                txtUsername.Text = "";
                txtEmail.Text = "";
            }
            else
            {
                // Do not reveal if the username or email is wrong, just say they don't match for security
                lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
                lblMsg.Text = "We could not find an account matching that Username and Email combination.";
            }
        }
    }

    // Identical hashing method used across your application
    private string HashPasswordSha256Base64(string password)
    {
        using (var sha = System.Security.Cryptography.SHA256.Create())
        {
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(password);
            byte[] hash = sha.ComputeHash(bytes);
            return Convert.ToBase64String(hash);
        }
    }
</script>