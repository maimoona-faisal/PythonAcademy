using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy.Learner_wei
{
    public partial class viewTopicContent : System.Web.UI.Page
    {
        private int TopicId => Request.QueryString["TopicId"] != null ? Convert.ToInt32(Request.QueryString["TopicId"]) : 0;
        private int ModuleId
        {
            get { return ViewState["ModuleId"] != null ? Convert.ToInt32(ViewState["ModuleId"]) : 0; }
            set { ViewState["ModuleId"] = value; }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"] == null)
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (TopicId == 0) Response.Redirect("~/Learner-Jo/MemberDashboard.aspx");
                LoadTopic();

                // Check if user is Admin or Lecturer
                string role = Session["Role"].ToString();
                if (role == "Admin" || role == "Lecturer")
                {
                    btnMarkComplete.Visible = false; // Hide the student button
                    btnAdminReturn.Visible = true;   // Show the admin button
                }
            }

        }
        private void LoadTopic()
        {
            string cs = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                // 1. added TopicType to the SELECT statement!
                using (SqlCommand cmd = new SqlCommand("SELECT ModuleId, TopicTitle, TopicContent, TopicType FROM ModuleTopics WHERE TopicId = @T", con))
                {
                    cmd.Parameters.AddWithValue("@T", TopicId);
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            ModuleId = Convert.ToInt32(rdr["ModuleId"]);
                            lblTopicTitle.Text = rdr["TopicTitle"].ToString();

                            string rawContent = rdr["TopicContent"].ToString();
                            string topicType = rdr["TopicType"].ToString();
                            string formattedHtml = "";

                            // 2. The Smart Wrapper Logic
                            if (topicType == "Text")
                            {
                                formattedHtml = rawContent;
                            }
                            else if (topicType == "PDF")
                            {
                                // Wraps PDFs in a tall iframe with a white background
                                string resolvedPath = ResolveUrl(rawContent);
                                formattedHtml = $"<iframe src='{resolvedPath}' width='100%' height='800px' style='border: none; border-radius: 12px; background: white;'></iframe>";
                            }
                            else if (topicType == "Word" || topicType == "PowerPoint")
                            {
                                // Fix: Browsers can't iframe these (docx, ppt) adding nice download button instead.
                                string resolvedPath = ResolveUrl(rawContent);
                                string fileIcon = topicType == "Word" ? "&#128196;" : "&#128202;";
                                formattedHtml = $"<div style='text-align: center; padding: 50px; background: rgba(0,0,0,0.3); border: 1px dashed rgba(255,255,255,0.2); border-radius: 12px;'><p style='color: #a9b8d6; margin-bottom: 20px;'>Browsers cannot preview {topicType} files directly.</p><a href='{resolvedPath}' target='_blank' style='display: inline-block; padding: 12px 24px; background: #00f3ff; color: #0b1220; text-decoration: none; font-weight: bold; border-radius: 8px;'>{fileIcon} Download {topicType} Document</a></div>";
                            }
                            else if (topicType == "Video")
                            {
                                // Wraps MP4s in a native HTML5 video player
                                string resolvedPath = ResolveUrl(rawContent);
                                formattedHtml = $"<video width='100%' height='auto' controls style='border-radius: 12px; border: 1px solid rgba(255,255,255,0.1);'><source src='{resolvedPath}' type='video/mp4'>Your browser does not support the video tag.</video>";
                            }
                            else if (topicType == "Link")
                            {
                                if (rawContent.Contains("youtu.be") || rawContent.Contains("youtube.com"))
                                {
                                    // YouTube Video logic
                                    string embedUrl = rawContent.Replace("watch?v=", "embed/").Replace("youtu.be/", "www.youtube.com/embed/");
                                    formattedHtml = $"<iframe src='{embedUrl}' width='100%' height='500px' style='border: none; border-radius: 12px;'></iframe>";
                                }
                                else if (rawContent.Contains("docs.google.com/presentation"))
                                {
                                    // GOOGLE SLIDES 
                                    formattedHtml = $"<iframe src='{rawContent}' width='100%' height='569' frameborder='0' allowfullscreen='true' mozallowfullscreen='true' webkitallowfullscreen='true' style='border-radius:12px; border:1px solid rgba(255,255,255,.1); background: #000;'></iframe>";
                                }
                                else
                                {
                                    // Standard external link button
                                    formattedHtml = $"<a href='{rawContent}' target='_blank' style='display: inline-block; padding: 12px 24px; background: #00f3ff; color: #0b1220; text-decoration: none; font-weight: bold; border-radius: 8px;'>Open External Resource &#8599;</a>";
                                }
                            }
                            else
                            {
                                formattedHtml = rawContent; // Fallback
                            }

                            // 3. Inject the beautifully wrapped HTML into the page
                            litTopicContent.Text = formattedHtml;
                        }
                    }
                }
            }
        }

        protected void lnkBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Learner-Jo/ViewCourseContent.aspx?ModuleID=" + ModuleId, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnMarkComplete_Click(object sender, EventArgs e)
        {
            int studentId = Convert.ToInt32(Session["UserId"]);
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. Mark this specific topic as complete
                string insertTopicSql = @"
                    IF NOT EXISTS (SELECT 1 FROM TopicProgress WHERE StudentId = @StudentId AND TopicId = @TopicId)
                    BEGIN
                        INSERT INTO TopicProgress (StudentId, TopicId) VALUES (@StudentId, @TopicId)
                    END";
                using (SqlCommand cmd = new SqlCommand(insertTopicSql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    cmd.Parameters.AddWithValue("@TopicId", TopicId);
                    cmd.ExecuteNonQuery();
                }

                // 2. Calculate the overall module progress
                string mathSql = @"
                    DECLARE @TotalTopics FLOAT = (SELECT COUNT(*) FROM ModuleTopics WHERE ModuleId = @ModuleId);
                    DECLARE @CompletedTopics FLOAT = (
                        SELECT COUNT(DISTINCT tp.TopicId) 
                        FROM TopicProgress tp 
                        INNER JOIN ModuleTopics mt ON tp.TopicId = mt.TopicId 
                        WHERE tp.StudentId = @StudentId AND mt.ModuleId = @ModuleId
                    );
                    SELECT CASE WHEN @TotalTopics = 0 THEN 0 ELSE (@CompletedTopics / @TotalTopics) * 100 END AS Pct;";

                int progressPct = 0;
                using (SqlCommand cmd = new SqlCommand(mathSql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    cmd.Parameters.AddWithValue("@ModuleId", ModuleId);
                    progressPct = Convert.ToInt32(cmd.ExecuteScalar());
                }

                // 3. Update the main Progress table
                string updateProgressSql = @"
                    IF EXISTS (SELECT 1 FROM Progress WHERE StudentId = @StudentId AND ModuleId = @ModuleId)
                        UPDATE Progress SET ProgressPercentage = @Pct WHERE StudentId = @StudentId AND ModuleId = @ModuleId
                    ELSE
                        INSERT INTO Progress (StudentId, ModuleId, ProgressPercentage) VALUES (@StudentId, @ModuleId, @Pct)";
                using (SqlCommand cmd = new SqlCommand(updateProgressSql, conn))
                {
                    cmd.Parameters.AddWithValue("@Pct", progressPct);
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    cmd.Parameters.AddWithValue("@ModuleId", ModuleId);
                    cmd.ExecuteNonQuery();
                }

                // 4. CERTIFICATE GENERATION: If 100%, grant a certificate!
                if (progressPct >= 100)
                {
                    string certSql = @"
                        IF NOT EXISTS (SELECT 1 FROM Certificates WHERE StudentId = @StudentId AND ModuleId = @ModuleId)
                        BEGIN
                            INSERT INTO Certificates (StudentId, ModuleId, CertificateHash) 
                            VALUES (@StudentId, @ModuleId, @Hash)
                        END";
                    using (SqlCommand cmd = new SqlCommand(certSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@StudentId", studentId);
                        cmd.Parameters.AddWithValue("@ModuleId", ModuleId);
                        cmd.Parameters.AddWithValue("@Hash", Guid.NewGuid().ToString("N"));
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Redirect back to the Table of Contents!
            Response.Redirect("~/Learner-Jo/ViewCourseContent.aspx?ModuleID=" + ModuleId, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnAdminReturn_Click(object sender, EventArgs e)
        {
            // Just redirect without running any database progress math!
            Response.Redirect("~/Learner-Jo/ViewCourseContent.aspx?ModuleID=" + ModuleId, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}