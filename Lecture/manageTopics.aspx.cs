using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy.Lecture
{
    public partial class manageTopics : System.Web.UI.Page
    {
        private string Cs = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;
        private int ModuleId => Request.QueryString["ModuleId"] != null ? Convert.ToInt32(Request.QueryString["ModuleId"]) : 0;
        private int CurrentUserId => Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0 || Session["Role"].ToString() == "Student")
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx");
                return;
            }

            if (ModuleId == 0)
            {
                lblMsg.Text = "Invalid Module ID.";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }

            if (!IsPostBack)
            {
                LoadModuleInfo();
                LoadTopics();
            }
        }
        private void LoadModuleInfo()
        {
            using (SqlConnection con = new SqlConnection(Cs))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT Title FROM LearningContent WHERE ContentId = @ID", con))
                {
                    cmd.Parameters.AddWithValue("@ID", ModuleId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) lblModuleTitle.Text = result.ToString();
                }
            }
        }

        private void LoadTopics()
        {
            using (SqlConnection con = new SqlConnection(Cs))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TopicId, TopicTitle, OrderIndex FROM ModuleTopics WHERE ModuleId = @ID ORDER BY OrderIndex ASC", con))
                {
                    cmd.Parameters.AddWithValue("@ID", ModuleId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvTopics.DataSource = dt;
                    gvTopics.DataBind();
                }
            }
        }

        protected void btnAddTopic_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTitle.Text) || string.IsNullOrWhiteSpace(txtOrder.Text))
            {
                lblMsg.Text = "Title and Order are required.";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }

            string topicType = ddlTopicType.SelectedValue;
            string finalContent = "";

            // 1. Just save the raw Text
            if (topicType == "Text")
            {
                finalContent = txtContent.Text.Trim();
                if (string.IsNullOrWhiteSpace(finalContent)) { lblMsg.Text = "Content text is required."; lblMsg.ForeColor = System.Drawing.Color.Red; return; }
            }
            // 2. Just save the raw URL
            else if (topicType == "Link")
            {
                finalContent = txtLinkUrl.Text.Trim();
                if (string.IsNullOrWhiteSpace(finalContent)) { lblMsg.Text = "A URL is required."; lblMsg.ForeColor = System.Drawing.Color.Red; return; }
            }
            // 3. Just save the raw File Path!
            else
            {
                if (!fuTopicFile.HasFile) { lblMsg.Text = "Please select a file to upload."; lblMsg.ForeColor = System.Drawing.Color.Red; return; }

                // Dynamic Upload Limit Check
                int maxUploadSizeMB = 50;
                try
                {
                    using (SqlConnection limitCon = new SqlConnection(Cs))
                    using (SqlCommand limitCmd = new SqlCommand("SELECT SettingValue FROM PlatformSettings WHERE SettingKey = 'MaxUploadSizeMB'", limitCon))
                    {
                        limitCon.Open();
                        object limitResult = limitCmd.ExecuteScalar();
                        if (limitResult != null && int.TryParse(limitResult.ToString(), out int parsedSize))
                        {
                            maxUploadSizeMB = parsedSize;
                        }
                    }
                }
                catch { }

                long maxBytes = maxUploadSizeMB * 1024L * 1024L;
                if (fuTopicFile.PostedFile.ContentLength > maxBytes)
                {
                    lblMsg.Text = "File size exceeds the platform limit of " + maxUploadSizeMB + "MB.";
                    lblMsg.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                // Clean the original file name (replace spaces with underscores)
                string originalName = Path.GetFileNameWithoutExtension(fuTopicFile.FileName).Replace(" ", "_");
                string ext = Path.GetExtension(fuTopicFile.FileName).ToLower();

                // Keep the readable name, but add a tiny timestamp so it stays unique!
                // Example: Python101_T1_143022.pdf
                string fileName = originalName + "_" + DateTime.Now.ToString("HHmmss") + ext;

                string savePath = Server.MapPath("~/Uploads/") + fileName;

                // Save the file to the folder
                fuTopicFile.SaveAs(savePath);

                // Save the file to the folder
                fuTopicFile.SaveAs(savePath);

                // Save ONLY the path to the database
                finalContent = ResolveUrl("~/Uploads/" + fileName);
            }

            // Finally, Save to DB with the NEW TopicType column
            using (SqlConnection con = new SqlConnection(Cs))
            {
                string sql;
                bool isEdit = !string.IsNullOrEmpty(hfEditTopicId.Value);

                if (isEdit)
                {
                    sql = "UPDATE ModuleTopics SET TopicTitle = @Title, TopicContent = @Content, TopicType = @Type, OrderIndex = @Order WHERE TopicId = @TopicId";
                }
                else
                {
                    sql = "INSERT INTO ModuleTopics (ModuleId, TopicTitle, TopicContent, TopicType, OrderIndex) VALUES (@ModId, @Title, @Content, @Type, @Order)";
                }

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@ModId", ModuleId);
                    cmd.Parameters.AddWithValue("@Title", txtTitle.Text.Trim());
                    cmd.Parameters.AddWithValue("@Content", finalContent);
                    cmd.Parameters.AddWithValue("@Type", topicType); // <--- NEW PARAMETER
                    cmd.Parameters.AddWithValue("@Order", Convert.ToInt32(txtOrder.Text));

                    if (isEdit) cmd.Parameters.AddWithValue("@TopicId", Convert.ToInt32(hfEditTopicId.Value));

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            ResetForm();
            lblMsg.Text = string.IsNullOrEmpty(hfEditTopicId.Value) ? "Topic added successfully!" : "Topic updated successfully!";
            lblMsg.ForeColor = System.Drawing.Color.LightGreen;
            LoadTopics();
        }

        protected void gvTopics_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int topicId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteTopic")
            {
                using (SqlConnection con = new SqlConnection(Cs))
                using (SqlCommand cmd = new SqlCommand("DELETE FROM ModuleTopics WHERE TopicId = @TID", con))
                {
                    cmd.Parameters.AddWithValue("@TID", topicId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                LoadTopics();
                lblMsg.Text = "Topic deleted.";
                lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
            }
            else if (e.CommandName == "EditTopic")
            {
                using (SqlConnection con = new SqlConnection(Cs))
                using (SqlCommand cmd = new SqlCommand("SELECT TopicTitle, TopicContent, TopicType, OrderIndex FROM ModuleTopics WHERE TopicId = @TID", con))
                {
                    cmd.Parameters.AddWithValue("@TID", topicId);
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            txtTitle.Text = rdr["TopicTitle"].ToString();
                            txtOrder.Text = rdr["OrderIndex"].ToString();

                            // 1. Grab the TopicType from the database
                            string pulledType = rdr["TopicType"].ToString();

                            // 2. Set the dropdown to match the type
                            ddlTopicType.SelectedValue = pulledType;

                            // 3. Put the data back in the correct textbox based on what type it is!
                            if (pulledType == "Text")
                            {
                                txtContent.Text = rdr["TopicContent"].ToString();
                            }
                            else if (pulledType == "Link")
                            {
                                txtLinkUrl.Text = rdr["TopicContent"].ToString();
                            }
                            // Note: If it's a file (PDF, Video, etc.), we leave the file upload blank because browsers don't allow pre-filling files for security.

                            // Switch form to "Edit Mode"
                            hfEditTopicId.Value = topicId.ToString();
                            btnAddTopic.Text = "Update Topic";
                            btnCancelEdit.Visible = true;

                            // 4. Update the JavaScript to show the correct input area based on the type
                            string jsToShowCorrectArea = "";
                            if (pulledType == "Text")
                            {
                                jsToShowCorrectArea = "document.getElementById('textInputArea').style.display = 'block'; document.getElementById('fileInputArea').style.display = 'none'; document.getElementById('linkInputArea').style.display = 'none';";
                            }
                            else if (pulledType == "Link")
                            {
                                jsToShowCorrectArea = "document.getElementById('textInputArea').style.display = 'none'; document.getElementById('fileInputArea').style.display = 'none'; document.getElementById('linkInputArea').style.display = 'block';";
                            }
                            else
                            {
                                jsToShowCorrectArea = "document.getElementById('textInputArea').style.display = 'none'; document.getElementById('fileInputArea').style.display = 'block'; document.getElementById('linkInputArea').style.display = 'none';";
                            }

                            Page.ClientScript.RegisterStartupScript(this.GetType(), "ShowCorrectArea", jsToShowCorrectArea, true);

                            lblMsg.Text = "Editing topic. Make your changes and click Update.";
                            lblMsg.ForeColor = System.Drawing.Color.SkyBlue;
                        }
                    }
                }
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
            lblMsg.Text = "Edit cancelled.";
            lblMsg.ForeColor = System.Drawing.Color.SkyBlue;
        }

        private void ResetForm()
        {
            txtTitle.Text = "";
            txtContent.Text = "";
            txtOrder.Text = "";
            txtLinkUrl.Text = "";
            ddlTopicType.SelectedIndex = 0;

            hfEditTopicId.Value = "";
            btnAddTopic.Text = "+ Add Topic";
            btnCancelEdit.Visible = false;

            // Reset UI via JS
            Page.ClientScript.RegisterStartupScript(this.GetType(), "ResetUI", "document.getElementById('textInputArea').style.display = 'block'; document.getElementById('fileInputArea').style.display = 'none'; document.getElementById('linkInputArea').style.display = 'none';", true);
        }
    }
}