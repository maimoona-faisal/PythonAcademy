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
            color: var(--neon-blue);
            text-shadow: 0 0 12px rgba(0, 243, 255, 0.35);
            margin-top: 10px;
        }
        .activity-log-container {
            background: #050a15; 
            border: 1px solid rgba(0, 243, 255, 0.2);
            border-radius: 12px;
            padding: 15px;
            font-family: 'JetBrains Mono', monospace;
            color: #00f3ff;
            font-size: 0.85rem;
            box-shadow: inset 0 0 20px rgba(0, 0, 0, 0.5);
        }
        .log-entry { margin-bottom: 8px; border-bottom: 1px dashed rgba(255,255,255,0.05); padding-bottom: 4px; }
        .log-time { color: #8899ac; margin-right: 10px; }
        .log-action { color: #bc13fe; font-weight: bold; margin-right: 10px; }

        .blinking-cursor::after {
            content: '_';
            animation: blink 1s step-end infinite;
        }
        @keyframes blink { 50% { opacity: 0; } }

        .card-alert {
            animation: pulse-alert 2s infinite;
        }
        @keyframes pulse-alert {
            0% { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0.4); }
            70% { box-shadow: 0 0 0 15px rgba(255, 193, 7, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0); }
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

            <a href="Verification.aspx" class="glass-card card-alert" style="border-color: rgba(255, 193, 7, 0.5); cursor: pointer;">
                <div style="display: flex; justify-content: space-between; color: #ffc107;">
                    <span>PENDING APPROVALS</span> <span style="font-size: 1.2rem;"></span>
                </div>
                <div class="stat-number" style="color: #ffc107; text-shadow: 0 0 12px rgba(255, 193, 7, 0.35);">
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

           <div class="activity-log-container blinking-cursor">
                <asp:Repeater ID="rptRecentActivity" runat="server">
                    <ItemTemplate>
                        <div class="log-entry">
                            <span class="log-time">[<%# Eval("Timestamp", "{0:MMM dd, HH:mm}") %>]</span>
                            <span class="log-action"><%# Eval("Action") %></span>
                            <span class="log-details" style="color: #a9b8d6;"><%# Eval("Details") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>
