using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using WebGrease.Activities;

namespace PythonAcademy
{
    public partial class ViewCourseContent : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["ModuleID"] != null)
                {
                    int moduleId = Convert.ToInt32(Request.QueryString["ModuleID"]);
                    Session["CurrentModuleID"] = moduleId;

                    LoadModuleDetails(moduleId);
                    LoadModuleTopics(moduleId);
                    CheckQuizAvailability(moduleId);
                    CheckExerciseAvailability(moduleId);
                }
                else
                {
                    lblError.Text = "No module selected.";
                    pnlContent.Visible = false;
                }
            }
        }

        private void LoadModuleDetails(int moduleId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT Title, Description FROM LearningContent WHERE ContentId=@ModuleID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblTitle.Text = reader["Title"].ToString();
                    lblDescription.Text = reader["Description"].ToString();
                }
                else
                {
                    lblError.Text = "Module not found.";
                    pnlContent.Visible = false;
                }
            }
        }

        private void LoadModuleTopics(int moduleId)
        {
            int studentId = Convert.ToInt32(Session["UserId"]);
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                SELECT lc.ContentId, lc.Title, lc.Description,
                       ISNULL(p.ProgressPercentage,0) AS ProgressPercentage
                FROM LearningContent lc
                LEFT JOIN Progress p
                    ON p.StudentId=@StudentId AND p.ModuleID=lc.ContentId
                WHERE lc.ContentId=@ModuleID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvTopics.DataSource = dt;
                gvTopics.DataBind();
            }
        }

        private void CheckQuizAvailability(int moduleId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
            SELECT TOP 1 a.AssessmentId
            FROM Assessment a
            INNER JOIN LearningContent lc ON lc.LecturerId = a.LecturerId
            WHERE a.IsPublished = 1
              AND a.AssessmentType = 'Quiz'
              AND lc.ContentId = @ModuleId";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@ModuleId", moduleId);  // Pass parameter
                conn.Open();
                object result = cmd.ExecuteScalar();
                conn.Close();

                btnTakeQuiz.Visible = result != null; // Show button if quiz exists
            }
        }

        protected void btnTakeQuiz_Click(object sender, EventArgs e)
        {
            if (Session["CurrentModuleID"] != null)
            {
                int moduleId = Convert.ToInt32(Session["CurrentModuleID"]);
                Response.Redirect("TakeAssessment.aspx?ModuleID=" + moduleId + "&Type=Quiz");
            }
        }

        protected void btnSubmitExercise_Click(object sender, EventArgs e)
        {
            if (Session["CurrentModuleID"] != null)
            {
                int moduleId = Convert.ToInt32(Session["CurrentModuleID"]);
                Response.Redirect("SubmitExercise.aspx?ModuleID=" + moduleId);
            }
        }

        private void CheckExerciseAvailability(int moduleId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            btnSubmitExercise.Visible = false;
        }
    }
}