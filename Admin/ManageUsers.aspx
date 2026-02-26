<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="PythonAcademy.Admin.ManageUsers" %>
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

        /* SEARCH & FILTER BAR */
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
            font-size: 1rem;
            outline: none;
            transition: 0.3s;
        }

        .search-box:focus {
            border-color: var(--neon-blue);
            box-shadow: 0 0 15px rgba(0, 243, 255, 0.2);
        }

        .filter-dropdown {
            background: #0b1220;
            color: white;
            border: 1px solid rgba(255,255,255,0.2);
            padding: 12px 20px;
            border-radius: 50px;
            cursor: pointer;
            outline: none;
        }

        .btn-search {
            background: linear-gradient(90deg, var(--neon-blue), #0066ff);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 0 15px rgba(0, 243, 255, 0.3);
            text-decoration: none;
        }

        /* TABLE STYLES */
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
            letter-spacing: 1px;
        }

        .user-table td {
            background: rgba(255,255,255,0.03);
            padding: 15px;
            color: white;
            border-top: 1px solid rgba(255,255,255,0.05);
            border-bottom: 1px solid rgba(255,255,255,0.05);
            vertical-align: middle;
        }

        .user-table tr:first-child td:first-child { border-top-left-radius: 10px; border-bottom-left-radius: 10px; }
        .user-table tr:first-child td:last-child { border-top-right-radius: 10px; border-bottom-right-radius: 10px; }

        /* Empty State */
        .empty-state {
            text-align: center !important;
            color: #8899ac !important;
            padding: 40px !important;
            font-style: italic;
            background: rgba(255,255,255,0.01) !important;
        }

        /* USER AVATAR (For when backend is added) */
        .user-avatar {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold; color: white; margin-right: 15px;
            box-shadow: 0 0 10px rgba(118, 75, 162, 0.5);
        }

        /* ROLE BADGES (For when backend is added) */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: bold; text-transform: uppercase; }
        .badge-student { background: rgba(0, 243, 255, 0.1); color: #00f3ff; border: 1px solid rgba(0, 243, 255, 0.3); }
        .badge-lecturer { background: rgba(188, 19, 254, 0.1); color: #bc13fe; border: 1px solid rgba(188, 19, 254, 0.3); }
        
        /* STATUS TEXT (For when backend is added) */
        .status-active { color: #00ff88; font-weight: bold; }
        .status-banned { color: #ff4d4d; font-weight: bold; }

        /* ACTION BUTTONS (For when backend is added) */
        .action-btn {
            background: transparent;
            border: 1px solid rgba(255,255,255,0.2);
            color: white;
            padding: 8px 12px;
            border-radius: 8px;
            cursor: pointer;
            margin-left: 5px;
            transition: 0.3s;
        }
        .btn-edit:hover { background: #00f3ff; color: black; border-color: #00f3ff; }
        .btn-ban:hover { background: #ffc107; color: black; border-color: #ffc107; }
        .btn-delete:hover { background: #ff4d4d; color: white; border-color: #ff4d4d; }

    </style>

    <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">
        
        <div style="margin-bottom: 30px;">
            <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
            <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0; text-shadow: 0 0 20px rgba(188, 19, 254, 0.4);">
                User Directory
            </h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">Search, edit, or remove platform accounts.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ffb9b9"
            Style="display:block; margin-bottom:12px; font-weight:bold;"></asp:Label>

            <div class="controls-container">
            <span style="font-size: 1.2rem; color: #8899ac;">🔍</span>
            
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" Placeholder="Search by name or email..."></asp:TextBox>
            
            <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="filter-dropdown">
                <asp:ListItem Value="All" Text="Show All Roles"></asp:ListItem>
                <asp:ListItem Value="Student" Text="Students Only"></asp:ListItem>
                <asp:ListItem Value="Lecturer" Text="Lecturers Only"></asp:ListItem>
            </asp:DropDownList>

            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-search" OnClick="btnSearch_Click" />
        </div>

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
                                    <div style="display: flex; align-items: center;">
                                        <div class="user-avatar"><%# Eval("Username").ToString().Substring(0, 1).ToUpper() %></div>
                                        <div>
                                            <div style="font-weight: bold; font-size: 1rem;"><%# Eval("Username") %></div>
                                            <div style="font-size: 0.8rem; color: #8899ac;"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </td>
                                
                                <td><span class="badge badge-<%# Eval("Role").ToString().ToLower() %>"><%# Eval("Role") %></span></td>
                                
                                <td><span class="status-<%# Eval("Status").ToString().ToLower() %>">● <%# Eval("Status") %></span></td>
                                
                                <td style="color: #8899ac;"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy") %></td>
                                
                                <td style="text-align: right;">
                                    <asp:LinkButton ID="btnToggleStatus" runat="server"
                                        CommandName="ToggleStatus"
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="action-btn btn-ban"
                                        OnClientClick="return confirm('Update account status?');"><%# Eval("Status").ToString().ToLower() == "active" ? "🚫 Suspend" : "✅ Activate" %></asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server"
                                        CommandName="DeleteUser"
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="action-btn btn-delete"
                                        OnClientClick="return confirm('Delete this user account? This action is irreversible.');">🗑️ Delete</asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

    </div>
</asp:Content>
