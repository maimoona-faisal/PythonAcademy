<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="PythonAcademy.Admin.ManageUsers" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
            --accent-cyan: #00d8ff;
            --accent-purple: #bc13fe;
            --accent-gold: #ffc857;
            --accent-red: #ff7b7b;
            --panel-bg: rgba(13, 25, 48, 0.88);
            --panel-border: rgba(255, 255, 255, 0.08);
            --muted-text: #8fa4c4;
        }

        .admin-shell {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px 20px 40px;
        }

        .admin-header {
            margin-bottom: 26px;
        }

        .admin-back-link {
            color: var(--muted-text);
            text-decoration: none;
            font-size: 0.92rem;
        }

        .admin-title {
            margin: 12px 0 8px;
            color: #ffffff;
            font-size: 2.5rem;
            font-weight: 700;
            text-shadow: 0 0 20px rgba(188, 19, 254, 0.24);
        }

        .admin-subtitle {
            margin: 0;
            color: var(--muted-text);
            max-width: 700px;
            line-height: 1.6;
        }

        .message-banner {
            display: block;
            margin-bottom: 16px;
            font-weight: 600;
        }

        .controls-container {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 26px;
            padding: 18px 20px;
            background: var(--panel-bg);
            border-radius: 18px;
            border: 1px solid var(--panel-border);
            backdrop-filter: blur(12px);
        }

        .search-box {
            flex: 1;
            min-width: 220px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.1);
            padding: 13px 18px;
            border-radius: 999px;
            color: white;
            font-size: 1rem;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .search-box:focus {
            border-color: rgba(0, 216, 255, 0.7);
            box-shadow: 0 0 0 4px rgba(0, 216, 255, 0.12);
        }

        .filter-dropdown {
            min-width: 180px;
            background: #0b1220;
            color: white;
            border: 1px solid rgba(255,255,255,0.18);
            padding: 13px 18px;
            border-radius: 999px;
            cursor: pointer;
            outline: none;
        }

        .btn-search {
            border: none;
            border-radius: 999px;
            padding: 13px 28px;
            font-weight: 700;
            color: #ffffff;
            cursor: pointer;
            background: linear-gradient(90deg, var(--accent-cyan), #0a67ff);
            box-shadow: 0 10px 22px rgba(0, 98, 255, 0.25);
        }

        .glass-card {
            background: var(--panel-bg);
            backdrop-filter: blur(12px);
            border: 1px solid var(--panel-border);
            border-radius: 22px;
            padding: 26px;
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.18);
            overflow-x: auto;
        }

        .user-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 12px;
        }

        .user-table th {
            text-align: left;
            padding: 0 14px 12px;
            color: var(--muted-text);
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            white-space: nowrap;
        }

        .user-table td {
            background: rgba(255,255,255,0.03);
            padding: 18px 14px;
            color: white;
            border-top: 1px solid rgba(255,255,255,0.05);
            border-bottom: 1px solid rgba(255,255,255,0.05);
            vertical-align: middle;
        }

        .user-table td:first-child {
            border-radius: 14px 0 0 14px;
        }

        .user-table td:last-child {
            border-radius: 0 14px 14px 0;
        }

        .empty-state {
            text-align: center !important;
            color: var(--muted-text) !important;
            padding: 42px !important;
            font-style: italic;
            background: rgba(255,255,255,0.01) !important;
        }

        .profile-cell {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 220px;
        }

        .user-avatar {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
            box-shadow: 0 0 18px rgba(118, 75, 162, 0.35);
            flex-shrink: 0;
        }

        .user-name {
            display: block;
            font-weight: 700;
            font-size: 1rem;
        }

        .user-email {
            display: block;
            margin-top: 4px;
            font-size: 0.83rem;
            color: var(--muted-text);
        }

        .badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .badge-student {
            background: rgba(0, 216, 255, 0.12);
            color: var(--accent-cyan);
            border: 1px solid rgba(0, 216, 255, 0.3);
        }

        .badge-lecturer {
            background: rgba(188, 19, 254, 0.12);
            color: #d97bff;
            border: 1px solid rgba(188, 19, 254, 0.3);
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-weight: 700;
            color: #ffffff;
        }

        .status-pill::before {
            content: "";
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #5d708d;
            box-shadow: 0 0 0 4px rgba(93, 112, 141, 0.16);
        }

        .status-active {
            color: #14f195;
        }

        .status-active::before {
            background: #14f195;
            box-shadow: 0 0 0 4px rgba(20, 241, 149, 0.14);
        }

        .status-suspended {
            color: var(--accent-gold);
        }

        .status-suspended::before {
            background: var(--accent-gold);
            box-shadow: 0 0 0 4px rgba(255, 200, 87, 0.14);
        }

        .status-pending {
            color: #d2dae7;
        }

        .status-pending::before {
            background: #d2dae7;
            box-shadow: 0 0 0 4px rgba(210, 218, 231, 0.12);
        }

        .status-rejected {
            color: var(--accent-red);
        }

        .status-rejected::before {
            background: var(--accent-red);
            box-shadow: 0 0 0 4px rgba(255, 123, 123, 0.14);
        }

        .joined-date {
            color: var(--muted-text);
        }

        .manage-actions {
            display: flex;
            justify-content: flex-end;
            flex-wrap: wrap;
            gap: 8px;
            min-width: 250px;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 112px;
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.18);
            background: transparent;
            color: white;
            cursor: pointer;
            transition: transform 0.18s ease, background 0.18s ease, border-color 0.18s ease;
            text-decoration: none;
            font-size: 0.86rem;
            font-weight: 600;
        }

        .action-btn:hover {
            transform: translateY(-1px);
            background: rgba(255,255,255,0.08);
        }

        .btn-ban {
            border-color: rgba(255, 200, 87, 0.5);
            color: var(--accent-gold);
        }

        .btn-delete {
            border-color: rgba(255, 123, 123, 0.5);
            color: #ff9b9b;
        }

        .action-btn-disabled,
        .action-btn-disabled:hover {
            transform: none;
            opacity: 0.45;
            cursor: not-allowed;
            background: transparent;
            color: var(--muted-text);
            border-color: rgba(255,255,255,0.12);
        }

        @media (max-width: 920px) {
            .controls-container {
                flex-wrap: wrap;
            }

            .filter-dropdown,
            .btn-search {
                width: 100%;
            }

            .manage-actions {
                justify-content: flex-start;
                min-width: 0;
            }
        }
    </style>

    <div class="admin-shell">
        
        <div class="admin-header">
            <a href="AdminDashboard.aspx" class="admin-back-link">&larr; Back to Dashboard</a>
            <h1 class="admin-title">User Directory</h1>
            <p class="admin-subtitle">Search accounts, review their status, and moderate only the states this page is meant to control.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="message-banner"></asp:Label>

        <asp:Panel ID="pnlSearch" runat="server" CssClass="controls-container" DefaultButton="btnSearch">
            <span style="font-size: 1.2rem; color: #8899ac;">&#128269;</span>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box"
                         Placeholder="Search by name or email..."
                         AutoPostBack="true"
                         OnTextChanged="btnSearch_Click"></asp:TextBox>
            <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="btnSearch_Click">
                <asp:ListItem Value="All"      Text="Show All Roles"></asp:ListItem>
                <asp:ListItem Value="Student"  Text="Students Only"></asp:ListItem>
                <asp:ListItem Value="Lecturer" Text="Lecturers Only"></asp:ListItem>
            </asp:DropDownList>
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-search" OnClick="btnSearch_Click" />
        </asp:Panel>

        <div class="glass-card">
            <table class="user-table">
                <thead>
                    <tr>
                        <th>User Profile</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Joined Date</th>
                        <th style="text-align: right;">Manage</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="profile-cell">
                                        <div class="user-avatar"><%# GetAvatarInitial(Eval("Username")) %></div>
                                        <div>
                                            <span class="user-name"><%# Eval("Username") %></span>
                                            <span class="user-email"><%# Eval("Email") %></span>
                                        </div>
                                    </div>
                                </td>

                                <td><span class='<%# GetRoleBadgeCssClass(Eval("Role")) %>'><%# Eval("Role") %></span></td>

                                <td><span class='<%# GetStatusCssClass(Eval("Status")) %>'><%# Eval("Status") %></span></td>

                                <td class="joined-date"><%# GetFormattedJoinedDate(Eval("CreatedAt")) %></td>

                                <td style="text-align: right;">
                                    <div class="manage-actions">
                                    <asp:LinkButton ID="btnToggleStatus" runat="server"
                                        CommandName="ToggleStatus"
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass='<%# GetToggleButtonCssClass(Eval("Status")) %>'
                                        Enabled='<%# CanToggleStatus(Eval("Status")) %>'
                                        OnClientClick='<%# GetToggleButtonOnClick(Eval("Status")) %>'><%# GetToggleButtonText(Eval("Role"), Eval("Status")) %></asp:LinkButton>

                                    <asp:LinkButton ID="btnDelete" runat="server"
                                        CommandName="DeleteUser"
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="action-btn btn-delete"
                                        OnClientClick="return confirm('Delete this user account? This action is irreversible.');">Delete</asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>

                    <tr id="rowEmpty" runat="server" visible="false">
                        <td colspan="5" class="empty-state">
                            No users found matching your search criteria.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

    </div>
</asp:Content>
