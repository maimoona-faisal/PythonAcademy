using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace PythonAcademy
{
    public partial class ViewResults : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int studentId;
                if (!TryGetStudentId(out studentId))
                {
                    ShowError("You must be logged in to view results.");
                    return;
                }

                int submissionId;
                if (!int.TryParse(Request.QueryString["SubmissionId"], out submissionId))
                {
                    ShowError("Submission not specified or invalid.");
                    return;
                }

                LoadResultsBySubmission(submissionId, studentId);
            }
        }

        protected void btnBackDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Learner-Jo/MemberDashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
            pnlResults.Visible = false;
        }

        private void LoadResultsBySubmission(int submissionId, int studentId)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdSubmission = new SqlCommand(@"
                    SELECT s.TotalScore,
                           s.AssessmentId,
                           a.Title AS AssessmentTitle
                    FROM   AssessmentSubmission s
                    INNER JOIN Assessment a ON a.AssessmentId = s.AssessmentId
                    WHERE  s.SubmissionId = @SubmissionId
                      AND  s.StudentId = @StudentId", conn);
                cmdSubmission.Parameters.AddWithValue("@SubmissionId", submissionId);
                cmdSubmission.Parameters.AddWithValue("@StudentId", studentId);

                int assessmentId;
                int totalScore;

                using (SqlDataReader reader = cmdSubmission.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Submission not found or access denied.");
                        return;
                    }

                    assessmentId = Convert.ToInt32(reader["AssessmentId"], CultureInfo.InvariantCulture);
                    totalScore = Convert.ToInt32(reader["TotalScore"], CultureInfo.InvariantCulture);
                    lblAssessmentTitle.Text = Convert.ToString(reader["AssessmentTitle"], CultureInfo.InvariantCulture);
                }

                SqlCommand cmdQuestions = new SqlCommand(@"
                    SELECT q.QuestionText,
                           sa.AnswerText,
                           qo.OptionText AS SelectedAnswer,
                           qo.IsCorrect
                    FROM   Question q
                    LEFT JOIN SubmissionAnswer sa
                           ON sa.QuestionId = q.QuestionId
                          AND sa.SubmissionId = @SubmissionId
                    LEFT JOIN QuestionOption qo
                           ON sa.SelectedOptionId = qo.OptionId
                    WHERE  q.AssessmentId = @AssessmentId
                    ORDER BY q.QuestionId", conn);
                cmdQuestions.Parameters.AddWithValue("@SubmissionId", submissionId);
                cmdQuestions.Parameters.AddWithValue("@AssessmentId", assessmentId);

                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmdQuestions))
                {
                    da.Fill(dt);
                }

                int totalQuestions = dt.Rows.Count;
                double percentage = totalQuestions > 0
                    ? (double)totalScore / totalQuestions * 100
                    : 0;

                lblTotalScore.Text = string.Format(
                    CultureInfo.InvariantCulture,
                    "Total Score: {0} / {1} ({2:F0}%)",
                    totalScore,
                    totalQuestions,
                    percentage);

                rptResults.DataSource = dt;
                rptResults.DataBind();
                pnlResults.Visible = true;
            }
        }

        protected string GetResultCardCss(object isCorrectValue)
        {
            return IsCorrect(isCorrectValue) ? "correct" : "incorrect";
        }

        protected string GetResultBadgeText(object isCorrectValue)
        {
            return IsCorrect(isCorrectValue) ? "Correct" : "Wrong";
        }

        protected string FormatSubmittedAnswer(object selectedAnswerValue, object answerTextValue)
        {
            string selectedAnswer = Convert.ToString(selectedAnswerValue, CultureInfo.InvariantCulture);
            if (!string.IsNullOrWhiteSpace(selectedAnswer))
            {
                return selectedAnswer;
            }

            string answerText = Convert.ToString(answerTextValue, CultureInfo.InvariantCulture);
            if (!string.IsNullOrWhiteSpace(answerText))
            {
                return answerText;
            }

            return "Not Answered";
        }

        private static bool IsCorrect(object isCorrectValue)
        {
            return isCorrectValue != null &&
                   isCorrectValue != DBNull.Value &&
                   Convert.ToBoolean(isCorrectValue, CultureInfo.InvariantCulture);
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
