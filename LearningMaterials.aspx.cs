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
    public partial class LearningMaterials : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadModules();
            }
        }

        private void LoadModules()
        {
            int studentId = Convert.ToInt32(Session["UserId"]); // make sure login sets this

            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
        SELECT lc.ContentId,
               lc.Title,
               lc.Description,
               ISNULL(e.Status, 'Not Enrolled') AS Status
        FROM LearningContent lc
        LEFT JOIN Enrolment e
            ON lc.ContentId = e.ModuleID
            AND e.StudentId = @StudentId
        WHERE lc.IsPublished = 1";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvModules.DataSource = dt;
                gvModules.DataBind();
            }
        }

        protected void gvModules_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "StartCourse")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = gvModules.Rows[index];

                int moduleId = Convert.ToInt32(row.Cells[0].Text);
                int studentId = Convert.ToInt32(Session["UserId"]);

                EnrollStudent(studentId, moduleId);

                Response.Redirect("ViewCourseContent.aspx?ModuleID=" + moduleId);
            }
        }
        private void EnrollStudent(int studentId, int moduleId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string checkQuery = "SELECT COUNT(*) FROM Enrolment WHERE StudentId=@StudentId AND ModuleID=@ModuleID";

                SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                checkCmd.Parameters.AddWithValue("@StudentId", studentId);
                checkCmd.Parameters.AddWithValue("@ModuleID", moduleId);

                conn.Open();
                int count = (int)checkCmd.ExecuteScalar();

                if (count == 0)
                {
                    string insertQuery = @"INSERT INTO Enrolment
                                   (StudentId, ModuleID, Status, EnrolledAt)
                                   VALUES (@StudentId, @ModuleID, 'In Progress', GETDATE())";

                    SqlCommand insertCmd = new SqlCommand(insertQuery, conn);
                    insertCmd.Parameters.AddWithValue("@StudentId", studentId);
                    insertCmd.Parameters.AddWithValue("@ModuleID", moduleId);
                    insertCmd.ExecuteNonQuery();
                }
            }
        }
    }
}