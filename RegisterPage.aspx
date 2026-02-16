<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterPage.aspx.cs" Inherits="PythonAcademy.WebForm2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Register.PythonAcademy
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <div style="display: flex; justify-content: center; align-items: center; min-height: 50vh;">
        <div style="width: 100%; max-width: 400px; padding: 40px; border-radius: 24px; background: var(--surface); box-shadow: 0 20px 50px rgba(0,0,0,0.5); border: 1px solid var(--line);">
            
            <div style="margin-bottom: 30px;">
                <h1 style="font-size: 2.5rem; font-weight: 800; color: white; margin: 0; line-height: 1.2;">
                    Create <br />
                    new account<span style="color: var(--primary);">.</span>
                </h1>
                <p style="color: var(--muted); margin-top: 10px;">
                    Join the community to start learning.
                </p>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:block; text-align:center; margin-bottom: 20px; font-weight:bold; padding: 10px; border-radius: 8px;"></asp:Label>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Username</label>
                <asp:TextBox ID="txtUsername" runat="server"  
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Full Name</label>
                <asp:TextBox ID="txtName" runat="server"  
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine"
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
            </div>

            <div style="margin-bottom: 30px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
            </div>

            <div style="margin-bottom: 30px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Verify Password</label>
                <asp:TextBox ID="TextBox1" runat="server" TextMode="Password"
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
            </div>

            <asp:Button ID="btnRegister" runat="server" Text="Create Account" OnClick="btnRegister_Click" CssClass="btn" 
                style="width: 100%; background-color: var(--primary); color: white; border: none; padding: 16px; font-size: 1.1rem; border-radius: 50px; cursor: pointer; font-weight: 800; box-shadow: 0 4px 15px rgba(47, 125, 255, 0.4);" />

        </div>
    </div>
    
    <style>
        input:focus, select:focus {
            border-color: var(--primary) !important;
            background: #0f1829 !important;
        }
    </style>
</asp:Content>
