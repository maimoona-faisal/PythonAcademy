<%@ Page Title="Edit Profile" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <style>
      /* --- NEON DARK THEME --- */
      :root {
          --accent-cyan: #00d8ff;
          --accent-red: #ff7b7b;
          --accent-lime: #14f195;
          --accent-gold: #ffc857;
          --panel-bg: rgba(13, 25, 48, 0.85);
          --panel-border: rgba(255, 255, 255, 0.1);
          --muted-text: #8fa4c4;
      }

      .admin-shell {
          max-width: 700px; /* Kept narrow for a clean profile form */
          margin: 0 auto;
          padding: 40px 20px;
      }

      .page-title { font-size: 2.2rem; font-weight: bold; color: white; margin: 0; }
      .page-subtitle { color: var(--muted-text); margin-top: 5px; margin-bottom: 30px; }

      /* Glassmorphism Card */
      .glass-panel { 
          background: var(--panel-bg); 
          backdrop-filter: blur(12px); 
          border: 1px solid var(--panel-border); 
          border-radius: 20px; 
          padding: 40px; 
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); 
      }

      /* Form Elements */
      .form-label { display: block; margin-bottom: 8px; color: var(--muted-text); font-size: 0.85rem; font-weight: bold; text-transform: uppercase; letter-spacing: 0.05em; }
      
      .neon-input { 
          width: 100%; padding: 14px; border-radius: 12px; 
          border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0, 0, 0, 0.2); 
          color: white; font-size: 1rem; outline: none; transition: 0.3s; 
          margin-bottom: 25px; box-sizing: border-box;
      }
      .neon-input:focus { border-color: var(--accent-cyan); box-shadow: 0 0 10px rgba(0, 216, 255, 0.15); }

      /* Specifics for Password Section */
      .password-section {
          background: rgba(255, 200, 87, 0.05);
          border: 1px dashed rgba(255, 200, 87, 0.3);
          border-radius: 12px;
          padding: 20px;
          margin-top: 30px;
          margin-bottom: 30px;
      }

      /* Buttons */
      .btn-actions { display: flex; gap: 15px; margin-top: 10px; }
      
      .btn-cyan { 
          background: linear-gradient(90deg, var(--accent-cyan), #0a67ff); 
          color: #ffffff; border: none; padding: 14px 28px; font-size: 1rem; font-weight: 800; 
          border-radius: 50px; cursor: pointer; transition: 0.3s; text-align: center;
          box-shadow: 0 6px 15px rgba(0, 216, 255, 0.25); flex: 1;
      }
      .btn-cyan:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 216, 255, 0.4); }
      
      .btn-outline-clear { 
          background: transparent; color: white; border: 1px solid rgba(255,255,255,0.2); 
          padding: 14px 28px; font-size: 1rem; font-weight: 600; border-radius: 50px; 
          cursor: pointer; transition: 0.3s; text-decoration: none; text-align: center;
      }
      .btn-outline-clear:hover { background: rgba(255,255,255,0.1); border-color: white; }

      /* Custom message styling */
      .msg-banner { display: block; margin-top: 20px; font-weight: 600; font-size: 0.95rem; text-align: center;}
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Instructor Profile</h2>
      <p class="page-subtitle">Manage your account details and security settings.</p>

      <div class="glass-panel">
          
          <label class="form-label">Username</label>
          <asp:TextBox ID="txtUsername" runat="server" CssClass="neon-input" />

          <label class="form-label">Email Address</label>
          <asp:TextBox ID="txtEmail" runat="server" CssClass="neon-input" />

          <div class="password-section">
              <p style="color: var(--accent-gold); font-size: 0.9rem; font-weight: bold; margin-top: 0; margin-bottom: 15px;">
                  ⚠️ Change Password
              </p>
              <p style="color: var(--muted-text); font-size: 0.85rem; margin-bottom: 15px;">
                  Leave this field blank if you want to keep your current password.
              </p>

              <label class="form-label" style="color: #fff;">New Password</label>
              <asp:TextBox ID="txtPassword" runat="server" CssClass="neon-input" TextMode="Password" style="margin-bottom: 0;" placeholder="Enter new password..." />
          </div>

          <div class="btn-actions">
              <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn-cyan" OnClick="SaveProfile" />
              <a href="Assessment.aspx" class="btn-outline-clear">Cancel</a>
          </div>

          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />

      </div>
  </div>

</asp:Content>

<script runat="server">

  private string Cs => ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

  private int UserId
  {
    get
    {
      if (Session["UserId"] == null)
      {
        Response.Redirect("Login.aspx");
        return 0;
      }
      return Convert.ToInt32(Session["UserId"]);
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      LoadUserData();
    }
  }

  private void LoadUserData()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT Username, Email
      FROM dbo.Users
      WHERE UserID = @UserId
    ", con))
    {
      cmd.Parameters.AddWithValue("@UserId", UserId);

      con.Open();
      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        if (reader.Read())
        {
          txtUsername.Text = reader["Username"].ToString();
          txtEmail.Text = reader["Email"].ToString();
        }
      }
    }
  }

  protected void SaveProfile(object sender, EventArgs e)
  {
    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string username = (txtUsername.Text ?? "").Trim();
    string email = (txtEmail.Text ?? "").Trim();
    string newPassword = (txtPassword.Text ?? "").Trim();

    if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(email))
    {
      lblMsg.Text = "Username and Email are required.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      {
        con.Open();

        // 1 Update Username & Email
        using (SqlCommand cmd = new SqlCommand(@"
          UPDATE dbo.Users
          SET Username = @Username,
              Email = @Email
          WHERE UserID = @UserId
        ", con))
        {
          cmd.Parameters.AddWithValue("@Username", username);
          cmd.Parameters.AddWithValue("@Email", email);
          cmd.Parameters.AddWithValue("@UserId", UserId);
          cmd.ExecuteNonQuery();
        }

        // 2 Update password ONLY if entered
        if (!string.IsNullOrWhiteSpace(newPassword))
        {
          // hash the password using the same method from the login page
          string hashedPassword = HashPasswordSha256Base64(newPassword);

          using (SqlCommand cmdPass = new SqlCommand(@"
            UPDATE dbo.Users
            SET PasswordHash = @PasswordHash, 
                Password = @Password 
            WHERE UserID = @UserId
          ", con))
          {
            cmdPass.Parameters.AddWithValue("@PasswordHash", hashedPassword);

            // Note: Storing plain text passwords is a security risk. 
            // Consider removing the Password column entirely in the future!
            cmdPass.Parameters.AddWithValue("@Password", newPassword);
            cmdPass.Parameters.AddWithValue("@UserId", UserId);

            cmdPass.ExecuteNonQuery();
          }
        }

      } // end using SqlConnection

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Profile updated successfully.";
      txtPassword.Text = "";
    }
    catch (SqlException ex)
    {
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

      if (ex.Message.Contains("UNIQUE"))
        lblMsg.Text = "Username or Email already exists.";
      else
        lblMsg.Text = "Update failed: " + ex.Message;
    }
  }

  // this method is outside SaveProfile - C# does not allow methods inside other methods
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
