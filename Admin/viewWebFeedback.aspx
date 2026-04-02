<%@ Page Title="Platform Feedback" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <style>
      /* --- NEON DARK THEME --- */
      :root {
          --accent-cyan: #00d8ff;
          --accent-red: #ff7b7b;
          --accent-gold: #ffc857;
          --panel-bg: rgba(13, 25, 48, 0.85);
          --panel-border: rgba(255, 255, 255, 0.1);
          --muted-text: #8fa4c4;
      }

      .admin-shell { max-width: 1200px; margin: 0 auto; padding: 20px; }
      .page-title { font-size: 2.2rem; font-weight: bold; color: white; margin: 0; }
      .page-subtitle { color: var(--muted-text); margin-top: 5px; margin-bottom: 30px; }

      .glass-panel { 
          background: var(--panel-bg); backdrop-filter: blur(12px); 
          border: 1px solid var(--panel-border); border-radius: 20px; 
          padding: 30px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); 
      }

      /* Dropdown Filter Styles */
      .filter-bar {
          display: flex; align-items: center; gap: 15px; margin-bottom: 25px;
          background: rgba(0,0,0,0.2); padding: 15px 20px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.05);
      }
      .filter-label { color: var(--muted-text); font-weight: bold; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em; }
      .neon-input { 
          padding: 10px 15px; border-radius: 8px; border: 1px solid rgba(255, 255, 255, 0.1); 
          background: #0b1220; color: white; font-size: 0.95rem; outline: none; transition: 0.3s; cursor: pointer; min-width: 250px;
      }
      .neon-input:focus { border-color: var(--accent-cyan); box-shadow: 0 0 10px rgba(0, 216, 255, 0.15); }

      .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
      .tech-table th { padding: 0 16px 12px; text-align: left; color: var(--muted-text); font-size: 0.82rem; letter-spacing: 0.08em; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); }
      .tech-table td { padding: 16px; color: #ffffff; background: rgba(255,255,255,0.03); border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: top;}
      .tech-table td:first-child { border-radius: 12px 0 0 12px; }
      .tech-table td:last-child { border-radius: 0 12px 12px 0; }
      .tech-table tr:hover td { background: rgba(255, 255, 255, 0.06); }

      .feedback-box {
          background: rgba(0,0,0,0.3); padding: 12px 16px; border-radius: 8px; 
          border-left: 3px solid var(--accent-cyan); color: #e7eefc; 
          font-size: 0.95rem; font-style: italic; line-height: 1.5;
      }
      
      .badge-general { background: rgba(0, 216, 255, 0.1); color: var(--accent-cyan); padding: 4px 10px; border-radius: 8px; font-size: 0.8rem; font-weight: bold; border: 1px solid rgba(0, 216, 255, 0.3); }
      .badge-course { background: rgba(255, 200, 87, 0.1); color: var(--accent-gold); padding: 4px 10px; border-radius: 8px; font-size: 0.8rem; font-weight: bold; border: 1px solid rgba(255, 200, 87, 0.3); }

      .student-info { display: flex; flex-direction: column; gap: 4px; }
      .student-name { font-weight: bold; color: white; }
      .student-email { font-size: 0.8rem; color: var(--muted-text); }

      .btn-del { 
          padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-decoration: none;
          border: 1px solid rgba(255, 123, 123, 0.5); color: var(--accent-red); background: transparent; cursor: pointer; transition: 0.2s;
      }
      .btn-del:hover { background: rgba(255, 123, 123, 0.1); }
      .msg-banner { display: block; margin-bottom: 15px; font-weight: 600; font-size: 0.95rem; text-align: center;}
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Platform Feedback Logs</h2>
      <p class="page-subtitle">Review all general application feedback and course-specific feedback submitted by users.</p>

      <div class="glass-panel">
          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />

          <div class="filter-bar">
              <span class="filter-label">&#128269; Filter By Source:</span>
              <asp:DropDownList ID="ddlFilter" runat="server" CssClass="neon-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                  <asp:ListItem Text="Show All Feedback" Value="All" />
                  <asp:ListItem Text="Global Platform (Application Only)" Value="Global" />
                  <asp:ListItem Text="Course Modules Only" Value="Course" />
              </asp:DropDownList>
          </div>

          <div style="overflow-x: auto;">
              <asp:GridView ID="gvAdminFeedback" runat="server" CssClass="tech-table"
                  AutoGenerateColumns="False" GridLines="None"
                  EmptyDataText="<div style='padding: 30px; text-align: center; color: #8fa4c4; font-style: italic; font-size: 1.1rem;'>No feedback matches this filter.</div>"
                  OnRowCommand="gvAdminFeedback_RowCommand">

                <Columns>
                  <asp:TemplateField HeaderText="Type / Source" ItemStyle-Width="20%">
                      <ItemTemplate>
                          <span class='<%# string.IsNullOrEmpty(Eval("ModuleTitle").ToString()) ? "badge-general" : "badge-course" %>'>
                              <%# string.IsNullOrEmpty(Eval("ModuleTitle").ToString()) ? "Global Platform" : Eval("ModuleTitle") %>
                          </span>
                      </ItemTemplate>
                  </asp:TemplateField>
                  
                  <asp:TemplateField HeaderText="User" ItemStyle-Width="25%">
                      <ItemTemplate>
                          <div class="student-info">
                              <span class="student-name">@<%# Eval("StudentUsername") %></span>
                              <span class="student-email"><%# Eval("StudentEmail") %></span>
                              <span class="student-email"><%# Eval("CreatedAt", "{0:MMM dd, yyyy}") %></span>
                          </div>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Message" ItemStyle-Width="45%">
                      <ItemTemplate>
                          <div class="feedback-box" style='<%# string.IsNullOrEmpty(Eval("ModuleTitle").ToString()) ? "border-left-color: var(--accent-cyan);" : "border-left-color: var(--accent-gold);" %>'>
                              "<%# Eval("FeedbackMessage") %>"
                          </div>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                      <asp:LinkButton runat="server" CssClass="btn-del" CommandName="DEL" CommandArgument='<%# Eval("FeedbackID") %>' OnClientClick="return confirm('Delete this feedback? This action cannot be undone.');">
                        Delete
                      </asp:LinkButton>
                    </ItemTemplate>
                  </asp:TemplateField>

                </Columns>
              </asp:GridView>
          </div>
      </div>
  </div>

</asp:Content>

<script runat="server">

  private string Cs => ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

  protected void Page_Load(object sender, EventArgs e)
  {
      // Security Check: Only Admins allowed
      if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
      {
          Response.Redirect("~/LoginandRegister/LoginPage.aspx");
          return;
      }

      if (!IsPostBack)
      {
          BindAdminFeedback();
      }
  }

  // Triggered instantly when the DropDown changes
  protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
  {
      lblMsg.Text = ""; // Clear any previous messages
      BindAdminFeedback();
  }

  private void BindAdminFeedback()
  {
      using (SqlConnection con = new SqlConnection(Cs))
      {
          // We start with a base query and 1=1 so we can easily append AND clauses
          string sql = @"
              SELECT 
                  f.FeedbackID, 
                  f.FeedbackMessage, 
                  f.CreatedAt,
                  u.Username AS StudentUsername, 
                  u.Email AS StudentEmail,
                  ISNULL(lc.Title, '') AS ModuleTitle
              FROM dbo.Feedback f
              INNER JOIN dbo.Users u ON f.StudentId = u.UserID
              LEFT JOIN dbo.LearningContent lc ON f.ContentId = lc.ContentId
              WHERE 1=1 ";

          // Dynamically append the WHERE clause based on the dropdown selection
          string filter = ddlFilter.SelectedValue;
          
          if (filter == "Global")
          {
              sql += " AND f.ContentId IS NULL ";
          }
          else if (filter == "Course")
          {
              sql += " AND f.ContentId IS NOT NULL ";
          }

          sql += " ORDER BY f.CreatedAt DESC";

          using (SqlCommand cmd = new SqlCommand(sql, con))
          using (SqlDataAdapter da = new SqlDataAdapter(cmd))
          {
              DataTable dt = new DataTable();
              da.Fill(dt);
              gvAdminFeedback.DataSource = dt;
              gvAdminFeedback.DataBind();
          }
      }
  }

  protected void gvAdminFeedback_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
      if (e.CommandName == "DEL")
      {
          int fid = Convert.ToInt32(e.CommandArgument);

          using (SqlConnection con = new SqlConnection(Cs))
          using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Feedback WHERE FeedbackID = @F", con))
          {
              cmd.Parameters.AddWithValue("@F", fid);
              con.Open();
              cmd.ExecuteNonQuery();
          }

          lblMsg.ForeColor = System.Drawing.Color.LightGreen;
          lblMsg.Text = "Feedback deleted permanently.";
          BindAdminFeedback();
      }
  }
</script>