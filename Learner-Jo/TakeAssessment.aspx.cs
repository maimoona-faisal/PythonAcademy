using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class TakeAssessment : System.Web.UI.Page
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
                string type = Convert.ToString(Request.QueryString["Type"], CultureInfo.InvariantCulture);
                int moduleId = GetModuleIdFromQuery();

                if (moduleId <= 0 || string.IsNullOrWhiteSpace(type))
                {
                    ShowError("Missing ModuleID or Type.");
                    return;
                }

                LoadAssessment(moduleId, type.Trim());
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
            pnlQuiz.Visible = false;
        }

        private void LoadAssessment(int moduleId, string type)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT AssessmentId, Title
                    FROM   Assessment
                    WHERE  ContentID = @ContentId
                      AND  AssessmentType = @Type
                      AND  IsPublished = 1";
                cmd.Parameters.AddWithValue("@ContentId", moduleId);
                cmd.Parameters.AddWithValue("@Type", type);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("No published assessment found for this module.");
                        return;
                    }

                    int assessmentId = Convert.ToInt32(reader["AssessmentId"], CultureInfo.InvariantCulture);
                    lblQuizTitle.Text = Convert.ToString(reader["Title"], CultureInfo.InvariantCulture);
                    ViewState["AssessmentId"] = assessmentId;
                }
            }

            LoadQuestions(Convert.ToInt32(ViewState["AssessmentId"], CultureInfo.InvariantCulture));
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
                    ShowError("No questions were found for this assessment.");
                    return;
                }

                rptQuestions.DataSource = dt;
                rptQuestions.DataBind();
            }
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            HiddenField hfQuestionId = (HiddenField)e.Item.FindControl("hfQuestionId");
            RadioButtonList rblOptions = (RadioButtonList)e.Item.FindControl("rblOptions");
            int questionId;
            if (hfQuestionId == null || rblOptions == null || !int.TryParse(hfQuestionId.Value, out questionId))
            {
                return;
            }

            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT OptionId, OptionText
                    FROM   QuestionOption
                    WHERE  QuestionId = @QuestionId
                    ORDER BY OptionId";
                cmd.Parameters.AddWithValue("@QuestionId", questionId);

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
            int studentId;
            if (!TryGetStudentId(out studentId))
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (ViewState["AssessmentId"] == null)
            {
                ShowError("Cannot submit. Reload the assessment and try again.");
                return;
            }

            int assessmentId = Convert.ToInt32(ViewState["AssessmentId"], CultureInfo.InvariantCulture);
            int totalScore = 0;

            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdInsertSubmission = new SqlCommand(@"
                    INSERT INTO AssessmentSubmission (AssessmentId, StudentId, SubmittedAt, TotalScore)
                    OUTPUT INSERTED.SubmissionId
                    VALUES (@AssessmentId, @StudentId, GETDATE(), 0)", conn);
                cmdInsertSubmission.Parameters.AddWithValue("@AssessmentId", assessmentId);
                cmdInsertSubmission.Parameters.AddWithValue("@StudentId", studentId);

                int submissionId = (int)cmdInsertSubmission.ExecuteScalar();

                foreach (RepeaterItem item in rptQuestions.Items)
                {
                    if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem)
                    {
                        continue;
                    }

                    HiddenField hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                    RadioButtonList rblOptions = (RadioButtonList)item.FindControl("rblOptions");
                    if (hfQuestionId == null || rblOptions == null || string.IsNullOrWhiteSpace(rblOptions.SelectedValue))
                    {
                        continue;
                    }

                    int questionId;
                    int selectedOptionId;
                    if (!int.TryParse(hfQuestionId.Value, out questionId) ||
                        !int.TryParse(rblOptions.SelectedValue, out selectedOptionId))
                    {
                        continue;
                    }

                    SqlCommand cmdInsertAnswer = new SqlCommand(@"
                        INSERT INTO SubmissionAnswer (SubmissionId, QuestionId, SelectedOptionId)
                        VALUES (@SubmissionId, @QuestionId, @SelectedOptionId)", conn);
                    cmdInsertAnswer.Parameters.AddWithValue("@SubmissionId", submissionId);
                    cmdInsertAnswer.Parameters.AddWithValue("@QuestionId", questionId);
                    cmdInsertAnswer.Parameters.AddWithValue("@SelectedOptionId", selectedOptionId);
                    cmdInsertAnswer.ExecuteNonQuery();

                    SqlCommand cmdCheck = new SqlCommand(
                        "SELECT IsCorrect FROM QuestionOption WHERE OptionId = @OptionId", conn);
                    cmdCheck.Parameters.AddWithValue("@OptionId", selectedOptionId);

                    object result = cmdCheck.ExecuteScalar();
                    if (result != null && result != DBNull.Value && Convert.ToBoolean(result, CultureInfo.InvariantCulture))
                    {
                        totalScore++;
                    }
                }

                SqlCommand cmdUpdate = new SqlCommand(@"
                    UPDATE AssessmentSubmission
                    SET    TotalScore = @TotalScore
                    WHERE  SubmissionId = @SubmissionId", conn);
                cmdUpdate.Parameters.AddWithValue("@TotalScore", totalScore);
                cmdUpdate.Parameters.AddWithValue("@SubmissionId", submissionId);
                cmdUpdate.ExecuteNonQuery();

                Response.Redirect("~/Learner-Jo/ViewResults.aspx?SubmissionId=" + submissionId, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private int GetModuleIdFromQuery()
        {
            int moduleId;
            if (int.TryParse(Convert.ToString(Request.QueryString["ModuleID"], CultureInfo.InvariantCulture), out moduleId))
            {
                return moduleId;
            }

            int contentId;
            if (int.TryParse(Convert.ToString(Request.QueryString["ContentID"], CultureInfo.InvariantCulture), out contentId))
            {
                return contentId;
            }

            return 0;
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

        private bool TryGetStudentId(out int currentStudentId)
        {
            object sessionValue = Session["UserId"];
            if (sessionValue == null)
            {
                currentStudentId = 0;
                return false;
            }

            if (sessionValue is int)
            {
                currentStudentId = (int)sessionValue;
                return true;
            }

            return int.TryParse(Convert.ToString(sessionValue, CultureInfo.InvariantCulture), out currentStudentId);
        }
    }
}
