using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class SubmitExercise : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            int ignoredStudentId;
            if (!TryGetStudentId(out ignoredStudentId))
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                int assessmentId;
                if (!TryGetAssessmentId(out assessmentId))
                {
                    ShowMessage("Cannot load exercise. Missing or invalid AssessmentId.", true);
                    rptQuestions.Visible = false;
                    btnSubmit.Visible = false;
                    return;
                }

                LoadAssessmentInfo(assessmentId);
                LoadQuestions(assessmentId);
            }
        }

        private void LoadAssessmentInfo(int assessmentId)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT a.Title AS AssessmentTitle,
                           lc.Title AS ModuleTitle
                    FROM   Assessment a
                    LEFT JOIN LearningContent lc ON lc.ContentId = a.ContentID
                    WHERE  a.AssessmentId = @AssessmentId";
                cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowMessage("The requested exercise could not be found.", true);
                        rptQuestions.Visible = false;
                        btnSubmit.Visible = false;
                        return;
                    }

                    lblAssessmentTitle.Text = Convert.ToString(reader["AssessmentTitle"], CultureInfo.InvariantCulture);
                    lblModuleTitle.Text = Convert.ToString(reader["ModuleTitle"], CultureInfo.InvariantCulture);
                }
            }
        }

        private void LoadQuestions(int assessmentId)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT QuestionId, QuestionText
                    FROM   Question
                    WHERE  AssessmentId = @AssessmentId
                    ORDER BY QuestionId";
                cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("No exercise questions were found for this assessment.", true);
                    rptQuestions.Visible = false;
                    btnSubmit.Visible = false;
                    return;
                }

                rptQuestions.DataSource = dt;
                rptQuestions.DataBind();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            int studentId;
            if (!TryGetStudentId(out studentId))
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            int assessmentId;
            if (!TryGetAssessmentId(out assessmentId))
            {
                ShowMessage("Cannot submit. Missing assessment information.", true);
                return;
            }

            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdSub = new SqlCommand(@"
                    INSERT INTO AssessmentSubmission (AssessmentId, StudentId, SubmittedAt, TotalScore)
                    OUTPUT INSERTED.SubmissionId
                    VALUES (@AssessmentId, @StudentId, GETDATE(), 0)", conn);
                cmdSub.Parameters.AddWithValue("@AssessmentId", assessmentId);
                cmdSub.Parameters.AddWithValue("@StudentId", studentId);

                int submissionId = (int)cmdSub.ExecuteScalar();

                foreach (RepeaterItem item in rptQuestions.Items)
                {
                    if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem)
                    {
                        continue;
                    }

                    HiddenField hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                    TextBox txtAnswer = (TextBox)item.FindControl("txtAnswer");
                    int questionId;
                    if (hfQuestionId == null || txtAnswer == null || !int.TryParse(hfQuestionId.Value, out questionId))
                    {
                        continue;
                    }

                    SqlCommand cmdAns = new SqlCommand(@"
                        INSERT INTO SubmissionAnswer (SubmissionId, QuestionId, AnswerText)
                        VALUES (@SubmissionId, @QuestionId, @AnswerText)", conn);
                    cmdAns.Parameters.AddWithValue("@SubmissionId", submissionId);
                    cmdAns.Parameters.AddWithValue("@QuestionId", questionId);
                    cmdAns.Parameters.AddWithValue("@AnswerText", txtAnswer.Text.Trim());
                    cmdAns.ExecuteNonQuery();
                }
            }

            ShowMessage("Your answers have been submitted successfully. Your lecturer will review and grade them.", false);
            btnSubmit.Visible = false;
            rptQuestions.Visible = false;
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            msgBox.Attributes["class"] = isError ? "msg-alert error" : "msg-alert success";
            pnlMsg.Visible = true;
        }

        private static string GetConnectionString()
        {
            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["PythonAcademyDB"];
            if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
            {
                throw new ConfigurationErrorsException("Connection string 'PythonAcademyDB' is missing.");
            }

            return settings.ConnectionString;
        }

        private bool TryGetAssessmentId(out int assessmentId)
        {
            return int.TryParse(
                Convert.ToString(Request.QueryString["AssessmentId"], CultureInfo.InvariantCulture),
                out assessmentId);
        }

        private bool TryGetStudentId(out int studentId)
        {
            object sessionValue = Session["UserId"];
            if (sessionValue == null)
            {
                studentId = 0;
                return false;
            }

            if (sessionValue is int)
            {
                studentId = (int)sessionValue;
                return true;
            }

            return int.TryParse(Convert.ToString(sessionValue, CultureInfo.InvariantCulture), out studentId);
        }
    }
}
