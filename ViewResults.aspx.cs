using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace PythonAcademy
{
    public partial class ViewResults : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Use the same session key as LoginPage / TakeAssessment
                if (Session["UserId"] == null)
                {
                    lblError.Text = "You must be logged in.";
                    pnlResults.Visible = false;
                    return;
                }

                // Get SubmissionId from query string
                if (Request.QueryString["SubmissionId"] != null &&
                    int.TryParse(Request.QueryString["SubmissionId"], out int submissionId))
                {
                    LoadResultsBySubmission(submissionId);
                }
                else
                {
                    lblError.Text = "Submission not specified or invalid.";
                    pnlResults.Visible = false;
                }
            }
        }

        protected void btnBackDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("MemberDashboard.aspx");
        }

        private void LoadResultsBySubmission(int submissionId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;
            int loggedInStudentId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string submissionQuery = @"
                    SELECT s.AssessmentId, s.StudentId, s.TotalScore, a.Title AS AssessmentTitle
                    FROM AssessmentSubmission s
                    INNER JOIN Assessment a ON a.AssessmentId = s.AssessmentId
                    WHERE s.SubmissionId = @SubmissionId
                    AND s.StudentId = @StudentId";

                SqlCommand cmdSubmission = new SqlCommand(submissionQuery, conn);
                cmdSubmission.Parameters.AddWithValue("@SubmissionId", submissionId);
                cmdSubmission.Parameters.AddWithValue("@StudentId", loggedInStudentId);

                SqlDataReader reader = cmdSubmission.ExecuteReader();

                if (!reader.Read())
                {
                    lblError.Text = "Submission not found or access denied.";
                    pnlResults.Visible = false;
                    reader.Close();
                    return;
                }

                int totalScore = Convert.ToInt32(reader["TotalScore"]);
                string assessmentTitle = reader["AssessmentTitle"].ToString();
                lblAssessmentTitle.Text = assessmentTitle;

                reader.Close();

                // Get all questions and selected answers
                string questionQuery = @"
                    SELECT q.QuestionText,
                           qo.OptionText AS SelectedAnswer,
                           qo.IsCorrect
                    FROM SubmissionAnswer sa
                    INNER JOIN Question q ON sa.QuestionId = q.QuestionId
                    LEFT JOIN QuestionOption qo ON sa.SelectedOptionId = qo.OptionId
                    WHERE sa.SubmissionId = @SubmissionId";

                SqlCommand cmdQuestions = new SqlCommand(questionQuery, conn);
                cmdQuestions.Parameters.AddWithValue("@SubmissionId", submissionId);

                SqlDataAdapter da = new SqlDataAdapter(cmdQuestions);
                DataTable dtQuestions = new DataTable();
                da.Fill(dtQuestions);

                int totalQuestions = dtQuestions.Rows.Count;
                double percentage = totalQuestions > 0
                    ? ((double)totalScore / totalQuestions) * 100
                    : 0;

                lblTotalScore.Text = $"Total Score: {totalScore} / {totalQuestions} ({percentage:F0}%)";

                // Bind to Repeater
                rptResults.DataSource = dtQuestions;
                rptResults.DataBind();

                pnlResults.Visible = true;
            }
        }
    }
}