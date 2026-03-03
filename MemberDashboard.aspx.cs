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
    public partial class MemberDashboard : System.Web.UI.Page
    {
        int studentId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/LoginPage.aspx");
                return;
            }

            studentId = Convert.ToInt32(Session["UserId"]);

            if (!IsPostBack)
            {
                LoadModules();
            }
        }

        private void LoadModules()
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT lc.ContentId,
                           lc.Title,
                           lc.Description,
                           ISNULL(e.Status,'Not Enrolled') AS ProgressStatus,
                           ISNULL(p.ProgressPercentage,0) AS ProgressPercentage
                    FROM LearningContent lc
                    LEFT JOIN Enrolment e
                        ON lc.ContentId = e.ModuleID AND e.StudentId=@StudentId
                    LEFT JOIN Progress p
                        ON lc.ContentId = p.ModuleID AND p.StudentId=@StudentId
                    WHERE lc.IsPublished = 1";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvDashboard.DataSource = dt;
                gvDashboard.DataBind();
            }
        }

        // GridView RowCommand for View / Quiz buttons
        protected void gvDashboard_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvDashboard.Rows[index];
            int moduleId = Convert.ToInt32(row.Cells[0].Text);

            if (e.CommandName == "ViewModule" || e.CommandName == "TakeQuiz")
            {
                // Auto-enroll the student
                EnrollStudentIfNotExists(studentId, moduleId);
            }

            if (e.CommandName == "ViewModule")
                Response.Redirect("ViewCourseContent.aspx?ModuleID=" + moduleId);
            else if (e.CommandName == "TakeQuiz")
                Response.Redirect("TakeAssessment.aspx?ModuleID=" + moduleId + "&Type=Quiz");
        }

        protected void btnDemoSubmit_Click(object sender, EventArgs e)
        {
            // Redirect to your submitExercise page
            Response.Redirect("~/SubmitExercise.aspx");
        }

        private void EnrollStudentIfNotExists(int studentId, int moduleId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string checkQuery = "SELECT COUNT(*) FROM Enrolment WHERE StudentId=@StudentId AND ModuleID=@ModuleID";
                SqlCommand cmdCheck = new SqlCommand(checkQuery, conn);
                cmdCheck.Parameters.AddWithValue("@StudentId", studentId);
                cmdCheck.Parameters.AddWithValue("@ModuleID", moduleId);

                conn.Open();
                int exists = (int)cmdCheck.ExecuteScalar();

                if (exists == 0)
                {
                    string insertQuery = @"INSERT INTO Enrolment (StudentId, ModuleID, Status, EnrolledAt) 
                                   VALUES (@StudentId, @ModuleID, 'In Progress', GETDATE())";
                    SqlCommand cmdInsert = new SqlCommand(insertQuery, conn);
                    cmdInsert.Parameters.AddWithValue("@StudentId", studentId);
                    cmdInsert.Parameters.AddWithValue("@ModuleID", moduleId);
                    cmdInsert.ExecuteNonQuery();
                }
                conn.Close();
            }
        }
    }
}