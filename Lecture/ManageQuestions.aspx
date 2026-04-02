<%@ Page Title="Manage Questions" Language="C#" MasterPageFile="~/Site.Master" %>
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
          --panel-bg: rgba(13, 25, 48, 0.85);
          --panel-border: rgba(255, 255, 255, 0.1);
          --muted-text: #8fa4c4;
      }

      .admin-shell {
          max-width: 1100px;
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
      
      .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }

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
      .badge-type { padding: 4px 10px; border-radius: 8px; font-size: 0.8rem; font-weight: 700; border: 1px solid transparent; }
      .badge-mcq { background: rgba(181, 123, 255, 0.1); color: var(--accent-purple); border-color: rgba(181, 123, 255, 0.3); }
      .badge-text { background: rgba(0, 216, 255, 0.1); color: var(--accent-cyan); border-color: rgba(0, 216, 255, 0.3); }

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

      @media (max-width: 900px) {
          .layout-2 { grid-template-columns: 1fr; }
      }
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Manage Questions</h2>
      <p class="page-subtitle">Add and configure questions for this assessment.</p>

      <div class="layout-2">

        <div class="glass-panel">
          <h3>Add Question</h3>

          <label class="form-label">Question Text</label>
          <asp:TextBox ID="txtQuestion" runat="server" CssClass="neon-input" TextMode="MultiLine" Rows="4" Placeholder="Type your question here..." />

          <div class="form-grid">
            <div>
              <label class="form-label">Question Type</label>
              <asp:DropDownList ID="ddlQType" runat="server" CssClass="neon-input">
                <asp:ListItem Text="MCQ (Multiple Choice)" Value="MCQ" />
                <asp:ListItem Text="Text (Written Answer)" Value="Text" />
              </asp:DropDownList>
            </div>

            <div>
              <label class="form-label">Marks Awarded</label>
              <asp:TextBox ID="txtMarks" runat="server" CssClass="neon-input" Text="1" />
            </div>
          </div>

          <div class="btn-actions">
            <asp:Button ID="btnAdd" runat="server" Text="Add Question" CssClass="btn-cyan" OnClick="AddQuestion" style="flex: 1;" />
            <a class="btn-outline-clear" href="CreateAssessment.aspx">Back</a>
          </div>

          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />
        </div>

        <div class="glass-panel">
          <h3>Current Questions</h3>
          <p style="color: var(--muted-text); font-size: 0.85rem; margin-top: -10px; margin-bottom: 20px;">
            Assessment ID: <span style="color: white; font-weight: bold;"><asp:Label ID="lblAid" runat="server" /></span>
          </p>

          <div style="overflow-x: auto;">
              <asp:GridView ID="gvQ" runat="server" CssClass="tech-table"
                  AutoGenerateColumns="False"
                  GridLines="None"
                  OnRowCommand="gvQ_RowCommand"
                  EmptyDataText="<div style='padding: 20px; text-align: center; color: #8fa4c4; font-style: italic;'>No questions added yet.</div>">

                <Columns>
                  <asp:BoundField DataField="QuestionText" HeaderText="Question" ItemStyle-Width="40%" />
                  
                  <asp:TemplateField HeaderText="Type">
                      <ItemTemplate>
                          <span class='<%# Eval("QuestionType").ToString() == "MCQ" ? "badge-type badge-mcq" : "badge-type badge-text" %>'>
                              <%# Eval("QuestionType") %>
                          </span>
                      </ItemTemplate>
                  </asp:TemplateField>
                  
                  <asp:TemplateField HeaderText="Marks">
                      <ItemTemplate>
                          <span style="color: var(--accent-lime); font-weight: bold;"><%# Eval("Marks") %> XP</span>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                      <div style="display: flex; gap: 8px;">
                          <asp:Panel runat="server" Visible='<%# Eval("QuestionType").ToString() == "MCQ" %>'>
                              <a class="action-link btn-options" href='<%# "ManageOptions.aspx?qid=" + Eval("QuestionId") + "&aid=" + Eval("AssessmentId") %>'>
                                Options
                              </a>
                          </asp:Panel>

                          <asp:LinkButton runat="server"
                              CssClass="action-link btn-del"
                              CommandName="DEL"
                              CommandArgument='<%# Eval("QuestionId") %>'
                              OnClientClick="return confirm('Delete this question? Questions with submitted answers cannot be deleted.');">
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

  private static readonly ISet<string> AllowedQuestionTypes =
    new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "MCQ", "Text" };

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

  private int CurrentAssessmentId
  {
    get
    {
      object value = ViewState["Aid"];
      return value == null ? 0 : Convert.ToInt32(value, CultureInfo.InvariantCulture);
    }
    set { ViewState["Aid"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!EnsureLecturerAccess())
    {
      return;
    }

    if (!EnsureAssessmentContext())
    {
      return;
    }

    if (!IsPostBack)
    {
      BindQuestions();
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

  private bool EnsureAssessmentContext()
  {
    if (CurrentAssessmentId > 0)
    {
      lblAid.Text = CurrentAssessmentId.ToString(CultureInfo.InvariantCulture);
      return true;
    }

    int assessmentId;
    if (!int.TryParse(Request.QueryString["aid"], out assessmentId) || assessmentId <= 0)
    {
      BlockPage("Invalid assessment selection.");
      return false;
    }

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT AssessmentId
      FROM dbo.Assessment
      WHERE AssessmentId = @Aid
        AND (@IsAdmin = 1 OR LecturerId = @LecturerId);", con))
    {
      cmd.Parameters.AddWithValue("@Aid", assessmentId);
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);
      con.Open();

      object result = cmd.ExecuteScalar();
      if (result == null)
      {
        BlockPage("You can only manage questions for your own assessments unless you are an admin.");
        return false;
      }
    }

    CurrentAssessmentId = assessmentId;
    lblAid.Text = assessmentId.ToString(CultureInfo.InvariantCulture);
    return true;
  }

  private void BlockPage(string message)
  {
    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
    lblMsg.Text = message;
    lblAid.Text = "?";
    btnAdd.Enabled = false;
    gvQ.Visible = false;
  }

  private void BindQuestions()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT QuestionId, AssessmentId, QuestionText, QuestionType, Marks
      FROM dbo.Question
      WHERE AssessmentId = @Aid
      ORDER BY QuestionId DESC;", con))
    {
      cmd.Parameters.AddWithValue("@Aid", CurrentAssessmentId);
      con.Open();
      gvQ.DataSource = cmd.ExecuteReader();
      gvQ.DataBind();
    }
  }

  protected void AddQuestion(object sender, EventArgs e)
  {
    if (!EnsureAssessmentContext())
    {
      return;
    }

    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string text = (txtQuestion.Text ?? string.Empty).Trim();
    string questionType = ddlQType.SelectedValue;
    int marks;

    if (string.IsNullOrWhiteSpace(text))
    {
      lblMsg.Text = "Question text is required.";
      return;
    }

    if (!AllowedQuestionTypes.Contains(questionType))
    {
      lblMsg.Text = "Please choose a valid question type.";
      return;
    }

    if (!int.TryParse((txtMarks.Text ?? string.Empty).Trim(), out marks) || marks <= 0 || marks > 1000)
    {
      lblMsg.Text = "Marks must be a whole number between 1 and 1000.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        INSERT INTO dbo.Question (AssessmentId, QuestionText, QuestionType, Marks)
        SELECT @Aid, @Text, @Type, @Marks
        WHERE EXISTS (
          SELECT 1
          FROM dbo.Assessment
          WHERE AssessmentId = @Aid
            AND (@IsAdmin = 1 OR LecturerId = @LecturerId)
        );", con))
      {
        cmd.Parameters.AddWithValue("@Aid", CurrentAssessmentId);
        cmd.Parameters.AddWithValue("@Text", text);
        cmd.Parameters.AddWithValue("@Type", questionType);
        cmd.Parameters.AddWithValue("@Marks", marks);
        cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
        cmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);

        con.Open();
        if (cmd.ExecuteNonQuery() == 0)
        {
          lblMsg.Text = "You can only add questions to assessments that you own unless you are an admin.";
          return;
        }
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Question added.";
      txtQuestion.Text = string.Empty;
      txtMarks.Text = "1";
      BindQuestions();
    }
    catch (Exception ex)
    {
      Trace.Warn("ManageQuestions", "Failed to add question.", ex);
      lblMsg.Text = "We couldn't add that question right now. Please try again.";
    }
  }

  protected void gvQ_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName != "DEL")
    {
      return;
    }

    int qid;
    if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out qid))
    {
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "Invalid question selection.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      {
        con.Open();

        using (SqlCommand answersCmd = new SqlCommand(@"
          SELECT COUNT(1)
          FROM dbo.SubmissionAnswer sa
          INNER JOIN dbo.Question q ON q.QuestionId = sa.QuestionId
          INNER JOIN dbo.Assessment a ON a.AssessmentId = q.AssessmentId
          WHERE q.QuestionId = @Q
            AND q.AssessmentId = @Aid
            AND (@IsAdmin = 1 OR a.LecturerId = @LecturerId);", con))
        {
          answersCmd.Parameters.AddWithValue("@Q", qid);
          answersCmd.Parameters.AddWithValue("@Aid", CurrentAssessmentId);
          answersCmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
          answersCmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);

          if (Convert.ToInt32(answersCmd.ExecuteScalar(), CultureInfo.InvariantCulture) > 0)
          {
            lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
            lblMsg.Text = "Questions with student answers cannot be deleted.";
            return;
          }
        }

        using (SqlTransaction tx = con.BeginTransaction())
        {
          using (SqlCommand delOpt = new SqlCommand(@"
            DELETE qo
            FROM dbo.QuestionOption qo
            INNER JOIN dbo.Question q ON q.QuestionId = qo.QuestionId
            INNER JOIN dbo.Assessment a ON a.AssessmentId = q.AssessmentId
            WHERE q.QuestionId = @Q
              AND q.AssessmentId = @Aid
              AND (@IsAdmin = 1 OR a.LecturerId = @LecturerId);", con, tx))
          {
            delOpt.Parameters.AddWithValue("@Q", qid);
            delOpt.Parameters.AddWithValue("@Aid", CurrentAssessmentId);
            delOpt.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            delOpt.Parameters.AddWithValue("@LecturerId", CurrentUserId);
            delOpt.ExecuteNonQuery();
          }

          using (SqlCommand delQ = new SqlCommand(@"
            DELETE q
            FROM dbo.Question q
            INNER JOIN dbo.Assessment a ON a.AssessmentId = q.AssessmentId
            WHERE q.QuestionId = @Q
              AND q.AssessmentId = @Aid
              AND (@IsAdmin = 1 OR a.LecturerId = @LecturerId);", con, tx))
          {
            delQ.Parameters.AddWithValue("@Q", qid);
            delQ.Parameters.AddWithValue("@Aid", CurrentAssessmentId);
            delQ.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            delQ.Parameters.AddWithValue("@LecturerId", CurrentUserId);

            if (delQ.ExecuteNonQuery() == 0)
            {
              tx.Rollback();
              lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
              lblMsg.Text = "You can only delete questions from assessments that you own unless you are an admin.";
              return;
            }
          }

          tx.Commit();
        }
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Question deleted.";
      BindQuestions();
    }
    catch (Exception ex)
    {
      Trace.Warn("ManageQuestions", "Failed to delete question.", ex);
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "We couldn't delete that question right now. Please try again.";
    }
  }

</script>
