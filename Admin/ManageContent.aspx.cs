using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    public partial class ManageContent : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindLecturerDropdown();
            BindContentGrid(string.Empty);
            LogEvent("Content.View", "Opened content manager page.");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string search = (txtSearch.Text ?? string.Empty).Trim();
            if (search.Length > 120)
            {
                ShowMessage("Search text is too long. Keep it under 120 characters.", true);
                return;
            }

            BindContentGrid(search);
            LogEvent("Content.Search", "Searched content records.");
        }

        protected void btnAddContent_Click(object sender, EventArgs e)
        {
            int lecturerId;
            if (!int.TryParse(ddlLecturer.SelectedValue, out lecturerId) || lecturerId <= 0)
            {
                ShowMessage("Please select a valid lecturer.", true);
                return;
            }

            string title = (txtTitle.Text ?? string.Empty).Trim();
            string description = (txtDescription.Text ?? string.Empty).Trim();
            string contentType = (ddlContentType.SelectedValue ?? string.Empty).Trim();
            string filePath = (txtFilePath.Text ?? string.Empty).Trim();
            string url = (txtUrl.Text ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(title))
            {
                ShowMessage("Title is required.", true);
                return;
            }

            if (title.Length > 200)
            {
                ShowMessage("Title cannot exceed 200 characters.", true);
                return;
            }

            if (description.Length > 2000)
            {
                ShowMessage("Description is too long.", true);
                return;
            }

            if (string.IsNullOrWhiteSpace(filePath) && string.IsNullOrWhiteSpace(url))
            {
                ShowMessage("Provide either a file path or a URL.", true);
                return;
            }

            if (!string.IsNullOrWhiteSpace(url))
            {
                Uri uri;
                if (!Uri.TryCreate(url, UriKind.Absolute, out uri))
                {
                    ShowMessage("The URL format is invalid.", true);
                    return;
                }
            }

            try
            {
                ExecuteNonQuery(
                    @"INSERT INTO LearningContent (LecturerID, Title, Description, ContentType, FilePath, Url, IsPublished)
                      VALUES (@LecturerID, @Title, @Description, @ContentType, @FilePath, @Url, @IsPublished)",
                    new SqlParameter("@LecturerID", lecturerId),
                    new SqlParameter("@Title", title),
                    new SqlParameter("@Description", string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description),
                    new SqlParameter("@ContentType", string.IsNullOrWhiteSpace(contentType) ? (object)DBNull.Value : contentType),
                    new SqlParameter("@FilePath", string.IsNullOrWhiteSpace(filePath) ? (object)DBNull.Value : filePath),
                    new SqlParameter("@Url", string.IsNullOrWhiteSpace(url) ? (object)DBNull.Value : url),
                    new SqlParameter("@IsPublished", false));

                LogEvent("Content.Create", "Created new content '" + title + "'.");
                ShowMessage("Content created successfully and marked as not published.", false);

                txtTitle.Text = string.Empty;
                txtDescription.Text = string.Empty;
                txtFilePath.Text = string.Empty;
                txtUrl.Text = string.Empty;

                BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
            }
            catch
            {
                ShowMessage("Unable to create content at the moment.", true);
            }
        }

        protected void gvContent_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvContent.EditIndex = e.NewEditIndex;
            BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
        }

        protected void gvContent_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvContent.EditIndex = -1;
            BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
        }

        protected void gvContent_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int contentId = Convert.ToInt32(gvContent.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvContent.Rows[e.RowIndex];

            TextBox txtEditTitle = row.FindControl("txtEditTitle") as TextBox;
            TextBox txtEditContentType = row.FindControl("txtEditContentType") as TextBox;
            TextBox txtEditFilePath = row.FindControl("txtEditFilePath") as TextBox;
            TextBox txtEditUrl = row.FindControl("txtEditUrl") as TextBox;

            string title = txtEditTitle == null ? string.Empty : txtEditTitle.Text.Trim();
            string contentType = txtEditContentType == null ? string.Empty : txtEditContentType.Text.Trim();
            string filePath = txtEditFilePath == null ? string.Empty : txtEditFilePath.Text.Trim();
            string url = txtEditUrl == null ? string.Empty : txtEditUrl.Text.Trim();

            if (string.IsNullOrWhiteSpace(title))
            {
                ShowMessage("Title is required.", true);
                return;
            }

            if (!string.IsNullOrWhiteSpace(url))
            {
                Uri uri;
                if (!Uri.TryCreate(url, UriKind.Absolute, out uri))
                {
                    ShowMessage("Edited URL is invalid.", true);
                    return;
                }
            }

            try
            {
                ExecuteNonQuery(
                    @"UPDATE LearningContent
                      SET Title = @Title,
                          ContentType = @ContentType,
                          FilePath = @FilePath,
                          Url = @Url
                      WHERE ContentID = @ContentID",
                    new SqlParameter("@Title", title),
                    new SqlParameter("@ContentType", string.IsNullOrWhiteSpace(contentType) ? (object)DBNull.Value : contentType),
                    new SqlParameter("@FilePath", string.IsNullOrWhiteSpace(filePath) ? (object)DBNull.Value : filePath),
                    new SqlParameter("@Url", string.IsNullOrWhiteSpace(url) ? (object)DBNull.Value : url),
                    new SqlParameter("@ContentID", contentId));

                gvContent.EditIndex = -1;
                BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
                ShowMessage("Content updated successfully.", false);
                LogEvent("Content.Update", "Updated content item ContentID=" + contentId + ".");
            }
            catch
            {
                ShowMessage("Unable to update content right now.", true);
            }
        }

        protected void gvContent_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Edit" || e.CommandName == "Update" || e.CommandName == "Cancel")
            {
                return;
            }

            int contentId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out contentId) || contentId <= 0)
            {
                ShowMessage("Invalid content selection.", true);
                return;
            }

            try
            {
                if (e.CommandName == "ApproveContent")
                {
                    SetPublishState(contentId, true, "Approved");
                    ShowMessage("Content approved and published.", false);
                }
                else if (e.CommandName == "RejectContent")
                {
                    SetPublishState(contentId, false, "Rejected");
                    ShowMessage("Content marked as not published.", false);
                }
                else if (e.CommandName == "DeleteContent")
                {
                    ExecuteNonQuery(
                        "DELETE FROM LearningContent WHERE ContentID = @ContentID",
                        new SqlParameter("@ContentID", contentId));

                    ShowMessage("Content deleted successfully.", false);
                    LogEvent("Content.Delete", "Deleted content ContentID=" + contentId + ".");
                }

                gvContent.EditIndex = -1;
                BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                {
                    ShowMessage("This content cannot be deleted because it has dependent records.", true);
                    return;
                }

                ShowMessage("Unable to process content action right now.", true);
            }
            catch
            {
                ShowMessage("Unable to process content action right now.", true);
            }
        }

        private void SetPublishState(int contentId, bool isPublished, string statusLabel)
        {
            ExecuteNonQuery(
                @"UPDATE LearningContent
                  SET IsPublished = @IsPublished
                  WHERE ContentID = @ContentID",
                new SqlParameter("@IsPublished", isPublished),
                new SqlParameter("@ContentID", contentId));

            try
            {
                object adminId = AdminUserId.HasValue ? (object)AdminUserId.Value : DBNull.Value;
                ExecuteNonQuery(
                    @"INSERT INTO VerificationLog (TargetID, TargetType, AdminID, Status, Comments)
                      VALUES (@TargetID, @TargetType, @AdminID, @Status, @Comments)",
                    new SqlParameter("@TargetID", contentId),
                    new SqlParameter("@TargetType", "LearningContent"),
                    new SqlParameter("@AdminID", adminId),
                    new SqlParameter("@Status", statusLabel),
                    new SqlParameter("@Comments", "Moderation action on learning content."));
            }
            catch
            {
                // Keep moderation flow successful even when optional audit insert fails.
            }

            LogEvent("Content.Moderation", statusLabel + " content ContentID=" + contentId + ".");
        }

        private void BindLecturerDropdown()
        {
            DataTable lecturers = ExecuteTable(
                @"SELECT UserID, Username
                  FROM Users
                  WHERE Role = @Role AND Status = @Status
                  ORDER BY Username",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Active"));

            ddlLecturer.DataSource = lecturers;
            ddlLecturer.DataTextField = "Username";
            ddlLecturer.DataValueField = "UserID";
            ddlLecturer.DataBind();
            ddlLecturer.Items.Insert(0, new ListItem("-- Select Lecturer --", string.Empty));
        }

        private void BindContentGrid(string search)
        {
            string trimmed = search == null ? string.Empty : search.Trim();
            string likeSearch = "%" + trimmed + "%";

            DataTable content = ExecuteTable(
                @"SELECT
                    c.ContentID,
                    c.Title,
                    ISNULL(u.Username, 'Unknown') AS LecturerName,
                    ISNULL(c.ContentType, '') AS ContentType,
                    ISNULL(c.FilePath, '') AS FilePath,
                    ISNULL(c.Url, '') AS Url,
                    c.IsPublished,
                    CASE WHEN c.IsPublished = 1 THEN 'Approved' ELSE 'Pending/Rejected' END AS ApprovalState,
                    c.CreatedAt
                  FROM LearningContent c
                  LEFT JOIN Users u ON c.LecturerID = u.UserID
                  WHERE (@Search = '' OR c.Title LIKE @LikeSearch OR u.Username LIKE @LikeSearch OR c.FilePath LIKE @LikeSearch OR c.Url LIKE @LikeSearch)
                  ORDER BY c.CreatedAt DESC",
                new SqlParameter("@Search", trimmed),
                new SqlParameter("@LikeSearch", likeSearch));

            gvContent.DataSource = content;
            gvContent.DataBind();
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }
    }
}
