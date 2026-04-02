<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ActivityLogs.aspx.cs" Inherits="PythonAcademy.Admin.ActivityLogs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root {
            --neon-blue: #00f3ff;
            --glass-bg: rgba(13, 25, 48, 0.85);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        .controls-container {
            display: grid;
            grid-template-columns: repeat(6, minmax(0, 1fr));
            gap: 15px;
            margin-bottom: 20px;
            background: var(--glass-bg);
            padding: 20px;
            border-radius: 16px;
            border: 1px solid var(--glass-border);
            backdrop-filter: blur(10px);
            align-items: end;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .filter-label {
            color: #8899ac;
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        .search-box,
        .filter-dropdown {
            width: 100%;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            padding: 12px 16px;
            border-radius: 12px;
            color: white;
            outline: none;
            transition: 0.3s;
            box-sizing: border-box;
        }

        .search-box:focus,
        .filter-dropdown:focus {
            border-color: var(--neon-blue);
            box-shadow: 0 0 15px rgba(0, 243, 255, 0.2);
        }

        .filter-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            grid-column: span 2;
        }

        .btn-search,
        .btn-secondary {
            border: 1px solid rgba(255,255,255,0.3);
            padding: 12px 22px;
            border-radius: 12px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
        }

        .btn-search {
            background: rgba(0, 243, 255, 0.12);
            color: white;
        }

        .btn-secondary {
            background: transparent;
            color: #c6d0dd;
        }

        .btn-search:hover,
        .btn-secondary:hover {
            background: rgba(255,255,255,0.1);
        }

        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
        }

        .toolbar-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }

        .status-message {
            display: block;
            margin-bottom: 12px;
            font-weight: bold;
        }

        .result-summary {
            color: #8899ac;
            font-size: 0.9rem;
        }

        .user-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 10px;
        }

        .user-table th {
            text-align: left;
            padding: 15px;
            color: #8899ac;
            font-size: 0.85rem;
            text-transform: uppercase;
        }

        .user-table td {
            background: rgba(255,255,255,0.03);
            padding: 15px;
            color: white;
            border-top: 1px solid rgba(255,255,255,0.05);
            border-bottom: 1px solid rgba(255,255,255,0.05);
            vertical-align: top;
        }

        .user-table tr:first-child td:first-child {
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;
            border-left: 3px solid #8899ac;
        }

        .user-table tr:first-child td:last-child {
            border-top-right-radius: 10px;
            border-bottom-right-radius: 10px;
        }

        .empty-state {
            text-align: center !important;
            color: #8899ac !important;
            padding: 40px !important;
            font-style: italic;
            border-left: none !important;
        }

        .pager-row {
            margin-top: 15px;
            color: #c6d0dd;
        }

        .user-table .pager-row table {
            margin-left: auto;
        }

        .user-table .pager-row td {
            background: transparent;
            border: none;
            padding: 4px;
        }

        .user-table .pager-row a,
        .user-table .pager-row span {
            display: inline-block;
            min-width: 34px;
            text-align: center;
            padding: 8px 10px;
            border-radius: 10px;
            color: white;
            text-decoration: none;
            border: 1px solid rgba(255,255,255,0.15);
            background: rgba(255,255,255,0.03);
        }

        .user-table .pager-row span {
            background: rgba(0,243,255,0.12);
            border-color: rgba(0,243,255,0.35);
            color: var(--neon-blue);
        }

        @media (max-width: 1080px) {
            .controls-container {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .filter-actions {
                grid-column: span 2;
            }
        }

        @media (max-width: 720px) {
            .controls-container {
                grid-template-columns: 1fr;
            }

            .filter-actions {
                grid-column: span 1;
                justify-content: stretch;
            }

            .filter-actions > * {
                flex: 1;
            }
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50%       { opacity: 0.2; }
        }
    </style>

    <div style="max-width: 1280px; margin: 0 auto; padding: 20px;">

        <div style="margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end; gap: 20px; flex-wrap: wrap;">
            <div>
                <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
                <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0;">System Logs</h1>
                <p style="color: #8899ac; margin: 5px 0 0 0;">Audit trail of meaningful admin and system activity.</p>
            </div>
            <div style="color: #00f3ff; font-size: 0.9rem;">
                <span style="animation: pulse 2s infinite;">&#9679;</span> Latest events first
            </div>
        </div>

        <div class="controls-container">
            <div class="filter-group">
                <label class="filter-label" for="<%= txtUsernameFilter.ClientID %>">Username</label>
                <asp:TextBox ID="txtUsernameFilter" runat="server" CssClass="search-box" placeholder="Admin username"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label class="filter-label" for="<%= ddlRoleFilter.ClientID %>">Role</label>
                <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="filter-dropdown">
                    <asp:ListItem Value="" Text="All roles"></asp:ListItem>
                    <asp:ListItem Value="Admin" Text="Admin"></asp:ListItem>
                    <asp:ListItem Value="Lecturer" Text="Lecturer"></asp:ListItem>
                    <asp:ListItem Value="Student" Text="Student"></asp:ListItem>
                    <asp:ListItem Value="System" Text="System"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label class="filter-label" for="<%= txtActionFilter.ClientID %>">Action</label>
                <asp:TextBox ID="txtActionFilter" runat="server" CssClass="search-box" placeholder="Verification.Approve"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label class="filter-label" for="<%= txtDateFrom.ClientID %>">Date From</label>
                <asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date" CssClass="search-box"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label class="filter-label" for="<%= txtDateTo.ClientID %>">Date To</label>
                <asp:TextBox ID="txtDateTo" runat="server" TextMode="Date" CssClass="search-box"></asp:TextBox>
            </div>
            <div class="filter-actions">
                <asp:Button ID="btnFilter" runat="server" Text="Apply Filters" CssClass="btn-search" OnClick="btnFilter_Click" />
                <asp:Button ID="btnResetFilters" runat="server" Text="Reset" CssClass="btn-secondary" OnClick="btnResetFilters_Click" CausesValidation="false" />
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="status-message" Visible="false"></asp:Label>

        <div class="glass-card">
            <div class="toolbar-row">
                <asp:Label ID="lblResultSummary" runat="server" CssClass="result-summary"></asp:Label>
            </div>

            <asp:GridView ID="gvLogs" runat="server"
                CssClass="user-table"
                AutoGenerateColumns="False"
                GridLines="None"
                AllowPaging="true"
                AllowCustomPaging="true"
                PageSize="50"
                OnPageIndexChanging="gvLogs_PageIndexChanging">
                <Columns>
                    <asp:BoundField DataField="Timestamp" HeaderText="Timestamp" DataFormatString="{0:MMM dd, yyyy - hh:mm tt}" ItemStyle-Width="18%" />
                    <asp:BoundField DataField="Username" HeaderText="User" ItemStyle-Width="14%" />
                    <asp:BoundField DataField="UserRole" HeaderText="Role" ItemStyle-Width="10%" />
                    <asp:BoundField DataField="Category" HeaderText="Category" ItemStyle-Width="12%" />
                    <asp:BoundField DataField="Action" HeaderText="Action" ItemStyle-Width="18%" />
                    <asp:BoundField DataField="Details" HeaderText="Details" ItemStyle-Width="28%" />
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state">
                        No activity logs match the current filters.
                    </div>
                </EmptyDataTemplate>
                <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" Position="Bottom" />
                <PagerStyle CssClass="pager-row" HorizontalAlign="Right" />
            </asp:GridView>
        </div>

    </div>
</asp:Content>
