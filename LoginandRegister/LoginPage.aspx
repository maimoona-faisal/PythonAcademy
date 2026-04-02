<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LoginPage.aspx.cs" Inherits="PythonAcademy.LoginPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Login.PythonAcademy
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <div style="display: flex; max-width: 900px; margin: 50px auto; min-height: 500px; background: var(--surface); border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); overflow: hidden;">
            
        <div style="flex: 1; background: var(--surface); padding: 40px; display: flex; flex-direction: column; justify-content: center; color: white;">
            <h1 style="font-size: 3rem; font-weight: bold; margin-bottom: 20px; line-height: 1.2;">
                WELCOME
            </h1>

            <p style="font-size: 1.1rem; opacity: 0.9; line-height: 1.6">
                The ALL-IN-ONE Education Portal
            </p>
        </div>
        <div class="dashboard-card" style="width: 100%; max-width: 400px; padding: 40px;">

            <h2 style="text-align: center; color: var(--primary); margin-bottom: 20px;">
                LOG IN</h2>
            <p style="text-align: center; color: var(--muted); margin-bottom: 30px;">
                Access your PythonAcademy account
            </p>

             <asp:Label ID="lblMsg" runat="server" ForeColor="#ff4d4d" style="display:block; text-align:center; margin-bottom: 15px;">
             </asp:Label>

             <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--text);">
                    Email
                </label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine" style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--line); background: rgba(0,0,0,0.2); color: white;">
                </asp:TextBox>           
            </div>

            <asp:Label ID="Label2" runat="server" ForeColor="#ff4d4d" Visible="false" style="display:block; text-align:center; margin-bottom: 15px;">
            </asp:Label>

            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--text);">
                    Password
                </label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--line); background: rgba(0,0,0,0.2); color: white;">
                </asp:TextBox>           
            </div>  

            <div style="margin-bottom: 30px; display: flex; align-items: center; justify-content: space-between;">
                
                <div style="display: flex; align-items: center;">
                    <input type="checkbox" id="showPass" onclick="togglePassword()" style="margin-right: 10px; cursor: pointer;">
                    <label for="showPass" style="color: var(--muted); cursor: pointer; font-size: 0.9rem;">
                        Show Password
                    </label>
                </div> 

                <a href="forgotPassword.aspx" style="color: var(--primary2); font-size: 0.9rem; text-decoration: none; font-weight: bold;">
                    Forgot Password?
                </a>

            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn" style="width: 100%; background-color: var(--primary); color: white; border: none; padding: 12px; font-size: 1rem;" />

            <div style="margin-top: 20px; text-align: center;">
                <span style="color: var(--muted);">
                    New here? Click here to Register
                </span>
                <br />
                <a href="RegisterPage.aspx" style="color: var(--primary2); text-decoration: none">
                    Create an Account
                </a>
            </div>
        </div>
    </div>
    <script>
        function togglePassword() {
            var passField = document.getElementById('<%= txtPassword.ClientID %>');
            var checkbox = document.getElementById('showPass');

            if (checkbox.checked) {
                passField.type = "text";
            } else {
                passField.type = "password";
            }
        }
    </script>
</asp:Content>

