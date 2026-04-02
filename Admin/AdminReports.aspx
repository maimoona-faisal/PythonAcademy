<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminReports.aspx.cs" Inherits="PythonAcademy.Admin.AdminReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root {
            --neon-blue: #00f3ff;
            --neon-purple: #bc13fe;
            --glass-bg: rgba(13, 25, 48, 0.85);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
        }

        .controls-container {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            background: var(--glass-bg);
            padding: 20px;
            border-radius: 16px;
            border: 1px solid var(--glass-border);
            backdrop-filter: blur(10px);
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .filter-group {
            flex: 1;
            min-width: 180px;
        }

        .filter-label {
            display: block;
            color: #8899ac;
            font-size: 0.8rem;
            text-transform: uppercase;
            margin-bottom: 5px;
        }

        .date-input {
            width: 100%;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            padding: 12px;
            border-radius: 10px;
            color: white;
            outline: none;
            box-sizing: border-box;
        }

        .btn-generate {
            background: linear-gradient(90deg, #7a0cd2, var(--neon-purple));
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: bold;
            cursor: pointer;
            height: 43px;
        }

        .btn-export {
            background: transparent;
            color: #00f3ff;
            border: 1px solid #00f3ff;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: bold;
        }

        .metric-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }

        .metric-box {
            text-align: center;
            padding: 20px;
            border-radius: 15px;
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.05);
        }

        .metric-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: white;
            margin: 10px 0;
        }

        .metric-title {
            color: #8899ac;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .metric-caption {
            color: #8899ac;
            font-size: 0.75rem;
        }

        .status-message {
            display: block;
            margin-bottom: 12px;
            font-weight: bold;
        }

        .report-summary {
            color: #8899ac;
            margin-bottom: 18px;
            line-height: 1.5;
        }

        .user-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            color: white;
        }

        .user-table th {
            background: rgba(0, 0, 0, 0.4);
            color: #00f3ff;
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid rgba(255, 255, 255, 0.1);
            font-weight: bold;
        }

        .user-table td {
            padding: 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .user-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }

        .empty-state {
            color: #8899ac;
            padding: 20px;
        }

        @media (max-width: 900px) {
            .metric-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px; gap: 20px; flex-wrap: wrap;">
            <div>
                <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
                <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0; text-shadow: 0 0 20px rgba(188, 19, 254, 0.4);">Analytics & Reports</h1>
                <p style="color: #8899ac; margin: 5px 0 0 0;">Generate focused admin reports for a selected period.</p>
            </div>
            <div>
                <asp:Button ID="btnExportCsv" runat="server" CssClass="btn-export" Text="Export to CSV" OnClick="btnExportCsv_Click" />
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="status-message" Visible="false"></asp:Label>

        <div class="controls-container">
            <div class="filter-group">
                <label class="filter-label" for="<%= ddlReportType.ClientID %>">Report Type</label>
                <asp:DropDownList ID="ddlReportType" runat="server" CssClass="date-input">
                    <asp:ListItem Value="UserGrowth">User Growth</asp:ListItem>
                    <asp:ListItem Value="VerificationActivity">Verification Activity</asp:ListItem>
                    <asp:ListItem Value="ContentActivity">Content Activity</asp:ListItem>
                    <asp:ListItem Value="SystemAudits">System Audits</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label class="filter-label" for="<%= txtStartDate.ClientID %>">Start Date</label>
                <asp:TextBox ID="txtStartDate" runat="server" CssClass="date-input" TextMode="Date"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label class="filter-label" for="<%= txtEndDate.ClientID %>">End Date</label>
                <asp:TextBox ID="txtEndDate" runat="server" CssClass="date-input" TextMode="Date"></asp:TextBox>
            </div>
            <div>
                <asp:Button ID="btnGenerateReport" runat="server" CssClass="btn-generate" Text="Generate Report" OnClick="btnGenerateReport_Click" />
            </div>
        </div>

        <div class="glass-card">
            <div class="metric-grid">
                <div class="metric-box">
                    <div class="metric-title"><asp:Label ID="lblMetricOneTitle" runat="server" Text="Metric One"></asp:Label></div>
                    <div class="metric-value" style="color: var(--neon-blue);"><asp:Label ID="lblMetricOneValue" runat="server" Text="0"></asp:Label></div>
                    <div class="metric-caption"><asp:Label ID="lblMetricOneCaption" runat="server" Text="Selected Period"></asp:Label></div>
                </div>
                <div class="metric-box">
                    <div class="metric-title"><asp:Label ID="lblMetricTwoTitle" runat="server" Text="Metric Two"></asp:Label></div>
                    <div class="metric-value" style="color: var(--neon-purple);"><asp:Label ID="lblMetricTwoValue" runat="server" Text="0"></asp:Label></div>
                    <div class="metric-caption"><asp:Label ID="lblMetricTwoCaption" runat="server" Text="Selected Period"></asp:Label></div>
                </div>
                <div class="metric-box">
                    <div class="metric-title"><asp:Label ID="lblMetricThreeTitle" runat="server" Text="Metric Three"></asp:Label></div>
                    <div class="metric-value" style="color: #ffc107;"><asp:Label ID="lblMetricThreeValue" runat="server" Text="0"></asp:Label></div>
                    <div class="metric-caption"><asp:Label ID="lblMetricThreeCaption" runat="server" Text="Selected Period"></asp:Label></div>
                </div>
            </div>

            <asp:Label ID="lblReportSummary" runat="server" CssClass="report-summary"></asp:Label>

            <asp:GridView ID="gvReportData" runat="server" CssClass="user-table"
                AutoGenerateColumns="true" GridLines="None">
                <EmptyDataTemplate>
                    <div class="empty-state">No report data is available for the selected filters.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
