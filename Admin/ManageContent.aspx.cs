using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    public partial class ManageContent : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            BindContentGrid(string.Empty);
            LogEvent("Content.View", "Opened content moderation page.");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string search = (txtSearch.Text ?? string.Empty).Trim();
            BindContentGrid(search);
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
                    c.IsPublished,
                    c.IsArchived, 
                    c.CreatedAt,
                    c.FilePath,
                    c.Url
                  FROM LearningContent c
                  LEFT JOIN Users u ON c.LecturerID = u.UserID
                  WHERE (@Search = ''
                         OR c.Title LIKE @LikeSearch
                         OR u.Username LIKE @LikeSearch
                         OR ISNULL(c.FilePath, '') LIKE @LikeSearch
                         OR ISNULL(c.Url, '') LIKE @LikeSearch)
                  ORDER BY c.CreatedAt DESC",
                            new SqlParameter("@Search", trimmed),
                            new SqlParameter("@LikeSearch", likeSearch));

            gvContent.DataSource = content;
            gvContent.DataBind();
        }

        protected void gvContent_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int contentId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out contentId)) return;

            try
            {
                DataTable targetContent = ExecuteTable(
                    @"SELECT ContentID, Title, IsPublished, IsArchived, FilePath, Url
                      FROM LearningContent
                      WHERE ContentID = @ID",
                    new SqlParameter("@ID", contentId));

                if (targetContent.Rows.Count == 0)
                {
                    ShowMessage("The selected content item could not be found.", true);
                    BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
                    return;
                }

                DataRow row = targetContent.Rows[0];
                string title = Convert.ToString(row["Title"], CultureInfo.InvariantCulture);
                bool isPublished = row["IsPublished"] != DBNull.Value && Convert.ToBoolean(row["IsPublished"]);
                bool isArchived = row["IsArchived"] != DBNull.Value && Convert.ToBoolean(row["IsArchived"]);

                if (e.CommandName == "TogglePublish")
                {
                    if (isArchived) return; // Prevent publishing if it's archived!

                    int affected = ExecuteNonQuery(
                        @"UPDATE LearningContent
                          SET IsPublished = CASE WHEN IsPublished = 1 THEN 0 ELSE 1 END
                          WHERE ContentID = @ID",
                        new SqlParameter("@ID", contentId));

                    string newState = isPublished ? "Hidden" : "Published";
                    LogEvent("Content.Toggle", $"Updated content '{title}' to {newState}.");
                    ShowMessage("Content visibility updated successfully.", false);
                }
                else if (e.CommandName == "ToggleArchive")
                {
                    // If we are archiving it, we ALSO force it to be hidden (IsPublished = 0)
                    int affected = ExecuteNonQuery(
                        @"UPDATE LearningContent
                          SET IsArchived = CASE WHEN IsArchived = 1 THEN 0 ELSE 1 END,
                              IsPublished = CASE WHEN IsArchived = 0 THEN 0 ELSE IsPublished END
                          WHERE ContentID = @ID",
                        new SqlParameter("@ID", contentId));

                    string newState = isArchived ? "Unarchived" : "Archived";
                    LogEvent("Content.Archive", $"Content '{title}' was {newState}.");
                    ShowMessage($"Content successfully {newState}.", false);
                }
                else if (e.CommandName == "HardDelete")
                {
                    try
                    {
                        int affected = ExecuteNonQuery(
                            "DELETE FROM LearningContent WHERE ContentID = @ID",
                            new SqlParameter("@ID", contentId));

                        LogEvent("Content.Delete", $"Permanently deleted content '{title}'.");
                        ShowMessage("Content permanently deleted from the database.", false);
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Number == 547)
                        {
                            ShowMessage("Cannot delete this content because it has active student enrollments. Please Archive it instead.", true);
                        }
                        else
                        {
                            ShowMessage("A database error occurred while trying to delete.", true);
                        }
                    }
                }

                BindContentGrid((txtSearch.Text ?? string.Empty).Trim());
            }
            catch
            {
                ShowMessage("Unexpected error while updating content.", true);
            }
        }

        /* --- FRONTEND DISPLAY HELPERS --- */
        protected string GetResourceUrl(object filePath, object url)
        {
            string path = Convert.ToString(filePath, CultureInfo.InvariantCulture);
            string link = Convert.ToString(url, CultureInfo.InvariantCulture);

            Uri parsedLink;
            if (!string.IsNullOrWhiteSpace(link) && Uri.TryCreate(link.Trim(), UriKind.Absolute, out parsedLink) && (parsedLink.Scheme == Uri.UriSchemeHttp || parsedLink.Scheme == Uri.UriSchemeHttps))
                return parsedLink.AbsoluteUri;

            if (!string.IsNullOrWhiteSpace(path) && (path.Trim().StartsWith("~/") || path.Trim().StartsWith("/")))
                return ResolveUrl(path.Trim());

            return "#";
        }

        protected bool HasResourceUrl(object filePath, object url) => GetResourceUrl(filePath, url) != "#";
        protected string GetResourceCssClass(object filePath, object url) => HasResourceUrl(filePath, url) ? "action-btn btn-resource" : "action-btn btn-resource action-btn-disabled";
        protected string GetResourceOnClick(object filePath, object url) => HasResourceUrl(filePath, url) ? string.Empty : "return false;";

        // Status Indicators (Visible, Hidden, Archived)
        protected string GetPublishedIndicatorCssClass(object isPub, object isArch)
        {
            bool archived = isArch != DBNull.Value && Convert.ToBoolean(isArch);
            bool published = isPub != DBNull.Value && Convert.ToBoolean(isPub);

            if (archived) return "publish-indicator is-archived";
            return published ? "publish-indicator is-live" : "publish-indicator is-hidden";
        }

        protected string GetPublishedIndicatorText(object isPub, object isArch)
        {
            bool archived = isArch != DBNull.Value && Convert.ToBoolean(isArch);
            bool published = isPub != DBNull.Value && Convert.ToBoolean(isPub);

            if (archived) return "Archived";
            return published ? "Visible" : "Hidden";
        }

        // Hide/Publish Button
        protected string GetToggleBtnCssClass(object isPub, object isArch)
        {
            bool archived = isArch != DBNull.Value && Convert.ToBoolean(isArch);
            bool published = isPub != DBNull.Value && Convert.ToBoolean(isPub);

            if (archived) return "action-btn btn-unpublish action-btn-disabled"; // Disabled if archived
            return published ? "action-btn btn-unpublish" : "action-btn btn-publish";
        }

        protected string GetToggleBtnText(object isPub)
        {
            bool published = isPub != DBNull.Value && Convert.ToBoolean(isPub);
            return published ? "Hide" : "Publish";
        }

        protected string GetToggleOnClick(object isPub, object isArch)
        {
            bool archived = isArch != DBNull.Value && Convert.ToBoolean(isArch);
            bool published = isPub != DBNull.Value && Convert.ToBoolean(isPub);

            if (archived) return "return false;";
            return published ? "return confirm('Hide this content from students?');" : "return confirm('Publish this content for students?');";
        }

        // Archive Button
        protected string GetArchiveBtnText(object isArch)
        {
            bool archived = isArch != DBNull.Value && Convert.ToBoolean(isArch);
            return archived ? "Unarchive" : "Archive";
        }

        protected string GetArchiveOnClick(object isArch)
        {
            bool archived = isArch != DBNull.Value && Convert.ToBoolean(isArch);
            return archived ? "return confirm('Unarchive this content?');" : "return confirm('Archive this content? It will be locked and hidden from students.');";
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }
    }
}