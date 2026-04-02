<%@ Page Title="Upload Content" Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="PythonAcademy.Helpers" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <style>
        /* Neon Dark Theme Styles */
        .glass-panel { background: rgba(13, 25, 48, 0.85); backdrop-filter: blur(12px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 20px; padding: 30px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); margin-bottom: 30px; }
        .form-label { display: block; margin-bottom: 8px; color: #8899ac; font-size: 0.9rem; font-weight: bold; }
        .neon-input { width: 100%; padding: 14px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0, 0, 0, 0.2); color: white; font-size: 1rem; outline: none; transition: 0.3s; margin-bottom: 20px; }
        .neon-input:focus { border-color: #00f3ff; box-shadow: 0 0 10px rgba(0, 243, 255, 0.1); }
        .btn-publish { background: #00f3ff; color: #0b1220; border: none; padding: 12px 24px; font-size: 1rem; font-weight: 800; border-radius: 50px; cursor: pointer; transition: 0.3s; box-shadow: 0 4px 15px rgba(0, 243, 255, 0.3); }
        .btn-publish:hover { background: white; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0, 243, 255, 0.5); }
        .dark-grid { width: 100%; border-collapse: collapse; color: #e7eefc; }
        .dark-grid th { background: rgba(0, 0, 0, 0.4); color: #00f3ff; padding: 12px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
        .dark-grid td { padding: 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
        .dark-grid tr:hover { background: rgba(255, 255, 255, 0.02); }

        /* --- THUMBNAIL GALLERY STYLES --- */
        .thumb-gallery { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 25px; }
        .thumb-option { width: 140px; height: 80px; border-radius: 8px; border: 2px solid rgba(255,255,255,0.1); cursor: pointer; background-size: cover; background-position: center; transition: all 0.2s ease; opacity: 0.5; }
        .thumb-option:hover { opacity: 0.9; }
        .thumb-option.selected { border-color: #00f3ff; box-shadow: 0 0 12px rgba(0, 243, 255, 0.4); opacity: 1; transform: scale(1.05); }
    </style>

    <div style="max-width: 1000px; margin: 0 auto; padding: 20px;">
        
        <div style="margin-bottom: 30px;">
            <h1 style="font-size: 2.2rem; font-weight: bold; color: white; margin: 0;">Create and Upload Modules</h1>
            <p style="color: #8899ac; margin-top: 5px;">Create the main module here, then add lessons and materials using Manage Topics.</p>
        </div>

        <div class="glass-panel">
            <asp:Label ID="lblMode" runat="server" Text="Creating New Content" Style="color: #00f3ff; font-weight: bold; font-size: 1.1rem; margin-bottom: 20px; display: block;" />
            <asp:Label ID="lblMsg" runat="server" Style="display:block; margin-bottom:15px; font-weight:bold;" />

            <label class="form-label">Module Title</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="neon-input" placeholder="e.g. Introduction to Python" />

            <label class="form-label">Course Category / Genre</label>
            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="neon-input">
                <asp:ListItem Text="General" Value="General" />
                <asp:ListItem Text="Python Basics" Value="Python Basics" />
                <asp:ListItem Text="Cybersecurity" Value="Cybersecurity" />
                <asp:ListItem Text="Data Analytics" Value="Data Analytics" />
                <asp:ListItem Text="Machine Learning" Value="Machine Learning" />
                <asp:ListItem Text="Web Development" Value="Web Development" />
                <asp:ListItem Text="Data Science" Value="Data Science" />
                <asp:ListItem Text="Automation" Value="Automation" />
                <asp:ListItem Text="Artificial Intelligence" Value="Artificial Intelligence" />
                <asp:ListItem Text="Game Development" Value="Game Development" />
            </asp:DropDownList>

            <label class="form-label">Description</label>
            <asp:TextBox ID="txtDesc" runat="server" CssClass="neon-input" TextMode="MultiLine" Rows="4" placeholder="What will students learn in this module?" />

            <label class="form-label">Course Cover Art (Thumbnail)</label>
            <div class="thumb-gallery">
                <div class="thumb-option selected" style="background-image: url('/Images/Thumbnails/python101.png');" onclick="selectThumb(this, '~/Images/Thumbnails/python101.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/ethicalHacking.png');" onclick="selectThumb(this, '~/Images/Thumbnails/ethicalHacking.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/data.jpg');" onclick="selectThumb(this, '~/Images/Thumbnails/data.jpg')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/cyber.jpg');" onclick="selectThumb(this, '~/Images/Thumbnails/cyber.jpg')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/ethicalHacking.png');" onclick="selectThumb(this, '~/Images/Thumbnails/ethicalHacking.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/automation.png');" onclick="selectThumb(this, '~/Images/Thumbnails/automation.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/DataScience.png');" onclick="selectThumb(this, '~/Images/Thumbnails/DataScience.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/game.png');" onclick="selectThumb(this, '~/Images/Thumbnails/game.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/machinelearning.png');" onclick="selectThumb(this, '~/Images/Thumbnails/machinelearning.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/web.png');" onclick="selectThumb(this, '~/Images/Thumbnails/web.png')"></div>
                <div class="thumb-option" style="background-image: url('/Images/Thumbnails/test.png');" onclick="selectThumb(this, '~/Images/Thumbnails/test.png')"></div>
                </div>

            <asp:HiddenField ID="hfSelectedThumbnail" runat="server" Value="~/Images/Thumbnails/python101.png" />
            <div style="display: flex; gap: 15px; margin-top: 10px;">
                <asp:Button ID="btnUpload" runat="server" Text="Create Module" CssClass="btn-publish" OnClick="UploadContent" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline" OnClick="ClearForm" CausesValidation="false" Style="border-radius: 50px; padding: 12px 24px;" />
            </div>
        </div>

        <div class="glass-panel">
            <h3 style="color: white; margin-top: 0; margin-bottom: 20px;">My Published Modules</h3>

            <div style="overflow-x: auto;">
                <asp:GridView ID="gvContent" runat="server" DataSourceID="dsContent" AutoGenerateColumns="False" CssClass="dark-grid" DataKeyNames="ContentId" OnRowCommand="gvContent_RowCommand" EmptyDataText="No modules created yet." GridLines="None">
                    <Columns>
                        <asp:TemplateField HeaderText="Module Title">
                            <ItemTemplate>
                                <asp:LinkButton 
                                    ID="lnkEditTitle" 
                                    runat="server"
                                    CommandName="EDIT"
                                    CommandArgument='<%# Eval("ContentId") %>'
                                    Style="color: #e7eefc; text-decoration: none; font-weight: 600;">
                                    <%# Eval("Title") %>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Created On" DataField="CreatedAt" SortExpression="CreatedAt" DataFormatString="{0:MMM dd, yyyy}" />
    
                        <asp:TemplateField HeaderText="Lesson Plan">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="MANAGE" CommandArgument='<%# Eval("ContentId") %>' CssClass="btn btn-outline" style="color: #ffd740; border-color: rgba(255, 215, 64, 0.3); font-size: 0.85rem; padding: 6px 12px;">
                                    &#9881; Manage Topics
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div style="display:flex; gap:12px; align-items:center;">
                                    <asp:LinkButton 
                                        ID="lnkEdit" 
                                        runat="server" 
                                        CommandName="EDIT" 
                                        CommandArgument='<%# Eval("ContentId") %>'
                                        Style="color:#00f3ff; font-size:0.85rem; text-decoration:none; font-weight:600;">
                                        Edit
                                    </asp:LinkButton>

                                    <asp:LinkButton 
                                        ID="lnkDelete"
                                        runat="server" 
                                        CommandName="DEL" 
                                        CommandArgument='<%# Eval("ContentId") %>' 
                                        ForeColor="#ff4d4d" 
                                        Style="font-size:0.85rem; text-decoration:none;"
                                        OnClientClick="return confirm('Unpublish this module?');">
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
    <script>
        function selectThumb(element, path) {
            // Remove highlight from all images
            document.querySelectorAll('.thumb-option').forEach(el => el.classList.remove('selected'));
            // Highlight the clicked one
            element.classList.add('selected');
            element.classList.add('selected');
            // Save the path to the hidden C# field
            document.getElementById('<%= hfSelectedThumbnail.ClientID %>').value = path;
        }
    </script>
    <asp:SqlDataSource ID="dsContent" runat="server" ConnectionString="<%$ ConnectionStrings:PythonAcademyDb %>" SelectCommand="SELECT ContentId, LecturerId, Title, Description, IsPublished, CreatedAt FROM dbo.LearningContent WHERE LecturerId = @LecturerId AND IsPublished = 1 ORDER BY CreatedAt DESC;">
        <SelectParameters>
            <asp:SessionParameter Name="LecturerId" SessionField="UserId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>

<script runat="server">

    private const int MaxUploadBytes = 25 * 1024 * 1024;

    private static readonly IDictionary<string, string[]> AllowedExtensionsByType =
        new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            { "PDF", new[] { ".pdf" } },
            { "Video", new[] { ".mp4", ".webm" } },
            { "Image", new[] { ".png", ".jpg", ".jpeg", ".gif" } },
            { "PowerPoint", new[] { ".ppt", ".pptx" } },
            { "Word", new[] { ".doc", ".docx" } },
            { "Link", Array.Empty<string>() }
        };

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

    private int? EditId
    {
        get
        {
            int id;
            return int.TryParse(Request.QueryString["editId"], out id) ? (int?)id : null;
        }
    }

    private string ExistingFilePath
    {
        get { return Convert.ToString(ViewState["ExistingFilePath"], CultureInfo.InvariantCulture); }
        set { ViewState["ExistingFilePath"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!EnsureLecturerAccess())
        {
            return;
        }

        if (!IsPostBack)
        {
            string msg = Convert.ToString(Request.QueryString["msg"], CultureInfo.InvariantCulture);

            if (string.Equals(msg, "created", StringComparison.OrdinalIgnoreCase))
            {
                ShowSuccess("Module created successfully. You can now add topics or create another module.");
            }
            else if (string.Equals(msg, "updated", StringComparison.OrdinalIgnoreCase))
            {
                ShowSuccess("Module updated successfully.");
            }

            if (EditId.HasValue)
            {
                if (!LoadExistingData(EditId.Value))
                {
                    return;
                }

                lblMode.Text = "Editing Module (ID: " + EditId.Value.ToString(CultureInfo.InvariantCulture) + ")";
                btnUpload.Text = "Update Module";
                btnClear.Text = "Cancel Edit";
            }
            else
            {
                lblMode.Text = "Creating New Content";
                btnUpload.Text = "Create Module";
                btnClear.Text = "Clear";
            }
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

  private bool LoadExistingData(int id)
    {
        using (SqlConnection con = new SqlConnection(Cs))
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT Title, Description, ISNULL(Category, 'General') AS Category, ThumbnailPath
            FROM dbo.LearningContent
            WHERE ContentId = @Id
              AND (@IsAdmin = 1 OR LecturerId = @LecturerId);", con))
        {
            // 1. Add the parameters back
            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            cmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);

            // 2. Actually OPEN the connection!
            con.Open();

            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                if (!rdr.Read()) 
                { 
                    ShowError("You can only edit content that you own unless you are an admin.");
                    btnUpload.Enabled = false;
                    return false; 
                }

                txtTitle.Text = rdr["Title"].ToString();
                txtDesc.Text = rdr["Description"].ToString();
                
                string cat = rdr["Category"].ToString();
                if (ddlCategory.Items.FindByValue(cat) != null)
                {
                    ddlCategory.SelectedValue = cat;
                }

                // Safer to have this outside! That way the image always loads, no matter what.
                if (rdr["ThumbnailPath"] != DBNull.Value)
                {
                    hfSelectedThumbnail.Value = rdr["ThumbnailPath"].ToString();
                }
            }
        }
        return true;
    }

protected void UploadContent(object sender, EventArgs e)
    {
        if (!EnsureLecturerAccess()) return;

        string title = (txtTitle.Text ?? string.Empty).Trim();
        string desc = (txtDesc.Text ?? string.Empty).Trim();
        string category = ddlCategory.SelectedValue; // <-- Grab the category

        if (string.IsNullOrWhiteSpace(title)) { ShowError("Title is required."); return; }

        try
        {
            using (SqlConnection con = new SqlConnection(Cs))
            {
                string sql;
                if (EditId.HasValue)
                {
                    sql = @"
                        UPDATE dbo.LearningContent
                        SET Title = @T, Description = @D, Category = @Cat, ThumbnailPath = @Thumb
                        WHERE ContentId = @ID AND (@IsAdmin = 1 OR LecturerId = @L);";
                }
                else
                {
                    sql = @"
                        INSERT INTO dbo.LearningContent
                        (LecturerId, Title, Description, ContentType, FilePath, Url, IsPublished, CreatedAt, Category, ThumbnailPath)
                        VALUES
                        (@L, @T, @D, 'Course', '', '', 1, GETDATE(), @Cat, @Thumb);";
                }

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    if (EditId.HasValue) { cmd.Parameters.AddWithValue("@ID", EditId.Value); cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin); }
                    cmd.Parameters.AddWithValue("@L", CurrentUserId);
                    cmd.Parameters.AddWithValue("@T", title);
                    cmd.Parameters.AddWithValue("@D", string.IsNullOrWhiteSpace(desc) ? (object)DBNull.Value : desc);
                    cmd.Parameters.AddWithValue("@Cat", category);
                    
                    // NEW: Save the thumbnail from the Hidden Field
                    cmd.Parameters.AddWithValue("@Thumb", hfSelectedThumbnail.Value);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            if (EditId.HasValue)
            {
                Response.Redirect("~/Lecture/UploadContent.aspx?msg=updated", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            else
            {
                Response.Redirect("~/Lecture/UploadContent.aspx?msg=created", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
        }
        catch (Exception ex)
        {
            Trace.Warn("UploadContent", "Failed to save content.", ex);
            ShowError("We couldn't save that content right now. Please try again.");
        }
    }

    private void ClearInputsOnly()
    {
        txtTitle.Text = string.Empty;
        txtDesc.Text = string.Empty;
    }

    protected void gvContent_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
{
    string contentIdStr = Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture);

    if (e.CommandName == "EDIT")
    {
        Response.Redirect("~/Lecture/UploadContent.aspx?editId=" + contentIdStr, false);
        Context.ApplicationInstance.CompleteRequest();
        return;
    }

    if (e.CommandName == "MANAGE")
    {
        Response.Redirect("~/Lecture/manageTopics.aspx?ModuleId=" + contentIdStr, false);
        Context.ApplicationInstance.CompleteRequest();
        return;
    }

    if (e.CommandName != "DEL")
    {
        return;
    }

    int contentId;
    if (!int.TryParse(contentIdStr, out contentId))
    {
        ShowError("Invalid content selection.");
        return;
    }

    try
    {
        using (SqlConnection con = new SqlConnection(Cs))
        using (SqlCommand cmd = new SqlCommand(@"
            UPDATE dbo.LearningContent
            SET IsPublished = 0
            WHERE ContentId = @Id
              AND (@IsAdmin = 1 OR LecturerId = @LecturerId);", con))
        {
            cmd.Parameters.AddWithValue("@Id", contentId);
            cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin);
            cmd.Parameters.AddWithValue("@LecturerId", CurrentUserId);

            con.Open();
            int rows = cmd.ExecuteNonQuery();

            if (rows == 0)
            {
                ShowError("You can only change content that you own unless you are an admin.");
                return;
            }
        }

        ShowSuccess("Content unpublished.");
        gvContent.DataBind();
    }
    catch (Exception ex)
    {
        Trace.Warn("UploadContent", "Failed to unpublish content.", ex);
        ShowError("We couldn't update that content right now. Please try again.");
    }
}

    protected void gvContent_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    protected void ClearForm(object sender, EventArgs e)
{
    Response.Redirect("~/Lecture/UploadContent.aspx", false);
    Context.ApplicationInstance.CompleteRequest();
}

    private void ShowError(string message)
    {
        lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
        lblMsg.Text = message;
    }

    private void ShowSuccess(string message)
    {
        lblMsg.ForeColor = System.Drawing.Color.LightGreen;
        lblMsg.Text = message;
    }
</script>
