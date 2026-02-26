using System;
using System.Data.SqlClient;
using System.Net.Mail;

namespace PythonAcademy.Admin
{
    public partial class Settings : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            try
            {
                EnsureSettingsTable();
                LoadSettings();
                LogEvent("Settings.View", "Opened settings page.");
            }
            catch
            {
                ShowMessage("Unable to load settings right now.", true);
            }
        }

        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            string supportEmail = (txtSupportEmail.Text ?? string.Empty).Trim();
            string maxUploadSizeText = (txtMaxUploadSize.Text ?? string.Empty).Trim();
            int maxUploadSize;

            if (string.IsNullOrWhiteSpace(supportEmail))
            {
                ShowMessage("Support email is required.", true);
                return;
            }

            try
            {
                MailAddress ignored = new MailAddress(supportEmail);
            }
            catch
            {
                ShowMessage("Support email format is invalid.", true);
                return;
            }

            if (!int.TryParse(maxUploadSizeText, out maxUploadSize) || maxUploadSize < 1 || maxUploadSize > 1024)
            {
                ShowMessage("Max upload size must be a number between 1 and 1024.", true);
                return;
            }

            try
            {
                EnsureSettingsTable();
                SaveSetting("SupportEmail", supportEmail);
                SaveSetting("MaxUploadSizeMB", maxUploadSize.ToString());
                SaveSetting("AllowRegistrations", chkAllowRegistrations.Checked ? "1" : "0");
                SaveSetting("MaintenanceMode", chkMaintenanceMode.Checked ? "1" : "0");

                ShowMessage("Settings saved successfully.", false);
                LogEvent("Settings.Save", "Updated platform settings.");
            }
            catch
            {
                ShowMessage("Unable to save settings right now.", true);
            }
        }

        private void LoadSettings()
        {
            string supportEmail = ReadSetting("SupportEmail", "admin@pythonacademy.com");
            string maxUploadSize = ReadSetting("MaxUploadSizeMB", "50");
            string allowRegistrations = ReadSetting("AllowRegistrations", "1");
            string maintenanceMode = ReadSetting("MaintenanceMode", "0");

            txtSupportEmail.Text = supportEmail;
            txtMaxUploadSize.Text = maxUploadSize;
            chkAllowRegistrations.Checked = allowRegistrations == "1";
            chkMaintenanceMode.Checked = maintenanceMode == "1";
        }

        private string ReadSetting(string key, string defaultValue)
        {
            object value = ExecuteScalar(
                "SELECT SettingValue FROM PlatformSettings WHERE SettingKey = @SettingKey",
                new SqlParameter("@SettingKey", key));

            if (value == null || value == DBNull.Value)
            {
                return defaultValue;
            }

            string str = Convert.ToString(value);
            return string.IsNullOrWhiteSpace(str) ? defaultValue : str;
        }

        private void SaveSetting(string key, string value)
        {
            ExecuteNonQuery(
                @"MERGE PlatformSettings AS target
                  USING (SELECT @SettingKey AS SettingKey, @SettingValue AS SettingValue) AS source
                  ON target.SettingKey = source.SettingKey
                  WHEN MATCHED THEN
                    UPDATE SET SettingValue = source.SettingValue, UpdatedAt = GETDATE()
                  WHEN NOT MATCHED THEN
                    INSERT (SettingKey, SettingValue, UpdatedAt) VALUES (source.SettingKey, source.SettingValue, GETDATE());",
                new SqlParameter("@SettingKey", key),
                new SqlParameter("@SettingValue", value));
        }

        private void EnsureSettingsTable()
        {
            ExecuteNonQuery(
                @"IF OBJECT_ID('dbo.PlatformSettings', 'U') IS NULL
                  BEGIN
                      CREATE TABLE PlatformSettings (
                          SettingKey NVARCHAR(100) NOT NULL PRIMARY KEY,
                          SettingValue NVARCHAR(500) NULL,
                          UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
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
