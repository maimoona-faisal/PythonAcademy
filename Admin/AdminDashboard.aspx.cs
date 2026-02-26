using System;
using System.Data.SqlClient;

namespace PythonAcademy.Admin
{
    public partial class AdminDashboard : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            try
            {
                LoadDashboardStats();
                LoadRecentActivity(); // <-- Here is the new line we added!
                LogEvent("Dashboard.View", "Opened admin dashboard.");
            }
            catch
            {
                lblMessage.Text = "Unable to load dashboard statistics right now.";
                lblMessage.Visible = true;
            }
        }

        private void LoadDashboardStats()
        {
            lblStudents.Text = Convert.ToString(ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = @Role",
                new SqlParameter("@Role", "Student")));

            lblLecturers.Text = Convert.ToString(ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = @Role AND Status = @Status",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Active")));

            lblPending.Text = Convert.ToString(ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = @Role AND Status = @Status",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Pending")));

            lblModules.Text = Convert.ToString(ExecuteScalar("SELECT COUNT(*) FROM LearningContent"));
        }

        // <-- Here is the brand new method we added!
        private void LoadRecentActivity()
        {
            // Pulls only the 4 most recent events
            string sql = "SELECT TOP 4 Timestamp, Action, Details FROM ActivityLogs ORDER BY Timestamp DESC";
            rptRecentActivity.DataSource = ExecuteTable(sql);
            rptRecentActivity.DataBind();
        }
    }
}