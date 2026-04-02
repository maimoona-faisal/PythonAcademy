<%@ Page Title="Manage Options" Language="C#" MasterPageFile="~/Site.Master" %>
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
          --panel-bg: rgba(13, 25, 48, 0.85);
          --panel-border: rgba(255, 255, 255, 0.1);
          --muted-text: #8fa4c4;
      }

      .admin-shell {
          max-width: 1000px;
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
          border-radius: 50px; cursor: pointer; transition: 0.3s; 
          box-shadow: 0 6px 15px rgba(0, 216, 255, 0.25); 
      }
      .btn-cyan:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 216, 255, 0.4); }
      
      .btn-outline-clear { 
          background: transparent; color: white; border: 1px solid rgba(255,255,255,0.2); 
          padding: 12px 24px; font-size: 1rem; font-weight: 600; border-radius: 50px; 
          cursor: pointer; transition: 0.3s; text-decoration: none;
      }
      .btn-outline-clear:hover { background: rgba(255,255,255,0.1); border-color: white; }

      /* Grid / Table Styles */
      .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
      .tech-table th { padding: 0 16px 12px; text-align: left; color: var(--muted-text); font-size: 0.82rem; letter-spacing: 0.08em; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); }
      .tech-table td { padding: 16px; color: #ffffff; background: rgba(255,255,255,0.03); border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle;}
      .tech-table td:first-child { border-radius: 12px 0 0 12px; }
      .tech-table td:last-child { border-radius: 0 12px 12px 0; }
      .tech-table tr:hover td { background: rgba(255, 255, 255, 0.06); }

      /* Action Links in Grid */
      .action-link {
          display: inline-flex; align-items: center; justify-content: center;
          padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-decoration: none;
          transition: 0.2s ease; border: 1px solid transparent; cursor: pointer;
      }
      .btn-correct { border-color: rgba(20, 241, 149, 0.5); color: var(--accent-lime); background: transparent; }
      .btn-correct:hover { background: rgba(20, 241, 149, 0.1); }
      .btn-del { border-color: rgba(255, 123, 123, 0.5); color: var(--accent-red); background: transparent; }
      .btn-del:hover { background: rgba(255, 123, 123, 0.1); }

      /* Custom message styling */
      .msg-banner { display: block; margin-top: 15px; font-weight: 600; font-size: 0.95rem; }

      @media (max-width: 800px) {
          .layout-2 { grid-template-columns: 1fr; }
      }
  </style>

  <div class="admin-shell">
      <h2 class="page-title">Manage Options</h2>
      <p class="page-subtitle">Add MCQ options for this question.</p>

      <div class="layout-2">

        <div class="glass-panel">
          <h3>Add Option</h3>

          <label class="form-label">Option Text</label>
          <asp:TextBox ID="txtOpt" runat="server" CssClass="neon-input" Placeholder="Type answer option here..." />

          <div class="checkrow">
            <asp:CheckBox ID="chkCorrect" runat="server" />
            <label for="chkCorrect" style="cursor: pointer;">Mark as correct answer</label>
          </div>

          <div class="btn-actions">
            <asp:Button ID="btnAdd" runat="server" Text="Add Option" CssClass="btn-cyan" OnClick="AddOption" />
            <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="btn-outline-clear" OnClick="Back" CausesValidation="false" />
          </div>

          <asp:Label ID="lblMsg" runat="server" CssClass="msg-banner" />
        </div>

        <div class="glass-panel">
          <h3>Current Options</h3>
          <p style="color: var(--muted-text); font-size: 0.85rem; margin-top: -10px; margin-bottom: 20px;">
            Question ID: <span style="color: white; font-weight: bold;"><asp:Label ID="lblQid" runat="server" /></span>
          </p>

          <div style="overflow-x: auto;">
              <asp:GridView ID="gvOpt" runat="server" CssClass="tech-table"
                  AutoGenerateColumns="False"
                  GridLines="None"
                  OnRowCommand="gvOpt_RowCommand"
                  EmptyDataText="<div style='padding: 20px; text-align: center; color: #8fa4c4; font-style: italic;'>No options added yet.</div>">

                <Columns>
                  <asp:BoundField DataField="OptionText" HeaderText="Option Text" />
                  
                  <asp:TemplateField HeaderText="Status">
                      <ItemTemplate>
                          <span style='<%# Convert.ToBoolean(Eval("IsCorrect")) ? "color: #14f195; font-weight: bold;" : "color: #8fa4c4;" %>'>
                              <%# Convert.ToBoolean(Eval("IsCorrect")) ? "★ Correct" : "Incorrect" %>
                          </span>
                      </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                      <div style="display: flex; gap: 8px;">
                          <asp:LinkButton runat="server"
                              CssClass="action-link btn-correct"
                              CommandName="SETCORRECT"
                              CommandArgument='<%# Eval("OptionId") %>'>
                            Set Correct
                          </asp:LinkButton>

                          <asp:LinkButton runat="server"
                              CssClass="action-link btn-del"
                              CommandName="DEL"
                              CommandArgument='<%# Eval("OptionId") %>'
                              OnClientClick="return confirm('Delete this option? Submitted attempts will block this action.');">
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

  private int CurrentQuestionId
  {
    get
    {
      object value = ViewState["Qid"];
      return value == null ? 0 : Convert.ToInt32(value, CultureInfo.InvariantCulture);
    }
    set { ViewState["Qid"] = value; }
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

  private string CurrentQuestionType
  {
    get { return Convert.ToString(ViewState["QuestionType"], CultureInfo.InvariantCulture); }
    set { ViewState["QuestionType"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!EnsureLecturerAccess())
    {
      return;
    }

    if (!EnsureQuestionContext())
    {
      return;
    }

    if (!IsPostBack)
    {
      BindOptions();
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

  private bool EnsureQuestionContext()
  {
    if (CurrentQuestionId > 0 && CurrentAssessmentId > 0 && !string.IsNullOrWhiteSpace(CurrentQuestionType))
    {
      lblQid.Text = CurrentQuestionId.ToString(CultureInfo.InvariantCulture);
      return true;
    }

    int questionId;
    int assessmentId;
    if (!int.TryParse(Request.QueryString["qid"], out questionId) || questionId <= 0 ||
        !int.TryParse(Request.QueryString["aid"], out assessmentId) || assessmentId <= 0)
    {
      BlockPage("Invalid question selection.");
      return false;
    }

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT q.QuestionId, q.AssessmentId, q.QuestionType
      FROM dbo.Question q
      INNER JOIN dbo.Assessment a ON a.AssessmentId = q.AssessmentId
      WHERE q.QuestionId = @Q
        AND q.AssessmentId = @A
        AND (@IsAdmin = 1 OR a.LecturerId = @LecturerId);", con))
    {
      cmd.Parameters.AddWithValue("@Q", questionId);
      cmd.Parameters.AddWithValue("@A", assessmentId);
      cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
      cmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);
      con.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        if (!reader.Read())
        {
          BlockPage("You can only manage options for your own MCQ questions unless you are an admin.");
          return false;
        }

        CurrentQuestionId = Convert.ToInt32(reader["QuestionId"], CultureInfo.InvariantCulture);
        CurrentAssessmentId = Convert.ToInt32(reader["AssessmentId"], CultureInfo.InvariantCulture);
        CurrentQuestionType = Convert.ToString(reader["QuestionType"], CultureInfo.InvariantCulture);
      }
    }

    lblQid.Text = CurrentQuestionId.ToString(CultureInfo.InvariantCulture);

    if (!string.Equals(CurrentQuestionType, "MCQ", StringComparison.OrdinalIgnoreCase))
    {
      BlockPage("Only MCQ questions can have answer options.");
      return false;
    }

    return true;
  }

  private void BlockPage(string message)
  {
    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
    lblMsg.Text = message;
    btnAdd.Enabled = false;
    gvOpt.Visible = false;
  }

  private void BindOptions()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT OptionId, QuestionId, OptionText, IsCorrect
      FROM dbo.QuestionOption
      WHERE QuestionId = @Q
      ORDER BY OptionId DESC;", con))
    {
      cmd.Parameters.AddWithValue("@Q", CurrentQuestionId);
      con.Open();
      gvOpt.DataSource = cmd.ExecuteReader();
      gvOpt.DataBind();
    }
  }

  protected void AddOption(object sender, EventArgs e)
  {
    if (!EnsureQuestionContext())
    {
      return;
    }

    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string text = (txtOpt.Text ?? string.Empty).Trim();
    bool makeCorrect = chkCorrect.Checked;

    if (string.IsNullOrWhiteSpace(text))
    {
      lblMsg.Text = "Option text is required.";
      return;
    }

    if (text.Length > 500)
    {
      lblMsg.Text = "Option text must be 500 characters or fewer.";
      return;
    }

    if (QuestionHasSubmittedAttempts())
    {
      lblMsg.Text = "You can't change options after students have submitted answers for this question.";
      return;
    }

    try
    {
      using (SqlConnection con = new SqlConnection(Cs))
      {
        con.Open();

        using (SqlTransaction tx = con.BeginTransaction())
        {
          if (makeCorrect)
          {
            using (SqlCommand unset = new SqlCommand(
              "UPDATE dbo.QuestionOption SET IsCorrect = 0 WHERE QuestionId = @Q", con, tx))
            {
              unset.Parameters.AddWithValue("@Q", CurrentQuestionId);
              unset.ExecuteNonQuery();
            }
          }

          using (SqlCommand ins = new SqlCommand(@"
            INSERT INTO dbo.QuestionOption (QuestionId, OptionText, IsCorrect)
            VALUES (@Q, @T, @C);", con, tx))
          {
            ins.Parameters.AddWithValue("@Q", CurrentQuestionId);
            ins.Parameters.AddWithValue("@T", text);
            ins.Parameters.AddWithValue("@C", makeCorrect);
            ins.ExecuteNonQuery();
          }

          tx.Commit();
        }
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Option added.";
      txtOpt.Text = string.Empty;
      chkCorrect.Checked = false;
      BindOptions();
    }
    catch (Exception ex)
    {
      Trace.Warn("ManageOptions", "Failed to add option.", ex);
      lblMsg.Text = "We couldn't add that option right now. Please try again.";
    }
  }

  protected void gvOpt_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    int optionId;
    if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out optionId))
    {
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "Invalid option selection.";
      return;
    }

    if (QuestionHasSubmittedAttempts())
    {
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "You can't change options after students have submitted answers for this question.";
      return;
    }

    try
    {
      if (e.CommandName == "DEL")
      {
        using (SqlConnection con = new SqlConnection(Cs))
        using (SqlCommand cmd = new SqlCommand(@"
          DELETE FROM dbo.QuestionOption
          WHERE OptionId = @O
            AND QuestionId = @Q;", con))
        {
          cmd.Parameters.AddWithValue("@O", optionId);
          cmd.Parameters.AddWithValue("@Q", CurrentQuestionId);
          con.Open();

          if (cmd.ExecuteNonQuery() == 0)
          {
            lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
            lblMsg.Text = "That option could not be found for this question.";
            return;
          }
        }

        lblMsg.ForeColor = System.Drawing.Color.LightGreen;
        lblMsg.Text = "Option deleted.";
        BindOptions();
      }
      else if (e.CommandName == "SETCORRECT")
      {
        using (SqlConnection con = new SqlConnection(Cs))
        {
          con.Open();

          using (SqlTransaction tx = con.BeginTransaction())
          {
            using (SqlCommand unset = new SqlCommand(
              "UPDATE dbo.QuestionOption SET IsCorrect = 0 WHERE QuestionId = @Q", con, tx))
            {
              unset.Parameters.AddWithValue("@Q", CurrentQuestionId);
              unset.ExecuteNonQuery();
            }

            using (SqlCommand set = new SqlCommand(@"
              UPDATE dbo.QuestionOption
              SET IsCorrect = 1
              WHERE OptionId = @O
                AND QuestionId = @Q;", con, tx))
            {
              set.Parameters.AddWithValue("@O", optionId);
              set.Parameters.AddWithValue("@Q", CurrentQuestionId);

              if (set.ExecuteNonQuery() == 0)
              {
                tx.Rollback();
                lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
                lblMsg.Text = "That option could not be found for this question.";
                return;
              }
            }

            tx.Commit();
          }
        }

        lblMsg.ForeColor = System.Drawing.Color.LightGreen;
        lblMsg.Text = "Correct option updated.";
        BindOptions();
      }
    }
    catch (Exception ex)
    {
      Trace.Warn("ManageOptions", "Failed to update option.", ex);
      lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
      lblMsg.Text = "We couldn't update that option right now. Please try again.";
    }
  }

  private bool QuestionHasSubmittedAttempts()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT COUNT(1)
      FROM dbo.SubmissionAnswer
      WHERE QuestionId = @Q;", con))
    {
      cmd.Parameters.AddWithValue("@Q", CurrentQuestionId);
      con.Open();
      return Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture) > 0;
    }
  }

  protected void Back(object sender, EventArgs e)
  {
    Response.Redirect("ManageQuestions.aspx?aid=" + CurrentAssessmentId.ToString(CultureInfo.InvariantCulture), false);
    Context.ApplicationInstance.CompleteRequest();
  }

</script>
