<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="announcements.aspx.cs" Inherits="PythonAcademy.Admin.announcements" %>
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
            background: var(--glass-bg); backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border); border-radius: 20px;
            padding: 30px; box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
        }

        /* Form Inputs */
        .form-label {
            display: block; color: #8899ac; font-size: 0.85rem; 
            font-weight: bold; margin-bottom: 8px; text-transform: uppercase;
        }

        .glass-input {
            width: 100%; background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1); padding: 15px;
            border-radius: 12px; color: white; font-size: 1rem;
            outline: none; transition: 0.3s; margin-bottom: 20px;
        }
        
        .glass-input:focus { border-color: var(--neon-purple); box-shadow: 0 0 15px rgba(188, 19, 254, 0.2); }

        textarea.glass-input {
            resize: vertical; min-height: 150px; font-family: inherit;
        }

        /* Broadcast Button */
        .btn-broadcast {
            background: linear-gradient(90deg, #7a0cd2, var(--neon-purple));
            color: white; border: none; padding: 15px 30px; width: 100%;
            border-radius: 50px; font-weight: bold; font-size: 1.1rem;
            cursor: pointer; box-shadow: 0 0 15px rgba(188, 19, 254, 0.4);
            transition: 0.3s;
        }
        .btn-broadcast:hover { box-shadow: 0 0 25px rgba(188, 19, 254, 0.7); transform: translateY(-2px); }

        /* Table Styles for History */
        .user-table { width: 100%; border-collapse: separate; border-spacing: 0 10px; }
        .user-table th { text-align: left; padding: 15px; color: #8899ac; font-size: 0.85rem; text-transform: uppercase; }
        .user-table td { background: rgba(255,255,255,0.03); padding: 15px; color: white; border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle; }
        .user-table tr:first-child td:first-child { border-top-left-radius: 10px; border-bottom-left-radius: 10px; border-left: 3px solid var(--neon-purple); }
        .user-table tr:first-child td:last-child { border-top-right-radius: 10px; border-bottom-right-radius: 10px; }

        .empty-state { text-align: center !important; color: #8899ac !important; padding: 40px !important; font-style: italic; border-left: none !important;}
        
        /* Layout Grid */
        .announcement-grid {
            display: grid;
            grid-template-columns: 1fr 1.5fr; /* Left side smaller, right side larger */
            gap: 30px;
        }
    </style>

    <div style="max-width: 1300px; margin: 0 auto; padding: 20px;">
        
        <div style="margin-bottom: 30px;">
            <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
            <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0; text-shadow: 0 0 20px rgba(188, 19, 254, 0.4);">
                System Announcements
            </h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">Broadcast messages to learners and instructors.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ffb9b9"
            Style="display:block; margin-bottom:12px; font-weight:bold;"></asp:Label>

        <div class="announcement-grid">
            
            <div class="glass-card">
                <h3 style="color: white; margin-top: 0; margin-bottom: 25px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;">
                    📝 Compose Broadcast
                </h3>

               <label class="form-label">Announcement Title</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="glass-input" Placeholder="e.g. Scheduled Maintenance Notice"></asp:TextBox>

                <label class="form-label">Target Audience</label>
                <asp:DropDownList ID="ddlAudience" runat="server" CssClass="glass-input">
                    <asp:ListItem Value="All">Everyone (Public)</asp:ListItem>
                    <asp:ListItem Value="Students">Learners Only</asp:ListItem>
                    <asp:ListItem Value="Lecturers">Instructors Only</asp:ListItem>
                </asp:DropDownList>

                <label class="form-label">Message Content</label>
                <asp:TextBox ID="txtMessage" runat="server" CssClass="glass-input" TextMode="MultiLine" Rows="5" Placeholder="Type your announcement here..."></asp:TextBox>

                <asp:Button ID="btnBroadcast" runat="server" Text="📡 Broadcast Message" CssClass="btn-broadcast" OnClick="btnBroadcast_Click" />
            </div>

            <div class="glass-card">
                <h3 style="color: white; margin-top: 0; margin-bottom: 25px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;">
                    🕰️ Broadcast History
                </h3>

               <asp:GridView ID="gvAnnouncements" runat="server" CssClass="user-table" 
                    AutoGenerateColumns="False" GridLines="None" 
                    DataKeyNames="AnnouncementID" OnRowDeleting="gvAnnouncements_RowDeleting">
                    
                    <Columns>
                        <asp:BoundField DataField="CreatedAt" HeaderText="Date Sent" DataFormatString="{0:MMM dd, yyyy}" ItemStyle-Width="20%" />
                        <asp:BoundField DataField="Title" HeaderText="Title" ItemStyle-Width="35%" />
                        <asp:BoundField DataField="TargetAudience" HeaderText="Audience" ItemStyle-Width="25%" />
                        
                        <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" 
                                    CssClass="action-btn btn-delete" 
                                    OnClientClick="return confirm('Delete this announcement?');">🗑️</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>

                    <EmptyDataTemplate>
                        <div class="empty-state">
                            No past announcements found.
                        </div>
                    </EmptyDataTemplate>

                </asp:GridView>
            </div>

        </div>
    </div>
</asp:Content>

