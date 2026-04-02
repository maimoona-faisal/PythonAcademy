<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="PythonAcademy.Admin.Settings" %>
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
            padding: 30px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            margin-bottom: 25px;
        }

        .form-label {
            display: block;
            color: #8899ac;
            font-size: 0.85rem;
            font-weight: bold;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .glass-input {
            width: 100%;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            padding: 12px 20px;
            border-radius: 12px;
            color: white;
            font-size: 1rem;
            outline: none;
            transition: 0.3s;
            margin-bottom: 20px;
        }

        .toggle-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }

        .btn-save {
            background: linear-gradient(90deg, #0066ff, var(--neon-blue));
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 0 15px rgba(0, 243, 255, 0.3);
        }
        /* Glowing Toggle Switch */
        .switch { position: relative; display: inline-block; width: 50px; height: 26px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(255,255,255,0.1); transition: .4s; border-radius: 34px; border: 1px solid rgba(255,255,255,0.2); }
        .slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: #8899ac; transition: .4s; border-radius: 50%; }
        input:checked + .slider { background-color: rgba(0, 243, 255, 0.2); border-color: #00f3ff; }
        input:checked + .slider:before { transform: translateX(24px); background-color: #00f3ff; box-shadow: 0 0 10px #00f3ff; }
    </style>

    <div style="max-width: 900px; margin: 0 auto; padding: 20px;">
        <div style="margin-bottom: 30px;">
            <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
            <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0; text-shadow: 0 0 20px rgba(0, 243, 255, 0.4);">
                Platform Settings
            </h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">Configure global system parameters and security controls.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ffb9b9"
            Style="display:block; margin-bottom:12px; font-weight:bold;"></asp:Label>

        <div class="glass-card">
            <h3 style="color: white; margin-top: 0; margin-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;">
                General Configuration
            </h3>

            <label class="form-label">Support Email Address</label>
            <asp:TextBox ID="txtSupportEmail" runat="server" CssClass="glass-input" MaxLength="150"></asp:TextBox>

            <label class="form-label">Max File Upload Size (MB)</label>
            <asp:TextBox ID="txtMaxUploadSize" runat="server" CssClass="glass-input" MaxLength="4"></asp:TextBox>
        </div>

        <div class="glass-card">
            <h3 style="color: white; margin-top: 0; margin-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;">
                Security & Access
            </h3>

           <div class="toggle-container">
                <div>
                    <div style="color: white; font-weight: bold; margin-bottom: 5px;">Allow New Registrations</div>
                    <div style="color: #8899ac; font-size: 0.85rem;">Let new learners and instructors create accounts.</div>
                </div>
                <label class="switch">
                    <asp:CheckBox ID="chkAllowRegistrations" runat="server" />
                    <span class="slider"></span>
                </label>
            </div>

            <div class="toggle-container">
                <div>
                    <div style="color: white; font-weight: bold; margin-bottom: 5px;">Enable Direct Messaging</div>
                    <div style="color: #8899ac; font-size: 0.85rem;">Allow users to send and receive internal messages.</div>
                </div>
                <label class="switch">
                    <asp:CheckBox ID="chkEnableMessaging" runat="server" />
                    <span class="slider"></span>
                </label>
            </div>

            <div class="toggle-container" style="border-bottom:none;">
                <div>
                    <div style="color: #ffc107; font-weight: bold; margin-bottom: 5px;">Maintenance Mode</div>
                    <div style="color: #8899ac; font-size: 0.85rem;">Locks out all non-admin users during maintenance.</div>
                </div>
                <label class="switch">
                    <asp:CheckBox ID="chkMaintenanceMode" runat="server" />
                    <span class="slider"></span>
                </label>
            </div>
        </div>

        <div style="text-align: right;">
            <asp:Button ID="btnSaveSettings" runat="server" Text="Save Configuration" CssClass="btn-save" OnClick="btnSaveSettings_Click" />
        </div>
    </div>
</asp:Content>
