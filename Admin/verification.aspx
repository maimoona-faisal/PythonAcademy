<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="verification.aspx.cs" Inherits="PythonAcademy.Admin.Verification" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root { --neon-blue: #00f3ff; --glass-bg: rgba(13, 25, 48, 0.95); --glass-border: rgba(255, 255, 255, 0.1); }

        .request-container {
            max-width: 1180px;
            margin: 0 auto;
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 30px;
            backdrop-filter: blur(20px);
        }

        .status-message {
            display: block;
            margin-bottom: 12px;
            font-weight: bold;
        }

        .queue-summary {
            color: #8899ac;
            margin-bottom: 18px;
            display: block;
        }

        .tech-table { width: 100%; border-collapse: separate; border-spacing: 0 15px; }
        .tech-table th { text-align: left; color: #8899ac; padding: 10px 20px; font-size: 0.85rem; text-transform: uppercase; }
        .tech-table td {
            background: rgba(255,255,255,0.03);
            padding: 20px;
            color: white;
            border: 1px solid rgba(255,255,255,0.05);
            vertical-align: top;
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

        .credential-link {
            color: #00f3ff;
            text-decoration: none;
            font-weight: bold;
            display: inline-block;
            margin-right: 12px;
            margin-bottom: 8px;
        }

        .reason-box {
            width: 100%;
            min-height: 72px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            color: white;
            border-radius: 10px;
            padding: 10px 12px;
            resize: vertical;
            box-sizing: border-box;
        }

        .reason-help {
            color: #8899ac;
            font-size: 0.75rem;
            margin-top: 6px;
        }

        .decision-cell {
            min-width: 220px;
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

        .action-row {
            margin-top: 12px;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .empty-state { text-align: center !important; color: #8899ac !important; padding: 40px !important; font-style: italic; border-left: none !important; }

        .pager-row {
            color: #c6d0dd;
        }

        .pager-row table {
            margin-left: auto;
        }

        .pager-row td {
            background: transparent !important;
            border: none !important;
            padding: 4px !important;
        }

        .pager-row a,
        .pager-row span {
            display: inline-block;
            min-width: 34px;
            text-align: center;
            padding: 8px 10px;
            border-radius: 10px;
            color: white;
            text-decoration: none;
            border: 1px solid rgba(255,255,255,0.15);
            background: rgba(255,255,255,0.03);
        }

        .pager-row span {
            background: rgba(255, 193, 7, 0.16);
            border-color: rgba(255, 193, 7, 0.4);
            color: #ffc107;
        }
    </style>

    <div style="padding: 40px 20px;">
        <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>

        <div style="margin: 20px 0 30px 0;">
            <h1 style="color: white; margin: 0; font-size: 2.5rem; text-shadow: 0 0 15px rgba(255, 193, 7, 0.3);">Verification Queue</h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">Review and process pending instructor registrations.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="status-message" Visible="false"></asp:Label>

        <div class="request-container">
            <asp:Label ID="lblQueueSummary" runat="server" CssClass="queue-summary"></asp:Label>

            <asp:GridView ID="gvPendingUsers" runat="server"
                CssClass="tech-table"
                AutoGenerateColumns="False"
                GridLines="None"
                DataKeyNames="UserID"
                AllowPaging="true"
                PageSize="20"
                OnPageIndexChanging="gvPendingUsers_PageIndexChanging"
                OnRowCommand="gvPendingUsers_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Username" HeaderText="Candidate" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="Date Applied" DataFormatString="{0:MMM dd, yyyy}" />

                    <asp:TemplateField HeaderText="Credentials">
                        <ItemTemplate>
                            <asp:HyperLink ID="lnkCv" runat="server"
                                CssClass="credential-link"
                                NavigateUrl='<%# GetSafeCvUrl(Eval("CVFilePath")) %>'
                                Target="_blank"
                                Visible='<%# HasSafeCvUrl(Eval("CVFilePath")) %>'>
                                &#128196; View CV
                            </asp:HyperLink>

                            <asp:HyperLink ID="lnkLinkedIn" runat="server"
                                CssClass="credential-link"
                                NavigateUrl='<%# GetSafeLinkedInUrl(Eval("LinkedInUrl")) %>'
                                Target="_blank"
                                Visible='<%# HasSafeLinkedInUrl(Eval("LinkedInUrl")) %>'>
                                &#128279; LinkedIn
                            </asp:HyperLink>

                            <asp:Label ID="lblNoCredentials" runat="server"
                                ForeColor="#8899ac"
                                Visible='<%# !HasSafeCvUrl(Eval("CVFilePath")) && !HasSafeLinkedInUrl(Eval("LinkedInUrl")) %>'
                                Text="No supporting documents provided."></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Rejection Reason">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRejectReason" runat="server" TextMode="MultiLine" Rows="3" CssClass="reason-box" MaxLength="250"
                                placeholder="Required if you reject this request."></asp:TextBox>
                            <div class="reason-help">Keep it brief and professional. This is stored for audit history.</div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Decision">
                        <ItemTemplate>
                            <div class="decision-cell">
                                <div class="action-row">
                                    <asp:LinkButton ID="btnApprove" runat="server"
                                        CommandName="ApproveUser"
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="btn-approve"
                                        OnClientClick="return confirm('Approve this instructor request?');">Approve</asp:LinkButton>
                                    <asp:LinkButton ID="btnReject" runat="server"
                                        CommandName="RejectUser"
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="btn-reject"
                                        OnClientClick="return confirm('Reject this instructor request? A rejection reason is required.');">Reject</asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state">No pending instructor requests at this time.</div>
                </EmptyDataTemplate>
                <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" Position="Bottom" />
                <PagerStyle CssClass="pager-row" HorizontalAlign="Right" />
            </asp:GridView>
        </div>
    </div>
</asp:Content>
