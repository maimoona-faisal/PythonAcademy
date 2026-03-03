using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WAPPAssignment
{
    public partial class TrackProgress : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProgress();
            }
        }

        private void LoadProgress()
        {
            int studentId = 1;  // Example student
            int moduleId = 1;   // Example module

            string connStr = ConfigurationManager.ConnectionStrings["UserDBConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT ModuleID, TopicsCompleted, TotalTopics, ProgressPercentage " +
                               "FROM Progress WHERE StudentId=@StudentId AND ModuleID=@ModuleID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    int progress = Convert.ToInt32(reader["ProgressPercentage"]);
                    TextBox1.Text = progress.ToString();

                    // Optionally set module name dynamically
                    Label2.Text = "Module Name: Python";  // You can replace with dynamic module name later
                }

                conn.Close();
            }
        }
    }
}