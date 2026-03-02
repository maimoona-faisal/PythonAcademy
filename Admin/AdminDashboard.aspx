<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="PythonAcademy.Admin.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
            --neon-blue: #00f3ff;
            --neon-pink: #bc13fe;
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
            transition: transform 0.3s ease;
            display: block;
            text-decoration: none;
        }

            .glass-card:hover {
                transform: translateY(-5px);
                border-color: var(--neon-blue);
                box-shadow: 0 0 20px rgba(0, 243, 255, 0.2);
            }

        .stat-number {
            font-size: 3rem;
            font-weight: 800;
            background: linear-gradient(45deg, var(--neon-blue), white);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-top: 10px;
        }
    </style>

    <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">
        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ff9b9b"
            Style="display: block; margin-bottom: 15px; font-weight: bold;"></asp:Label>

        <div style="margin-bottom: 40px;">
            <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 0; text-shadow: 0 0 20px rgba(0, 243, 255, 0.3);">Admin Dashboard</h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">System Overview</p>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 25px;">

            <div class="glass-card">
                <div style="display: flex; justify-content: space-between; color: #8899ac;">
                    <span>TOTAL LEARNERS</span> <span style="font-size: 1.2rem;"></span>
                </div>
                <div class="stat-number">
                    <asp:Label ID="lblStudents" runat="server" Text="0"></asp:Label>
                </div>
            </div>

            <div class="glass-card">
                <div style="display: flex; justify-content: space-between; color: #8899ac;">
                    <span>ACTIVE INSTRUCTORS</span> <span style="font-size: 1.2rem;"></span>
                </div>
                <div class="stat-number">
                    <asp:Label ID="lblLecturers" runat="server" Text="0"></asp:Label>
                </div>
            </div>

            <a href="Verification.aspx" class="glass-card" style="border-color: rgba(255, 193, 7, 0.5); cursor: pointer;">
                <div style="display: flex; justify-content: space-between; color: #ffc107;">
                    <span>PENDING APPROVALS</span> <span style="font-size: 1.2rem;"></span>
                </div>
                <div class="stat-number" style="background: none; -webkit-text-fill-color: #ffc107;">
                    <asp:Label ID="lblPending" runat="server" Text="0"></asp:Label>
                </div>
                <div style="color: #ffc107; font-size: 0.8rem; margin-top: 5px;">Tap to review requests &rarr;</div>
            </a>

            <div class="glass-card">
                <div style="display: flex; justify-content: space-between; color: #8899ac;">
                    <span>LEARNING MODULES</span> <span style="font-size: 1.2rem;"></span>
                </div>
                <div class="stat-number">
                    <asp:Label ID="lblModules" runat="server" Text="0"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 25px;">

        <div class="glass-card">
            <h3 style="color: white; margin-top: 0; margin-bottom: 20px; font-size: 1.1rem;"> Quick Actions</h3>

            <div style="display: flex; flex-direction: column; gap: 15px;">
                <a href="ManageUsers.aspx" style="text-decoration: none; display: flex; align-items: center; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 12px; color: white; transition: 0.3s;">
                    <span style="background: rgba(0, 243, 255, 0.2); width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; border-radius: 8px; margin-right: 15px; color: #00f3ff;"></span>
                    <div>
                        <div style="font-weight: bold; font-size: 0.9rem;">Manage Users</div>
                        <div style="font-size: 0.75rem; color: #8899ac;">Edit, ban, or remove accounts</div>
                    </div>
                </a>

                <a href="announcements.aspx" style="text-decoration: none; display: flex; align-items: center; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 12px; color: white; transition: 0.3s;">
                    <span style="background: rgba(188, 19, 254, 0.2); width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; border-radius: 8px; margin-right: 15px; color: #bc13fe;"></span>
                    <div>
                        <div style="font-weight: bold; font-size: 0.9rem;">System Announcement</div>
                        <div style="font-size: 0.75rem; color: #8899ac;">Post a message to all students</div>
                    </div>
                </a>

                <a href="Settings.aspx" style="text-decoration: none; display: flex; align-items: center; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 12px; color: white; transition: 0.3s;">
                    <span style="background: rgba(255, 193, 7, 0.2); width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; border-radius: 8px; margin-right: 15px; color: #ffc107;"></span>
                    <div>
                        <div style="font-weight: bold; font-size: 0.9rem;">Platform Settings</div>
                        <div style="font-size: 0.75rem; color: #8899ac;">Configure database & backup</div>
                    </div>
                </a>
            </div>
        </div>

        <div class="glass-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="color: white; margin: 0; font-size: 1.1rem;">Recent System Activity</h3>
                <span style="font-size: 0.8rem; color: #00f3ff; animation: pulse 2s infinite;">~ LIVE</span>
            </div>

            <table class="tech-table">
                <tbody>
                    <asp:Repeater ID="rptRecentActivity" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="width: 80px; text-align: center; color: #8899ac; font-size: 0.8rem;">
                                    <%# Eval("Timestamp", "{0:MMM dd, HH:mm}") %>
                                </td>
                                <td><strong style="color: #00f3ff;"><%# Eval("Action") %></strong></td>
                                <td style="color: #8899ac;"><%# Eval("Details") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
