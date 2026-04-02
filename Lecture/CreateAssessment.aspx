<%@ Page Title="Create Assessment" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Globalization" %>

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
          grid-template-columns: 1fr 2fr; /* Left side smaller, right side larger */
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
      
      .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0 15px; }
      .span-2 { grid-column: span 2; }

      /* Checkbox layout */
      .checkrow {
          display: flex; align-items: center; gap: 10px;
          background: rgba(0,0,0,0.2); padding: 12px 16px; border-radius: 12px;
          border: 1px solid rgba(255, 255, 255, 0.05);
          color: white; font-weight: 600; margin-bottom: 25px;
      }
      .checkrow input[type="checkbox"] { transform: scale(1.3); cursor: pointer; accent-color: var(--accent-cyan); }

      /* Buttons */
      .btn-actions { display: flex; gap: 12px; margin-top: 10px; }
      
      .btn-cyan { 
          background: linear-gradient(90deg, var(--accent-cyan), #0a67ff); 
          color: #ffffff; border: none; padding: 12px 24px; font-size: 1rem; font-weight: 800; 
          border-radius: 50px; cursor: pointer; transition: 0.3s; text-align: center;
          box-shadow: 0 6px 15px rgba(0, 216, 255, 0.25); 
      }
      .btn-cyan:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 216, 255, 0.4); }
      
      .btn-outline-clear { 
          background: transparent; color: white; border: 1px solid rgba(255,255,255,0.2); 
          padding: 12px 24px; font-size: 1rem; font-weight: 600; border-radius: 50px; 
          cursor: pointer; transition: 0.3s; text-decoration: none; text-align: center;
      }
      .btn-outline-clear:hover { background: rgba(255,255,255,0.1); border-color: white; }

      /* Grid / Table Styles */
      .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
      .tech-table th { padding: 0 16px 12px; text-align: left; color: var(--muted-text); font-size: 0.82rem; letter-spacing: 0.08em; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); }
      .tech-table td { padding: 16px; color: #ffffff; background: rgba(255,255,255,0.03); border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle;}
      .tech-table td:first-child { border-radius: 12px 0 0 12px; }
      .tech-table td:last-child { border-radius: 0 12px 12px 0; }
      .tech-table tr:hover td { background: rgba(255, 255, 255, 0.06); }

      /* Type Badges */
      .badge-type { padding: 4px 10px; border-radius: 8px; font-size: 0.8rem; font-weight: 700; border: 1px solid transparent; white-space: nowrap; }
      .badge-exercise { background: rgba(181, 123, 255, 0.1); color: var(--accent-purple); border-color: rgba(181, 123, 255, 0.3); }
      .badge-quiz { background: rgba(0, 216, 255, 0.1); color: var(--accent-cyan); border-color: rgba(0, 216, 255, 0.3); }
      .badge-exam { background: rgba(255, 200, 87, 0.1); color: var(--accent-gold); border-color: rgba(255, 200, 87, 0.3); }

      /* Action Links in Grid */
      .action-link {
          display: inline-flex; align-items: center; justify-content: center;
          padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-decoration: none;
          transition: 0.2s ease; border: 1px solid transparent; cursor: pointer;
      }
      .btn-options { border-color: rgba(0, 216, 255, 0.5); color: var(--accent-cyan); background: transparent; }
      .btn-options:hover { background: rgba(0, 216, 255, 0.1); }
      .btn-del { border-color: rgba(255, 123, 123, 0.5); color: var(--accent-red); background: transparent; }
      .btn-del:hover { background: rgba(255, 123, 123, 0.1); }

      /* Custom message styling */
      .msg-banner { display: block; margin-top: 15px; font-weight: 600; font-size: 0.95rem; }

      @media (max-width: 1000px) {
          .layout-2 { grid-template-columns: 1fr; }
      }
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Create Assessment</h2>
      <p class="page-subtitle">Build exercises, quizzes, or final exams linked to specific learning modules.</p>

      <div class="layout-2">

        <div class="glass-panel">
          <h3>New Assessment</h3>

          <div class="form-grid">
            <div class="span-2">
              <label class="form-label">Module / Content</label>
              <asp:DropDownList ID="ddlContent" runat="server" CssClass="neon-input" />
            </div>

            <div class="span-2">
              <label class="form-label">Assessment Title</label>
              <asp:TextBox ID="txtTitle" runat="server" CssClass="neon-input" Placeholder="e.g. Python Basics Quiz" />
            </div>

            <div>
              <label class="form-label">Assessment Type</label>
              <asp:DropDownList ID="ddlType" runat="server" CssClass="neon-input">
                <asp:ListItem Text="Exercise" Value="Exercise" />
                <asp:ListItem Text="Quiz" Value="Quiz" />
                <asp:ListItem Text="Final Exam" Value="FinalExam" />
              </asp:DropDownList>
            </div>

            <div>
              <label class="form-label">Total Marks (XP)</label>
              <asp:TextBox ID="txtTotalMarks" runat="server" CssClass="neon-input" Text="1" />
            </div>

            <div class="span-2">
              <label class="form-label">Instructions (Optional)</label>
              <asp:TextBox ID="txtInstr" runat="server" CssClass="neon-input" TextMode="MultiLine" Rows="3" Placeholder="Guidelines for the students..." />
            </div>

            <div class="span-2">
              <label class="form-label">Visibility</label>
              <div class="checkrow">
                <asp:CheckBox ID="chkPublish" runat="server" />
                <label for="chkPublish" style="cursor: pointer;">Publish immediately to students</label>
              </div>
            </div>
          </div>

          <div class="btn-actions">
            <asp:Button ID="btnCreate" runat="server" Text="Create Assessment" CssClass="btn-cyan" OnClick="CreateAssessment" style="flex: 1;" />
            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn-outline-clear" OnClick="ClearForm" CausesValidation="false" />
          </div>

          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />
        </div>

        <div class="glass-panel">
          <h3>My Assessments</h3>

          <div style="overflow-x: auto;">
              <asp:GridView ID="gvAssess" runat="server" CssClass="tech-table"
                  AutoGenerateColumns="False"
                  GridLines="None"
                  OnRowCommand="gvAssess_RowCommand"
                  EmptyDataText="<div style='padding: 20px; text-align: center; color: #8fa4c4; font-style: italic;'>No assessments created yet.</div>">

                <Columns>
                  <asp:BoundField DataField="ModuleTitle" HeaderText="Module" ItemStyle-Width="25%" />
                  <asp:BoundField DataField="Title" HeaderText="Assessment Title" ItemStyle-Width="25%" />
                  
                  <asp:TemplateField HeaderText="Type">
                      <ItemTemplate>
                          <span class='<%# Eval("AssessmentType").ToString() == "FinalExam" ? "badge-type badge-exam" : (Eval("AssessmentType").ToString() == "Quiz" ? "badge-type badge-quiz" : "badge-type badge-exercise") %>'>
                              <%# Eval("AssessmentType").ToString() == "FinalExam" ? "Final Exam" : Eval("AssessmentType") %>
                          </span>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Marks">
                      <ItemTemplate>
                          <span style="color: var(--accent-lime); font-weight: bold;"><%# Eval("TotalMarks") %> XP</span>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Status">
                      <ItemTemplate>
                          <span style='<%# Convert.ToBoolean(Eval("IsPublished")) ? "color: var(--accent-lime); font-weight: bold;" : "color: var(--muted-text);" %>'>
                              <%# Convert.ToBoolean(Eval("IsPublished")) ? "● Published" : "○ Draft" %>
                          </span>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                      <div style="display: flex; gap: 8px;">
                          <a class="action-link btn-options" href='<%# "ManageQuestions.aspx?aid=" + Eval("AssessmentId") %>'>
                            Questions
                          </a>

                          <asp:LinkButton runat="server"
                              CssClass="action-link btn-del"
                              CommandName="DEL"
                              CommandArgument='<%# Eval("AssessmentId") %>'
                              OnClientClick="return confirm('Delete this assessment? Existing submissions will block deletion.');">
                            Delete
                          </asp:LinkButton>
                      </div>
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

  private static readonly ISet<string> AllowedAssessmentTypes =
    new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "Exercise", "Quiz", "FinalExam" };

  private string Cs => ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;

  private bool IsAdmin
  {
    get
    {
      return string.Equals(Convert.ToString(Session["Role"], CultureInfo.InvariantCulture), "Admin", StringComparison.OrdinalIgnoreCase);
    }
  }

  private int CurrentUserId
  {
    get
    {
      object userId = Session["UserId"] ?? Session["UserID"];
      return Convert.ToInt32(userId, CultureInfo.InvariantCulture);
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!EnsureLecturerAccess())
    {
      return;
    }

    if (!IsPostBack)
    {
      BindContentSelector();
      BindAssessments();
    }
  }

  private bool EnsureLecturerAccess()
  {
    object userId = Session["UserId"] ?? Session["UserID"];
    string role = Convert.ToString(Session["Role"], CultureInfo.InvariantCulture);
    int parsedUserId;

    if (userId == null ||
        !int.TryParse(Convert.ToString(userId, CultureInfo.InvariantCulture), out parsedUserId) ||
        (!string.Equals(role, "Lecturer", StringComparison.OrdinalIgnoreCase) &&
         !string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase)))
    {
      string returnUrl = Server.UrlEncode(Request.RawUrl);
      Response.Redirect("~/LoginandRegister/LoginPage.aspx?returnUrl=" + returnUrl, false);
      Context.ApplicationInstance.CompleteRequest();
      return false;
    }

    return true;
  }

  private void BindContentSelector()
  {
    ddlContent.Items.Clear();
    ddlContent.Items.Add(new ListItem("-- Select Module --", "0"));

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT ContentId, Title
      FROM dbo.LearningContent
      WHERE @IsAdmin = 1 OR LecturerId = @L
      ORDER BY Title ASC;", con))
    {
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@L", CurrentUserId);
      con.Open();

      using (SqlDataReader r = cmd.ExecuteReader())
      {
        while (r.Read())
        {
          ddlContent.Items.Add(new ListItem(
            Convert.ToString(r["Title"], CultureInfo.InvariantCulture),
            Convert.ToString(r["ContentId"], CultureInfo.InvariantCulture)));
        }
      }
    }
  }

  private void BindAssessments()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT a.AssessmentId,
             a.Title,
             a.AssessmentType,
             a.TotalMarks,
             a.IsPublished,
             lc.Title AS ModuleTitle
      FROM dbo.Assessment a
      INNER JOIN dbo.LearningContent lc ON lc.ContentId = a.ContentId
      WHERE @IsAdmin = 1 OR a.LecturerId = @L
      ORDER BY a.CreatedAt DESC;", con))
    {
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@L", CurrentUserId);

      using (SqlDataAdapter da = new SqlDataAdapter(cmd))
      {
        DataTable dt = new DataTable();
        da.Fill(dt);
        gvAssess.DataSource = dt;
        gvAssess.DataBind();
      }
    }
  }

  protected void CreateAssessment(object sender, EventArgs e)
  {
    if (!EnsureLecturerAccess())
    {
      return;
    }

    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string title = (txtTitle.Text ?? string.Empty).Trim();
    string instructions = (txtInstr.Text ?? string.Empty).Trim();
    string type = ddlType.SelectedValue;
    int contentId;
    int totalMarks;

    if (!int.TryParse(ddlContent.SelectedValue, out contentId) || contentId <= 0)
    {
      lblMsg.Text = "Please choose a module for this assessment.";
      return;
    }

    if (!ContentBelongsToCurrentUser(contentId))
    {
      lblMsg.Text = "You can only attach assessments to your own modules unless you are an admin.";
      return;
    }

    if (string.IsNullOrWhiteSpace(title))
    {
      lblMsg.Text = "Title is required.";
      return;
    }

    if (title.Length > 200)
    {
      lblMsg.Text = "Title must be 200 characters or fewer.";
      return;
    }

    if (!AllowedAssessmentTypes.Contains(type))
    {
      lblMsg.Text = "Please choose a valid assessment type.";
      return;
    }

    if (!int.TryParse((txtTotalMarks.Text ?? string.Empty).Trim(), out totalMarks) || totalMarks <= 0 || totalMarks > 1000)
    {
      lblMsg.Text = "Total marks must be a whole number between 1 and 1000.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        INSERT INTO dbo.Assessment
          (LecturerId, ContentId, Title, AssessmentType, Instructions, TotalMarks, IsPublished, CreatedAt)
        VALUES
          (@L, @C, @T, @Ty, @I, @M, @P, GETDATE());", con))
      {
        cmd.Parameters.AddWithValue("@L", CurrentUserId);
        cmd.Parameters.AddWithValue("@C", contentId);
        cmd.Parameters.AddWithValue("@T", title);
        cmd.Parameters.AddWithValue("@Ty", type);
        cmd.Parameters.AddWithValue("@I", string.IsNullOrWhiteSpace(instructions) ? (object)DBNull.Value : instructions);
        cmd.Parameters.AddWithValue("@M", totalMarks);
        cmd.Parameters.AddWithValue("@P", chkPublish.Checked);

        con.Open();
        cmd.ExecuteNonQuery();
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Assessment created.";
      ClearInputsOnly();
      BindAssessments();
    }
    catch (Exception ex)
    {
      Trace.Warn("CreateAssessment", "Failed to create assessment.", ex);
      lblMsg.Text = "We couldn't create that assessment right now. Please try again.";
    }
  }

  private bool ContentBelongsToCurrentUser(int contentId)
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT COUNT(1)
      FROM dbo.LearningContent
      WHERE ContentId = @ContentId
        AND (@IsAdmin = 1 OR LecturerId = @LecturerId);", con))
    {
      cmd.Parameters.AddWithValue("@ContentId", contentId);
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);
      con.Open();
      return Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture) > 0;
    }
  }

  protected void ClearForm(object sender, EventArgs e)
  {
    lblMsg.Text = string.Empty;
    ClearInputsOnly();
  }

  private void ClearInputsOnly()
  {
    txtTitle.Text = string.Empty;
    txtInstr.Text = string.Empty;
    txtTotalMarks.Text = "1";
    chkPublish.Checked = false;
    ddlType.SelectedIndex = 0;
    if (ddlContent.Items.Count > 0)
    {
      ddlContent.SelectedIndex = 0;
    }
  }

  protected void gvAssess_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName != "DEL")
    {
      return;
    }

    int assessmentId;
    if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out assessmentId))
    {
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "Invalid assessment selection.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      {
        con.Open();

        using (SqlCommand submissionsCmd = new SqlCommand(@"
          SELECT COUNT(1)
          FROM dbo.AssessmentSubmission s
          INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
          WHERE s.AssessmentId = @A
            AND (@IsAdmin = 1 OR a.LecturerId = @L);", con))
        {
          submissionsCmd.Parameters.AddWithValue("@A", assessmentId);
          submissionsCmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
          submissionsCmd.Parameters.AddWithValue("@L", CurrentUserId);

          if (Convert.ToInt32(submissionsCmd.ExecuteScalar(), CultureInfo.InvariantCulture) > 0)
          {
            lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
            lblMsg.Text = "Assessments with student submissions cannot be deleted.";
            return;
          }
        }

        using (SqlTransaction tx = con.BeginTransaction())
        {
          using (SqlCommand delOptions = new SqlCommand(@"
            DELETE qo
            FROM dbo.QuestionOption qo
            INNER JOIN dbo.Question q ON q.QuestionId = qo.QuestionId
            INNER JOIN dbo.Assessment a ON a.AssessmentId = q.AssessmentId
            WHERE a.AssessmentId = @A
              AND (@IsAdmin = 1 OR a.LecturerId = @L);", con, tx))
          {
            delOptions.Parameters.AddWithValue("@A", assessmentId);
            delOptions.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            delOptions.Parameters.AddWithValue("@L", CurrentUserId);
            delOptions.ExecuteNonQuery();
          }

          using (SqlCommand delQuestions = new SqlCommand(@"
            DELETE q
            FROM dbo.Question q
            INNER JOIN dbo.Assessment a ON a.AssessmentId = q.AssessmentId
            WHERE a.AssessmentId = @A
              AND (@IsAdmin = 1 OR a.LecturerId = @L);", con, tx))
          {
            delQuestions.Parameters.AddWithValue("@A", assessmentId);
            delQuestions.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            delQuestions.Parameters.AddWithValue("@L", CurrentUserId);
            delQuestions.ExecuteNonQuery();
          }

          using (SqlCommand delAssessment = new SqlCommand(@"
            DELETE FROM dbo.Assessment
            WHERE AssessmentId = @A
              AND (@IsAdmin = 1 OR LecturerId = @L);", con, tx))
          {
            delAssessment.Parameters.AddWithValue("@A", assessmentId);
            delAssessment.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            delAssessment.Parameters.AddWithValue("@L", CurrentUserId);

            if (delAssessment.ExecuteNonQuery() == 0)
            {
              tx.Rollback();
              lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
              lblMsg.Text = "You can only delete assessments that you own unless you are an admin.";
              return;
            }
          }

          tx.Commit();
        }
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Assessment deleted.";
      BindAssessments();
    }
    catch (Exception ex)
    {
      Trace.Warn("CreateAssessment", "Failed to delete assessment.", ex);
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "We couldn't delete that assessment right now. Please try again.";
    }
  }

</script>
