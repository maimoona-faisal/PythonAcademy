<%@ Page Title="Manage Options" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <h2>Manage Options</h2>
  <p class="muted">Add MCQ options for this question.</p>

  <div class="layout-2">

    <!-- LEFT: ADD OPTION -->
    <div class="card">
      <h3 style="margin-top:0;">Add Option</h3>

      <div class="field">
        <label>Option Text</label>
        <asp:TextBox ID="txtOpt" runat="server" CssClass="input" />
      </div>

      <div class="checkrow" style="margin-top:10px;">
        <asp:CheckBox ID="chkCorrect" runat="server" />
        <span>Mark as correct</span>
      </div>

      <div class="actions">
        <asp:Button ID="btnAdd" runat="server" Text="Add Option"
            CssClass="btn btn-primary" OnClick="AddOption" />
        <asp:Button ID="btnBack" runat="server" Text="Back"
            CssClass="btn btn-outline" OnClick="Back" CausesValidation="false" />
      </div>

      <asp:Label ID="lblMsg" runat="server" CssClass="muted" />
    </div>

    <!-- RIGHT: LIST OPTIONS -->
    <div class="card">
      <h3 style="margin-top:0;">Options</h3>
      <p class="muted">
        QuestionId: <asp:Label ID="lblQid" runat="server" />
      </p>

      <asp:GridView ID="gvOpt" runat="server" CssClass="grid"
          AutoGenerateColumns="False"
          OnRowCommand="gvOpt_RowCommand"
          EmptyDataText="No options added yet.">

        <Columns>
          <asp:BoundField DataField="OptionText" HeaderText="Option" />
          <asp:CheckBoxField DataField="IsCorrect" HeaderText="Correct" />

          <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
              <asp:LinkButton runat="server"
                  CssClass="btn btn-outline"
                  CommandName="SETCORRECT"
                  CommandArgument='<%# Eval("OptionId") %>'>
                Set Correct
              </asp:LinkButton>

              <asp:LinkButton runat="server"
                  CssClass="btn btn-outline"
                  CommandName="DEL"
                  CommandArgument='<%# Eval("OptionId") %>'
                  OnClientClick="return confirm('Delete this option?');">
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

  private int Qid
  {
    get
    {
      int id;
      if (!int.TryParse(Request.QueryString["qid"], out id)) return 0;
      return id;
    }
  }

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
      lblQid.Text = Qid.ToString();
      BindOptions();
    }
  }

  private void BindOptions()
  {
    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      SELECT OptionId, QuestionId, OptionText, IsCorrect
      FROM dbo.QuestionOption
      WHERE QuestionId = @Q
      ORDER BY OptionId DESC;
    ", con))
    {
      cmd.Parameters.AddWithValue("@Q", Qid);
      con.Open();
      gvOpt.DataSource = cmd.ExecuteReader();
      gvOpt.DataBind();
    }
  }

  protected void AddOption(object sender, EventArgs e)
  {
    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string text = (txtOpt.Text ?? "").Trim();
    if (string.IsNullOrWhiteSpace(text))
    {
      lblMsg.Text = "Option text is required.";
      return;
    }

    bool makeCorrect = chkCorrect.Checked;

    using (SqlConnection con = new SqlConnection(Cs))
    {
      con.Open();

      // Only ONE correct option per question
      if (makeCorrect)
      {
        using (SqlCommand unset = new SqlCommand(
          "UPDATE dbo.QuestionOption SET IsCorrect=0 WHERE QuestionId=@Q", con))
        {
          unset.Parameters.AddWithValue("@Q", Qid);
          unset.ExecuteNonQuery();
        }
      }

      using (SqlCommand ins = new SqlCommand(@"
        INSERT INTO dbo.QuestionOption (QuestionId, OptionText, IsCorrect)
        VALUES (@Q, @T, @C);
      ", con))
      {
        ins.Parameters.AddWithValue("@Q", Qid);
        ins.Parameters.AddWithValue("@T", text);
        ins.Parameters.AddWithValue("@C", makeCorrect);
        ins.ExecuteNonQuery();
      }
    }

    lblMsg.ForeColor = System.Drawing.Color.LightGreen;
    lblMsg.Text = "Option added.";
    txtOpt.Text = "";
    chkCorrect.Checked = false;

    BindOptions();
  }

  protected void gvOpt_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    int optId = Convert.ToInt32(e.CommandArgument);

    if (e.CommandName == "DEL")
    {
      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.QuestionOption WHERE OptionId=@O", con))
      {
        cmd.Parameters.AddWithValue("@O", optId);
        con.Open();
        cmd.ExecuteNonQuery();
      }
      BindOptions();
    }

    if (e.CommandName == "SETCORRECT")
    {
      using (SqlConnection con = new SqlConnection(Cs))
      {
        con.Open();

        using (SqlCommand unset = new SqlCommand(
          "UPDATE dbo.QuestionOption SET IsCorrect=0 WHERE QuestionId=@Q", con))
        {
          unset.Parameters.AddWithValue("@Q", Qid);
          unset.ExecuteNonQuery();
        }

        using (SqlCommand set = new SqlCommand(
          "UPDATE dbo.QuestionOption SET IsCorrect=1 WHERE OptionId=@O", con))
        {
          set.Parameters.AddWithValue("@O", optId);
          set.ExecuteNonQuery();
        }
      }

      BindOptions();
    }
  }

  protected void Back(object sender, EventArgs e)
  {
    // go back to ManageQuestions for same assessment
    Response.Redirect("ManageQuestions.aspx?aid=" + Aid);
  }

</script>
