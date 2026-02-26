using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using PythonAcademy.Helpers;

namespace PythonAcademy.Admin
{
    public partial class ActivityLogs : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindLogs();
                LogEvent("Logs.View", "Opened activity logs page.");
            }
        }

        // This runs when you click the "Filter Logs" button
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindLogs();
        }

        private void BindLogs()
        {
            // Base SQL query
            string sql = @"
                SELECT 
                    l.Timestamp,
                    ISNULL(u.Username, 'System') AS Username,
                    l.Action,
                    l.Details
                FROM ActivityLogs l
                LEFT JOIN Users u ON l.UserID = u.UserID
                WHERE 1=1 ";

            List<SqlParameter> parameters = new List<SqlParameter>();

            // If the user selected a date, filter by it
            if (!string.IsNullOrWhiteSpace(txtDateFilter.Text))
            {
                sql += " AND CAST(l.Timestamp AS DATE) = @FilterDate ";
                parameters.Add(new SqlParameter("@FilterDate", txtDateFilter.Text));
            }

            // If the user typed a keyword, search the action, username, or details
            if (!string.IsNullOrWhiteSpace(txtSearchFilter.Text))
            {
                sql += " AND (l.Action LIKE @Keyword OR u.Username LIKE @Keyword OR l.Details LIKE @Keyword) ";
                parameters.Add(new SqlParameter("@Keyword", "%" + txtSearchFilter.Text + "%"));
            }

            // Always show the newest logs at the top
            sql += " ORDER BY l.Timestamp DESC";

            // ExecuteTable comes from your AdminPage base class!
            gvLogs.DataSource = ExecuteTable(sql, parameters.ToArray());
            gvLogs.DataBind();
        }
    }
}