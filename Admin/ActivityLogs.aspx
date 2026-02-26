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
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
            background: var(--glass-bg);
            padding: 20px;
            border-radius: 16px;
            border: 1px solid var(--glass-border);
            backdrop-filter: blur(10px);
            align-items: center;
        }

        .search-box {
            flex: 1;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            padding: 12px 20px;
            border-radius: 50px;
            color: white;
            outline: none;
            transition: 0.3s;
        }

            .search-box:focus {
                border-color: var(--neon-blue);
                box-shadow: 0 0 15px rgba(0, 243, 255, 0.2);
            }

        .btn-search {
            background: transparent;
            color: white;
            border: 1px solid rgba(255,255,255,0.3);
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
        }

            .btn-search:hover {
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
                vertical-align: middle;
            }

            .user-table tr:first-child td:first-child {
                border-top-left-radius: 10px;
                border-bottom-left-radius: 10px;
                border-left: 3px solid #8899ac;
            }
            /* Left accent border */
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
    </style>

    <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">

        <div style="margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end;">
            <div>
                <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
                <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0;">System Logs
                </h1>
                <p style="color: #8899ac; margin: 5px 0 0 0;">Audit trail of platform activities.</p>
            </div>
            <div style="color: #00f3ff; font-size: 0.9rem;">
                <span style="animation: pulse 2s infinite;">●</span> Live Tracking Enabled
            </div>
        </div>

        <div class="controls-container">
            <span style="font-size: 1.2rem; color: #8899ac;">📅</span>
            <asp:TextBox ID="txtDateFilter" runat="server" TextMode="Date" CssClass="search-box" Style="flex: 0.5;"></asp:TextBox>
            <asp:TextBox ID="txtSearchFilter" runat="server" CssClass="search-box" placeholder="Filter by event type or username..."></asp:TextBox>
            <asp:Button ID="btnFilter" runat="server" Text="Filter Logs" CssClass="btn-search" OnClick="btnFilter_Click" />
        </div>

        <div class="glass-card">
            <div class="glass-card">
                <asp:GridView ID="gvLogs" runat="server" CssClass="user-table"
                    AutoGenerateColumns="False" GridLines="None">

                    <Columns>
                        <asp:BoundField DataField="Timestamp" HeaderText="Timestamp" DataFormatString="{0:MMM dd, yyyy - hh:mm tt}" ItemStyle-Width="20%" />
                        <asp:BoundField DataField="Username" HeaderText="User" ItemStyle-Width="15%" />
                        <asp:BoundField DataField="Action" HeaderText="Event Type" ItemStyle-Width="25%" />
                        <asp:BoundField DataField="Details" HeaderText="Details" ItemStyle-Width="40%" />
                    </Columns>

                    <EmptyDataTemplate>
                        <div class="empty-state">
                            No system events recorded. Audit trail is empty.
                        </div>
                    </EmptyDataTemplate>

                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>
