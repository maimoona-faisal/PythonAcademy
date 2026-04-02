using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
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
            if (Session["UserId"] == null) return;
            int studentId = Convert.ToInt32(Session["UserId"]);

            string connStr = ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT 
                        p.ModuleID, 
                        lc.Title, 
                        ISNULL(p.ProgressPercentage, 0) AS ProgressPercentage,
                        c.CertificateHash
                    FROM Progress p
                    JOIN LearningContent lc ON p.ModuleID = lc.ContentId
                    LEFT JOIN Certificates c ON p.StudentId = c.StudentId AND p.ModuleID = c.ModuleId
                    WHERE p.StudentId = @StudentId";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptProgress.DataSource = dt;
                rptProgress.DataBind();
            } // end of using block
        }
    }
       
}