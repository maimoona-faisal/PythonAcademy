<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageContent.aspx.cs" Inherits="PythonAcademy.Admin.ManageContent" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root {
            --accent-cyan: #00d8ff;
            --accent-gold: #ffc857;
            --accent-lime: #81f7c5;
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
            text-shadow: 0 0 20px rgba(0, 216, 255, 0.24);
        }

        .admin-subtitle {
            margin: 0;
            color: var(--muted-text);
            max-width: 760px;
            line-height: 1.6;
        }

        .message-banner {
            display: block;
            margin-bottom: 16px;
            font-weight: 600;
        }

        .search-panel {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 26px;
            padding: 18px 20px;
            border-radius: 18px;
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            backdrop-filter: blur(12px);
        }

        .search-icon {
            color: var(--muted-text);
            font-size: 1.2rem;
        }

        .search-box {
            flex: 1;
            min-width: 220px;
            padding: 13px 18px;
            border-radius: 999px;
            border: 1px solid rgba(255,255,255,0.1);
            background: rgba(255,255,255,0.04);
            color: #fff;
            font-size: 1rem;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .search-box:focus {
            border-color: rgba(0, 216, 255, 0.7);
            box-shadow: 0 0 0 4px rgba(0, 216, 255, 0.12);
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

        .content-card {
            padding: 26px;
            border-radius: 22px;
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.18);
            overflow-x: auto;
        }

        .tech-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 12px;
        }

        .tech-table th {
            padding: 0 16px 12px;
            text-align: left;
            color: var(--muted-text);
            font-size: 0.82rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .tech-table td {
            padding: 18px 16px;
            color: #ffffff;
            vertical-align: middle;
            background: rgba(255,255,255,0.03);
            border-top: 1px solid rgba(255,255,255,0.05);
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }

        .tech-table td:first-child {
            border-radius: 14px 0 0 14px;
        }

        .tech-table td:last-child {
            border-radius: 0 14px 14px 0;
        }

        .title-cell {
            min-width: 220px;
        }

        .title-text {
            display: block;
            font-weight: 700;
            font-size: 1rem;
            margin-bottom: 4px;
        }

        .title-meta {
            color: var(--muted-text);
            font-size: 0.82rem;
        }

        .publish-indicator {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: #ffffff;
            font-weight: 600;
        }

        .publish-indicator::before {
            content: "";
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: #5d708d;
            box-shadow: 0 0 0 4px rgba(93, 112, 141, 0.15);
        }

        .publish-indicator.is-live::before {
            background: #14f195;
            box-shadow: 0 0 0 4px rgba(20, 241, 149, 0.15);
        }

        .publish-indicator.is-hidden::before {
            background: var(--accent-gold);
            box-shadow: 0 0 0 4px rgba(255, 200, 87, 0.15);
        }

        .publish-indicator.is-archived::before {
            background: #ff7b7b;
            box-shadow: 0 0 0 4px rgba(255, 123, 123, 0.15);
        }

        .resource-type {
            color: var(--muted-text);
            font-size: 0.88rem;
        }

        .action-stack {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            width: 180px; 
            justify-content: flex-end;
            margin-left: auto;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex: 1 1 45%; 
            padding: 7px 6px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.18);
            background: transparent;
            color: #ffffff;
            text-decoration: none;
            font-size: 0.75rem; 
            font-weight: 600;
            transition: transform 0.18s ease, background 0.18s ease, border-color 0.18s ease;
            cursor: pointer;
            text-align: center;
        }

        .action-btn:hover {
            transform: translateY(-1px);
            background: rgba(255,255,255,0.08);
        }

        .btn-hard-delete {
            border-color: rgba(255, 50, 50, 0.6);
            color: #ff4d4d;
        }
        .btn-hard-delete:hover {
            background: rgba(255, 50, 50, 0.1);
        }

        .btn-view {
            border-color: rgba(47, 125, 255, 0.5);
            color: #84b4ff;
        }

        .btn-resource {
            border-color: rgba(129, 247, 197, 0.5);
            color: var(--accent-lime);
        }

        .btn-publish {
            border-color: rgba(0, 216, 255, 0.55);
            color: var(--accent-cyan);
        }

        .btn-unpublish {
            border-color: rgba(255, 200, 87, 0.55);
            color: var(--accent-gold);
        }

        .btn-delete {
            border-color: rgba(255, 123, 123, 0.55);
            color: #ff9b9b;
        }

        .action-btn-disabled,
        .action-btn-disabled:hover {
            transform: none;
            opacity: 0.45;
            cursor: not-allowed;
            color: var(--muted-text);
            border-color: rgba(255,255,255,0.1);
            background: transparent;
        }

        .empty-grid {
            padding: 42px 18px;
            color: var(--muted-text);
            text-align: center;
            font-style: italic;
        }

        @media (max-width: 900px) {
            .search-panel {
                flex-wrap: wrap;
            }

            .btn-search {
                width: 100%;
            }

            .action-stack {
                justify-content: flex-start;
                min-width: 0;
            }
        }
    </style>

    <div class="admin-shell">
        <div class="admin-header">
            <a href="AdminDashboard.aspx" class="admin-back-link">&larr; Back to Dashboard</a>
            <h1 class="admin-title">Content Moderation</h1>
            <p class="admin-subtitle">Review uploaded learning material, control student visibility, and archive records safely without permanently removing them.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="message-banner"></asp:Label>

        <asp:Panel ID="pnlSearch" runat="server" CssClass="search-panel" DefaultButton="btnSearch">
            <span class="search-icon">&#128269;</span>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" Placeholder="Search by title, lecturer, file path, or URL..." AutoPostBack="true" OnTextChanged="btnSearch_Click"></asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-search" OnClick="btnSearch_Click" />
        </asp:Panel>

        <div class="content-card">
            <asp:GridView ID="gvContent" runat="server"
                CssClass="tech-table"
                AutoGenerateColumns="False"
                GridLines="None"
                DataKeyNames="ContentID"
                OnRowCommand="gvContent_RowCommand">
                <Columns>
                    <asp:TemplateField HeaderText="Title">
                        <ItemTemplate>
                            <div class="title-cell">
                                <span class="title-text"><%# Eval("Title") %></span>
                                <span class="title-meta">Content ID <%# Eval("ContentID") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" />

                    <asp:TemplateField HeaderText="Type">
                        <ItemTemplate>
                            <span class="resource-type"><%# Eval("ContentType") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

<asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='<%# GetPublishedIndicatorCssClass(Eval("IsPublished"), Eval("IsArchived")) %>'><%# GetPublishedIndicatorText(Eval("IsPublished"), Eval("IsArchived")) %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="CreatedAt" HeaderText="Uploaded On" DataFormatString="{0:MMM dd, yyyy}" ReadOnly="True" />

                    <asp:TemplateField HeaderText="Moderate">
                        <ItemTemplate>
                           <div class="action-stack">
                                <a href='<%# ResolveUrl("~/Learner-jo/ViewCourseContent.aspx?id=" + Eval("ContentID")) %>' class="action-btn btn-view">View</a>

                                <a href='<%# GetResourceUrl(Eval("FilePath"), Eval("Url")) %>'
                                   class='<%# GetResourceCssClass(Eval("FilePath"), Eval("Url")) %>'
                                   target="_blank"
                                   rel="noopener noreferrer"
                                   onclick='<%# GetResourceOnClick(Eval("FilePath"), Eval("Url")) %>'>Resource</a>

                                <asp:LinkButton ID="btnToggle" runat="server"
                                    CommandName="TogglePublish"
                                    CommandArgument='<%# Eval("ContentID") %>'
                                    CssClass='<%# GetToggleBtnCssClass(Eval("IsPublished"), Eval("IsArchived")) %>'
                                    OnClientClick='<%# GetToggleOnClick(Eval("IsPublished"), Eval("IsArchived")) %>'><%# GetToggleBtnText(Eval("IsPublished")) %></asp:LinkButton>

                                <asp:LinkButton ID="btnArchive" runat="server"
                                    CommandName="ToggleArchive"
                                    CommandArgument='<%# Eval("ContentID") %>'
                                    CssClass="action-btn btn-delete"
                                    OnClientClick='<%# GetArchiveOnClick(Eval("IsArchived")) %>'><%# GetArchiveBtnText(Eval("IsArchived")) %></asp:LinkButton>
                                
                                <asp:LinkButton ID="btnHardDelete" runat="server"
                                    CommandName="HardDelete"
                                    CommandArgument='<%# Eval("ContentID") %>'
                                    CssClass="action-btn btn-hard-delete"
                                    OnClientClick="return confirm('WARNING: Are you sure you want to PERMANENTLY delete this content? This cannot be undone.');">Delete</asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-grid">No learning materials matched the current search.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
