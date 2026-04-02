using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy.Lecture
{
    public partial class l_dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAnnouncements();
            }
        }
        private void LoadAnnouncements()
        {
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["PythonAcademyDB"].ConnectionString;

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                string query = @"SELECT Title, Message, CreatedAt 
                                 FROM Announcements 
                                 WHERE TargetAudience IN ('All', 'Lecturers') 
                                 ORDER BY CreatedAt DESC";

                System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn);
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd);
                System.Data.DataTable dt = new System.Data.DataTable();

                conn.Open();
                da.Fill(dt);
                conn.Close();

                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
            }
        }
    }
}