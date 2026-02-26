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
            margin-bottom: 30px;
            background: var(--glass-bg);
            padding: 20px;
            border-radius: 16px;
            border: 1px solid var(--glass-border);
            backdrop-filter: blur(10px);
            align-items: flex-end;
        }

        .filter-group { flex: 1; }

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
            margin-bottom: 30px;
        }

        .metric-box {
            text-align: center;
            padding: 20px;
            border-radius: 15px;
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.05);
        }

        .metric-value { font-size: 2.5rem; font-weight: 800; color: white; margin: 10px 0; }
        .metric-title { color: #8899ac; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; }
        .user-table { width: 100%; color: white; }
    </style>

    <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px;">
            <div>
                <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
                <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0; text-shadow: 0 0 20px rgba(188, 19, 254, 0.4);">Analytics & Reports</h1>
                <p style="color: #8899ac; margin: 5px 0 0 0;">Generate system reports for a selected period.</p>
            </div>
            <div>
                <asp:Button ID="btnExportCsv" runat="server" CssClass="btn-export" Text="Export to CSV" OnClick="btnExportCsv_Click" />
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ffb9b9"
            Style="display:block; margin-bottom:12px; font-weight:bold;"></asp:Label>

        <div class="controls-container">
            <div class="filter-group">
                <label class="filter-label">Report Type</label>
                <asp:DropDownList ID="ddlReportType" runat="server" CssClass="date-input">
                    <asp:ListItem Value="UserGrowth">User Growth</asp:ListItem>
                    <asp:ListItem Value="ContentEngagement">Content Engagement</asp:ListItem>
                    <asp:ListItem Value="SystemAudits">System Audits</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label class="filter-label">Start Date</label>
                <asp:TextBox ID="txtStartDate" runat="server" CssClass="date-input" TextMode="Date"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label class="filter-label">End Date</label>
                <asp:TextBox ID="txtEndDate" runat="server" CssClass="date-input" TextMode="Date"></asp:TextBox>
            </div>
            <div>
                <asp:Button ID="btnGenerateReport" runat="server" CssClass="btn-generate" Text="Generate Report" OnClick="btnGenerateReport_Click" />
            </div>
        </div>

        <div class="glass-card">
            <div class="metric-grid">
                <div class="metric-box">
                    <div class="metric-title">New Registrations</div>
                    <div class="metric-value" style="color: var(--neon-blue);"><asp:Label ID="lblRegistrations" runat="server" Text="0"></asp:Label></div>
                    <div style="color: #8899ac; font-size: 0.75rem;">Selected Period</div>
                </div>
                <div class="metric-box">
                    <div class="metric-title">Content Uploads</div>
                    <div class="metric-value" style="color: var(--neon-purple);"><asp:Label ID="lblUploads" runat="server" Text="0"></asp:Label></div>
                    <div style="color: #8899ac; font-size: 0.75rem;">Selected Period</div>
                </div>
                <div class="metric-box">
                    <div class="metric-title">Active Users (Logs)</div>
                    <div class="metric-value" style="color: #ffc107;"><asp:Label ID="lblActiveUsers" runat="server" Text="0"></asp:Label></div>
                    <div style="color: #8899ac; font-size: 0.75rem;">Selected Period</div>
                </div>
            </div>

            <asp:GridView ID="gvReportData" runat="server" CssClass="user-table"
                AutoGenerateColumns="true" GridLines="None">
                <EmptyDataTemplate>
                    <div style="color:#8899ac; padding:20px;">No report data available for the selected filters.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
