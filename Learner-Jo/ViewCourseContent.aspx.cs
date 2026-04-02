using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class ViewCourseContent : System.Web.UI.Page
    {
        private int currentUserId;
        private int studentId;
        private string currentRole;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out currentUserId))
            {
                RedirectToLogin();
                return;
            }

            currentRole = Convert.ToString(Session["Role"], CultureInfo.InvariantCulture);
            if (string.IsNullOrWhiteSpace(currentRole))
            {
                RedirectToLogin();
                return;
            }

            studentId = IsStudentRole ? currentUserId : 0;

            if (!IsPostBack)
            {
                int moduleId;
                string qsId = Request.QueryString["ModuleID"] ?? Request.QueryString["id"];

                if (!int.TryParse(qsId, out moduleId) || moduleId <= 0)
                {
                    ShowError("No module selected.");
                    return;
                }

                bool canManageModule = CanManageModule(moduleId);
                Session["CurrentModuleID"] = moduleId;

                LoadModuleDetails(moduleId, canManageModule);
                if (!pnlContent.Visible)
                {
                    return;
                }

                if (IsStudentRole)
                {
                    CheckQuizAvailability(moduleId);
                    CheckExerciseAvailability(moduleId);
                    pnlAdminControls.Visible = false;
                    pnlFeedback.Visible = true; // SHOW FEEDBACK FOR STUDENTS
                }
                else
                {
                    pnlAdminControls.Visible = canManageModule;
                    pnlFeedback.Visible = false; // HIDE FEEDBACK FOR LECTURERS/ADMINS
                }

                LoadModuleTopics(moduleId, canManageModule);
            }
        }

        private bool IsStudentRole
        {
            get { return string.Equals(currentRole, "Student", StringComparison.OrdinalIgnoreCase); }
        }

        private bool IsLecturerRole
        {
            get { return string.Equals(currentRole, "Lecturer", StringComparison.OrdinalIgnoreCase); }
        }

        private bool IsAdminRole
        {
            get { return string.Equals(currentRole, "Admin", StringComparison.OrdinalIgnoreCase); }
        }

        private void RedirectToLogin()
        {
            string returnUrl = Server.UrlEncode(Request.RawUrl);
            Response.Redirect("~/LoginandRegister/LoginPage.aspx?returnUrl=" + returnUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
            pnlContent.Visible = false;
        }

        private void LoadModuleDetails(int moduleId, bool canManageModule)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                // --- Fetching Thumbnail and Lecturer Name---
                cmd.CommandText = @"
                    SELECT lc.Title, lc.Description, lc.ThumbnailPath, ISNULL(u.FullName, u.Username) AS LecturerName
                    FROM LearningContent lc
                    LEFT JOIN Users u ON lc.LecturerId = u.UserID
                    WHERE lc.ContentId = @ModuleID
                      AND (@CanManage = 1 OR lc.IsPublished = 1)";
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);
                cmd.Parameters.AddWithValue("@CanManage", canManageModule);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Module not found or not available.");
                        return;
                    }

                    lblTitle.Text = Convert.ToString(reader["Title"], CultureInfo.InvariantCulture);
                    lblDescription.Text = Convert.ToString(reader["Description"], CultureInfo.InvariantCulture);
                    lblLecturer.Text = Convert.ToString(reader["LecturerName"], CultureInfo.InvariantCulture);

                    // Load Thumbnail
                    string thumbPath = Convert.ToString(reader["ThumbnailPath"], CultureInfo.InvariantCulture);
                    if (!string.IsNullOrWhiteSpace(thumbPath))
                    {
                        imgThumbnail.ImageUrl = ResolveUrl(thumbPath);
                    }
                    else
                    {
                        imgThumbnail.ImageUrl = ResolveUrl("~/Images/Thumbnails/python101.png"); // Fallback
                    }
                }
            }
        }

        private void LoadModuleTopics(int moduleId, bool canManageModule)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
            SELECT mt.TopicId,
                   mt.TopicTitle,
                   mt.TopicContent,
                   mt.OrderIndex,
                   CASE WHEN tp.ProgressId IS NOT NULL THEN 1 ELSE 0 END AS IsCompleted
            FROM   ModuleTopics mt
            LEFT JOIN TopicProgress tp
                   ON tp.TopicId = mt.TopicId AND tp.StudentId = @StudentId
            WHERE  mt.ModuleId = @ModuleID
            ORDER BY mt.OrderIndex ASC";

                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptTopics.DataSource = dt;
                rptTopics.DataBind();
                pnlNoTopics.Visible = (dt.Rows.Count == 0);

                if (dt.Rows.Count > 0 && IsStudentRole)
                {
                    int completedTopicsCount = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        if (Convert.ToInt32(row["IsCompleted"]) == 1) completedTopicsCount++;
                    }

                    bool allTopicsDone = (completedTopicsCount == dt.Rows.Count);
                    bool quizDone = !btnTakeQuiz.Visible || btnTakeQuiz.Text.Contains("Quiz Complete");
                    bool exerciseDone = !btnSubmitExercise.Visible || btnSubmitExercise.Text.Contains("Graded:");

                    if (allTopicsDone && quizDone && exerciseDone)
                    {
                        GenerateCertificateIfNeeded(studentId, moduleId);
                        btnViewCert.Visible = true;
                    }
                    else
                    {
                        btnViewCert.Visible = false;
                    }
                }
            }
        }

        private void GenerateCertificateIfNeeded(int studentId, int moduleId)
        {
            string connStr = GetConnectionString();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string certSql = @"
                    IF NOT EXISTS (SELECT 1 FROM Certificates WHERE StudentId = @StudentId AND ModuleId = @ModuleId)
                    BEGIN
                        INSERT INTO Certificates (StudentId, ModuleId, CertificateHash) 
                        VALUES (@StudentId, @ModuleId, @Hash)
                    END";
                using (SqlCommand cmd = new SqlCommand(certSql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    cmd.Parameters.AddWithValue("@ModuleId", moduleId);
                    cmd.Parameters.AddWithValue("@Hash", Guid.NewGuid().ToString("N"));
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void CheckQuizAvailability(int moduleId)
        {
            string connStr = GetConnectionString();
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT a.AssessmentId, s.SubmissionId, s.TotalScore
                    FROM Assessment a
                    LEFT JOIN AssessmentSubmission s ON a.AssessmentId = s.AssessmentId AND s.StudentId = @StudentId
                    WHERE a.ContentID = @ModuleId AND a.AssessmentType = 'Quiz' AND a.IsPublished = 1";
                cmd.Parameters.AddWithValue("@ModuleId", moduleId);
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        btnTakeQuiz.Visible = true;
                        Session["CurrentQuizAssessmentId"] = reader["AssessmentId"];

                        if (reader["SubmissionId"] != DBNull.Value)
                        {
                            string score = reader["TotalScore"] != DBNull.Value ? reader["TotalScore"].ToString() : "Pending";
                            btnTakeQuiz.Text = $"✅ Quiz Complete (Score: {score})";
                            btnTakeQuiz.Enabled = false;
                            btnTakeQuiz.CssClass = "btn-outline";
                        }
                        else
                        {
                            btnTakeQuiz.Text = "Take Quiz";
                            btnTakeQuiz.Enabled = true;
                            btnTakeQuiz.CssClass = "btn-quiz-act";
                        }
                    }
                    else
                    {
                        btnTakeQuiz.Visible = false;
                    }
                }
            }
        }

        private void CheckExerciseAvailability(int moduleId)
        {
            string connStr = GetConnectionString();
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT a.AssessmentId, s.SubmissionId, s.TotalScore
                    FROM Assessment a
                    LEFT JOIN AssessmentSubmission s ON a.AssessmentId = s.AssessmentId AND s.StudentId = @StudentId
                    WHERE a.ContentID = @ModuleId AND a.AssessmentType = 'Exercise' AND a.IsPublished = 1";
                cmd.Parameters.AddWithValue("@ModuleId", moduleId);
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        btnSubmitExercise.Visible = true;
                        Session["CurrentExerciseAssessmentId"] = reader["AssessmentId"];

                        if (reader["SubmissionId"] != DBNull.Value)
                        {
                            if (reader["TotalScore"] != DBNull.Value)
                            {
                                btnSubmitExercise.Text = $"✅ Graded: {reader["TotalScore"]}";
                                btnSubmitExercise.CssClass = "btn-outline";
                                btnSubmitExercise.Enabled = true;
                            }
                            else
                            {
                                btnSubmitExercise.Text = "⏳ Pending Grade";
                                btnSubmitExercise.CssClass = "btn-outline";
                                btnSubmitExercise.Enabled = false;
                            }
                        }
                        else
                        {
                            btnSubmitExercise.Text = "Submit Exercise";
                            btnSubmitExercise.Enabled = true;
                            btnSubmitExercise.CssClass = "btn-ex-act";
                        }
                    }
                    else
                    {
                        Session.Remove("CurrentExerciseAssessmentId");
                        btnSubmitExercise.Visible = false;
                    }
                }
            }
        }

        protected void rptTopics_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "START_LESSON")
            {
                int topicId = Convert.ToInt32(e.CommandArgument);
                Response.Redirect("~/Learner-wei/viewTopicContent.aspx?TopicId=" + topicId, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected string GetLessonButtonText(object isCompleted)
        {
            return Convert.ToInt32(isCompleted) == 1
                ? "Review Lesson"
                : "Start Lesson →";
        }

        protected void btnViewCert_Click(object sender, EventArgs e)
        {
            int moduleId = Convert.ToInt32(Session["CurrentModuleID"]);
            string hash = "";

            string connStr = GetConnectionString();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT CertificateHash FROM Certificates WHERE StudentId = @S AND ModuleId = @M", conn))
                {
                    cmd.Parameters.AddWithValue("@S", studentId);
                    cmd.Parameters.AddWithValue("@M", moduleId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) hash = result.ToString();
                }
            }

            if (!string.IsNullOrEmpty(hash))
            {
                Response.Redirect("~/Learner-wei/viewCert.aspx?hash=" + hash, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnTakeQuiz_Click(object sender, EventArgs e)
        {
            if (Session["CurrentModuleID"] == null)
            {
                ShowError("No module selected.");
                return;
            }

            int moduleId = Convert.ToInt32(Session["CurrentModuleID"], CultureInfo.InvariantCulture);
            Response.Redirect("~/Learner-Jo/TakeAssessment.aspx?ModuleID=" + moduleId + "&Type=Quiz", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnSubmitExercise_Click(object sender, EventArgs e)
        {
            if (Session["CurrentExerciseAssessmentId"] == null) return;
            int assessmentId = Convert.ToInt32(Session["CurrentExerciseAssessmentId"]);

            if (btnSubmitExercise.Text.Contains("Graded"))
            {
                Response.Redirect("~/Learner-wei/viewMyGrade.aspx?AssessmentId=" + assessmentId, false);
            }
            else
            {
                Response.Redirect("~/Learner-Jo/SubmitExercise.aspx?AssessmentId=" + assessmentId, false);
            }
            Context.ApplicationInstance.CompleteRequest();
        }

        private static string GetConnectionString()
        {
            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["PythonAcademyDb"];
            return settings.ConnectionString;
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            object sessionValue = Session["UserId"] ?? Session["UserID"];
            if (sessionValue == null) { userId = 0; return false; }
            if (sessionValue is int) { userId = (int)sessionValue; return true; }
            return int.TryParse(Convert.ToString(sessionValue, CultureInfo.InvariantCulture), out userId);
        }

        private bool TryGetCurrentModuleId(out int moduleId)
        {
            object sessionValue = Session["CurrentModuleID"];
            if (sessionValue == null) { moduleId = 0; return false; }
            if (sessionValue is int) { moduleId = (int)sessionValue; return true; }
            return int.TryParse(Convert.ToString(sessionValue, CultureInfo.InvariantCulture), out moduleId);
        }

        private bool CanManageModule(int moduleId)
        {
            if (moduleId <= 0 || (!IsAdminRole && !IsLecturerRole)) return false;

            string connStr = GetConnectionString();
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT COUNT(1)
                    FROM   LearningContent
                    WHERE  ContentId = @ModuleID
                      AND (@IsAdmin = 1 OR LecturerId = @UserId)";
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);
                cmd.Parameters.AddWithValue("@IsAdmin", IsAdminRole);
                cmd.Parameters.AddWithValue("@UserId", currentUserId);

                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture) > 0;
            }
        }

        protected void btnEditContent_Click(object sender, EventArgs e)
        {
            int moduleId;
            if (!TryGetCurrentModuleId(out moduleId) || !CanManageModule(moduleId)) return;
            Response.Redirect("~/Lecture/UploadContent.aspx?editId=" + moduleId.ToString(CultureInfo.InvariantCulture), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnDeleteContent_Click(object sender, EventArgs e)
        {
            int moduleId;
            if (!TryGetCurrentModuleId(out moduleId) || !CanManageModule(moduleId)) return;

            string connStr = GetConnectionString();
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE LearningContent
                SET IsPublished = 0
                WHERE ContentId = @ID
                  AND (@IsAdmin = 1 OR LecturerId = @UserId)", conn))
            {
                cmd.Parameters.AddWithValue("@ID", moduleId);
                cmd.Parameters.AddWithValue("@IsAdmin", IsAdminRole);
                cmd.Parameters.AddWithValue("@UserId", currentUserId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            string redirectUrl = IsAdminRole ? "~/Admin/ManageContent.aspx" : "~/Lecture/UploadContent.aspx";
            Response.Redirect(redirectUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnManageTopics_Click(object sender, EventArgs e)
        {
            int moduleId;
            if (!TryGetCurrentModuleId(out moduleId) || !CanManageModule(moduleId)) return;
            Response.Redirect("~/Lecture/manageTopics.aspx?ModuleId=" + moduleId.ToString(CultureInfo.InvariantCulture), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // --- STUDENT FEEDBACK HANDLER ---
        protected void btnSubmitFeedback_Click(object sender, EventArgs e)
        {
            if (!IsStudentRole) return;

            string feedbackText = txtFeedback.Text.Trim();
            if (string.IsNullOrWhiteSpace(feedbackText))
            {
                lblFeedbackMsg.Text = "Please enter your feedback before submitting.";
                lblFeedbackMsg.ForeColor = System.Drawing.Color.OrangeRed;
                lblFeedbackMsg.Visible = true;
                return;
            }

            int moduleId = Convert.ToInt32(Session["CurrentModuleID"]);

            try
            {
                string connStr = GetConnectionString();
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"
                        INSERT INTO Feedback (ContentId, StudentId, FeedbackMessage)
                        VALUES (@ContentId, @StudentId, @Msg)";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ContentId", moduleId);
                        cmd.Parameters.AddWithValue("@StudentId", studentId);
                        cmd.Parameters.AddWithValue("@Msg", feedbackText);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                txtFeedback.Text = string.Empty;
                lblFeedbackMsg.Text = "Thank you! Your feedback has been sent to the instructor.";
                lblFeedbackMsg.ForeColor = System.Drawing.Color.LightGreen;
                lblFeedbackMsg.Visible = true;
            }
            catch (Exception ex)
            {
                Trace.Warn("Feedback", "Failed to submit feedback.", ex);
                lblFeedbackMsg.Text = "We couldn't submit your feedback right now. Please try again.";
                lblFeedbackMsg.ForeColor = System.Drawing.Color.OrangeRed;
                lblFeedbackMsg.Visible = true;
            }
        }
    }
}