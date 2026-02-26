<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="verification.aspx.cs" Inherits="PythonAcademy.Admin.Verification" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root { --neon-blue: #00f3ff; --glass-bg: rgba(13, 25, 48, 0.95); --glass-border: rgba(255, 255, 255, 0.1); }

        .request-container {
            max-width: 1100px;
            margin: 0 auto;
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 30px;
            backdrop-filter: blur(20px);
        }

        .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 15px; }
        .tech-table th { text-align: left; color: #8899ac; padding: 10px 20px; font-size: 0.85rem; text-transform: uppercase; }
        .tech-table td {
            background: rgba(255,255,255,0.03);
            padding: 20px;
            color: white;
            border: 1px solid rgba(255,255,255,0.05);
            vertical-align: middle;
        }
        .tech-table tr td:first-child {
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;
            border-left: 3px solid #ffc107;
        }
        .tech-table tr td:last-child {
            border-top-right-radius: 10px;
            border-bottom-right-radius: 10px;
        }

        .btn-approve {
            background: #00ff88;
            color: black;
            border: none;
            padding: 8px 20px;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .btn-reject {
            background: transparent;
            border: 1px solid #ff4d4d;
            color: #ff4d4d;
            padding: 8px 20px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin-left: 8px;
        }

        .empty-state { text-align: center !important; color: #8899ac !important; padding: 40px !important; font-style: italic; border-left: none !important; }
    </style>

    <div style="padding: 40px 20px;">
        <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>

        <div style="margin: 20px 0 30px 0;">
            <h1 style="color: white; margin: 0; font-size: 2.5rem; text-shadow: 0 0 15px rgba(255, 193, 7, 0.3);">Verification Queue</h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">Review and process pending instructor registrations.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ffb9b9"
            Style="display:block; margin-bottom:12px; font-weight:bold;"></asp:Label>

        <div class="request-container">
            <asp:GridView ID="gvPendingUsers" runat="server"
                CssClass="tech-table"
                AutoGenerateColumns="False"
                GridLines="None"
                DataKeyNames="UserID"
                OnRowCommand="gvPendingUsers_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Username" HeaderText="Candidate" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="Date Applied" DataFormatString="{0:MMM dd, yyyy}" />
                    <asp:TemplateField HeaderText="Decision">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnApprove" runat="server"
                                CommandName="ApproveUser"
                                CommandArgument='<%# Eval("UserID") %>'
                                CssClass="btn-approve">Approve</asp:LinkButton>
                            <asp:LinkButton ID="btnReject" runat="server"
                                CommandName="RejectUser"
                                CommandArgument='<%# Eval("UserID") %>'
                                CssClass="btn-reject"
                                OnClientClick="return confirm('Reject this instructor request?');">Reject</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state">No pending instructor requests at this time.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
