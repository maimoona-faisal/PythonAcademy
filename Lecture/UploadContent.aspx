<%@ Page Title="Upload Content" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <h2>Upload Learning Content</h2>
  <p class="muted">Upload a file (PDF/Image/Video/PowerPoint/Word) or provide a resource link.</p>

  <!-- FORM -->
  <div style="max-width:760px; display:grid; gap:10px; margin-top:12px;">

    <label>Title</label>
    <asp:TextBox ID="txtTitle" runat="server" CssClass="input" />

    <label>Description</label>
    <asp:TextBox ID="txtDesc" runat="server" CssClass="input"
                 TextMode="MultiLine" Rows="4" />

    <label>Content Type</label>
    <asp:DropDownList ID="ddlType" runat="server" CssClass="input">
      <asp:ListItem Text="PDF" Value="PDF" />
      <asp:ListItem Text="Video" Value="Video" />
      <asp:ListItem Text="Image" Value="Image" />
      <asp:ListItem Text="Link" Value="Link" />
      <asp:ListItem Text="PowerPoint" Value="PowerPoint" />
      <asp:ListItem Text="Word" Value="Word" />
    </asp:DropDownList>

    <label>Upload File (optional)</label>
    <asp:FileUpload ID="fuFile" runat="server" CssClass="input" />

    <label>OR Resource URL (optional)</label>
    <asp:TextBox ID="txtUrl" runat="server" CssClass="input" />

    <div style="display:flex; align-items:center; gap:10px; margin-top:6px;">
      <asp:CheckBox ID="chkPublish" runat="server" />
      <span>Publish now</span>
    </div>

    <div style="display:flex; gap:10px; margin-top:10px;">
      <asp:Button ID="btnUpload" runat="server" Text="Save Content"
                  CssClass="btn btn-primary" OnClick="UploadContent" />
      <asp:Button ID="btnClear" runat="server" Text="Clear"
                  CssClass="btn btn-outline" OnClick="ClearForm" CausesValidation="false" />
    </div>

    <asp:Label ID="lblMsg" runat="server" />

  </div>

  <hr style="margin:22px 0; border:none; border-top:1px solid rgba(255,255,255,.12);" />

  <!-- GRID -->
  <h3 style="margin:0 0 10px 0;">My Uploaded Content</h3>

  <asp:GridView ID="gvContent" runat="server"
      DataSourceID="dsContent"
      AutoGenerateColumns="False"
      CssClass="grid"
      DataKeyNames="ContentId&nbsp;&nbsp;&nbsp;"
      OnRowCommand="gvContent_RowCommand"
      EmptyDataText="No content uploaded yet." OnSelectedIndexChanged="gvContent_SelectedIndexChanged">

    <Columns>
      <asp:BoundField HeaderText="ContentId&nbsp;&nbsp;&nbsp;" DataField="ContentId&nbsp;&nbsp;&nbsp;" ReadOnly="True" SortExpression="ContentId&nbsp;&nbsp;&nbsp;" />
      <asp:BoundField HeaderText="LecturerId" DataField="LecturerId" SortExpression="LecturerId" />
      <asp:BoundField HeaderText="Title&nbsp;&nbsp;" DataField="Title&nbsp;&nbsp;" SortExpression="Title&nbsp;&nbsp;" />
      <asp:BoundField HeaderText="Description&nbsp;&nbsp;" DataField="Description&nbsp;&nbsp;" SortExpression="Description&nbsp;&nbsp;" />

        <asp:BoundField DataField="ContentType" HeaderText="ContentType" SortExpression="ContentType" />
		<asp:BoundField DataField="FilePath&nbsp;" HeaderText="FilePath&nbsp;" SortExpression="FilePath&nbsp;" />
		<asp:BoundField DataField="Url&nbsp;&nbsp;&nbsp;" HeaderText="Url&nbsp;&nbsp;&nbsp;" SortExpression="Url&nbsp;&nbsp;&nbsp;" />
		<asp:CheckBoxField DataField="IsPublished&nbsp;" HeaderText="IsPublished&nbsp;" SortExpression="IsPublished&nbsp;" />
		<asp:BoundField DataField="CreatedAt&nbsp;" HeaderText="CreatedAt&nbsp;" SortExpression="CreatedAt&nbsp;" />
    </Columns>

  </asp:GridView>

  <!-- DATASOURCE (METHOD 2) -->
  <asp:SqlDataSource ID="dsContent" runat="server"
      ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
      SelectCommand="SELECT * FROM [LearningContent]">
  </asp:SqlDataSource>

</asp:Content>

