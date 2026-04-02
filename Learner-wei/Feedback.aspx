<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="WAPPAssignment.Feedback" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
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

        .feedback-box
        {
            width: 80%;
            max-width: 600px;
            padding: 10px;
            border-radius: 12px;
            border: 1px solid var(--line);
            background-color: rgba(255,255,255,.05);
            color: var(--text);
        } 
    </style>

    <div style="text-align:center; padding: 20px;">
        <asp:Label ID="Label1" runat="server" Text="Feedback Submission"
                   BorderColor="Black"
                   Style="font-weight:bold; font-size:32px; color:#333;"></asp:Label>
        <br /><br />

        <asp:Label ID="Label2" runat="server"
                   Text="Feel free to give any opinions for our application"></asp:Label>
        <br /><br />

        <asp:TextBox ID="TextBox1" runat="server"
                     TextMode="MultiLine" Rows="5" Columns="60"
                     CssClass="feedback-box"></asp:TextBox>
        <br /><br />

        <asp:Button ID="Button1" runat="server" Text="Confirm"
                    OnClick="btnConfirm_Click" CssClass="btn btn-outline" />
        <br /><br />

        <asp:Label ID="Label3" runat="server"
                   Text="Your feedback means a lot to us~"
                   Style="font-weight:bold; font-size:16px; color:#0026ff"></asp:Label>
    </div>
</asp:Content>
