<%@ Page Title="Grade Submissions" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
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
      
      /* Mini input for grading marks */
      .grade-input {
          width: 70px !important; padding: 8px !important; text-align: center; margin-bottom: 0 !important;
          font-weight: bold; color: var(--accent-lime) !important;
      }

      /* Buttons */
      .btn-actions { display: flex; gap: 12px; margin-top: 10px; }
      
      .btn-cyan { 
          background: linear-gradient(90deg, var(--accent-cyan), #0a67ff); 
          color: #ffffff; border: none; padding: 12px 24px; font-size: 1rem; font-weight: 800; 
          border-radius: 50px; cursor: pointer; transition: 0.3s; text-align: center;
          box-shadow: 0 6px 15px rgba(0, 216, 255, 0.25); 
      }
      .btn-cyan:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 216, 255, 0.4); }

      /* Grid / Table Styles */
      .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
      .tech-table th { padding: 0 16px 12px; text-align: left; color: var(--muted-text); font-size: 0.82rem; letter-spacing: 0.08em; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); }
      .tech-table td { padding: 16px; color: #ffffff; background: rgba(255,255,255,0.03); border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle;}
      .tech-table td:first-child { border-radius: 12px 0 0 12px; }
      .tech-table td:last-child { border-radius: 0 12px 12px 0; }
      .tech-table tr:hover td { background: rgba(255, 255, 255, 0.06); }

      /* Type Badges */
      .badge-type { padding: 4px 10px; border-radius: 8px; font-size: 0.8rem; font-weight: 700; border: 1px solid transparent; }
      .badge-mcq { background: rgba(181, 123, 255, 0.1); color: var(--accent-purple); border-color: rgba(181, 123, 255, 0.3); }
      .badge-text { background: rgba(0, 216, 255, 0.1); color: var(--accent-cyan); border-color: rgba(0, 216, 255, 0.3); }

      /* Action Links in Grid */
      .action-link {
          display: inline-flex; align-items: center; justify-content: center;
          padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-decoration: none;
          transition: 0.2s ease; border: 1px solid transparent; cursor: pointer;
      }
      .btn-grade { border-color: rgba(255, 200, 87, 0.5); color: var(--accent-gold); background: transparent; }
      .btn-grade:hover { background: rgba(255, 200, 87, 0.1); }
      
      .btn-save { border-color: rgba(20, 241, 149, 0.5); color: var(--accent-lime); background: transparent; }
      .btn-save:hover { background: rgba(20, 241, 149, 0.1); }

      /* Custom message styling */
      .msg-banner { display: block; margin-top: 15px; font-weight: 600; font-size: 0.95rem; }
      
      .student-answer-box {
          background: rgba(0,0,0,0.3); padding: 10px; border-radius: 8px; 
          border-left: 3px solid var(--accent-cyan); color: #e7eefc; font-size: 0.9rem;
      }

      @media (max-width: 1000px) {
          .layout-2 { grid-template-columns: 1fr; }
      }
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Grade Submissions</h2>
      <p class="page-subtitle">Select an assessment, review submissions, and grade text answers. MCQs are auto-graded.</p>

      <div class="layout-2">

        <div class="glass-panel">
          <h3>Submissions</h3>

          <label class="form-label">Select Assessment</label>
          <asp:DropDownList ID="ddlAssess" runat="server" CssClass="neon-input" AutoPostBack="true" OnSelectedIndexChanged="ddlAssess_Changed" />
          
          <asp:Label ID="lblLeftMsg" runat="server" CssClass="msg-banner" />

          <div style="overflow-x: auto;">
              <asp:GridView ID="gvSubs" runat="server" CssClass="tech-table" AutoGenerateColumns="False"
                  GridLines="None"
                  EmptyDataText="<div style='padding: 20px; text-align: center; color: #8fa4c4; font-style: italic;'>No submissions found.</div>"
                  OnRowCommand="gvSubs_RowCommand">

                <Columns>
                  <asp:BoundField DataField="SubmissionId" HeaderText="ID" />
                  <asp:BoundField DataField="StudentId" HeaderText="Student" />
                  
                  <asp:TemplateField HeaderText="Score">
                      <ItemTemplate>
                          <span style="color: var(--accent-lime); font-weight: bold;"><%# Eval("TotalScore") %></span>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                      <asp:LinkButton runat="server" CssClass="action-link btn-grade"
                          CommandName="OPEN"
                          CommandArgument='<%# Eval("SubmissionId") %>'>
                        Review / Grade
                      </asp:LinkButton>
                    </ItemTemplate>
                  </asp:TemplateField>
                </Columns>

              </asp:GridView>
          </div>
        </div>

        <div class="glass-panel">
          <h3>Grade Submission</h3>

          <asp:Panel ID="pnlGrade" runat="server" Visible="false">
            
            <div style="display: flex; gap: 15px; margin-bottom: 20px; background: rgba(0,0,0,0.2); padding: 12px 20px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.05);">
                <span style="color: var(--muted-text);">Submission ID: <strong style="color: white;"><asp:Label ID="lblSid" runat="server" /></strong></span>
                <span style="color: rgba(255,255,255,0.2);">|</span>
                <span style="color: var(--muted-text);">Student ID: <strong style="color: var(--accent-cyan);"><asp:Label ID="lblStudent" runat="server" /></strong></span>
            </div>

            <div style="overflow-x: auto;">
                <asp:GridView ID="gvAnswers" runat="server" CssClass="tech-table" AutoGenerateColumns="False"
                    GridLines="None"
                    EmptyDataText="<div style='padding: 20px; text-align: center; color: #8fa4c4; font-style: italic;'>No answers found.</div>"
                    OnRowCommand="gvAnswers_RowCommand">

                  <Columns>
                    <asp:BoundField DataField="QuestionText" HeaderText="Question" ItemStyle-Width="30%" />
                    
                    <asp:TemplateField HeaderText="Type">
                        <ItemTemplate>
                            <span class='<%# Eval("QuestionType").ToString() == "MCQ" ? "badge-type badge-mcq" : "badge-type badge-text" %>'>
                                <%# Eval("QuestionType") %>
                            </span>
                            <br /><span style="font-size: 0.75rem; color: var(--muted-text); margin-top: 4px; display: block;">Max: <%# Eval("QuestionMarks") %>XP</span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Student Answer" ItemStyle-Width="35%">
                      <ItemTemplate>
                        <div class="student-answer-box">
                          <%# GetAnswerDisplay(Eval("SelectedOptionText"), Eval("AnswerText")) %>
                        </div>
                      </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Award">
                      <ItemTemplate>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <asp:HiddenField ID="hfAnswerId" runat="server" Value='<%# Eval("AnswerId") %>' />
                            <asp:TextBox ID="txtAward" runat="server" CssClass="neon-input grade-input"
                                Text='<%# Eval("MarksAwarded") %>' />
                            
                            <asp:LinkButton runat="server" CssClass="action-link btn-save"
                                CommandName="SAVE"
                                CommandArgument='<%# Eval("AnswerId") %>'>
                              Save
                            </asp:LinkButton>
                        </div>
                      </ItemTemplate>
                    </asp:TemplateField>

                  </Columns>
                </asp:GridView>
            </div>

            <div class="btn-actions" style="margin-top: 25px;">
              <asp:Button ID="btnRecalc" runat="server" Text="Save & Recalculate Total Score"
                  CssClass="btn-cyan" style="width: 100%;" OnClick="RecalculateTotal" />
            </div>

            <asp:Label ID="lblRightMsg" runat="server" CssClass="msg-banner" style="text-align: center;" />

          </asp:Panel>

          <asp:Panel ID="pnlEmpty" runat="server" Visible="true">
            <div style="text-align: center; padding: 60px 20px; border: 2px dashed rgba(255,255,255,0.1); border-radius: 16px;">
                <span style="font-size: 3rem; opacity: 0.5;">&#128221;</span>
                <p style="color: var(--muted-text); font-size: 1.1rem; margin-top: 15px;">Click <strong>"Review / Grade"</strong> on a submission on the left to start grading.</p>
            </div>
          </asp:Panel>

        </div>

      </div>
  </div>

</asp:Content>

<script runat="server">

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

  private int SelectedAssessmentId
  {
    get
    {
      int id;
      return int.TryParse(ddlAssess.SelectedValue, out id) ? id : 0;
    }
  }

  private int CurrentSubmissionId
  {
    get
    {
      object o = ViewState["SID"];
      return o == null ? 0 : Convert.ToInt32(o, CultureInfo.InvariantCulture);
    }
    set { ViewState["SID"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!EnsureLecturerAccess())
    {
      return;
    }

    if (!IsPostBack)
    {
      BindAssessments();
      BindSubmissions();
      HideGradePanel();
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

  private void ShowGradePanel()
  {
    pnlGrade.Visible = true;
    pnlEmpty.Visible = false;
  }

  private void HideGradePanel()
  {
    pnlGrade.Visible = false;
    pnlEmpty.Visible = true;
    lblSid.Text = string.Empty;
    lblStudent.Text = string.Empty;
    lblRightMsg.Text = string.Empty;
  }

  public string GetAnswerDisplay(object selectedOptionTextObj, object answerTextObj)
  {
    string opt = (selectedOptionTextObj == null || selectedOptionTextObj == DBNull.Value)
      ? string.Empty : selectedOptionTextObj.ToString();

    string txt = (answerTextObj == null || answerTextObj == DBNull.Value)
      ? string.Empty : answerTextObj.ToString();

    if (!string.IsNullOrWhiteSpace(opt)) return "MCQ: " + opt;
    if (!string.IsNullOrWhiteSpace(txt)) return "Text: " + txt;
    return "(No answer)";
  }

  private void BindAssessments()
  {
    ddlAssess.Items.Clear();
    ddlAssess.Items.Add(new ListItem("-- Select --", "0"));

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT AssessmentId, Title
      FROM dbo.Assessment
      WHERE @IsAdmin = 1 OR LecturerId = @L
      ORDER BY CreatedAt DESC;", con))
    {
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@L", CurrentUserId);
      con.Open();

      using (SqlDataReader r = cmd.ExecuteReader())
      {
        while (r.Read())
        {
          ddlAssess.Items.Add(new ListItem(
            Convert.ToString(r["Title"], CultureInfo.InvariantCulture),
            Convert.ToString(r["AssessmentId"], CultureInfo.InvariantCulture)));
        }
      }
    }
  }

  private void BindSubmissions()
  {
    lblLeftMsg.Text = string.Empty;

    if (SelectedAssessmentId == 0)
    {
      gvSubs.DataSource = null;
      gvSubs.DataBind();
      lblLeftMsg.Text = "Select an assessment to view submissions.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        SELECT s.SubmissionId, s.StudentId, s.SubmittedAt, s.TotalScore
        FROM dbo.AssessmentSubmission s
        INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
        WHERE s.AssessmentId = @A
          AND (@IsAdmin = 1 OR a.LecturerId = @L)
        ORDER BY s.SubmittedAt DESC;", con))
      {
        cmd.Parameters.AddWithValue("@A", SelectedAssessmentId);
        cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
        cmd.Parameters.AddWithValue("@L", CurrentUserId);

        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
        {
          DataTable dt = new DataTable();
          da.Fill(dt);
          gvSubs.DataSource = dt;
          gvSubs.DataBind();
        }
      }
    }
    catch (Exception ex)
    {
      Trace.Warn("Grade", "Failed to bind submissions.", ex);
      lblLeftMsg.Text = "We couldn't load submissions right now. Please try again.";
    }
  }

  private void BindAnswers(int submissionId)
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT
        sa.AnswerId,
        sa.SubmissionId,
        sa.QuestionId,
        q.QuestionText,
        q.QuestionType,
        q.Marks AS QuestionMarks,
        sa.SelectedOptionId,
        qo.OptionText AS SelectedOptionText,
        sa.AnswerText,
        ISNULL(sa.MarksAwarded, 0) AS MarksAwarded
      FROM dbo.SubmissionAnswer sa
      INNER JOIN dbo.Question q ON q.QuestionId = sa.QuestionId
      INNER JOIN dbo.AssessmentSubmission s ON s.SubmissionId = sa.SubmissionId
      INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
      LEFT JOIN dbo.QuestionOption qo ON qo.OptionId = sa.SelectedOptionId
      WHERE sa.SubmissionId = @S
        AND (@IsAdmin = 1 OR a.LecturerId = @L)
      ORDER BY sa.AnswerId ASC;", con))
    {
      cmd.Parameters.AddWithValue("@S", submissionId);
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@L", CurrentUserId);

      using (SqlDataAdapter da = new SqlDataAdapter(cmd))
      {
        DataTable dt = new DataTable();
        da.Fill(dt);
        gvAnswers.DataSource = dt;
        gvAnswers.DataBind();
      }
    }
  }

  protected void ddlAssess_Changed(object sender, EventArgs e)
  {
    HideGradePanel();
    BindSubmissions();
  }

  protected void gvSubs_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName != "OPEN")
    {
      return;
    }

    int sid;
    if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out sid))
    {
      lblLeftMsg.Text = "Invalid submission selection.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        SELECT s.SubmissionId, s.StudentId
        FROM dbo.AssessmentSubmission s
        INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
        WHERE s.SubmissionId = @S
          AND (@IsAdmin = 1 OR a.LecturerId = @L);", con))
      {
        cmd.Parameters.AddWithValue("@S", sid);
        cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
        cmd.Parameters.AddWithValue("@L", CurrentUserId);

        con.Open();
        using (SqlDataReader r = cmd.ExecuteReader())
        {
          if (!r.Read())
          {
            HideGradePanel();
            lblLeftMsg.Text = "You can't access that submission.";
            return;
          }

          CurrentSubmissionId = sid;
          lblSid.Text = Convert.ToString(r["SubmissionId"], CultureInfo.InvariantCulture);
          lblStudent.Text = Convert.ToString(r["StudentId"], CultureInfo.InvariantCulture);
        }
      }

      AutoGradeMcqAnswers(sid);
      ShowGradePanel();
      BindAnswers(sid);
      lblRightMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblRightMsg.Text = "MCQ answers were auto-graded. Save marks only for text answers.";
    }
    catch (Exception ex)
    {
      Trace.Warn("Grade", "Failed to open submission.", ex);
      HideGradePanel();
      lblLeftMsg.Text = "We couldn't open that submission right now. Please try again.";
    }
  }

  protected void gvAnswers_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName != "SAVE")
    {
      return;
    }

    int answerId;
    if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out answerId))
    {
      lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblRightMsg.Text = "Invalid answer selection.";
      return;
    }

    foreach (System.Web.UI.WebControls.GridViewRow row in gvAnswers.Rows)
    {
      var hf = row.FindControl("hfAnswerId") as System.Web.UI.WebControls.HiddenField;
      if (hf == null || hf.Value != answerId.ToString(CultureInfo.InvariantCulture))
      {
        continue;
      }

      var txt = row.FindControl("txtAward") as System.Web.UI.WebControls.TextBox;
      SaveAwardedMarks(answerId, txt == null ? string.Empty : txt.Text);
      break;
    }

    if (CurrentSubmissionId > 0)
    {
      BindAnswers(CurrentSubmissionId);
    }
  }

  private void SaveAwardedMarks(int answerId, string rawValue)
  {
    try
    {
      int maxMarks;
      string questionType;
      int autoMarks;

      if (!TryLoadAnswerContext(answerId, out maxMarks, out questionType, out autoMarks))
      {
        lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
        lblRightMsg.Text = "You can't update that answer.";
        return;
      }

      int marksToSave;
      if (string.Equals(questionType, "MCQ", StringComparison.OrdinalIgnoreCase))
      {
        marksToSave = autoMarks;
        lblRightMsg.ForeColor = System.Drawing.Color.LightGreen;
        lblRightMsg.Text = "MCQ answers are auto-graded. The saved mark was recalculated automatically.";
      }
      else
      {
        int parsedAward;
        if (!int.TryParse((rawValue ?? string.Empty).Trim(), out parsedAward))
        {
          lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
          lblRightMsg.Text = "Enter a whole number for awarded marks.";
          return;
        }

        if (parsedAward < 0 || parsedAward > maxMarks)
        {
          lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
          lblRightMsg.Text = "Awarded marks must be between 0 and " + maxMarks.ToString(CultureInfo.InvariantCulture) + ".";
          return;
        }

        marksToSave = parsedAward;
        lblRightMsg.ForeColor = System.Drawing.Color.LightGreen;
        lblRightMsg.Text = "Marks saved.";
      }

      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        UPDATE sa
        SET sa.MarksAwarded = @M
        FROM dbo.SubmissionAnswer sa
        INNER JOIN dbo.AssessmentSubmission s ON s.SubmissionId = sa.SubmissionId
        INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
        WHERE sa.AnswerId = @A
          AND (@IsAdmin = 1 OR a.LecturerId = @L);", con))
      {
        cmd.Parameters.AddWithValue("@M", marksToSave);
        cmd.Parameters.AddWithValue("@A", answerId);
        cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
        cmd.Parameters.AddWithValue("@L", CurrentUserId);
        con.Open();

        if (cmd.ExecuteNonQuery() == 0)
        {
          lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
          lblRightMsg.Text = "You can't update that answer.";
        }
      }
    }
    catch (Exception ex)
    {
      Trace.Warn("Grade", "Failed to save answer marks.", ex);
      lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblRightMsg.Text = "We couldn't save that mark right now. Please try again.";
    }
  }

  private bool TryLoadAnswerContext(int answerId, out int maxMarks, out string questionType, out int autoMarks)
  {
    maxMarks = 0;
    questionType = null;
    autoMarks = 0;

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT TOP 1
        q.Marks,
        q.QuestionType,
        CASE WHEN q.QuestionType = 'MCQ' AND qo.IsCorrect = 1 THEN q.Marks ELSE 0 END AS AutoMarks
      FROM dbo.SubmissionAnswer sa
      INNER JOIN dbo.AssessmentSubmission s ON s.SubmissionId = sa.SubmissionId
      INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
      INNER JOIN dbo.Question q ON q.QuestionId = sa.QuestionId
      LEFT JOIN dbo.QuestionOption qo
        ON qo.OptionId = sa.SelectedOptionId
       AND qo.QuestionId = q.QuestionId
      WHERE sa.AnswerId = @A
        AND (@IsAdmin = 1 OR a.LecturerId = @L);", con))
    {
      cmd.Parameters.AddWithValue("@A", answerId);
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@L", CurrentUserId);
      con.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        if (!reader.Read())
        {
          return false;
        }

        maxMarks = Convert.ToInt32(reader["Marks"], CultureInfo.InvariantCulture);
        questionType = Convert.ToString(reader["QuestionType"], CultureInfo.InvariantCulture);
        autoMarks = Convert.ToInt32(reader["AutoMarks"], CultureInfo.InvariantCulture);
        return true;
      }
    }
  }

  private void AutoGradeMcqAnswers(int submissionId)
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      UPDATE sa
      SET sa.MarksAwarded = CASE WHEN qo.IsCorrect = 1 THEN q.Marks ELSE 0 END
      FROM dbo.SubmissionAnswer sa
      INNER JOIN dbo.AssessmentSubmission s ON s.SubmissionId = sa.SubmissionId
      INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
      INNER JOIN dbo.Question q ON q.QuestionId = sa.QuestionId
      LEFT JOIN dbo.QuestionOption qo
        ON qo.OptionId = sa.SelectedOptionId
       AND qo.QuestionId = q.QuestionId
      WHERE sa.SubmissionId = @S
        AND q.QuestionType = 'MCQ'
        AND (@IsAdmin = 1 OR a.LecturerId = @L);", con))
    {
      cmd.Parameters.AddWithValue("@S", submissionId);
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@L", CurrentUserId);
      con.Open();
      cmd.ExecuteNonQuery();
    }
  }

  protected void RecalculateTotal(object sender, EventArgs e)
  {
    int sid = CurrentSubmissionId;
    if (sid == 0)
    {
      return;
    }

    try
    {
      AutoGradeMcqAnswers(sid);

      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        UPDATE s
        SET s.TotalScore = totals.TotalMarks
        FROM dbo.AssessmentSubmission s
        INNER JOIN dbo.Assessment a ON a.AssessmentId = s.AssessmentId
        CROSS APPLY (
          SELECT ISNULL(SUM(ISNULL(sa.MarksAwarded, 0)), 0) AS TotalMarks
          FROM dbo.SubmissionAnswer sa
          WHERE sa.SubmissionId = s.SubmissionId
        ) totals
        WHERE s.SubmissionId = @S
          AND (@IsAdmin = 1 OR a.LecturerId = @L);", con))
      {
        cmd.Parameters.AddWithValue("@S", sid);
        cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
        cmd.Parameters.AddWithValue("@L", CurrentUserId);
        con.Open();

        if (cmd.ExecuteNonQuery() == 0)
        {
          lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
          lblRightMsg.Text = "You can't update that submission.";
          return;
        }
      }

      lblRightMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblRightMsg.Text = "Total score recalculated and saved.";
      BindSubmissions();
      BindAnswers(sid);
    }
    catch (Exception ex)
    {
      Trace.Warn("Grade", "Failed to recalculate submission total.", ex);
      lblRightMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblRightMsg.Text = "We couldn't recalculate the total score right now. Please try again.";
    }
  }

</script>
