using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    public partial class viewCert : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string hash = Request.QueryString["hash"];
                if (string.IsNullOrEmpty(hash))
                {
                    pnlCert.Visible = false;
                    pnlError.Visible = true;
                    return;
                }

                LoadCertificateData(hash);
            }
        }
        private void LoadCertificateData(string hash)
        {
            string cs = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                string sql = @"
                    SELECT u.FullName, lc.Title, c.IssuedAt, c.CertificateHash
                    FROM Certificates c
                    INNER JOIN Users u ON c.StudentId = u.UserId
                    INNER JOIN LearningContent lc ON c.ModuleId = lc.ContentId
                    WHERE c.CertificateHash = @Hash";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Hash", hash);
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string fullName = rdr["FullName"].ToString();

                            if (string.IsNullOrWhiteSpace(fullName))
                            {
                                fullName = "NO NAME PROVIDED IN DATABASE";
                            }

                            lblStudentName.Text = fullName.ToUpper();
                            lblCourseName.Text = rdr["Title"].ToString();
                            lblDate.Text = Convert.ToDateTime(rdr["IssuedAt"]).ToString("MMMM dd, yyyy");
                            lblHash.Text = rdr["CertificateHash"].ToString();

                            pnlCert.Visible = true;
                            pnlError.Visible = false;
                        }
                        else
                        {
                            pnlCert.Visible = false;
                            pnlError.Visible = true;
                        }
                    }
                }
            }
        }

    }
}