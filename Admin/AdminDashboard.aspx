<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="PythonAcademy.Admin.AdminDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
            --neon-blue: #00f3ff;
            --neon-pink: #bc13fe;
            --glass-bg: rgba(13, 25, 48, 0.85);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        /* The Glass Card */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s ease;
        }

        .glass-card:hover {
            transform: translateY(-5px);
            border-color: var(--neon-blue);
            box-shadow: 0 0 20px rgba(0, 243, 255, 0.2);
        }

        /* Glowing Numbers */
        .stat-number {
            font-size: 3rem;
            font-weight: 800;
            background: linear-gradient(45deg, var(--neon-blue), white);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-top: 10px;
        }

        /* Table Styles */
        .tech-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 10px;
        }
        
        .tech-table th {
            text-align: left;
            padding: 15px;
            color: #8899ac;
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .tech-table td {
            background: rgba(255,255,255,0.03);
            padding: 15px;
            color: white;
            border-top: 1px solid rgba(255,255,255,0.05);
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }
        
        /* Empty State Style */
        .empty-state {
            text-align: center;
            color: #8899ac;
            padding: 30px !important;
            font-style: italic;
        }

        .tech-table tr:first-child td:first-child { border-top-left-radius: 10px; border-bottom-left-radius: 10px; }
        .tech-table tr:first-child td:last-child { border-top-right-radius: 10px; border-bottom-right-radius: 10px; }

    </style>

    <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">

        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 40px;">
            <div>
                <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 0; text-shadow: 0 0 20px rgba(0, 243, 255, 0.3);">
                    Admin Dashboard
                </h1>
                <p style="color: #8899ac; margin: 5px 0 0 0;">System Overview & Analytics</p>
            </div>
            <div style="text-align: right;">
                 <span style="display:inline-block; width:8px; height:8px; background:#00f3ff; border-radius:50%; box-shadow: 0 0 10px #00f3ff;"></span>
                 <span style="color: #00f3ff; margin-left: 8px; font-size: 0.9rem; letter-spacing: 1px;">SYSTEM ONLINE</span>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 25px; margin-bottom: 40px;">
            
            <div class="glass-card">
                <div style="display: flex; justify-content: space-between; color: #8899ac;">
                    <span>TOTAL LEARNERS</span>
                    <span style="font-size: 1.2rem;">🎓</span>
                </div>
                <div class="stat-number">
                    <asp:Label ID="lblStudents" runat="server" Text="0"></asp:Label>
                </div>
            </div>

            <div class="glass-card">
                <div style="display: flex; justify-content: space-between; color: #8899ac;">
                    <span>ACTIVE INSTRUCTORS</span>
                    <span style="font-size: 1.2rem;">👨‍🏫</span>
                </div>
                <div class="stat-number" style="background: linear-gradient(45deg, #bc13fe, white); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
                    <asp:Label ID="lblLecturers" runat="server" Text="0"></asp:Label>
                </div>
            </div>

            <div class="glass-card" style="border-color: rgba(255, 193, 7, 0.3);">
                <div style="display: flex; justify-content: space-between; color: #ffc107;">
                    <span>PENDING APPROVALS</span>
                    <span style="font-size: 1.2rem;">⚠️</span>
                </div>
                <div class="stat-number" style="background: none; -webkit-text-fill-color: #ffc107;">
                    <asp:Label ID="lblPending" runat="server" Text="0"></asp:Label>
                </div>
            </div>

            <div class="glass-card">
                <div style="display: flex; justify-content: space-between; color: #8899ac;">
                    <span>LEARNING MODULES</span>
                    <span style="font-size: 1.2rem;">📦</span>
                </div>
                <div class="stat-number">
                    <asp:Label ID="lblModules" runat="server" Text="0"></asp:Label>
                </div>
            </div>
        </div>

        <div class="glass-card">
            <h3 style="color: white; margin-top: 0; margin-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 15px;">
                Incoming Requests
            </h3>

            <table class="tech-table">
                <thead>
                    <tr>
                        <th>User Identity</th>
                        <th>Contact Info</th>
                        <th>Role Requested</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="5" class="empty-state">
                            No pending requests found. System is up to date.
                        </td>
                    </tr>
                </tbody>
            </table>

        </div>

    </div>

</asp:Content>