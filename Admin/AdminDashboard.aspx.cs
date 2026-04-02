using System;
using System.Data.SqlClient;

namespace PythonAcademy.Admin
{
    // first page the admin sees after logging in
    public partial class AdminDashboard : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // only load data on the first visit, not every time a button is clicked
            if (IsPostBack)
            {
                return;
            }

            try
            {
                LoadDashboardStats();
                LoadRecentActivity(); 
                LogEvent("Dashboard.View", "Opened admin dashboard.");
            }
            catch
            {
                // if anything goes wrong, just show a friendly message instead of crashing
                lblMessage.Text = "Unable to load dashboard statistics right now.";
                lblMessage.Visible = true;
            }
        }

        // pulls the four stat numbers shown at the top of the dashboard
        private void LoadDashboardStats()
        {
            // count all students in the system
            lblStudents.Text = Convert.ToString(ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = @Role",
                new SqlParameter("@Role", "Student")));

            // only count lecturers who have been approved (Active status)
            lblLecturers.Text = Convert.ToString(ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = @Role AND Status = @Status",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Active")));

            // lecturers waiting to be approved show as pending
            lblPending.Text = Convert.ToString(ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = @Role AND Status = @Status",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Pending")));

            // total number of learning modules uploaded
            lblModules.Text = Convert.ToString(ExecuteScalar("SELECT COUNT(*) FROM LearningContent"));
        }
        private void LoadRecentActivity()
        {
            // Pulls only the 4 most recent events
            string sql = "SELECT TOP 4 Timestamp, Action, Details FROM ActivityLogs ORDER BY Timestamp DESC";
            rptRecentActivity.DataSource = ExecuteTable(sql);
            rptRecentActivity.DataBind();
        }
    }
}
