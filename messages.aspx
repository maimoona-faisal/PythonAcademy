<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="messages.aspx.cs" Inherits="PythonAcademy.messages" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .chat-container { display: flex; height: 75vh; background: #0d1627; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.5); margin: 20px auto; max-width: 1200px; }
        .chat-sidebar { width: 300px; background: #111c33; border-right: 1px solid rgba(255, 255, 255, 0.1); display: flex; flex-direction: column; }
        .chat-sidebar-header { padding: 20px; font-weight: bold; font-size: 1.2rem; color: white; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
        .contact-list { flex: 1; overflow-y: auto; }
        .contact-item { padding: 15px 20px; color: #8899ac; border-bottom: 1px solid rgba(255, 255, 255, 0.05); cursor: pointer; transition: 0.2s; display: block; text-decoration: none; }
        .contact-item:hover, .contact-item.active { background: rgba(0, 243, 255, 0.1); color: white; border-left: 4px solid #00f3ff; }
        .chat-window { flex: 1; display: flex; flex-direction: column; background: #0d1627; }
        .chat-header { padding: 20px; background: #111c33; border-bottom: 1px solid rgba(255, 255, 255, 0.1); color: white; font-weight: bold; }
        .chat-history { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; }
        .msg-bubble { max-width: 65%; padding: 12px 16px; border-radius: 18px; font-size: 0.95rem; line-height: 1.4; }
        .msg-received { background: #1e2a44; color: white; align-self: flex-start; border-bottom-left-radius: 4px; }
        .msg-sent { background: #007bff; color: white; align-self: flex-end; border-bottom-right-radius: 4px; }
        .msg-time { font-size: 0.7rem; color: rgba(255, 255, 255, 0.5); margin-top: 5px; text-align: right; }
        .chat-input-area { padding: 15px 20px; background: #111c33; border-top: 1px solid rgba(255, 255, 255, 0.1); display: flex; gap: 10px; }
        .chat-textbox { flex: 1; padding: 12px 15px; border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0,0,0,0.2); color: white; outline: none; }
        .chat-textbox:focus { border-color: #00f3ff; }
        .btn-send { background: #00f3ff; color: black; border: none; padding: 10px 20px; border-radius: 20px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-send:hover { background: white; }
    </style>

    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            
            <div class="chat-container">
                
                <div class="chat-sidebar">
                    <div class="chat-sidebar-header">Contacts</div>
                    <div class="contact-list">
                        <asp:Repeater ID="rptContacts" runat="server" OnItemCommand="rptContacts_ItemCommand">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkContact" runat="server" 
                                    CommandName="SelectContact" 
                                    CommandArgument='<%# Eval("UserID") %>' 
                                    CssClass='<%# Convert.ToInt32(Eval("UserID")) == ActiveContactId ? "contact-item active" : "contact-item" %>'>
                                    <strong><%# Eval("DisplayName") %></strong>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="chat-window">
                    
                    <div class="chat-header">
                        <asp:Label ID="lblChattingWith" runat="server" Text="Select a contact to start chatting..."></asp:Label>
                    </div>

                    <div class="chat-history" id="chatHistory" runat="server">
                        <asp:Repeater ID="rptChat" runat="server">
                            <ItemTemplate>
                                <div class='<%# Convert.ToInt32(Eval("SenderID")) == CurrentUserId ? "msg-bubble msg-sent" : "msg-bubble msg-received" %>'>
                                    <%# Eval("Body") %>
                                    <div class="msg-time"><%# Eval("CreatedAt", "{0:hh:mm tt}") %></div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="chat-input-area" id="inputArea" runat="server" visible="false">
                        <asp:TextBox ID="txtNewMessage" runat="server" CssClass="chat-textbox" placeholder="Type a message..." AutoCompleteType="Disabled"></asp:TextBox>
                        <asp:Button ID="btnSend" runat="server" Text="Send 🚀" CssClass="btn-send" OnClick="btnSend_Click" />
                    </div>

                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
