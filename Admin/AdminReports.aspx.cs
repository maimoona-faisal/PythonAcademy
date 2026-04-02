using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;

namespace PythonAcademy.Admin
{
    // this page lets the admin generate and export meaningful operational reports
    public partial class AdminReports : AdminPage
    {
        // small data container for one of the three stat cards shown at the top of each report
        private sealed class ReportMetric
        {
            public string Title { get; set; }
            public string Value { get; set; }
            public string Caption { get; set; }
        }

        // bundles everything a report needs into one object so we can pass it around easily
        private sealed class ReportResult
        {
            public string ReportName { get; set; }
            public string ExportFilePrefix { get; set; }
            public string SummaryText { get; set; }
            public string StatusMessage { get; set; }
            public bool IsErrorStatus { get; set; }
            public DataTable Data { get; set; }
            public ReportMetric MetricOne { get; set; }
            public ReportMetric MetricTwo { get; set; }
            public ReportMetric MetricThree { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            // default the date range to the last 30 days on first load
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtStartDate.Text = DateTime.Today.AddDays(-30).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

            BindReport();
            LogEvent("Reports.View", "Opened admin reports page.");
        }

        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            DateTime startDate;
            DateTime endDateExclusive;
            if (!ValidateDateRange(out startDate, out endDateExclusive))
            {
                return;
            }

            try
            {
                BindReport(startDate, endDateExclusive);
                LogEvent(
                    "Reports.Generate",
                    string.Format(
                        CultureInfo.InvariantCulture,
                        "Generated {0} report for {1:yyyy-MM-dd} to {2:yyyy-MM-dd}.",
                        ddlReportType.SelectedValue,
                        startDate,
                        endDateExclusive.AddDays(-1)));
            }
            catch
            {
                SetStatusMessage(lblMessage, "Unable to generate report right now.", true);
            }
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DateTime startDate;
            DateTime endDateExclusive;
            if (!ValidateDateRange(out startDate, out endDateExclusive))
            {
                return;
            }

            try
            {
                ReportResult report = BuildReport(ddlReportType.SelectedValue, startDate, endDateExclusive);

                // build a filename like "UserGrowth_20250101_20250131.csv"
                string fileName = string.Format(
                    CultureInfo.InvariantCulture,
                    "{0}_{1:yyyyMMdd}_{2:yyyyMMdd}.csv",
                    report.ExportFilePrefix,
                    startDate,
                    endDateExclusive.AddDays(-1));

                LogEvent(
                    "Reports.Export",
                    string.Format(
                        CultureInfo.InvariantCulture,
                        "Exported {0} report for {1:yyyy-MM-dd} to {2:yyyy-MM-dd}.",
                        ddlReportType.SelectedValue,
                        startDate,
                        endDateExclusive.AddDays(-1)));

                ExportDataTableToCsv(report.Data, fileName);
            }
            catch
            {
                SetStatusMessage(lblMessage, "Unable to export report right now.", true);
            }
        }

        // overload with no args — uses the default last-30-days range
        private void BindReport()
        {
            BindReport(DateTime.Today.AddDays(-30), DateTime.Today.AddDays(1));
        }

        private void BindReport(DateTime startDate, DateTime endDateExclusive)
        {
            ClearStatusMessage(lblMessage);

            ReportResult report = BuildReport(ddlReportType.SelectedValue, startDate, endDateExclusive);
            ApplyReport(report); // push the result into the page labels and grid
        }

        // routes to the correct report builder based on the dropdown selection
        private ReportResult BuildReport(string reportType, DateTime startDate, DateTime endDateExclusive)
        {
            if (string.Equals(reportType, "VerificationActivity", StringComparison.OrdinalIgnoreCase))
            {
                return BuildVerificationActivityReport(startDate, endDateExclusive);
            }

            if (string.Equals(reportType, "ContentActivity", StringComparison.OrdinalIgnoreCase))
            {
                return BuildContentActivityReport(startDate, endDateExclusive);
            }

            if (string.Equals(reportType, "SystemAudits", StringComparison.OrdinalIgnoreCase))
            {
                return BuildSystemAuditReport(startDate, endDateExclusive);
            }

            // default if nothing else matches
            return BuildUserGrowthReport(startDate, endDateExclusive);
        }

