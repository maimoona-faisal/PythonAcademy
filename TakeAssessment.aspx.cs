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
    public partial class TakeAssessment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null)
                {
                    lblError.Text = "You must be logged in to take the assessment.";
                    pnlQuiz.Visible = false;
                    return;
                }

                string moduleIdStr = Request.QueryString["ModuleID"];
                string type = Request.QueryString["Type"];

                if (!string.IsNullOrEmpty(moduleIdStr) && type != null)
                {
                    if (int.TryParse(moduleIdStr, out int moduleId))
                    {
                        LoadAssessment(moduleId, type);
                    }
                    else
                    {
                        lblError.Text = "Invalid ModuleID.";
                        pnlQuiz.Visible = false;
                    }
                }
                else
                {
                    lblError.Text = "Missing ModuleID or Type.";
                    pnlQuiz.Visible = false;
                }
            }
        }

        private void LoadAssessment(int moduleId, string type)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            string moduleTitle = "";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmdModule = new SqlCommand(
                    "SELECT Title FROM LearningContent WHERE ContentId=@ModuleId", conn);
                cmdModule.Parameters.AddWithValue("@ModuleId", moduleId);
                conn.Open();
                object result = cmdModule.ExecuteScalar();
                if (result != null)
                    moduleTitle = result.ToString();
                else
                {
                    lblError.Text = $"Module not found for ModuleID={moduleId}";
                    pnlQuiz.Visible = false;
                    return;
                }
                conn.Close();
            }

            DataTable dtAssessments = new DataTable();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT a.AssessmentId, a.Title
                    FROM Assessment a
                    INNER JOIN LearningContent lc ON lc.LecturerId = a.LecturerId
                    WHERE a.IsPublished = 1 AND a.AssessmentType = @Type";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Type", type);
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtAssessments);
                conn.Close();
            }

            DataRow matchedRow = null;
            string cleanModuleTitle = moduleTitle.Replace(" ", "").ToLower();
            foreach (DataRow row in dtAssessments.Rows)
            {
                string cleanAssessmentTitle = row["Title"].ToString().Replace(" ", "").ToLower();
                if (cleanAssessmentTitle.Contains(cleanModuleTitle))
                {
                    matchedRow = row;
                    break;
                }
            }

            if (matchedRow == null)
            {
                lblError.Text = "No matching assessment found for this module.";
                pnlQuiz.Visible = false;
                return;
            }

            int assessmentId = Convert.ToInt32(matchedRow["AssessmentId"]);
            lblQuizTitle.Text = matchedRow["Title"].ToString();
            ViewState["AssessmentId"] = assessmentId;

            LoadQuestions();
        }

        private void LoadQuestions()
        {
            if (ViewState["AssessmentId"] == null)
            {
                lblError.Text = "AssessmentId is null.";
                return;
            }

            int assessmentId = Convert.ToInt32(ViewState["AssessmentId"]);
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"SELECT QuestionId, QuestionText FROM Question WHERE AssessmentId=@AssessmentId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptQuestions.DataSource = dt;
                rptQuestions.DataBind();
            }
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            int questionId = Convert.ToInt32(((HiddenField)e.Item.FindControl("hfQuestionId")).Value);
            RadioButtonList rblOptions = (RadioButtonList)e.Item.FindControl("rblOptions");

            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT OptionId, OptionText FROM QuestionOption WHERE QuestionId=@QuestionId", conn))
            {
                cmd.Parameters.AddWithValue("@QuestionId", questionId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dtOptions = new DataTable();
                da.Fill(dtOptions);

                rblOptions.DataSource = dtOptions;
                rblOptions.DataTextField = "OptionText";
                rblOptions.DataValueField = "OptionId";
                rblOptions.DataBind();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (ViewState["AssessmentId"] == null)
            {
                lblError.Text = "Cannot submit. AssessmentId is null.";
                return;
            }

            int assessmentId = Convert.ToInt32(ViewState["AssessmentId"]);
            int studentId = Convert.ToInt32(Session["UserId"]);
            int submissionId = 0;
            int totalScore = 0;

            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Insert new submission
                string insertSubmissionQuery = @"
            INSERT INTO AssessmentSubmission
            (AssessmentId, StudentId, SubmittedAt, TotalScore)
            OUTPUT INSERTED.SubmissionId
            VALUES (@AssessmentId, @StudentId, GETDATE(), 0)";
                SqlCommand cmdInsertSubmission = new SqlCommand(insertSubmissionQuery, conn);
                cmdInsertSubmission.Parameters.AddWithValue("@AssessmentId", assessmentId);
                cmdInsertSubmission.Parameters.AddWithValue("@StudentId", studentId);

                submissionId = (int)cmdInsertSubmission.ExecuteScalar();

                // Loop through questions
                foreach (RepeaterItem item in rptQuestions.Items)
                {
                    if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem)
                        continue;

                    int questionId = Convert.ToInt32(((HiddenField)item.FindControl("hfQuestionId")).Value);
                    RadioButtonList rblOptions = (RadioButtonList)item.FindControl("rblOptions");

                    if (rblOptions == null || string.IsNullOrEmpty(rblOptions.SelectedValue))
                        continue; // skip unanswered questions

                    int selectedOptionId = Convert.ToInt32(rblOptions.SelectedValue);

                    string insertAnswerQuery = @"
                INSERT INTO SubmissionAnswer
                (SubmissionId, QuestionId, SelectedOptionId)
                VALUES (@SubmissionId, @QuestionId, @SelectedOptionId)";
                    SqlCommand cmdInsertAnswer = new SqlCommand(insertAnswerQuery, conn);
                    cmdInsertAnswer.Parameters.AddWithValue("@SubmissionId", submissionId);
                    cmdInsertAnswer.Parameters.AddWithValue("@QuestionId", questionId);
                    cmdInsertAnswer.Parameters.AddWithValue("@SelectedOptionId", selectedOptionId);
                    cmdInsertAnswer.ExecuteNonQuery();

                    // Check correctness
                    string checkCorrectQuery = "SELECT IsCorrect FROM QuestionOption WHERE OptionId=@OptionId";
                    SqlCommand cmdCheck = new SqlCommand(checkCorrectQuery, conn);
                    cmdCheck.Parameters.AddWithValue("@OptionId", selectedOptionId);
                    object result = cmdCheck.ExecuteScalar();
                    if (result != null && result != DBNull.Value && (bool)result)
                        totalScore += 1;
                }

                // Update total score
                string updateScoreQuery = @"
            UPDATE AssessmentSubmission
            SET TotalScore=@TotalScore
            WHERE SubmissionId=@SubmissionId";
                SqlCommand cmdUpdate = new SqlCommand(updateScoreQuery, conn);
                cmdUpdate.Parameters.AddWithValue("@TotalScore", totalScore);
                cmdUpdate.Parameters.AddWithValue("@SubmissionId", submissionId);
                cmdUpdate.ExecuteNonQuery();

                conn.Close();
            }

            // Redirect to ViewResults.aspx
            Response.Redirect("ViewResults.aspx?SubmissionId=" + submissionId);
        }

        private string GetQuestionText(int questionId, SqlConnection conn)
        {
            string qText = "";
            string query = "SELECT QuestionText FROM Question WHERE QuestionId=@QId";
            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@QId", questionId);
            object result = cmd.ExecuteScalar();
            if (result != null) qText = result.ToString();
            return qText;
        }
    }
}