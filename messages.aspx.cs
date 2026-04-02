using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PythonAcademy
{
    // this page lets users send messages to each other and view their inbox
    public partial class messages : System.Web.UI.Page
    {
        private string Cs = ConfigurationManager.ConnectionStrings["PythonAcademyDb"].ConnectionString;

        // Make CurrentUserId public so the ASPX page can read it to color the bubbles
        public int CurrentUserId => Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;

        // Keeps track of who we are currently chatting with
        public int ActiveContactId
        {
            get { return ViewState["ActiveContactId"] != null ? Convert.ToInt32(ViewState["ActiveContactId"]) : 0; }
            set { ViewState["ActiveContactId"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("~/LoginandRegister/LoginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // --- NEW: MESSAGING KILL SWITCH CHECK ---
            using (SqlConnection con = new SqlConnection(Cs))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT SettingValue FROM PlatformSettings WHERE SettingKey = 'EnableMessaging'", con))
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    string role = Session["Role"] != null ? Session["Role"].ToString() : "";

                    // If messaging is turned OFF ("0") and the user is NOT an Admin
                    if (result != null && result.ToString() == "0" && role != "Admin")
                    {
                        // Kick them back to their respective dashboards
                        if (role == "Lecturer")
                            Response.Redirect("~/Lecture/l_dashboard.aspx", false);
                        else
                            Response.Redirect("~/Learner-jo/MemberDashboard.aspx", false);

                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }
            }
            // ----------------------------------------

            // Tell the page to actually load the contacts when it opens!
            if (!IsPostBack)
            {
                LoadContacts();
            }
        }

        private void LoadContacts()
        {
            using (SqlConnection con = new SqlConnection(Cs))
            {
                string myRole = Session["Role"] != null ? Session["Role"].ToString() : "";
                string sql = "";

                if (myRole == "Admin")
                {
                    // ADMIN RULE: The Master Key. Can see and message literally everyone on the platform.
                    sql = @"SELECT UserID, ISNULL(FullName, Username) + ' (' + Role + ')' AS DisplayName 
                            FROM Users 
                            WHERE UserID != @MyID 
                            ORDER BY Role ASC, DisplayName ASC";
                }
                else if (myRole == "Student")
                {
                    // STUDENT RULE: Can see Admins AND Lecturers they are actively enrolled with.
                    sql = @"SELECT DISTINCT u.UserId, ISNULL(u.FullName, u.Username) + ' (' + u.Role + ')' AS DisplayName 
                            FROM Users u
                            LEFT JOIN LearningContent lc ON u.UserId = lc.LecturerId
                            LEFT JOIN Enrolment e ON lc.ContentId = e.ModuleId AND e.StudentId = @MyID
                            WHERE u.UserId != @MyID 
                              AND (u.Role = 'Admin' OR (u.Role = 'Lecturer' AND e.StudentId IS NOT NULL))
                            ORDER BY DisplayName ASC";
                }
                else if (myRole == "Lecturer")
                {
                    // LECTURER RULE: Can see Admins AND Students enrolled in their courses.
                    sql = @"SELECT DISTINCT u.UserId, ISNULL(u.FullName, u.Username) + ' (' + u.Role + ')' AS DisplayName 
                            FROM Users u
                            LEFT JOIN Enrolment e ON u.UserId = e.StudentId
                            LEFT JOIN LearningContent lc ON e.ModuleId = lc.ContentId AND lc.LecturerId = @MyID
                            WHERE u.UserId != @MyID 
                              AND (u.Role = 'Admin' OR (u.Role = 'Student' AND lc.ContentId IS NOT NULL))
                            ORDER BY DisplayName ASC";
                }

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@MyID", CurrentUserId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptContacts.DataSource = dt;
                    rptContacts.DataBind();
                }
            }
        }

        // Fires when a user clicks a name in the left sidebar
        protected void rptContacts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectContact")
            {
                ActiveContactId = Convert.ToInt32(e.CommandArgument);

                // Get the name of the person we clicked to show in the header
                LinkButton btn = (LinkButton)e.CommandSource;
                lblChattingWith.Text = "Chatting with: " + btn.Text;

                LoadChatHistory();

                // Show the text box area now that a user is selected
                inputArea.Visible = true;

                // Refresh contacts to update the blue highlight on the active user
                LoadContacts();
            }
        }

        private void LoadChatHistory()
        {
            if (ActiveContactId == 0) return;

            using (SqlConnection con = new SqlConnection(Cs))
            {
                // Fetch messages where I am the sender and they are receiver, OR they are sender and I am receiver.
                // Order by time ASCENDING so newest messages are at the bottom like WhatsApp
                string sql = @"
                    SELECT SenderID, Body, CreatedAt 
                    FROM Messages 
                    WHERE (SenderID = @MyID AND ReceiverID = @ThemID) 
                       OR (SenderID = @ThemID AND ReceiverID = @MyID)
                    ORDER BY CreatedAt ASC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@MyID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@ThemID", ActiveContactId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptChat.DataSource = dt;
                    rptChat.DataBind();
                }

                // Mark messages from this specific user as read
                string updateSql = "UPDATE Messages SET IsRead = 1 WHERE ReceiverID = @MyID AND SenderID = @ThemID AND IsRead = 0";
                using (SqlCommand updateCmd = new SqlCommand(updateSql, con))
                {
                    updateCmd.Parameters.AddWithValue("@MyID", CurrentUserId);
                    updateCmd.Parameters.AddWithValue("@ThemID", ActiveContactId);
                    con.Open();
                    updateCmd.ExecuteNonQuery();
                }
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string messageBody = txtNewMessage.Text.Trim();

            if (string.IsNullOrWhiteSpace(messageBody) || ActiveContactId == 0) return;

            using (SqlConnection con = new SqlConnection(Cs))
            {
                // Insert message. We hardcode 'Chat' as the subject since WhatsApp doesn't use subjects!
                string sql = "INSERT INTO Messages (SenderID, ReceiverID, Subject, Body, CreatedAt, IsRead) VALUES (@Sender, @Receiver, 'Chat', @Body, GETDATE(), 0)";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Sender", CurrentUserId);
                    cmd.Parameters.AddWithValue("@Receiver", ActiveContactId);
                    cmd.Parameters.AddWithValue("@Body", messageBody);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Clear the textbox and reload the chat to show the new message
            txtNewMessage.Text = "";
            LoadChatHistory();
        }
    }
}
