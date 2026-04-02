using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace PythonAcademy
{
    public partial class CourseView : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourse();
            }
        }

        private void LoadCourse()
        {
            string idText = Request.QueryString["id"];

            int contentId;
            if (!int.TryParse(idText, out contentId))
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            string sql = @"
                SELECT ContentId, Title, Description, ContentType, Url, FilePath
                FROM LearningContent
                WHERE ContentId = @ContentId
                  AND IsPublished = 1";

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@ContentId", contentId);
                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        Response.Redirect("~/Default.aspx");
                        return;
                    }

                    litTitle.Text = dr["Title"].ToString();
                    litDescription.Text = dr["Description"].ToString();

                    bool isLoggedIn = Session["UserId"] != null;
                    bool isPreviewCourse = (contentId == 1); // Python Basics only

                    if (isLoggedIn)
                    {
                        phFullAccess.Visible = true;
                        phGuestPreview.Visible = false;

                        string title = dr["Title"].ToString();
                        string description = dr["Description"].ToString();
                        string url = dr["Url"] == DBNull.Value ? "" : dr["Url"].ToString();

                        litFullContent.Text = BuildFullContentHtml(title, description, url);
                    }
                    else
                    {
                        if (isPreviewCourse)
                        {
                            phGuestPreview.Visible = true;
                            phFullAccess.Visible = false;

                            litPreviewContent.Text = BuildPreviewHtml(contentId);
                        }
                        else
                        {
                            Response.Redirect("~/Default.aspx");
                        }
                    }
                }
            }
        }

        private string BuildPreviewHtml(int contentId)
        {
            if (contentId == 1)
            {
                return @"
                    <p>Python is a beginner-friendly programming language known for its simple syntax and readability.</p>
                    <p>In this topic, learners are introduced to variables, basic data types, and simple output using <code>print()</code>.</p>
                    <p>Example:</p>
                    <pre>x = 5
name = ""Alice""
print(x)
print(name)</pre>
                    <p>This preview gives a basic introduction only. The remaining lesson, quiz, and exercise are available for registered learners.</p>";
            }

            return "<p>Preview not available.</p>";
        }

        private string BuildFullContentHtml(string title, string description, string url)
        {
            string resourceLink = "";

            if (!string.IsNullOrWhiteSpace(url))
            {
                resourceLink = "<p><a href='" + url + "' target='_blank'>Open learning resource</a></p>";
            }

            return @"
                <p>" + description + @"</p>
                <h3>Lesson Overview</h3>
                <p>This module contains the full learning material, linked resources, and related assessments for registered learners.</p>
                <h3>What you will learn</h3>
                <ul>
                    <li>Core concepts for this topic</li>
                    <li>Examples and explanations</li>
                    <li>Follow-up quiz and exercise tasks</li>
                </ul>
                " + resourceLink;
        }
    }
}
