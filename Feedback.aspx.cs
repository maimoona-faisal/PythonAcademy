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
    public partial class Feedback : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Label3.Text = "";
            }
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            string feedback = TextBox1.Text.Trim();

            if (string.IsNullOrEmpty(feedback))
            {
                Label3.Text = "Feel free to give any opinions for our applications";
                return;
            }

            int studentId = 1;
            int moduleId = 1; 

            string connStr = ConfigurationManager.ConnectionStrings["UserDBConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "INSERT INTO Feedback (StudentId, ModuleID, FeedbackMessage, CreatedAt) " +
                               "VALUES (@StudentId, @ModuleID, @FeedbackMessage, GETDATE())";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);
                cmd.Parameters.AddWithValue("@FeedbackMessage", feedback);

                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
            }

            Label3.Text = "Your feedback means a lot to us~";
            TextBox1.Text = "";
        }
    }
}