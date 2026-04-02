using System;
using System.Data.SqlClient;
using System.Net.Mail;

namespace PythonAcademy.Admin
{
    // admin can configure platform-wide settings here like email and upload limits
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
                // make sure the settings table exists before we try to read from it
                EnsureSettingsTable();
                LoadSettings();
                LogEvent("Settings.View", "Opened settings page.");
            }
            catch
            {
                ShowMessage("Unable to load settings right now.", true);
            }
        }

        // fires when the admin clicks Save Settings
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

            // using MailAddress to validate the email format properly instead of regex
            // new MailAddress() throws a FormatException if the format is invalid
            try
            {
                MailAddress ignored = new MailAddress(supportEmail);
            }
            catch
            {
                ShowMessage("Support email format is invalid.", true);
                return;
            }

            // upload size must be a whole number between 1 and 1024 MB
            if (!int.TryParse(maxUploadSizeText, out maxUploadSize) || maxUploadSize < 1 || maxUploadSize > 1024)
            {
                ShowMessage("Max upload size must be a number between 1 and 1024.", true);
                return;
            }

            try
            {
                EnsureSettingsTable();
                // save each setting individually as a key-value pair
                SaveSetting("SupportEmail", supportEmail);
                SaveSetting("MaxUploadSizeMB", maxUploadSize.ToString());
                // store checkboxes as "1" or "0" since the column is NVARCHAR
                SaveSetting("AllowRegistrations", chkAllowRegistrations.Checked ? "1" : "0");
                SaveSetting("MaintenanceMode", chkMaintenanceMode.Checked ? "1" : "0");
                SaveSetting("EnableMessaging", chkEnableMessaging.Checked ? "1" : "0");

                ShowMessage("Settings saved successfully.", false);
                LogEvent("Settings.Save", "Updated platform settings.");
            }
            catch
            {
                ShowMessage("Unable to save settings right now.", true);
            }
        }

        // reads all settings from the db and fills in the form fields
        private void LoadSettings()
        {
            // second argument is the default value if the key doesnt exist yet
            string supportEmail = ReadSetting("SupportEmail", "admin@pythonacademy.com");
            string maxUploadSize = ReadSetting("MaxUploadSizeMB", "50");
            string allowRegistrations = ReadSetting("AllowRegistrations", "1");
            string maintenanceMode = ReadSetting("MaintenanceMode", "0");
            string enableMessaging = ReadSetting("EnableMessaging", "1");

            txtSupportEmail.Text = supportEmail;
            txtMaxUploadSize.Text = maxUploadSize;
            // "== 1" converts the stored "1"/"0" string back into a true/false for the checkbox
            chkAllowRegistrations.Checked = allowRegistrations == "1";
            chkMaintenanceMode.Checked = maintenanceMode == "1";
            chkEnableMessaging.Checked = enableMessaging == "1";
        }

        // reads a single setting by its key, returns the default if it doesnt exist
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

        // inserts or updates a setting using MERGE so i dont need separate INSERT/UPDATE logic
        // MERGE = "if the key already exists, UPDATE it; if not, INSERT it" — one query does both
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

        // creates the PlatformSettings table if it doesnt already exist
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

        // shows a green or red status message depending on the outcome
        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }
    }
}
