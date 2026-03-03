using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class SubmitExercise : System.Web.UI.Page
    {
        int studentId;
        int assessmentId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] != null && Request.QueryString["AssessmentId"] != null)
                {
                    studentId = Convert.ToInt32(Session["UserId"]);
                    assessmentId = Convert.ToInt32(Request.QueryString["AssessmentId"]);

                    LoadAssessmentTitle(assessmentId);
                    LoadQuestions(assessmentId);
                }
                else
                {
                    lblMessage.Text = "Cannot load assessment. Missing information.";
                    rptQuestions.Visible = false;
                    btnSubmit.Visible = false;
                }
            }
        }

        private void LoadAssessmentTitle(int assessmentId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT Title FROM Assessment WHERE AssessmentId=@AssessmentId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                conn.Open();
                object title = cmd.ExecuteScalar();
                lblAssessmentTitle.Text = title != null ? title.ToString() : "Assessment";
            }
        }

        private void LoadQuestions(int assessmentId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;
            DataTable dt = new DataTable();
            dt.Columns.Add("QuestionId", typeof(int));
            dt.Columns.Add("QuestionText", typeof(string));

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT QuestionId, QuestionText FROM Question WHERE AssessmentId=@AssessmentId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            rptQuestions.DataSource = dt;
            rptQuestions.DataBind();
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Request.QueryString["AssessmentId"] == null)
            {
                lblMessage.Text = "Cannot submit. Missing user or assessment info.";
                return;
            }

            studentId = Convert.ToInt32(Session["UserId"]);
            assessmentId = Convert.ToInt32(Request.QueryString["AssessmentId"]);

            // Collect answers from Repeater
            Dictionary<int, string> submittedAnswers = new Dictionary<int, string>();

            foreach (RepeaterItem item in rptQuestions.Items)
            {
                HiddenField hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                TextBox txtAnswer = (TextBox)item.FindControl("txtAnswer");

                if (hfQuestionId != null && txtAnswer != null)
                {
                    int questionId = Convert.ToInt32(hfQuestionId.Value);
                    string answerText = txtAnswer.Text.Trim();
                    submittedAnswers[questionId] = answerText;
                }
            }

            // Store in Session per student + assessment
            string sessionKey = $"TempSubmission_{studentId}_{assessmentId}";
            Session[sessionKey] = submittedAnswers;

            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Your answers have been saved successfully!";

        }
    }
}