using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI.WebControls;

namespace PythonAcademy.Admin
{
    // this page shows a searchable log of meaningful admin and system activity
    public partial class ActivityLogs : AdminPage
    {
        // how many rows to show per page on the grid
        private const int DefaultPageSize = 50;

        // runs automatically when the page first loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // IsPostBack is true when a button is clicked (not the first load)
            // we skip reloading on postback because the button handlers do it themselves
            if (IsPostBack)
            {
                return;
            }

            gvLogs.PageSize = DefaultPageSize;
            BindLogs(0); // load page 0 (first page) on initial visit
            LogEvent("Logs.View", "Opened activity logs page.");
        }

        // fires when the Filter button is clicked — just re-runs the query from page 0
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindLogs(0);
        }

        // clears all the filter inputs and reloads the full unfiltered log
        protected void btnResetFilters_Click(object sender, EventArgs e)
        {
            txtUsernameFilter.Text = string.Empty;
            ddlRoleFilter.SelectedIndex = 0;
            txtActionFilter.Text = string.Empty;
            txtDateFrom.Text = string.Empty;
            txtDateTo.Text = string.Empty;

            BindLogs(0);
        }

        // fires when the user clicks a page number on the grid
        protected void gvLogs_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            BindLogs(e.NewPageIndex); // e.NewPageIndex is which page they clicked
        }

        // main method that builds the SQL query, runs it, and binds results to the grid
        private void BindLogs(int requestedPageIndex)
        {
            ClearStatusMessage(lblMessage);
            lblResultSummary.Text = string.Empty;

            // safety check — if the table doesn't exist yet, show a friendly message instead of crashing
            if (!TableExists("ActivityLogs"))
            {
                BindEmptyLogs(0, "Activity log storage is not available in this database.");
                SetStatusMessage(lblMessage, "ActivityLogs table was not found. The page will stay available, but log data cannot be shown until the table exists.", true);
                return;
            }

            // validate and parse the date range from the filter inputs
            // out parameters let the method "return" multiple values
            DateTime? startDate;
            DateTime? endDateExclusive;
            if (!TryGetDateRange(out startDate, out endDateExclusive))
            {
                BindEmptyLogs(0, "No activity logs match the current filters.");
                return;
            }

            // we build the WHERE clause dynamically based on which filters have values
            List<string> filters = new List<string>();
            List<SqlParameter> parameters = new List<SqlParameter>(); // parameterized queries prevent SQL injection

            string usernameFilter = (txtUsernameFilter.Text ?? string.Empty).Trim();
            if (usernameFilter.Length > 0)
            {
                // LIKE with % wildcards = partial match 
                filters.Add("u.Username LIKE @Username");
                parameters.Add(new SqlParameter("@Username", "%" + usernameFilter + "%"));
            }

            string selectedRole = (ddlRoleFilter.SelectedValue ?? string.Empty).Trim();
            if (selectedRole.Length > 0)
            {
                // "System" events have no user attached, so UserID will be NULL in the DB
                if (string.Equals(selectedRole, "System", StringComparison.OrdinalIgnoreCase))
                {
                    filters.Add("l.UserID IS NULL");
                }
                else
                {
                    filters.Add("u.Role = @Role");
                    parameters.Add(new SqlParameter("@Role", selectedRole));
                }
            }

            string actionFilter = (txtActionFilter.Text ?? string.Empty).Trim();
            if (actionFilter.Length > 0)
            {
                filters.Add("l.Action LIKE @Action");
                parameters.Add(new SqlParameter("@Action", "%" + actionFilter + "%"));
            }

            if (startDate.HasValue)
            {
                filters.Add("l.Timestamp >= @DateFrom");
                parameters.Add(new SqlParameter("@DateFrom", startDate.Value));
            }

            if (endDateExclusive.HasValue)
            {
                // we add 1 day to the end date and use < instead of <=
                // this includes the whole last day (up to 23:59:59) without messy time math
                filters.Add("l.Timestamp < @DateToExclusive");
                parameters.Add(new SqlParameter("@DateToExclusive", endDateExclusive.Value));
            }

            // build the FROM + WHERE block as a reusable string
            // we'll use it twice: once for COUNT, once for the actual SELECT
            StringBuilder fromClause = new StringBuilder();
            fromClause.AppendLine("FROM ActivityLogs l");
            fromClause.AppendLine("LEFT JOIN Users u ON l.UserID = u.UserID"); // LEFT JOIN keeps logs even if user was deleted
            fromClause.AppendLine("WHERE 1 = 1"); // "1=1" is a trick so we can always safely append "AND ..."

            foreach (string filter in filters)
            {
                fromClause.AppendLine("AND " + filter);
            }

            // first get just the count so we know total pages without fetching all rows
            int totalRecords = ExecuteScalarInt(
                "SELECT COUNT(*) " + fromClause,
                parameters.ToArray());

            if (totalRecords == 0)
            {
                BindEmptyLogs(0, "No activity logs match the current filters.");
                lblResultSummary.Text = "No matching activity was found.";
                return;
            }

            // clamp the page index so we don't go past the last page
            int pageIndex = requestedPageIndex < 0 ? 0 : requestedPageIndex;
            int pageCount = (int)Math.Ceiling(totalRecords / (double)gvLogs.PageSize);
            if (pageIndex >= pageCount)
            {
                pageIndex = pageCount - 1;
            }

            // calculate which row numbers we want for this page (1-based, for SQL ROW_NUMBER)
            int startRow = (pageIndex * gvLogs.PageSize) + 1;
            int endRow = startRow + gvLogs.PageSize - 1;

            // copy the existing parameters list and add paging params on top
            List<SqlParameter> pagedParameters = new List<SqlParameter>(parameters)
            {
                new SqlParameter("@StartRow", startRow),
                new SqlParameter("@EndRow", endRow)
            };

            // CTE (Common Table Expression) — the WITH block is like a temporary named result set
            // ROW_NUMBER() assigns a sequential number to each row after sorting, which we use for paging
            DataTable logs = ExecuteTable(
                @"
                WITH FilteredLogs AS
                (
                    SELECT
                        l.LogId,
                        l.Timestamp,
                        CASE
                            WHEN l.UserID IS NULL THEN 'System'
                            WHEN u.Username IS NULL OR LTRIM(RTRIM(u.Username)) = '' THEN 'Unknown User'
                            ELSE u.Username
                        END AS Username,
                        CASE
                            WHEN l.UserID IS NULL THEN 'System'
                            WHEN u.Role IS NULL OR LTRIM(RTRIM(u.Role)) = '' THEN 'Unknown'
                            ELSE u.Role
                        END AS UserRole,
                        -- extract the category prefix from the Action string, such as Logs from Logs.View
                        CASE
                            WHEN l.Action IS NULL OR LTRIM(RTRIM(l.Action)) = '' THEN 'General'
                            WHEN CHARINDEX('.', l.Action) > 0 THEN LEFT(l.Action, CHARINDEX('.', l.Action) - 1)
                            WHEN CHARINDEX(':', l.Action) > 0 THEN LEFT(l.Action, CHARINDEX(':', l.Action) - 1)
                            ELSE l.Action
                        END AS Category,
                        ISNULL(l.Action, 'General') AS Action,
                        l.Details,
                        ROW_NUMBER() OVER (ORDER BY l.Timestamp DESC, l.LogId DESC) AS RowNum
                    " + fromClause + @"
                )
                SELECT Timestamp, Username, UserRole, Category, Action, Details
                FROM FilteredLogs
                WHERE RowNum BETWEEN @StartRow AND @EndRow
                ORDER BY RowNum;",
                pagedParameters.ToArray());

            gvLogs.PageIndex = pageIndex;
            gvLogs.VirtualItemCount = totalRecords; // tells the pager how many total pages to show
            gvLogs.DataSource = logs;
            gvLogs.DataBind();

            // build the "Showing 1-50 of 312 log entries." label
            int shownFrom = (pageIndex * gvLogs.PageSize) + 1;
            int shownTo = Math.Min(totalRecords, shownFrom + logs.Rows.Count - 1);
            lblResultSummary.Text = string.Format(
                CultureInfo.InvariantCulture,
                "Showing {0}-{1} of {2} log entries.",
                shownFrom,
                shownTo,
                totalRecords);
        }

        // helper to show an empty grid with a message instead of crashing or showing nothing
        private void BindEmptyLogs(int pageIndex, string emptyMessage)
        {
            gvLogs.PageIndex = 0;
            gvLogs.VirtualItemCount = 0;
            gvLogs.EmptyDataText = emptyMessage;
            gvLogs.DataSource = CreateLogsTable(); // empty table with the right columns
            gvLogs.DataBind();
        }

        // creates an empty DataTable with the correct column structure for the grid
        // needed so the grid knows what columns exist even when there are zero rows
        private static DataTable CreateLogsTable()
        {
            DataTable table = new DataTable();
            table.Columns.Add("Timestamp", typeof(DateTime));
            table.Columns.Add("Username", typeof(string));
            table.Columns.Add("UserRole", typeof(string));
            table.Columns.Add("Category", typeof(string));
            table.Columns.Add("Action", typeof(string));
            table.Columns.Add("Details", typeof(string));
            return table;
        }

        // parses the two date text boxes and validates them
        // uses "out" params so it can return both dates + a success/fail bool at once
        private bool TryGetDateRange(out DateTime? startDate, out DateTime? endDateExclusive)
        {
            startDate = null;
            endDateExclusive = null;

            DateTime parsedStart;
            if (!TryParseDate(txtDateFrom.Text, out parsedStart))
            {
                SetStatusMessage(lblMessage, "Please provide a valid start date.", true);
                return false;
            }

            DateTime parsedEnd;
            if (!TryParseDate(txtDateTo.Text, out parsedEnd))
            {
                SetStatusMessage(lblMessage, "Please provide a valid end date.", true);
                return false;
            }

            // only assign if the user actually typed something (blank = no filter)
            if (!string.IsNullOrWhiteSpace(txtDateFrom.Text))
            {
                startDate = parsedStart.Date; // .Date strips the time component (sets to midnight)
            }

            if (!string.IsNullOrWhiteSpace(txtDateTo.Text))
            {
                endDateExclusive = parsedEnd.Date.AddDays(1); // end of day = start of next day
            }

            // make sure start isn't after end
            if (startDate.HasValue && endDateExclusive.HasValue && startDate.Value >= endDateExclusive.Value)
            {
                SetStatusMessage(lblMessage, "Date From must be on or before Date To.", true);
                return false;
            }

            return true;
        }

        // tries to parse a date string — returns true if it worked (or if input was empty)
        // empty input is valid here because it just means "no date filter"
        private static bool TryParseDate(string input, out DateTime parsedDate)
        {
            parsedDate = DateTime.MinValue; // default value if parsing fails

            string safeInput = (input ?? string.Empty).Trim();
            if (safeInput.Length == 0)
            {
                return true; // empty is OK — caller handles the null case
            }

            return DateTime.TryParse(safeInput, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedDate);
        }
    }
}
