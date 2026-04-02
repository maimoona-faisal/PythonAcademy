using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class LearningMaterials : System.Web.UI.Page
    {
        private int studentId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetStudentId(out studentId))
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadModules();
            }
        }

        private void LoadModules()
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT  lc.ContentId,
                            lc.Title,
                            lc.Description,
                            lc.ContentType,
                            ISNULL(lc.ThumbnailPath, '') AS ThumbnailPath,
                            ISNULL(lc.Category, '') AS Category,
                            ISNULL(e.Status, 'Not Enrolled') AS Status
                    FROM    LearningContent lc
                    LEFT JOIN Enrolment e
                            ON  lc.ContentId = e.ModuleID
                            AND e.StudentId = @StudentId
                    WHERE   lc.IsPublished = 1
                    ORDER BY lc.ContentId";
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                DataTable dt = new DataTable();
                conn.Open();
                da.Fill(dt);

                rptModules.DataSource = dt;
                rptModules.DataBind();
                pnlEmpty.Visible = dt.Rows.Count == 0;
            }
        }

        protected void rptModules_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!TryGetStudentId(out studentId))
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            int moduleId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out moduleId))
            {
                return;
            }

            // If the user clicks "Enroll Now"
            if (e.CommandName == "Enroll")
            {
                EnrollStudentIfNeeded(studentId, moduleId);

                // Refresh the modules on the page so the button changes to "Go to Module"
                LoadModules();
            }
            // If the user is already enrolled and clicks "Go to Module"
            else if (e.CommandName == "StartCourse")
            {
                Response.Redirect("~/Learner-Jo/ViewCourseContent.aspx?ModuleID=" + moduleId, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnModalEnroll_Click(object sender, EventArgs e)
        {
            if (!TryGetStudentId(out studentId))
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            int moduleId;
            // Read the module ID from the HiddenField that Javascript sets
            if (int.TryParse(hfSelectedModule.Value, out moduleId))
            {
                EnrollStudentIfNeeded(studentId, moduleId);

                // Refresh the list so the button turns to "Go to Module"
                LoadModules();

                ScriptManager.RegisterStartupScript(this, GetType(), "enrollSuccess",
                    "alert('Successfully enrolled! You can now access this module.');", true);
            }
        }

        protected string GetStatusClass(object statusValue)
        {
            string status = Convert.ToString(statusValue, CultureInfo.InvariantCulture);
            if (string.IsNullOrWhiteSpace(status))
            {
                return "mod-status-new";
            }

            switch (status.Trim().ToLowerInvariant())
            {
                case "in progress":
                    return "mod-status-inprogress";
                case "completed":
                    return "mod-status-done";
                default:
                    return "mod-status-new";
            }
        }

        protected string GetThumbnailUrl(object thumbnailPath)
        {
            string path = Convert.ToString(thumbnailPath, CultureInfo.InvariantCulture).Trim();
            if (string.IsNullOrEmpty(path))
            {
                return ResolveUrl("~/Images/contentImage.jpg");
            }

            return ResolveUrl(path);
        }

        protected string GetCategoryLabel(object categoryValue)
        {
            string cat = Convert.ToString(categoryValue, CultureInfo.InvariantCulture).Trim();
            return string.IsNullOrEmpty(cat) ? "General" : cat;
        }

        protected string GetSearchTitle(object titleValue)
        {
            return Convert.ToString(titleValue, CultureInfo.InvariantCulture)
                .Trim()
                .ToLowerInvariant();
        }

        private void EnrollStudentIfNeeded(int currentStudentId, int moduleId)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string checkQuery = @"
                    SELECT COUNT(*)
                    FROM   Enrolment
                    WHERE  StudentId = @StudentId AND ModuleID = @ModuleID";

                SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                checkCmd.Parameters.AddWithValue("@StudentId", currentStudentId);
                checkCmd.Parameters.AddWithValue("@ModuleID", moduleId);

                int count = (int)checkCmd.ExecuteScalar();
                if (count == 0)
                {
                    string insertQuery = @"
                        INSERT INTO Enrolment (StudentId, ModuleID, Status, EnrolledAt)
                        VALUES (@StudentId, @ModuleID, 'In Progress', GETDATE())";

                    SqlCommand insertCmd = new SqlCommand(insertQuery, conn);
                    insertCmd.Parameters.AddWithValue("@StudentId", currentStudentId);
                    insertCmd.Parameters.AddWithValue("@ModuleID", moduleId);
                    insertCmd.ExecuteNonQuery();
                }
            }
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
