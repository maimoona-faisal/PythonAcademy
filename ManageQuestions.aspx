<%@ Page Title="Manage Questions" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <h2>Manage Questions</h2>
  <p class="muted">Add questions for this assessment.</p>

  <div class="layout-2">

    <!-- LEFT: ADD QUESTION -->
    <div class="card">
      <h3 style="margin-top:0;">Add Question</h3>

      <div class="field">
        <label>Question Text</label>
        <asp:TextBox ID="txtQuestion" runat="server" CssClass="input"
            TextMode="MultiLine" Rows="4" />
      </div>

      <div class="form-grid">
        <div class="field">
          <label>Question Type</label>
          <asp:DropDownList ID="ddlQType" runat="server" CssClass="input">
            <asp:ListItem Text="MCQ" Value="MCQ" />
            <asp:ListItem Text="Text" Value="Text" />
          </asp:DropDownList>
        </div>

        <div class="field">
          <label>Marks</label>
          <asp:TextBox ID="txtMarks" runat="server" CssClass="input" Text="1" />
        </div>
      </div>

      <div class="actions">
        <asp:Button ID="btnAdd" runat="server" Text="Add Question"
            CssClass="btn btn-primary" OnClick="AddQuestion" />
        <a class="btn btn-outline" href="Assessment.aspx">Back</a>
      </div>

      <asp:Label ID="lblMsg" runat="server" CssClass="muted" />
    </div>

    <!-- RIGHT: LIST QUESTIONS -->
    <div class="card">
      <h3 style="margin-top:0;">Questions</h3>
      <p class="muted">AssessmentId: <asp:Label ID="lblAid" runat="server" /></p>

      <asp:GridView ID="gvQ" runat="server" CssClass="grid"
          AutoGenerateColumns="False"
          OnRowCommand="gvQ_RowCommand"
          EmptyDataText="No questions added yet.">

        <Columns>
          <asp:BoundField DataField="QuestionText" HeaderText="Question" />
          <asp:BoundField DataField="QuestionType" HeaderText="Type" />
          <asp:BoundField DataField="Marks" HeaderText="Marks" />

          <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
              <a class="btn btn-outline"
                 href='<%# "ManageOptions.aspx?qid=" + Eval("QuestionId") + "&aid=" + Eval("AssessmentId") %>'>
                Options
              </a>

              <asp:LinkButton runat="server"
                  CssClass="btn btn-outline"
                  CommandName="DEL"
                  CommandArgument='<%# Eval("QuestionId") %>'
                  OnClientClick="return confirm('Delete this question? Options will also delete if FK cascade is set.');">
                Delete
              </asp:LinkButton>
            </ItemTemplate>
          </asp:TemplateField>
        </Columns>

      </asp:GridView>
    </div>

  </div>

</asp:Content>

<script runat="server">

  private string Cs => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

  private int Aid
  {
    get
    {
      int id;
      if (!int.TryParse(Request.QueryString["aid"], out id)) return 0;
      return id;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      lblAid.Text = Aid.ToString();
      BindQuestions();
    }
  }

  private void BindQuestions()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT QuestionId, AssessmentId, QuestionText, QuestionType, Marks
      FROM dbo.Question
      WHERE AssessmentId = @Aid
      ORDER BY QuestionId DESC;
    ", con))
    {
      cmd.Parameters.AddWithValue("@Aid", Aid);
      con.Open();
      gvQ.DataSource = cmd.ExecuteReader();
      gvQ.DataBind();
    }
  }

  protected void AddQuestion(object sender, EventArgs e)
  {
    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string text = (txtQuestion.Text ?? "").Trim();
    if (string.IsNullOrWhiteSpace(text))
    {
      lblMsg.Text = "Question text is required.";
      return;
    }

    int marks = 1;
    int.TryParse((txtMarks.Text ?? "1").Trim(), out marks);

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      INSERT INTO dbo.Question (AssessmentId, QuestionText, QuestionType, Marks)
      VALUES (@Aid, @Text, @Type, @Marks);
    ", con))
    {
      cmd.Parameters.AddWithValue("@Aid", Aid);
      cmd.Parameters.AddWithValue("@Text", text);
      cmd.Parameters.AddWithValue("@Type", ddlQType.SelectedValue);
      cmd.Parameters.AddWithValue("@Marks", marks);

      con.Open();
      cmd.ExecuteNonQuery();
    }

    lblMsg.ForeColor = System.Drawing.Color.LightGreen;
    lblMsg.Text = "Question added.";
    txtQuestion.Text = "";
    txtMarks.Text = "1";

    BindQuestions();
  }

  protected void gvQ_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName == "DEL")
    {
      int qid = Convert.ToInt32(e.CommandArgument);

      using (SqlConnection con = new SqlConnection(Cs))
      {
        con.Open();

        // If you have FK cascade from QuestionOption -> Question, this isn't needed,
        // but it's safe even without FK.
        using (SqlCommand delOpt = new SqlCommand("DELETE FROM dbo.QuestionOption WHERE QuestionId=@Q", con))
        {
          delOpt.Parameters.AddWithValue("@Q", qid);
          delOpt.ExecuteNonQuery();
        }

        using (SqlCommand delQ = new SqlCommand("DELETE FROM dbo.Question WHERE QuestionId=@Q", con))
        {
          delQ.Parameters.AddWithValue("@Q", qid);
          delQ.ExecuteNonQuery();
        }
      }

      BindQuestions();
    }
  }

</script>

