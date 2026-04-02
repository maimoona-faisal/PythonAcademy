<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="manageTopics.aspx.cs" Inherits="PythonAcademy.Lecture.manageTopics" ValidateRequest="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Manage Topics
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .glass-panel { background: rgba(13, 25, 48, 0.85); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px; padding: 25px; margin-bottom: 25px; }
        .form-label { display: block; margin-bottom: 8px; color: #a9b8d6; font-size: 0.9rem; font-weight: bold; }
        .neon-input { width: 100%; padding: 12px; border-radius: 10px; border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0, 0, 0, 0.2); color: white; margin-bottom: 20px; outline: none; }
        .neon-input:focus { border-color: #00f3ff; }
        .btn-primary { background: #00f3ff; color: #0b1220; border: none; padding: 10px 20px; font-weight: bold; border-radius: 8px; cursor: pointer; transition: 0.2s; }
        .btn-primary:hover { background: white; transform: translateY(-2px); }
        .topic-grid { width: 100%; border-collapse: collapse; margin-top: 15px; color: white; }
        .topic-grid th { background: rgba(0,0,0,0.3); padding: 12px; text-align: left; color: #00f3ff; }
        .topic-grid td { padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.05); }
    </style>

    <div style="max-width: 900px; margin: 0 auto; padding: 20px;">
        <h1 style="color: white; margin-bottom: 5px;">Manage Topics</h1>
        <p style="color: #a9b8d6; margin-top: 0;">Module: <asp:Label ID="lblModuleTitle" runat="server" Font-Bold="true" ForeColor="White" /></p>
        
        <asp:Label ID="lblMsg" runat="server" Font-Bold="true" style="display:block; margin-bottom: 15px;" />

        <div class="glass-panel">
            <h3 style="color: #00f3ff; margin-top: 0;">Add New Lesson/Topic</h3>
            
            <label class="form-label">Topic Title</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="neon-input" placeholder="e.g., '1. Introduction to Variables'" />

            <label class="form-label">Topic Format</label>
            <asp:DropDownList ID="ddlTopicType" runat="server" CssClass="neon-input" onchange="toggleInputFields()">
                <asp:ListItem Text="Normal Text / Embed Code" Value="Text" />
                <asp:ListItem Text="Upload PDF Document" Value="PDF" />
                <asp:ListItem Text="Upload Word Document" Value="Word" />
                <asp:ListItem Text="Upload PowerPoint" Value="PowerPoint" />
                <asp:ListItem Text="Upload Video (MP4)" Value="Video" />
                <asp:ListItem Text="Upload Image" Value="Image" />
                <asp:ListItem Text="External Link" Value="Link" />
            </asp:DropDownList>

            <div id="textInputArea">
                <label class="form-label">Topic Content</label>
                <asp:TextBox ID="txtContent" runat="server" CssClass="neon-input" TextMode="MultiLine" Rows="5" placeholder="Enter lesson text or paste iframe links here..." />
            </div>

            <div id="fileInputArea" style="display: none;">
                <label class="form-label">Upload File (Max 25 MB)</label>
                <asp:FileUpload ID="fuTopicFile" runat="server" CssClass="neon-input" Style="padding: 10px;" />
            </div>

            <div id="linkInputArea" style="display: none;">
                <label class="form-label">Resource URL</label>
                <asp:TextBox ID="txtLinkUrl" runat="server" CssClass="neon-input" placeholder="https://www.example.com" />
            </div>

            <label class="form-label">Order / Lesson Number</label>
            <asp:TextBox ID="txtOrder" runat="server" CssClass="neon-input" TextMode="Number" placeholder="1" Width="100px" />

            <asp:Button ID="btnAddTopic" runat="server" Text="+ Add Topic" CssClass="btn-primary" OnClick="btnAddTopic_Click" />
            <asp:HiddenField ID="hfEditTopicId" runat="server" />
            <div style="display: flex; gap: 10px; margin-top: 10px;">
                <asp:Button ID="Button1" runat="server" Text="+ Add Topic" CssClass="btn-primary" OnClick="btnAddTopic_Click" />
                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel Edit" CssClass="btn-primary" style="background: transparent; border: 1px solid #a9b8d6; color: #a9b8d6;" OnClick="btnCancelEdit_Click" Visible="false" CausesValidation="false" />
            </div>
        </div>

        <div class="glass-panel">
            <h3 style="color: white; margin-top: 0;">Existing Topics</h3>
            <asp:GridView ID="gvTopics" runat="server" AutoGenerateColumns="False" CssClass="topic-grid" GridLines="None" EmptyDataText="No topics added yet." OnRowCommand="gvTopics_RowCommand">
                <Columns>
                    <asp:BoundField DataField="OrderIndex" HeaderText="Order" ItemStyle-Width="60px" />
                    <asp:BoundField DataField="TopicTitle" HeaderText="Title" />
                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="120px">
                        <ItemTemplate>
                            <asp:LinkButton runat="server" CommandName="EditTopic" CommandArgument='<%# Eval("TopicId") %>' ForeColor="#ffd740" style="margin-right: 15px; text-decoration: none; font-weight: bold;">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="DeleteTopic" CommandArgument='<%# Eval("TopicId") %>' ForeColor="#ff4d4d" style="text-decoration: none; font-weight: bold;" OnClientClick="return confirm('Delete this topic?');">Delete</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <script>
        function toggleInputFields() {
            var type = document.getElementById('<%= ddlTopicType.ClientID %>').value;

            // Hide all first
            document.getElementById('textInputArea').style.display = 'none';
            document.getElementById('fileInputArea').style.display = 'none';
            document.getElementById('linkInputArea').style.display = 'none';

            // Show only what is needed
            if (type === "Text") {
                document.getElementById('textInputArea').style.display = 'block';
            } else if (type === "Link") {
                document.getElementById('linkInputArea').style.display = 'block';
            } else {
                document.getElementById('fileInputArea').style.display = 'block';
            }
        }
    </script>
</asp:Content>
