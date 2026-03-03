<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrackProgress.aspx.cs" Inherits="WAPPAssignment.TrackProgress" MasterPageFile="~/Site.Master" %>

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
    }
    </style>

    <div style="text-align:center;">
        <asp:Label ID="Label1" runat="server" Text="Progress Tracking" 
            Style="font-weight:bold; font-size:32px; color:#e7eefc;"></asp:Label>
        <br /><br />

        <asp:Image ID="Image1" runat="server" Height="209px" Width="335px" 
            ImageUrl="~/python_image.jpeg"/>
        <br /><br />

        <asp:Label ID="Label2" runat="server" Text="Module Name: " 
            Style="font-size:18px; font-weight:bold;"></asp:Label>
        <br /><br />

        <asp:Label ID="Label3" runat="server" Text="Progress: " 
            Style="font-size:18px; font-weight:bold;"></asp:Label>
        &nbsp;&nbsp;&nbsp;
        <asp:TextBox ID="TextBox1" runat="server" ReadOnly="True" Width="60px"></asp:TextBox>
        <span>%</span>
    </div>
</asp:Content>