        private ReportResult BuildUserGrowthReport(DateTime startDate, DateTime endDateExclusive)
        {
            ReportResult result = CreateBaseReportResult(
                "User Growth",
                "UserGrowth",
                startDate,
                endDateExclusive);

            if (!TableExists("Users"))
            {
                result.StatusMessage = "Users table was not found. User growth data cannot be generated.";
                result.IsErrorStatus = true;
                result.Data = CreateEmptyTable("Date", "New Users", "Students", "Lecturers", "Admins");
                result.MetricOne = CreateMetric("New Users", "0", "Selected period");
                result.MetricTwo = CreateMetric("Students", "0", "Selected period");
                result.MetricThree = CreateMetric("Lecturers", "0", "Selected period");
                return result;
            }

            SqlParameter[] parameters =
            {
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive)
            };

            int totalUsers = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE CreatedAt >= @StartDate AND CreatedAt < @EndDateExclusive",
                parameters);

            int students = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE Role = @Role
                    AND CreatedAt >= @StartDate
                    AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@Role", "Student"),
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            int lecturers = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE Role = @Role
                    AND CreatedAt >= @StartDate
                    AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            result.MetricOne = CreateMetric("New Users", totalUsers.ToString(CultureInfo.InvariantCulture), "Selected period");
            result.MetricTwo = CreateMetric("Students", students.ToString(CultureInfo.InvariantCulture), "Selected period");
            result.MetricThree = CreateMetric("Lecturers", lecturers.ToString(CultureInfo.InvariantCulture), "Selected period");

            // SUM(CASE WHEN Role = 'X' THEN 1 ELSE 0 END) is a trick to count per-role in a single query
            result.Data = ExecuteTable(
                @"SELECT
                    CAST(u.CreatedAt AS DATE) AS [Date],
                    COUNT(*) AS [New Users],
                    SUM(CASE WHEN u.Role = 'Student' THEN 1 ELSE 0 END) AS [Students],
                    SUM(CASE WHEN u.Role = 'Lecturer' THEN 1 ELSE 0 END) AS [Lecturers],
                    SUM(CASE WHEN u.Role = 'Admin' THEN 1 ELSE 0 END) AS [Admins]
                  FROM Users u
                  WHERE u.CreatedAt >= @StartDate AND u.CreatedAt < @EndDateExclusive
                  GROUP BY CAST(u.CreatedAt AS DATE)
                  ORDER BY [Date] DESC",
                parameters);

