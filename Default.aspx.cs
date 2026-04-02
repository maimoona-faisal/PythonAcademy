using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace PythonAcademy
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCourses();
            }
        }

        private void BindCourses()
        {
            // Added 'TOP 5' and ordered by ContentId DESC so the newest show first!
            string sql = @"
            SELECT TOP 5
                ContentId,
                Title,
                Description,
                ContentType,
                FilePath,
                Url,
                IsPublished,
                ThumbnailPath, -- <--- WE ADDED THIS LINE HERE!
                CASE 
                    WHEN ContentId = 1 THEN CAST(1 AS BIT)
                    ELSE CAST(0 AS BIT)
                END AS IsPreviewFree
            FROM LearningContent
            WHERE IsPublished = 1
            ORDER BY ContentId DESC";

            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptCourses.DataSource = dt;
                rptCourses.DataBind();
            }
        }

        protected bool UserIsLoggedIn()
        {
            return Session["UserId"] != null;
        }

        protected bool IsPreviewFree(object value)
        {
            if (value == null || value == DBNull.Value)
                return false;

            return Convert.ToBoolean(value);
        }

        protected string GetCourseCardCss(object previewValue)
        {
            if (UserIsLoggedIn() || IsPreviewFree(previewValue))
                return "course-card";

            return "course-card locked";
        }

        protected bool ShowLockedBadge(object previewValue)
        {
            return !UserIsLoggedIn() && !IsPreviewFree(previewValue);
        }

        protected string GetCourseUrl(object contentIdObj, object previewValue)
        {
            if (UserIsLoggedIn() || IsPreviewFree(previewValue))
                return ResolveUrl("~/CourseView.aspx?id=" + contentIdObj);

            return "javascript:void(0);";
        }

        protected string GetCourseOnClick(object previewValue)
        {
            if (UserIsLoggedIn() || IsPreviewFree(previewValue))
                return "";

            return "showLoginModal(); return false;";
        }

        protected string GetResourceLink(object url, object filePath)
        {
            if (url != null && url != DBNull.Value && !string.IsNullOrWhiteSpace(url.ToString()))
                return url.ToString();
            if (filePath != null && filePath != DBNull.Value && !string.IsNullOrWhiteSpace(filePath.ToString()))
                return filePath.ToString();
            return "";
        }

        protected string GetCourseButtonText(object previewValue)
        {
            if (UserIsLoggedIn())
                return "View Course";

            if (IsPreviewFree(previewValue))
                return "View Preview";

            return "Log In to Access";
        }
    }
}