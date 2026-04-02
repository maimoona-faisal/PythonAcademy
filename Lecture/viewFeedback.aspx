<%@ Page Title="View Feedback" Language="C#" MasterPageFile="~/Site.Master" %>
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
          --accent-lime: #14f195;
          --accent-purple: #b57bff;
          --accent-gold: #ffc857;
          --panel-bg: rgba(13, 25, 48, 0.85);
          --panel-border: rgba(255, 255, 255, 0.1);
          --muted-text: #8fa4c4;
      }

      .admin-shell {
          max-width: 1200px;
          margin: 0 auto;
          padding: 20px;
      }

      .page-title { font-size: 2.2rem; font-weight: bold; color: white; margin: 0; }
      .page-subtitle { color: var(--muted-text); margin-top: 5px; margin-bottom: 30px; }

      .layout-2 {
          display: grid;
          grid-template-columns: 1fr 3fr; /* Left side smaller, right side larger */
          gap: 30px;
          align-items: start;
      }

      /* Glassmorphism Cards */
      .glass-panel { 
          background: var(--panel-bg); 
          backdrop-filter: blur(12px); 
          border: 1px solid var(--panel-border); 
          border-radius: 20px; 
          padding: 30px; 
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); 
      }

      .glass-panel h3 { color: white; margin-top: 0; margin-bottom: 20px; font-weight: 700; }

      /* Form Elements */
      .form-label { display: block; margin-bottom: 8px; color: var(--muted-text); font-size: 0.85rem; font-weight: bold; text-transform: uppercase; letter-spacing: 0.05em; }
      
      .neon-input { 
          width: 100%; padding: 14px; border-radius: 12px; 
          border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0, 0, 0, 0.2); 
          color: white; font-size: 1rem; outline: none; transition: 0.3s; 
          margin-bottom: 20px; box-sizing: border-box;
      }
      .neon-input:focus { border-color: var(--accent-cyan); box-shadow: 0 0 10px rgba(0, 216, 255, 0.15); }

      /* Buttons */
      .btn-actions { display: flex; gap: 12px; margin-top: 10px; }
      
      .btn-outline-clear { 
          background: transparent; color: white; border: 1px solid rgba(255,255,255,0.2); 
          padding: 12px 24px; font-size: 1rem; font-weight: 600; border-radius: 50px; 
          cursor: pointer; transition: 0.3s; text-decoration: none; text-align: center;
          width: 100%;
      }
      .btn-outline-clear:hover { background: rgba(255,255,255,0.1); border-color: white; }

      /* Grid / Table Styles */
      .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
      .tech-table th { padding: 0 16px 12px; text-align: left; color: var(--muted-text); font-size: 0.82rem; letter-spacing: 0.08em; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); }
      .tech-table td { padding: 16px; color: #ffffff; background: rgba(255,255,255,0.03); border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: top;}
      .tech-table td:first-child { border-radius: 12px 0 0 12px; }
      .tech-table td:last-child { border-radius: 0 12px 12px 0; }
      .tech-table tr:hover td { background: rgba(255, 255, 255, 0.06); }

      /* Action Links in Grid */
      .action-link {
          display: inline-flex; align-items: center; justify-content: center;
          padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-decoration: none;
          transition: 0.2s ease; border: 1px solid transparent; cursor: pointer;
      }
      .btn-del { border-color: rgba(255, 123, 123, 0.5); color: var(--accent-red); background: transparent; }
      .btn-del:hover { background: rgba(255, 123, 123, 0.1); }

      /* Specifics for Feedback */
      .feedback-box {
          background: rgba(0,0,0,0.3); padding: 12px 16px; border-radius: 8px; 
          border-left: 3px solid var(--accent-gold); color: #e7eefc; 
          font-size: 0.95rem; font-style: italic; line-height: 1.5;
      }
      .student-info { display: flex; flex-direction: column; gap: 4px; }
      .student-name { font-weight: bold; color: var(--accent-cyan); }
      .student-email { font-size: 0.8rem; color: var(--muted-text); }

      /* Custom message styling */
      .msg-banner { display: block; margin-top: 15px; font-weight: 600; font-size: 0.95rem; text-align: center;}

      @media (max-width: 900px) {
          .layout-2 { grid-template-columns: 1fr; }
      }
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Student Feedback</h2>
      <p class="page-subtitle">Review feedback submitted by learners for your learning modules.</p>

      <div class="layout-2">

        <div class="glass-panel">
          <h3>Filter</h3>

          <label class="form-label">Module / Learning Content</label>
          <asp:DropDownList ID="ddlModule" runat="server" CssClass="neon-input"
              AutoPostBack="true" OnSelectedIndexChanged="ddlModule_Changed" />

          <div class="btn-actions">
            <asp:Button ID="btnClear" runat="server" Text="Clear Filter"
                CssClass="btn-outline-clear" OnClick="ClearFilter" CausesValidation="false" />
          </div>

          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />
        </div>

        <div class="glass-panel">
          <h3>Feedback List</h3>

          <div style="overflow-x: auto;">
              <asp:GridView ID="gvFeedback" runat="server" CssClass="tech-table"
                  AutoGenerateColumns="False" GridLines="None"
                  EmptyDataText="<div style='padding: 30px; text-align: center; color: #8fa4c4; font-style: italic; font-size: 1.1rem;'>No feedback found for this selection.</div>"
                  OnRowCommand="gvFeedback_RowCommand">

                <Columns>
                  <asp:BoundField DataField="ModuleTitle" HeaderText="Module" ItemStyle-Width="20%" />
                  
                  <asp:TemplateField HeaderText="Student" ItemStyle-Width="25%">
                      <ItemTemplate>
                          <div class="student-info">
                              <span class="student-name">@<%# Eval("StudentUsername") %></span>
                              <span class="student-email"><%# Eval("StudentEmail") %></span>
                          </div>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Message" ItemStyle-Width="45%">
                      <ItemTemplate>
                          <div class="feedback-box">
                              "<%# Eval("FeedbackMessage") %>"
                          </div>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                      <asp:LinkButton runat="server"
                          CssClass="action-link btn-del"
                          CommandName="DEL"
                          CommandArgument='<%# Eval("FeedbackID") %>'
                          OnClientClick="return confirm('Delete this feedback? This action cannot be undone.');">
                        Delete
                      </asp:LinkButton>
                    </ItemTemplate>
                  </asp:TemplateField>

                </Columns>
              </asp:GridView>
          </div>
        </div>

      </div>
  </div>

</asp:Content>

<script runat="server">

  private string Cs => ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

  // Lecturer is the currently logged in user
  private int LecturerId
  {
    get
    {
      if (Session["UserId"] == null) return 1; // testing fallback
      return Convert.ToInt32(Session["UserId"]);
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      BindModules();
      BindFeedback();
    }
  }

  private void BindModules()
  {
    ddlModule.Items.Clear();
    ddlModule.Items.Add(new System.Web.UI.WebControls.ListItem("-- All Modules --", "0"));

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT ContentId, Title
      FROM dbo.LearningContent
      WHERE LecturerId = @L
      ORDER BY CreatedAt DESC;
    ", con))
    {
      cmd.Parameters.AddWithValue("@L", LecturerId);
      con.Open();

      using (SqlDataReader r = cmd.ExecuteReader())
      {
        while (r.Read())
        {
          ddlModule.Items.Add(
            new System.Web.UI.WebControls.ListItem(
              r["Title"].ToString(),
              r["ContentId"].ToString()
            )
          );
        }
      }
    }
  }

  private void BindFeedback()
  {
    int moduleId = 0;
    int.TryParse(ddlModule.SelectedValue, out moduleId);

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT
        f.FeedbackID,
        f.ContentId,  /* <-- CHANGED HERE */
        lc.Title AS ModuleTitle,
        u.Username AS StudentUsername,
        u.Email AS StudentEmail,
        f.FeedbackMessage
      FROM dbo.Feedback f
      INNER JOIN dbo.LearningContent lc ON lc.ContentId = f.ContentId /* <-- CHANGED HERE */
      INNER JOIN dbo.Users u ON u.UserID = f.StudentId
      WHERE lc.LecturerId = @L
        AND (@ModuleId = 0 OR f.ContentId = @ModuleId) /* <-- CHANGED HERE */
      ORDER BY f.FeedbackID DESC;
    ", con))
    {
      cmd.Parameters.AddWithValue("@L", LecturerId);
      cmd.Parameters.AddWithValue("@ModuleId", moduleId);

      using (SqlDataAdapter da = new SqlDataAdapter(cmd))
      {
        DataTable dt = new DataTable();
        da.Fill(dt);
        gvFeedback.DataSource = dt;
        gvFeedback.DataBind();
      }
    }
  }

  protected void ddlModule_Changed(object sender, EventArgs e)
  {
    lblMsg.Text = "";
    BindFeedback();
  }

  protected void ClearFilter(object sender, EventArgs e)
  {
    ddlModule.SelectedIndex = 0;
    lblMsg.Text = "";
    BindFeedback();
  }

  protected void gvFeedback_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName == "DEL")
    {
      int fid = Convert.ToInt32(e.CommandArgument);

      // Security: only delete feedback related to lecturer’s content
     using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        DELETE f
        FROM dbo.Feedback f
        INNER JOIN dbo.LearningContent lc ON lc.ContentId = f.ContentId /* <-- CHANGED HERE */
        WHERE f.FeedbackID = @F AND lc.LecturerId = @L;
      ", con))
      {
        cmd.Parameters.AddWithValue("@F", fid);
        cmd.Parameters.AddWithValue("@L", LecturerId);
        con.Open();
        cmd.ExecuteNonQuery();
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Feedback deleted.";
      BindFeedback();
    }
  }

</script>
