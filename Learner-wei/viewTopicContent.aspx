<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="viewTopicContent.aspx.cs" Inherits="PythonAcademy.Learner_wei.viewTopicContent" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .lesson-container {
            max-width: 900px;
            margin: 0 auto;
            background: rgba(13, 25, 48, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .lesson-title {
            font-size: 2rem;
            color: #00f3ff;
            margin-top: 0;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            padding-bottom: 15px;
        }
        .lesson-body {
            color: #e7eefc;
            font-size: 1.1rem;
            line-height: 1.8;
            margin-top: 20px;
            margin-bottom: 40px;
        }
        .btn-complete {
            background: linear-gradient(135deg, #00e676, #00b35c);
            color: black;
            border: none;
            padding: 15px 30px;
            font-size: 1.1rem;
            font-weight: bold;
            border-radius: 12px;
            cursor: pointer;
            transition: 0.2s;
            display: block;
            width: 100%;
            text-align: center;
        }
        .btn-complete:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 230, 118, 0.3); }
        .btn-back {
            color: #a9b8d6;
            text-decoration: none;
            display: inline-block;
            margin-bottom: 20px;
            font-weight: bold;
            transition: 0.2s;
        }
        .btn-back:hover { color: white; }
    </style>

    <div class="lesson-container">
        <asp:LinkButton ID="lnkBack" runat="server" CssClass="btn-back" OnClick="lnkBack_Click">← Back to Module Overview</asp:LinkButton>
        
        <h1 class="lesson-title"><asp:Label ID="lblTopicTitle" runat="server"></asp:Label></h1>
        
        <div class="lesson-body">
            <asp:Literal ID="litTopicContent" runat="server"></asp:Literal>
        </div>

        <asp:Button ID="btnMarkComplete" runat="server" Text="Mark as Complete & Return" CssClass="btn-complete" OnClick="btnMarkComplete_Click" />

        <asp:Button ID="btnAdminReturn" runat="server" Text="← Finish Reviewing (Return)" 
            CssClass="btn-complete" style="background: linear-gradient(135deg, #2f7dff, #00c2ff);" 
            OnClick="btnAdminReturn_Click" Visible="false" />
    </div>
</asp:Content>
