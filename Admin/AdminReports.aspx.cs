using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;

namespace PythonAcademy.Admin
{
    public partial class AdminReports : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtStartDate.Text = DateTime.Today.AddDays(-30).ToString("yyyy-MM-dd");

            BindReport();
            LogEvent("Reports.View", "Opened admin reports page.");
        }

        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            if (!ValidateDateRange(out DateTime startDate, out DateTime endDateExclusive))
            {
                return;
            }

            try
            {
                BindReport(startDate, endDateExclusive);
                LogEvent("Reports.Generate", "Generated report type '" + ddlReportType.SelectedValue + "'.");
            }
            catch
            {
                ShowMessage("Unable to generate report right now.", true);
            }
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            if (!ValidateDateRange(out DateTime startDate, out DateTime endDateExclusive))
            {
                return;
            }

            try
            {
                DataTable reportData = GetReportData(ddlReportType.SelectedValue, startDate, endDateExclusive);
                ExportDataTableToCsv(reportData, ddlReportType.SelectedValue + "_Report.csv");
                LogEvent("Reports.Export", "Exported report type '" + ddlReportType.SelectedValue + "' to CSV.");
            }
            catch
            {
                ShowMessage("Unable to export report right now.", true);
            }
        }

        private void BindReport()
        {
            BindReport(DateTime.Today.AddDays(-30), DateTime.Today.AddDays(1));
        }

        private void BindReport(DateTime startDate, DateTime endDateExclusive)
        {
            BindSummaryMetrics(startDate, endDateExclusive);
            DataTable reportData = GetReportData(ddlReportType.SelectedValue, startDate, endDateExclusive);
            gvReportData.DataSource = reportData;
            gvReportData.DataBind();
        }

        private void BindSummaryMetrics(DateTime startDate, DateTime endDateExclusive)
        {
            lblRegistrations.Text = Convert.ToString(ExecuteScalar(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE CreatedAt >= @StartDate AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive)));

            lblUploads.Text = Convert.ToString(ExecuteScalar(
                @"SELECT COUNT(*)
                  FROM LearningContent
                  WHERE CreatedAt >= @StartDate AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive)));

            lblActiveUsers.Text = Convert.ToString(ExecuteScalar(
                @"SELECT COUNT(DISTINCT UserID)
                  FROM ActivityLogs
                  WHERE UserID IS NOT NULL
                    AND Timestamp >= @StartDate
                    AND Timestamp < @EndDateExclusive",
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive)));
        }

        private DataTable GetReportData(string reportType, DateTime startDate, DateTime endDateExclusive)
        {
            if (reportType == "ContentEngagement")
            {
                return ExecuteTable(
                    @"SELECT
                        CAST(c.CreatedAt AS DATE) AS [Date],
                        COUNT(*) AS [Uploads]
                      FROM LearningContent c
                      WHERE c.CreatedAt >= @StartDate AND c.CreatedAt < @EndDateExclusive
                      GROUP BY CAST(c.CreatedAt AS DATE)
                      ORDER BY [Date] DESC",
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive));
            }

            if (reportType == "SystemAudits")
            {
                return ExecuteTable(
                    @"SELECT TOP 300
                        l.Timestamp,
                        ISNULL(u.Username, 'System') AS Username,
                        l.Action,
                        l.Details
                      FROM ActivityLogs l
                      LEFT JOIN Users u ON l.UserID = u.UserID
                      WHERE l.Timestamp >= @StartDate AND l.Timestamp < @EndDateExclusive
                      ORDER BY l.Timestamp DESC",
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive));
            }

            return ExecuteTable(
                @"SELECT
                    CAST(u.CreatedAt AS DATE) AS [Date],
                    COUNT(*) AS [NewUsers]
                  FROM Users u
                  WHERE u.CreatedAt >= @StartDate AND u.CreatedAt < @EndDateExclusive
                  GROUP BY CAST(u.CreatedAt AS DATE)
                  ORDER BY [Date] DESC",
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));
        }

        private bool ValidateDateRange(out DateTime startDate, out DateTime endDateExclusive)
        {
            startDate = DateTime.MinValue;
            endDateExclusive = DateTime.MinValue;

            if (!DateTime.TryParse(txtStartDate.Text, out DateTime parsedStart) ||
                !DateTime.TryParse(txtEndDate.Text, out DateTime parsedEnd))
            {
                ShowMessage("Please provide valid start and end dates.", true);
                return false;
            }

            if (parsedStart.Date > parsedEnd.Date)
            {
                ShowMessage("Start date cannot be after end date.", true);
                return false;
            }

            if ((parsedEnd.Date - parsedStart.Date).TotalDays > 366)
            {
                ShowMessage("Date range cannot exceed 366 days.", true);
                return false;
            }

            startDate = parsedStart.Date;
            endDateExclusive = parsedEnd.Date.AddDays(1);
            return true;
        }

        private void ExportDataTableToCsv(DataTable table, string fileName)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=" + fileName);
            Response.Charset = string.Empty;
            Response.ContentType = "text/csv";

            StringBuilder csv = new StringBuilder();

            for (int i = 0; i < table.Columns.Count; i++)
            {
                if (i > 0)
                {
                    csv.Append(",");
                }

                csv.Append(EscapeCsvField(table.Columns[i].ColumnName));
            }

            csv.AppendLine();

            foreach (DataRow row in table.Rows)
            {
                for (int i = 0; i < table.Columns.Count; i++)
                {
                    if (i > 0)
                    {
                        csv.Append(",");
                    }

                    csv.Append(EscapeCsvField(Convert.ToString(row[i])));
                }

                csv.AppendLine();
            }

            Response.Output.Write(csv.ToString());
            Response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        private static string EscapeCsvField(string value)
        {
            string safe = value ?? string.Empty;
            safe = safe.Replace("\"", "\"\"");
            return "\"" + safe + "\"";
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(255, 185, 185) : System.Drawing.Color.FromArgb(130, 255, 190);
            lblMessage.Visible = true;
        }
    }
}
