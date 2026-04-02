using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class MemberDashboard : System.Web.UI.Page
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
                LoadAnnouncements();
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
                            e.Status AS ProgressStatus,
                            ISNULL(p.ProgressPercentage, 0) AS ProgressPercentage
                    FROM    LearningContent lc
                    INNER JOIN Enrolment e
                            ON  lc.ContentId = e.ModuleID
                            AND e.StudentId = @StudentId
                    LEFT JOIN Progress p
                            ON  lc.ContentId = p.ModuleID
                            AND p.StudentId = @StudentId
                    WHERE   lc.IsPublished = 1
                    ORDER BY lc.ContentId";
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                DataTable dt = new DataTable();
                conn.Open();
                da.Fill(dt);

                rptDashboard.DataSource = dt;
                rptDashboard.DataBind();
                pnlEmpty.Visible = dt.Rows.Count == 0;
            }
        }

        private void LoadAnnouncements()
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand())
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Connection = conn;
                cmd.CommandText = @"
                    SELECT Title, Message, CreatedAt
                    FROM   Announcements
                    WHERE  TargetAudience IN ('All', 'Students')
                    ORDER BY CreatedAt DESC";

                DataTable dt = new DataTable();
                conn.Open();
                da.Fill(dt);

                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();

                // Set the count label for the stack hint
                if (dt.Rows.Count > 0)
                {
                    lblStackCount.Text = dt.Rows.Count + (dt.Rows.Count == 1 ? " announcement" : " announcements");
                }
                else
                {
                    lblStackCount.Text = "No announcements";
                }
            }
        }

        protected void rptDashboard_ItemCommand(object source, RepeaterCommandEventArgs e)
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

            switch (e.CommandName)
            {
                case "ViewModule":
                    EnrollStudentIfNotExists(studentId, moduleId);
                    Response.Redirect("~/Learner-Jo/ViewCourseContent.aspx?ModuleID=" + moduleId, false);
                    Context.ApplicationInstance.CompleteRequest();
                    break;
                case "TakeQuiz":
                    EnrollStudentIfNotExists(studentId, moduleId);
                    Response.Redirect("~/Learner-Jo/TakeAssessment.aspx?ContentID=" + moduleId + "&Type=Quiz", false);
                    Context.ApplicationInstance.CompleteRequest();
                    break;
            }
        }

        protected string GetStatusClass(object statusValue)
        {
            string status = Convert.ToString(statusValue, CultureInfo.InvariantCulture);
            if (string.IsNullOrWhiteSpace(status))
            {
                return "status-not-enrolled";
            }

            switch (status.Trim().ToLowerInvariant())
            {
                case "in progress":
                    return "status-in-progress";
                case "completed":
                    return "status-completed";
                case "not enrolled":
                    return "status-not-enrolled";
                default:
                    return "status-not-started";
            }
        }

        protected string FormatAnnouncementDate(object createdAt)
        {
            if (createdAt == null || createdAt == DBNull.Value)
            {
                return "No date";
            }

            if (createdAt is DateTime)
            {
                DateTime dateTime = (DateTime)createdAt;
                return dateTime.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
            }

            DateTime parsedDate;
            if (DateTime.TryParse(Convert.ToString(createdAt, CultureInfo.InvariantCulture), out parsedDate))
            {
                return parsedDate.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
            }

            return "No date";
        }

        protected int GetProgressPercentage(object progressValue)
        {
            if (progressValue == null || progressValue == DBNull.Value)
            {
                return 0;
            }

            if (progressValue is decimal)
            {
                decimal decimalValue = (decimal)progressValue;
                return ClampProgress(decimal.ToInt32(decimal.Round(decimalValue)));
            }

            if (progressValue is double)
            {
                double doubleValue = (double)progressValue;
                return ClampProgress(Convert.ToInt32(Math.Round(doubleValue)));
            }

            if (progressValue is float)
            {
                float floatValue = (float)progressValue;
                return ClampProgress(Convert.ToInt32(Math.Round(floatValue)));
            }

            int parsedValue;
            if (int.TryParse(Convert.ToString(progressValue, CultureInfo.InvariantCulture), out parsedValue))
            {
                return ClampProgress(parsedValue);
            }

            return 0;
        }

        private void EnrollStudentIfNotExists(int currentStudentId, int moduleId)
        {
            string connStr = GetConnectionString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string checkQuery = @"
                    SELECT COUNT(*)
                    FROM   Enrolment
                    WHERE  StudentId = @StudentId AND ModuleID = @ModuleID";

                SqlCommand cmdCheck = new SqlCommand(checkQuery, conn);
                cmdCheck.Parameters.AddWithValue("@StudentId", currentStudentId);
                cmdCheck.Parameters.AddWithValue("@ModuleID", moduleId);

                int exists = (int)cmdCheck.ExecuteScalar();

                if (exists == 0)
                {
                    string insertQuery = @"
                        INSERT INTO Enrolment (StudentId, ModuleID, Status, EnrolledAt)
                        VALUES (@StudentId, @ModuleID, 'In Progress', GETDATE())";

                    SqlCommand cmdInsert = new SqlCommand(insertQuery, conn);
                    cmdInsert.Parameters.AddWithValue("@StudentId", currentStudentId);
                    cmdInsert.Parameters.AddWithValue("@ModuleID", moduleId);
                    cmdInsert.ExecuteNonQuery();
                }
            }
        }

        private static int ClampProgress(int progressPercentage)
        {
            return Math.Max(0, Math.Min(100, progressPercentage));
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
