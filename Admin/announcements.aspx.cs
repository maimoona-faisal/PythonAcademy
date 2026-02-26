using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    public partial class announcements : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            try
            {
                EnsureAnnouncementsTable();
                BindAnnouncements();
                LogEvent("Announcements.View", "Opened announcements page.");
            }
            catch
            {
                ShowMessage("Unable to load announcements right now.", true);
            }
        }

        protected void btnBroadcast_Click(object sender, EventArgs e)
        {
            string title = (txtTitle.Text ?? string.Empty).Trim();
            string audience = (ddlAudience.SelectedValue ?? string.Empty).Trim();
            string message = (txtMessage.Text ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(title))
            {
                ShowMessage("Announcement title is required.", true);
                return;
            }

            if (title.Length > 200)
            {
                ShowMessage("Title cannot exceed 200 characters.", true);
                return;
            }

            if (string.IsNullOrWhiteSpace(message))
            {
                ShowMessage("Announcement message is required.", true);
                return;
            }

            if (message.Length > 4000)
            {
                ShowMessage("Message is too long.", true);
                return;
            }

            if (audience != "All" && audience != "Students" && audience != "Lecturers")
            {
                ShowMessage("Selected audience is invalid.", true);
                return;
            }

            if (!AdminUserId.HasValue)
            {
                ShowMessage("Your session expired. Please sign in again.", true);
                return;
            }

            try
            {
                EnsureAnnouncementsTable();
                ExecuteNonQuery(
                    @"INSERT INTO Announcements (AdminID, Title, Message, TargetAudience, CreatedAt)
                      VALUES (@AdminID, @Title, @Message, @TargetAudience, GETDATE())",
                    new SqlParameter("@AdminID", AdminUserId.Value),
                    new SqlParameter("@Title", title),
                    new SqlParameter("@Message", message),
                    new SqlParameter("@TargetAudience", audience));

                txtTitle.Text = string.Empty;
                txtMessage.Text = string.Empty;
                ddlAudience.SelectedValue = "All";

                BindAnnouncements();
                ShowMessage("Announcement broadcasted successfully.", false);
                LogEvent("Announcements.Broadcast", "Created announcement for audience '" + audience + "'.");
            }
            catch
            {
                ShowMessage("Unable to broadcast the announcement right now.", true);
            }
        }

        protected void gvAnnouncements_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int announcementId = Convert.ToInt32(gvAnnouncements.DataKeys[e.RowIndex].Value);

            try
            {
                int affected = ExecuteNonQuery(
                    "DELETE FROM Announcements WHERE AnnouncementID = @AnnouncementID",
                    new SqlParameter("@AnnouncementID", announcementId));

                if (affected == 0)
                {
                    ShowMessage("Announcement no longer exists.", true);
                }
                else
                {
                    ShowMessage("Announcement deleted successfully.", false);
                    LogEvent("Announcements.Delete", "Deleted announcement AnnouncementID=" + announcementId + ".");
                }

                BindAnnouncements();
            }
            catch
            {
                ShowMessage("Unable to delete announcement right now.", true);
            }
        }

        private void BindAnnouncements()
        {
            DataTable announcementsTable = ExecuteTable(
                @"SELECT AnnouncementID, CreatedAt, Title, TargetAudience
                  FROM Announcements
                  ORDER BY CreatedAt DESC");

            gvAnnouncements.DataSource = announcementsTable;
            gvAnnouncements.DataBind();
        }

        private void EnsureAnnouncementsTable()
        {
            ExecuteNonQuery(
                @"IF OBJECT_ID('dbo.Announcements', 'U') IS NULL
                  BEGIN
                      CREATE TABLE Announcements (
                          AnnouncementID INT IDENTITY(1,1) PRIMARY KEY,
                          AdminID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
                          Title NVARCHAR(200) NOT NULL,
                          Message NVARCHAR(MAX) NOT NULL,
                          TargetAudience NVARCHAR(50) NOT NULL,
                          CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
                      )
                  END");
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }
    }
}
