<%@ Page Title="Learner Profile" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="LearnersProfile.aspx.cs"
    Inherits="WAPPAssignment.LearnersProfile" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
	        --bg: #0b1220;
	        --surface: rgba(16, 31, 58, .60);
	        --text: #e7eefc;
	        --muted: #a9b8d6;
	        --line: rgba(255,255,255,.12);
	        --primary: #2f7dff;
	        --primary2: #00c2ff;
	        --shadow: 0 10px 30px rgba(0,0,0,.35);
	        --radius: 16px;
        }

        body {
	        margin: 0;
	        font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
	        color: var(--text);
	        background: radial-gradient(1100px 500px at 15% 10%, rgba(47,125,255,.18), transparent 60%), 
                        radial-gradient(800px 450px at 85% 15%, rgba(0,194,255,.12), transparent 55%), 
                        linear-gradient(180deg, #070d18 0%, #0b1220 100%);
        }

        .main {
	        padding: 30px;
        }

        h2 {
	        color: var(--text);
        }

        table {
	        margin-top: 20px;
        }

        .label-cell {
	        font-weight: bold;
	        padding-right: 15px;
        }

        .btn {
	        display: inline-flex;
	        align-items: center;
	        justify-content: center;
	        padding: 10px 12px;
	        border-radius: 12px;
	        text-decoration: none;
	        font-weight: 800;
	        border: 1px solid transparent;
	        cursor: pointer;
        }

        .btn-outline {
	        background: rgba(255,255,255,.05);
	        border-color: rgba(255,255,255,.12);
	        color: var(--text);
        }

        .btn-outline:hover {
	        background: rgba(255,255,255,.07);
	        border-color: rgba(255,255,255,.18);
        }

        .footer {
	        margin-top: auto;
	        background: transparent;
	        border-top: 1px solid var(--line);
	        padding: 10px 0;
        }
    </style>

    <div class="main">
        <h2>Learner's Profile</h2>

        <table>
            <tr>
                <td class="label-cell">User ID:</td>
                <td>
                    <asp:TextBox ID="TextBox1" runat="server" ReadOnly="True" AutoPostBack="True"
                        OnTextChanged="TextBox1_TextChanged" Width="200px" />
                </td>
            </tr>
            <tr>
                <td class="label-cell">Username:</td>
                <td>
                    <asp:TextBox ID="TextBox2" runat="server" ReadOnly="True" Width="200px" />
                </td>
            </tr>
            <tr>
                <td class="label-cell">Email:</td>
                <td>
                    <asp:TextBox ID="TextBox4" runat="server" ReadOnly="True" Width="200px" />
                </td>
            </tr>
            <tr>
                <td class="label-cell">Password:</td>
                <td>
                    <asp:TextBox ID="TextBox5" runat="server" ReadOnly="True" TextMode="Password" Width="200px" />
                </td>
            </tr>
            <tr>
                <td class="label-cell">User Role:</td>
                <td>
                    <asp:TextBox ID="TextBox6" runat="server" ReadOnly="True" Width="200px" />
                </td>
            </tr>
        </table>

        <br />

        <asp:Button ID="Button1" runat="server" Text="Edit" CssClass="btn btn-outline" OnClick="btnEdit_Click" />
        &nbsp;&nbsp;&nbsp;
        <asp:Button ID="Button2" runat="server" Text="Confirm" CssClass="btn btn-outline" OnClick="btnConfirm_Click" Enabled="False" />
        &nbsp;&nbsp;&nbsp;
        <asp:Button ID="btnProgressCheck" runat="server" Text="Progress Check" CssClass="btn btn-outline" OnClick="btnProgressCheck_Click" />
        &nbsp;&nbsp;&nbsp;
        <asp:Button ID="btnFeedback" runat="server" Text="Feedback" CssClass="btn btn-outline" OnClick="btnFeedback_Click" />
    </div>

</asp:Content>
