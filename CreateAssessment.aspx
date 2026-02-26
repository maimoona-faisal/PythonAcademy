<%@ Page Title="Create Assessment" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <h2>Create Assessment</h2>
  <p class="muted">Exercise / Quiz / Final Exam</p>

  <div class="layout-2">

    <!-- LEFT: FORM -->
    <div class="card">
      <h3 class="muted" style="margin-top:0;">New Assessment</h3>

      <div class="form-grid">
        <div class="field">
          <label>Title</label>
          <asp:TextBox ID="txtTitle" runat="server" CssClass="input" />
        </div>

        <div class="field">
          <label>Assessment Type</label>
          <asp:DropDownList ID="ddlType" runat="server" CssClass="input">
            <asp:ListItem Text="Exercise" Value="Exercise" />
            <asp:ListItem Text="Quiz" Value="Quiz" />
            <asp:ListItem Text="FinalExam" Value="FinalExam" />
          </asp:DropDownList>
        </div>

        <div class="field span-2">
          <label>Instructions</label>
          <asp:TextBox ID="txtInstr" runat="server" CssClass="input"
              TextMode="MultiLine" Rows="4" />
        </div>

        <div class="field">
          <label>Total Marks</label>
          <asp:TextBox ID="txtTotalMarks" runat="server" CssClass="input" Text="0" />
        </div>

        <div class="field">
          <label>Publish</label>
          <div class="checkrow">
            <asp:CheckBox ID="chkPublish" runat="server" />
            <span>Publish now</span>
          </div>
        </div>
      </div>

      <div class="actions">
        <asp:Button ID="btnCreate" runat="server" Text="Create Assessment"
            CssClass="btn btn-primary" OnClick="CreateAssessment" />
        <asp:Button ID="btnClear" runat="server" Text="Clear"
            CssClass="btn btn-outline" OnClick="ClearForm" CausesValidation="false" />
      </div>

      <asp:Label ID="lblMsg" runat="server" CssClass="muted" />
    </div>

    <!-- RIGHT: LIST -->
    <div class="card">
      <h3 class="muted" style="margin-top:0;">My Assessments</h3>

      <asp:GridView ID="gvAssess" runat="server"
          DataSourceID="dsAssessment"
          AutoGenerateColumns="False"
          CssClass="grid"
          OnRowCommand="gvAssess_RowCommand"
          EmptyDataText="No assessments created yet.">

        <Columns>
          <asp:BoundField DataField="Title" HeaderText="Title" />
          <asp:BoundField DataField="AssessmentType" HeaderText="Type" />
          <asp:BoundField DataField="TotalMarks" HeaderText="Marks" />
          <asp:CheckBoxField DataField="IsPublished" HeaderText="Published" />

          <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
              <a class="btn btn-outline"
                 href='<%# "ManageQuestions.aspx?aid=" + Eval("AssessmentId") %>'>
                Questions
              </a>

              <asp:LinkButton runat="server"
                  CssClass="btn btn-outline"
                  CommandName="DEL"
                  CommandArgument='<%# Eval("AssessmentId") %>'
                  OnClientClick="return confirm('Delete this assessment? Questions will be deleted too.');">
                Delete
              </asp:LinkButton>
            </ItemTemplate>
          </asp:TemplateField>

        </Columns>
      </asp:GridView>

      <asp:SqlDataSource ID="dsAssessment" runat="server"
          ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
          SelectCommand="
            SELECT AssessmentId, LecturerId, Title, AssessmentType, Instructions,
                   TotalMarks, TimeLimitMinutes, DueDate, IsPublished, CreatedAt
            FROM dbo.Assessment
            WHERE LecturerId = @LecturerId
            ORDER BY CreatedAt DESC;">
        <SelectParameters>
          <asp:SessionParameter Name="LecturerId" SessionField="UserId" Type="Int32" DefaultValue="1" />
        </SelectParameters>
      </asp:SqlDataSource>

    </div>

  </div>

</asp:Content>

<script runat="server">

  private string Cs => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

  private int LecturerId => (Session["UserId"] == null) ? 1 : Convert.ToInt32(Session["UserId"]);

  protected void CreateAssessment(object sender, EventArgs e)
  {
    lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

    string title = (txtTitle.Text ?? "").Trim();
    if (string.IsNullOrWhiteSpace(title))
    {
      lblMsg.Text = "Title is required.";
      return;
    }

    int totalMarks = 0;
    int.TryParse((txtTotalMarks.Text ?? "0").Trim(), out totalMarks);

    using (SqlConnection con = new SqlConnection(Cs))
    using (SqlCommand cmd = new SqlCommand(@"
      INSERT INTO dbo.Assessment
        (LecturerId, Title, AssessmentType, Instructions, TotalMarks,
         TimeLimitMinutes, DueDate, IsPublished, CreatedAt)
      VALUES
        (@L, @T, @Ty, @I, @M, NULL, NULL, @P, GETDATE());
    ", con))
    {
      cmd.Parameters.AddWithValue("@L", LecturerId);
      cmd.Parameters.AddWithValue("@T", title);
      cmd.Parameters.AddWithValue("@Ty", ddlType.SelectedValue);
      cmd.Parameters.AddWithValue("@I", (object)(txtInstr.Text ?? "") ?? DBNull.Value);
      cmd.Parameters.AddWithValue("@M", totalMarks);
      cmd.Parameters.AddWithValue("@P", chkPublish.Checked);

      con.Open();
      cmd.ExecuteNonQuery();
    }

    lblMsg.ForeColor = System.Drawing.Color.LightGreen;
    lblMsg.Text = "Assessment created.";
    ClearInputsOnly();
    gvAssess.DataBind();
  }

  protected void ClearForm(object sender, EventArgs e)
  {
    lblMsg.Text = "";
    ClearInputsOnly();
  }

  private void ClearInputsOnly()
  {
    txtTitle.Text = "";
    txtInstr.Text = "";
    txtTotalMarks.Text = "0";
    chkPublish.Checked = false;
    ddlType.SelectedIndex = 0;
  }

  protected void gvAssess_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
  {
    if (e.CommandName == "DEL")
    {
      int assessmentId = Convert.ToInt32(e.CommandArgument);

      // With FK ON DELETE CASCADE in place:
      // deleting Assessment will automatically delete Question + QuestionOption (and optionally submissions)
      using (SqlConnection con = new SqlConnection(Cs))
      using (SqlCommand cmd = new SqlCommand(@"
        DELETE FROM dbo.Assessment
        WHERE AssessmentId = @A AND LecturerId = @L;
      ", con))
      {
        cmd.Parameters.AddWithValue("@A", assessmentId);
        cmd.Parameters.AddWithValue("@L", LecturerId);
        con.Open();
        cmd.ExecuteNonQuery();
      }

      lblMsg.ForeColor = System.Drawing.Color.LightGreen;
      lblMsg.Text = "Assessment deleted.";
      gvAssess.DataBind();
    }
  }

</script>
