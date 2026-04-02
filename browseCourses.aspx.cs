using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class BrowseCourses : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
            }
        }

        // ---- Fetches the courses and translates DB columns to match your HTML ----
        private void LoadCourses()
        {
            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    // FIXED: We use 'AS' to map your database columns to the exact names your HTML Eval() expects!
                    string sql = @"
                        SELECT 
                            ContentId AS CourseID,
                            Title AS CourseName,
                            Description,
                            Category,
                            Level AS Difficulty,
                            DurationText AS Duration,
                            (SELECT COUNT(*) FROM ModuleTopics WHERE ModuleId = ContentId) AS LessonCount,
                            ThumbnailPath
                        FROM LearningContent 
                        WHERE IsPublished = 1 
                        ORDER BY ContentId DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // FIXED: Reconnected to your correct repeater ID
                        rptCourses.DataSource = dt;
                        rptCourses.DataBind();
                    }
                }
            }
            catch { /* Fallback */ }
        }

        // FIXED: Brought back the missing method your custom HTML needs for the difficulty badges!
        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                var lblDiff = (Label)e.Item.FindControl("lblDiff");

                if (lblDiff != null)
                {
                    string diff = (row["Difficulty"] ?? "").ToString().ToLower();
                    lblDiff.CssClass = "bc-diff " + diff;
                }
            }
        }

        // ---- build pipe-delimited learn points from module titles ----
        protected string GetLearnPoints(object courseId)
        {
            if (courseId == null || courseId == DBNull.Value) return "";

            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;
            StringBuilder sb = new StringBuilder();

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 8 TopicTitle FROM ModuleTopics WHERE ModuleId = @id ORDER BY OrderIndex ASC", conn))
                {
                    cmd.Parameters.AddWithValue("@id", courseId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            if (sb.Length > 0) sb.Append("|");
                            sb.Append(dr["TopicTitle"].ToString());
                        }
                    }
                }
            }
            catch { }

            return sb.ToString();
        }
    }
}