<script runat="server">

    private string Cs => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

    private int LecturerId
    {
        get
        {
            if (Session["UserId"] == null) return 1; // temp for testing
            return Convert.ToInt32(Session["UserId"]);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            lblMsg.Text = "";
        }
    }

    protected void UploadContent(object sender, EventArgs e)
    {
        lblMsg.ForeColor = System.Drawing.Color.OrangeRed;

        string title = (txtTitle.Text ?? "").Trim();
        string desc = (txtDesc.Text ?? "").Trim();
        string type = ddlType.SelectedValue;
        string url = (txtUrl.Text ?? "").Trim();
        bool published = chkPublish.Checked;

        if (string.IsNullOrWhiteSpace(title))
        {
            lblMsg.Text = "Title is required.";
            return;
        }

        // For Link type, URL is required
        if (type == "Link" && string.IsNullOrWhiteSpace(url))
        {
            lblMsg.Text = "For Content Type = Link, please provide a URL.";
            return;
        }

        string filePath = null;

        // Save uploaded file into ~/Uploads/
        if (fuFile.HasFile)
        {
            string uploadsFolder = Server.MapPath("~/Uploads/");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            string originalName = Path.GetFileName(fuFile.FileName);
            string ext = Path.GetExtension(originalName);

            // Optional: simple allow-list (adjust as you want)
            string allowed = ".pdf,.png,.jpg,.jpeg,.gif,.mp4,.webm,.ppt,.pptx,.doc,.docx";
            if (!allowed.Contains(ext.ToLower()))
            {
                lblMsg.Text = "File type not allowed.";
                return;
            }

            string safeBase = Path.GetFileNameWithoutExtension(originalName);
            string uniqueName = safeBase + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ext;

            fuFile.SaveAs(Path.Combine(uploadsFolder, uniqueName));
            filePath = "~/Uploads/" + uniqueName;
        }

        // Must have either file or URL
        if (string.IsNullOrWhiteSpace(filePath) && string.IsNullOrWhiteSpace(url))
        {
            lblMsg.Text = "Please upload a file or provide a URL.";
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(Cs))
            using (SqlCommand cmd = new SqlCommand(@"
        INSERT INTO dbo.LearningContent
          (LecturerId, Title, Description, ContentType, FilePath, Url, IsPublished, CreatedAt)
        VALUES
          (@LecturerId, @Title, @Description, @ContentType, @FilePath, @Url, @IsPublished, GETDATE());
      ", con))
            {
                cmd.Parameters.AddWithValue("@LecturerId", LecturerId);
                cmd.Parameters.AddWithValue("@Title", title);
                cmd.Parameters.AddWithValue("@Description", (object)desc ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ContentType", (object)type ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FilePath", (object)filePath ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Url", (object)url ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@IsPublished", published);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            lblMsg.ForeColor = System.Drawing.Color.LightGreen;
            lblMsg.Text = "Saved successfully.";

            ClearInputsOnly();

            // Refresh Method 2 binding
            gvContent.DataBind();
        }
        catch (Exception ex)
        {
            lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
            lblMsg.Text = "Save failed: " + ex.Message;
        }
    }

    protected void ClearForm(object sender, EventArgs e)
    {
        lblMsg.Text = "";
        ClearInputsOnly();
    }

    private void ClearInputsOnly()
    {
        txtTitle.Text = "";
        txtDesc.Text = "";
        ddlType.SelectedIndex = 0;
        txtUrl.Text = "";
        chkPublish.Checked = false;
    }

    protected void gvContent_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DEL")
        {
            int contentId = Convert.ToInt32(e.CommandArgument);

            string filePath = null;

            try
            {
                using (SqlConnection con = new SqlConnection(Cs))
                {
                    con.Open();

                    // get filepath
                    using (SqlCommand getCmd = new SqlCommand(@"
            SELECT FilePath
            FROM dbo.LearningContent
            WHERE ContentId=@Id AND LecturerId=@L;
          ", con))
                    {
                        getCmd.Parameters.AddWithValue("@Id", contentId);
                        getCmd.Parameters.AddWithValue("@L", LecturerId);

                        object fp = getCmd.ExecuteScalar();
                        if (fp != null && fp != DBNull.Value) filePath = fp.ToString();
                    }

                    // delete row
                    using (SqlCommand delCmd = new SqlCommand(@"
            DELETE FROM dbo.LearningContent
            WHERE ContentId=@Id AND LecturerId=@L;
          ", con))
                    {
                        delCmd.Parameters.AddWithValue("@Id", contentId);
                        delCmd.Parameters.AddWithValue("@L", LecturerId);
                        delCmd.ExecuteNonQuery();
                    }
                }

                // delete physical file if exists
                if (!string.IsNullOrWhiteSpace(filePath))
                {
                    string physical = Server.MapPath(filePath);
                    if (File.Exists(physical))
                        File.Delete(physical);
                }

                lblMsg.ForeColor = System.Drawing.Color.LightGreen;
                lblMsg.Text = "Deleted.";

                gvContent.DataBind();
            }
            catch (Exception ex)
            {
                lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
                lblMsg.Text = "Delete failed: " + ex.Message;
            }
        }
    }

    protected void gvContent_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
</script>
