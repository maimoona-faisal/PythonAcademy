<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageContent.aspx.cs" Inherits="PythonAcademy.Admin.ManageContent" %>
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

        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            margin-bottom: 20px;
        }

        .glass-input {
            width: 100%;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            padding: 10px 12px;
            border-radius: 10px;
            color: white;
            margin-bottom: 10px;
        }

        .user-table { width: 100%; border-collapse: separate; border-spacing: 0 10px; }
        .user-table th { text-align: left; padding: 15px; color: #8899ac; font-size: 0.85rem; text-transform: uppercase; }
        .user-table td { background: rgba(255,255,255,0.03); padding: 12px; color: white; border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle; }

        .action-btn {
            background: transparent;
            border: 1px solid rgba(255,255,255,0.2);
            color: white;
            padding: 6px 10px;
            border-radius: 8px;
            cursor: pointer;
            margin-right: 5px;
            font-size: 0.82rem;
        }

        .empty-state { text-align: center !important; color: #8899ac !important; padding: 35px !important; font-style: italic; }
    </style>

    <div style="max-width: 1300px; margin: 0 auto; padding: 20px;">
        <div style="margin-bottom: 30px;">
            <a href="AdminDashboard.aspx" style="color: #8899ac; text-decoration: none; font-size: 0.9rem;">&larr; Back to Dashboard</a>
            <h1 style="font-size: 2.5rem; font-weight: bold; color: white; margin: 10px 0 0 0; text-shadow: 0 0 20px rgba(0, 243, 255, 0.4);">
                Content Manager
            </h1>
            <p style="color: #8899ac; margin: 5px 0 0 0;">Manage course content and moderation decisions.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" ForeColor="#ffb9b9"
            Style="display:block; margin-bottom:12px; font-weight:bold;"></asp:Label>

        <div class="controls-container">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box"
                Placeholder="Search by title, lecturer, file path, or URL..."></asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" CssClass="btn-search" Text="Search" OnClick="btnSearch_Click" />
        </div>

        <div class="glass-card">
            <h3 style="color:white; margin-top:0;">Add Content</h3>
            <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="glass-input"></asp:DropDownList>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="glass-input" MaxLength="200" Placeholder="Title"></asp:TextBox>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="glass-input" TextMode="MultiLine" Rows="3" Placeholder="Description (optional)"></asp:TextBox>
            <asp:DropDownList ID="ddlContentType" runat="server" CssClass="glass-input">
                <asp:ListItem Value="Document">Document</asp:ListItem>
                <asp:ListItem Value="Video">Video</asp:ListItem>
                <asp:ListItem Value="Link">External Link</asp:ListItem>
                <asp:ListItem Value="Assessment">Assessment</asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtFilePath" runat="server" CssClass="glass-input" MaxLength="300" Placeholder="File path (optional)"></asp:TextBox>
            <asp:TextBox ID="txtUrl" runat="server" CssClass="glass-input" MaxLength="500" Placeholder="URL (optional)"></asp:TextBox>
            <asp:Button ID="btnAddContent" runat="server" CssClass="btn-search" Text="Create Content" OnClick="btnAddContent_Click" />
        </div>

        <div class="glass-card">
            <asp:GridView ID="gvContent" runat="server" CssClass="user-table"
                AutoGenerateColumns="False" GridLines="None" DataKeyNames="ContentID"
                OnRowEditing="gvContent_RowEditing"
                OnRowCancelingEdit="gvContent_RowCancelingEdit"
                OnRowUpdating="gvContent_RowUpdating"
                OnRowCommand="gvContent_RowCommand">
                <Columns>
                    <asp:TemplateField HeaderText="Title">
                        <ItemTemplate>
                            <%# Eval("Title") %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditTitle" runat="server" CssClass="glass-input"
                                Text='<%# Bind("Title") %>' MaxLength="200"></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="LecturerName" HeaderText="Uploaded By" ReadOnly="True" />

                    <asp:TemplateField HeaderText="Content Type">
                        <ItemTemplate>
                            <%# Eval("ContentType") %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditContentType" runat="server" CssClass="glass-input"
                                Text='<%# Bind("ContentType") %>' MaxLength="50"></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="File / URL">
                        <ItemTemplate>
                            <div><%# Eval("FilePath") %></div>
                            <div style="font-size:0.75rem; color:#8ca7c5;"><%# Eval("Url") %></div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditFilePath" runat="server" CssClass="glass-input"
                                Text='<%# Bind("FilePath") %>' MaxLength="300" Placeholder="File path"></asp:TextBox>
                            <asp:TextBox ID="txtEditUrl" runat="server" CssClass="glass-input"
                                Text='<%# Bind("Url") %>' MaxLength="500" Placeholder="URL"></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="ApprovalState" HeaderText="Status" ReadOnly="True" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="Date Added" DataFormatString="{0:MMM dd, yyyy}" ReadOnly="True" />

                    <asp:CommandField ShowEditButton="True" />

                    <asp:TemplateField HeaderText="Moderation">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnApprove" runat="server"
                                CommandName="ApproveContent"
                                CommandArgument='<%# Eval("ContentID") %>'
                                CssClass="action-btn">Approve</asp:LinkButton>
                            <asp:LinkButton ID="btnReject" runat="server"
                                CommandName="RejectContent"
                                CommandArgument='<%# Eval("ContentID") %>'
                                CssClass="action-btn">Reject</asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server"
                                CommandName="DeleteContent"
                                CommandArgument='<%# Eval("ContentID") %>'
                                CssClass="action-btn"
                                OnClientClick="return confirm('Delete this content item?');">Delete</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state">No learning materials match your current filter.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
