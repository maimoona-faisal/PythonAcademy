using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy.Learner_wei
{
    public partial class viewMyGrade : System.Web.UI.Page
    {
        private string Cs = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Request.QueryString["AssessmentId"] != null)
                {
                    LoadReportCard(Convert.ToInt32(Request.QueryString["AssessmentId"]));
                }
            }
        }

        private void LoadReportCard(int assessmentId)
        {
            int studentId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(Cs))
            {
                // 1. Get the Total Score
                using (SqlCommand cmd = new SqlCommand("SELECT TotalScore FROM AssessmentSubmission WHERE AssessmentId = @A AND StudentId = @S", con))
                {
                    cmd.Parameters.AddWithValue("@A", assessmentId);
                    cmd.Parameters.AddWithValue("@S", studentId);
                    con.Open();
                    object score = cmd.ExecuteScalar();
                    lblTotalScore.Text = score != null ? score.ToString() : "Pending";
                }

                // 2. Get the individual answers and marks
                string sql = @"
                    SELECT 
                        q.QuestionText, 
                        q.Marks AS MaxMarks, 
                        sa.AnswerText, 
                        qo.OptionText, 
                        ISNULL(sa.MarksAwarded, 0) AS MarksAwarded
                    FROM AssessmentSubmission s
                    INNER JOIN SubmissionAnswer sa ON s.SubmissionId = sa.SubmissionId
                    INNER JOIN Question q ON sa.QuestionId = q.QuestionId
                    LEFT JOIN QuestionOption qo ON sa.SelectedOptionId = qo.OptionId
                    WHERE s.AssessmentId = @A AND s.StudentId = @S";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@A", assessmentId);
                    cmd.Parameters.AddWithValue("@S", studentId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptAnswers.DataSource = dt;
                        rptAnswers.DataBind();
                    }
                }
            }
        }
    }
}