            result.SummaryText += " Tracks new account creation by role so admins can spot overall growth and lecturer application volume.";
            return result;
        }

        private ReportResult BuildVerificationActivityReport(DateTime startDate, DateTime endDateExclusive)
        {
            ReportResult result = CreateBaseReportResult(
                "Verification Activity",
                "VerificationActivity",
                startDate,
                endDateExclusive);

            if (!TableExists("Users"))
            {
                result.StatusMessage = "Users table was not found. Verification activity cannot be generated.";
                result.IsErrorStatus = true;
                result.Data = CreateEmptyTable("Date", "Applications Submitted", "Approved", "Rejected");
                result.MetricOne = CreateMetric("Applications", "0", "Selected period");
                result.MetricTwo = CreateMetric("Approved", "0", "Selected period");
                result.MetricThree = CreateMetric("Rejected", "0", "Selected period");
                return result;
            }

            SqlParameter[] rangeParameters =
            {
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive)
            };

            int submitted = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE Role = @Role
                    AND CreatedAt >= @StartDate
                    AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            result.MetricOne = CreateMetric("Applications", submitted.ToString(CultureInfo.InvariantCulture), "Selected period");

            // if the VerificationLog table exists, use it for accurate approve/reject counts
            // otherwise fall back to the current status on the Users record (less precise)
            bool hasVerificationLog = TableExists("VerificationLog");
            int pendingQueue = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE Role = @Role AND Status = @Status",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Pending"));

            if (hasVerificationLog)
            {
                int approved = ExecuteScalarInt(
                    @"SELECT COUNT(*)
                      FROM VerificationLog
                      WHERE TargetType = @TargetType
                        AND Status IN ('Approved', 'Active')
                        AND ReviewedAt >= @StartDate
                        AND ReviewedAt < @EndDateExclusive",
                    new SqlParameter("@TargetType", "InstructorRegistration"),
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive));

                int rejected = ExecuteScalarInt(
                    @"SELECT COUNT(*)
                      FROM VerificationLog
                      WHERE TargetType = @TargetType
                        AND Status = @Status
                        AND ReviewedAt >= @StartDate
                        AND ReviewedAt < @EndDateExclusive",
                    new SqlParameter("@TargetType", "InstructorRegistration"),
                    new SqlParameter("@Status", "Rejected"),
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive));

                result.MetricTwo = CreateMetric("Approved", approved.ToString(CultureInfo.InvariantCulture), "Selected period");
                result.MetricThree = CreateMetric("Rejected", rejected.ToString(CultureInfo.InvariantCulture), "Selected period");

                // FULL OUTER JOIN combines two CTEs so a date appears even if it only has submissions OR reviews (not both)
                result.Data = ExecuteTable(
                    @"
                    WITH Submitted AS
                    (
                        SELECT
                            CAST(u.CreatedAt AS DATE) AS ActivityDate,
                            COUNT(*) AS SubmittedCount
                        FROM Users u
                        WHERE u.Role = 'Lecturer'
                          AND u.CreatedAt >= @StartDate
                          AND u.CreatedAt < @EndDateExclusive
                        GROUP BY CAST(u.CreatedAt AS DATE)
                    ),
                    Reviewed AS
                    (
                        SELECT
                            CAST(v.ReviewedAt AS DATE) AS ActivityDate,
                            SUM(CASE WHEN v.Status IN ('Approved', 'Active') THEN 1 ELSE 0 END) AS ApprovedCount,
                            SUM(CASE WHEN v.Status = 'Rejected' THEN 1 ELSE 0 END) AS RejectedCount
                        FROM VerificationLog v
                        WHERE v.TargetType = @TargetType
                          AND v.ReviewedAt >= @StartDate
                          AND v.ReviewedAt < @EndDateExclusive
                        GROUP BY CAST(v.ReviewedAt AS DATE)
                    )
                    SELECT
                        COALESCE(s.ActivityDate, r.ActivityDate) AS [Date],
                        ISNULL(s.SubmittedCount, 0) AS [Applications Submitted],
                        ISNULL(r.ApprovedCount, 0) AS [Approved],
                        ISNULL(r.RejectedCount, 0) AS [Rejected]
                    FROM Submitted s
                    FULL OUTER JOIN Reviewed r ON s.ActivityDate = r.ActivityDate
                    ORDER BY [Date] DESC",
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive),
                    new SqlParameter("@TargetType", "InstructorRegistration"));

                result.SummaryText += string.Format(
                    CultureInfo.InvariantCulture,
                    " Includes both lecturer applications and verification decisions. Current pending queue: {0}.",
                    pendingQueue);

                return result;
            }

            // VerificationLog doesn't exist — fall back to reading current status from Users table
            int currentlyPendingInRange = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE Role = @Role
                    AND Status = @Status
                    AND CreatedAt >= @StartDate
                    AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Pending"),
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            int currentlyRejectedInRange = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM Users
                  WHERE Role = @Role
                    AND Status = @Status
                    AND CreatedAt >= @StartDate
                    AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@Role", "Lecturer"),
                new SqlParameter("@Status", "Rejected"),
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            result.MetricTwo = CreateMetric("Still Pending", currentlyPendingInRange.ToString(CultureInfo.InvariantCulture), "Current status in range");
            result.MetricThree = CreateMetric("Currently Rejected", currentlyRejectedInRange.ToString(CultureInfo.InvariantCulture), "Current status in range");

            result.Data = ExecuteTable(
                @"SELECT
                    CAST(u.CreatedAt AS DATE) AS [Date],
                    COUNT(*) AS [Applications Submitted],
                    SUM(CASE WHEN u.Status = 'Pending' THEN 1 ELSE 0 END) AS [Still Pending],
                    SUM(CASE WHEN u.Status = 'Active' THEN 1 ELSE 0 END) AS [Currently Approved],
                    SUM(CASE WHEN u.Status = 'Rejected' THEN 1 ELSE 0 END) AS [Currently Rejected]
                  FROM Users u
                  WHERE u.Role = 'Lecturer'
                    AND u.CreatedAt >= @StartDate
                    AND u.CreatedAt < @EndDateExclusive
                  GROUP BY CAST(u.CreatedAt AS DATE)
                  ORDER BY [Date] DESC",
                rangeParameters);

            result.StatusMessage = "VerificationLog table was not found. Showing lecturer application status by current account state instead of review history.";
            result.IsErrorStatus = false;
            result.SummaryText += string.Format(
                CultureInfo.InvariantCulture,
                " Historical review decisions are unavailable because VerificationLog is missing. Current pending queue: {0}.",
                pendingQueue);
            return result;
        }

        private ReportResult BuildContentActivityReport(DateTime startDate, DateTime endDateExclusive)
        {
            ReportResult result = CreateBaseReportResult(
                "Content Activity",
                "ContentActivity",
                startDate,
                endDateExclusive);

            if (!TableExists("LearningContent"))
            {
                result.StatusMessage = "LearningContent table was not found. Content activity cannot be generated.";
                result.IsErrorStatus = true;
                result.Data = CreateEmptyTable("Module", "Lecturer", "Uploaded In Period", "New Enrolments", "Completions", "Publish Status");
                result.MetricOne = CreateMetric("Uploads", "0", "Selected period");
                result.MetricTwo = CreateMetric("Enrolments", "0", "Selected period");
                result.MetricThree = CreateMetric("Completions", "0", "Selected period");
                return result;
            }

            // check which optional tables exist so we can conditionally include their columns
            bool hasEnrolment = TableExists("Enrolment");
            bool hasCertificates = TableExists("Certificates");

            int uploads = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM LearningContent
                  WHERE CreatedAt >= @StartDate AND CreatedAt < @EndDateExclusive",
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            // ternary used here: if table exists run the query, otherwise just use 0
            int enrolments = hasEnrolment
                ? ExecuteScalarInt(
                    @"SELECT COUNT(*)
                      FROM Enrolment
                      WHERE EnrolledAt >= @StartDate AND EnrolledAt < @EndDateExclusive",
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive))
                : 0;

            int completions = hasEnrolment
                ? ExecuteScalarInt(
                    @"SELECT COUNT(*)
                      FROM Enrolment
                      WHERE CompletedAt IS NOT NULL
                        AND CompletedAt >= @StartDate
                        AND CompletedAt < @EndDateExclusive",
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDateExclusive", endDateExclusive))
                : 0;

            result.MetricOne = CreateMetric("Uploads", uploads.ToString(CultureInfo.InvariantCulture), "Selected period");
            result.MetricTwo = CreateMetric("Enrolments", enrolments.ToString(CultureInfo.InvariantCulture), hasEnrolment ? "Selected period" : "Enrolment table missing");
            result.MetricThree = CreateMetric("Completions", completions.ToString(CultureInfo.InvariantCulture), hasEnrolment ? "Selected period" : "Enrolment table missing");

            // build the SELECT dynamically — only add enrolment/certificate columns if those tables exist
            StringBuilder sql = new StringBuilder();
            sql.AppendLine("SELECT TOP 100");
            sql.AppendLine("    c.Title AS [Module],");
            sql.AppendLine("    ISNULL(lecturer.Username, 'Unknown Lecturer') AS [Lecturer],");
            sql.AppendLine("    CASE WHEN c.CreatedAt >= @StartDate AND c.CreatedAt < @EndDateExclusive THEN 'Yes' ELSE 'No' END AS [Uploaded In Period],");

            if (hasEnrolment)
            {
                sql.AppendLine("    (SELECT COUNT(*) FROM Enrolment e WHERE e.ModuleID = c.ContentId AND e.EnrolledAt >= @StartDate AND e.EnrolledAt < @EndDateExclusive) AS [New Enrolments],");
                sql.AppendLine("    (SELECT COUNT(*) FROM Enrolment e WHERE e.ModuleID = c.ContentId AND e.CompletedAt IS NOT NULL AND e.CompletedAt >= @StartDate AND e.CompletedAt < @EndDateExclusive) AS [Completions],");
            }
            else
            {
                sql.AppendLine("    CAST(0 AS INT) AS [New Enrolments],");
                sql.AppendLine("    CAST(0 AS INT) AS [Completions],");
            }

            if (hasCertificates)
            {
                sql.AppendLine("    (SELECT COUNT(*) FROM Certificates cert WHERE cert.ModuleID = c.ContentId AND cert.IssuedAt >= @StartDate AND cert.IssuedAt < @EndDateExclusive) AS [Certificates],");
            }

            sql.AppendLine("    CASE WHEN c.IsPublished = 1 THEN 'Published' ELSE 'Draft' END AS [Publish Status]");
            sql.AppendLine("FROM LearningContent c");
            sql.AppendLine("LEFT JOIN Users lecturer ON lecturer.UserId = c.LecturerId");
            sql.AppendLine("WHERE");
            sql.AppendLine("    (c.CreatedAt >= @StartDate AND c.CreatedAt < @EndDateExclusive)");

            if (hasEnrolment)
            {
                // EXISTS subquery — include a module even if it wasn't uploaded in this period, as long as it had activity
                sql.AppendLine("    OR EXISTS (");
                sql.AppendLine("        SELECT 1");
                sql.AppendLine("        FROM Enrolment e");
                sql.AppendLine("        WHERE e.ModuleID = c.ContentId");
                sql.AppendLine("          AND (");
                sql.AppendLine("              (e.EnrolledAt >= @StartDate AND e.EnrolledAt < @EndDateExclusive)");
                sql.AppendLine("              OR (e.CompletedAt IS NOT NULL AND e.CompletedAt >= @StartDate AND e.CompletedAt < @EndDateExclusive)");
                sql.AppendLine("          )");
                sql.AppendLine("    )");
            }

            if (hasCertificates)
            {
                sql.AppendLine("    OR EXISTS (");
                sql.AppendLine("        SELECT 1");
                sql.AppendLine("        FROM Certificates cert");
                sql.AppendLine("        WHERE cert.ModuleID = c.ContentId");
                sql.AppendLine("          AND cert.IssuedAt >= @StartDate");
                sql.AppendLine("          AND cert.IssuedAt < @EndDateExclusive");
                sql.AppendLine("    )");
            }

            sql.AppendLine("ORDER BY [New Enrolments] DESC, [Completions] DESC, c.CreatedAt DESC, c.Title ASC");

            result.Data = ExecuteTable(
                sql.ToString(),
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive));

            if (!hasEnrolment || !hasCertificates)
            {
                result.StatusMessage = "Some optional activity tables are unavailable. The report still loads, but missing tables reduce engagement detail.";
                result.IsErrorStatus = false;
            }

            result.SummaryText += " Highlights uploads alongside learner activity so admins can quickly spot which modules drew attention during the selected period.";
            return result;
        }

        private ReportResult BuildSystemAuditReport(DateTime startDate, DateTime endDateExclusive)
        {
            ReportResult result = CreateBaseReportResult(
                "System Audits",
                "SystemAudits",
                startDate,
                endDateExclusive);

            if (!TableExists("ActivityLogs"))
            {
                result.StatusMessage = "ActivityLogs table was not found. System audit reporting is unavailable.";
                result.IsErrorStatus = true;
                result.Data = CreateEmptyTable("Category", "Action", "Events", "Distinct Actors", "Last Occurred");
                result.MetricOne = CreateMetric("Audit Events", "0", "Selected period");
                result.MetricTwo = CreateMetric("Distinct Actors", "0", "Selected period");
                result.MetricThree = CreateMetric("High-Impact Actions", "0", "Selected period");
                return result;
            }

            SqlParameter[] parameters =
            {
                new SqlParameter("@StartDate", startDate),
                new SqlParameter("@EndDateExclusive", endDateExclusive)
            };

            int events = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM ActivityLogs
                  WHERE Timestamp >= @StartDate AND Timestamp < @EndDateExclusive",
                parameters);

            // COUNT(DISTINCT ...) only counts unique values — tells us how many different admins acted
            int actors = ExecuteScalarInt(
                @"SELECT COUNT(DISTINCT UserID)
                  FROM ActivityLogs
                  WHERE UserID IS NOT NULL
                    AND Timestamp >= @StartDate
                    AND Timestamp < @EndDateExclusive",
                parameters);

            // "high impact" = actions that change data or configuration (not just views)
            int highImpact = ExecuteScalarInt(
                @"SELECT COUNT(*)
                  FROM ActivityLogs
                  WHERE Timestamp >= @StartDate
                    AND Timestamp < @EndDateExclusive
                    AND
                    (
                        Action IN ('Verification.Approve', 'Verification.Reject', 'Reports.Export')
                        OR Action LIKE 'Users.%'
                        OR Action LIKE 'Content.%'
                        OR Action LIKE 'Settings.%'
                    )",
                parameters);

            result.MetricOne = CreateMetric("Audit Events", events.ToString(CultureInfo.InvariantCulture), "Selected period");
            result.MetricTwo = CreateMetric("Distinct Actors", actors.ToString(CultureInfo.InvariantCulture), "Selected period");
            result.MetricThree = CreateMetric("High-Impact Actions", highImpact.ToString(CultureInfo.InvariantCulture), "Selected period");

            result.Data = ExecuteTable(
                @"SELECT TOP 100
                    CASE
                        WHEN l.Action IS NULL OR LTRIM(RTRIM(l.Action)) = '' THEN 'General'
                        WHEN CHARINDEX('.', l.Action) > 0 THEN LEFT(l.Action, CHARINDEX('.', l.Action) - 1)
                        WHEN CHARINDEX(':', l.Action) > 0 THEN LEFT(l.Action, CHARINDEX(':', l.Action) - 1)
                        ELSE l.Action
                    END AS [Category],
                    ISNULL(l.Action, 'General') AS [Action],
                    COUNT(*) AS [Events],
                    COUNT(DISTINCT l.UserID) AS [Distinct Actors],
                    MAX(l.Timestamp) AS [Last Occurred]
                  FROM ActivityLogs l
                  WHERE l.Timestamp >= @StartDate AND l.Timestamp < @EndDateExclusive
                  GROUP BY
                    CASE
                        WHEN l.Action IS NULL OR LTRIM(RTRIM(l.Action)) = '' THEN 'General'
                        WHEN CHARINDEX('.', l.Action) > 0 THEN LEFT(l.Action, CHARINDEX('.', l.Action) - 1)
                        WHEN CHARINDEX(':', l.Action) > 0 THEN LEFT(l.Action, CHARINDEX(':', l.Action) - 1)
                        ELSE l.Action
                    END,
                    ISNULL(l.Action, 'General')
                  ORDER BY [Last Occurred] DESC, [Events] DESC, [Action] ASC",
                parameters);

            result.SummaryText += " Groups meaningful audit events by action so admins can review operational changes without wading through a raw activity dump.";
            return result;
        }

        private static ReportMetric CreateMetric(string title, string value, string caption)
        {
            return new ReportMetric
            {
                Title = title,
                Value = value,
                Caption = caption
            };
        }

        // sets up common fields every report shares — avoids repeating this in every Build* method
        private ReportResult CreateBaseReportResult(string reportName, string exportFilePrefix, DateTime startDate, DateTime endDateExclusive)
        {
            return new ReportResult
            {
                ReportName = reportName,
                ExportFilePrefix = exportFilePrefix,
                SummaryText = string.Format(
                    CultureInfo.InvariantCulture,
                    "{0} for {1:MMM dd, yyyy} to {2:MMM dd, yyyy}.",
                    reportName,
                    startDate,
                    endDateExclusive.AddDays(-1)),
                Data = new DataTable()
            };
        }

        // takes a finished ReportResult and pushes its values into all the visible controls on the page
        private void ApplyReport(ReportResult report)
        {
            if (!string.IsNullOrWhiteSpace(report.StatusMessage))
            {
                SetStatusMessage(lblMessage, report.StatusMessage, report.IsErrorStatus);
            }
            else
            {
                ClearStatusMessage(lblMessage);
            }

            ApplyMetric(lblMetricOneTitle, lblMetricOneValue, lblMetricOneCaption, report.MetricOne);
            ApplyMetric(lblMetricTwoTitle, lblMetricTwoValue, lblMetricTwoCaption, report.MetricTwo);
            ApplyMetric(lblMetricThreeTitle, lblMetricThreeValue, lblMetricThreeCaption, report.MetricThree);

            lblReportSummary.Text = report.SummaryText ?? string.Empty;
            gvReportData.DataSource = report.Data;
            gvReportData.DataBind();
        }

        // fills in the three label controls for one metric card
        private static void ApplyMetric(
            System.Web.UI.WebControls.Label titleLabel,
            System.Web.UI.WebControls.Label valueLabel,
            System.Web.UI.WebControls.Label captionLabel,
            ReportMetric metric)
        {
            // if metric is null for some reason, fall back to safe defaults
            ReportMetric safeMetric = metric ?? CreateMetric("Metric", "0", string.Empty);
            titleLabel.Text = safeMetric.Title ?? string.Empty;
            valueLabel.Text = safeMetric.Value ?? "0";
            captionLabel.Text = safeMetric.Caption ?? string.Empty;
        }

        // creates an empty DataTable with string columns — used when the report can't run
        private static DataTable CreateEmptyTable(params string[] columns)
        {
            DataTable table = new DataTable();
            foreach (string column in columns)
            {
                table.Columns.Add(column, typeof(string));
            }

            return table;
        }

        // validates both date inputs and returns them as proper DateTime values
        // also enforces a max range of 366 days to avoid huge slow queries
        private bool ValidateDateRange(out DateTime startDate, out DateTime endDateExclusive)
        {
            startDate = DateTime.MinValue;
            endDateExclusive = DateTime.MinValue;

            DateTime parsedStart;
            DateTime parsedEnd;
            if (!DateTime.TryParse(txtStartDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedStart) ||
                !DateTime.TryParse(txtEndDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedEnd))
            {
                SetStatusMessage(lblMessage, "Please provide valid start and end dates.", true);
                return false;
            }

            if (parsedStart.Date > parsedEnd.Date)
            {
                SetStatusMessage(lblMessage, "Start date cannot be after end date.", true);
                return false;
            }

            if ((parsedEnd.Date - parsedStart.Date).TotalDays > 366)
            {
                SetStatusMessage(lblMessage, "Date range cannot exceed 366 days.", true);
                return false;
            }

            startDate = parsedStart.Date;
            endDateExclusive = parsedEnd.Date.AddDays(1); // same end-of-day trick as other pages
            return true;
        }

        // streams the DataTable as a .csv file download directly to the browser
        private void ExportDataTableToCsv(DataTable table, string fileName)
        {
            Response.Clear();
            Response.Buffer = true;
            // "attachment" tells the browser to download the file instead of displaying it
            Response.AddHeader("content-disposition", "attachment;filename=" + fileName);
            Response.Charset = string.Empty;
            Response.ContentType = "text/csv";

            StringBuilder csv = new StringBuilder();

            // write the header row (column names)
            for (int i = 0; i < table.Columns.Count; i++)
            {
                if (i > 0)
                {
                    csv.Append(",");
                }

                csv.Append(EscapeCsvField(table.Columns[i].ColumnName));
            }

            csv.AppendLine();

            // write each data row
            foreach (DataRow row in table.Rows)
            {
                for (int i = 0; i < table.Columns.Count; i++)
                {
                    if (i > 0)
                    {
                        csv.Append(",");
                    }

                    csv.Append(EscapeCsvField(Convert.ToString(row[i], CultureInfo.InvariantCulture)));
                }

                csv.AppendLine();
            }

            Response.Output.Write(csv.ToString());
            Response.Flush();
            Response.SuppressContent = true;
            // CompleteRequest() stops the rest of the page lifecycle after we've sent the file
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        // wraps a CSV field in quotes and escapes any existing quotes inside it
        // a quote inside a CSV field is escaped by doubling it: " becomes ""
        private static string EscapeCsvField(string value)
        {
            string safe = value ?? string.Empty;
            safe = safe.Replace("\"", "\"\"");
            return "\"" + safe + "\"";
        }
    }
}
