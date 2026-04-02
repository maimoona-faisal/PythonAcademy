<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="practiceCode.aspx.cs" Inherits="PythonAcademy.practiceCode" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div style="max-width: 1000px; margin: 0 auto;">
        
        <div style="margin-bottom: 25px;">
            <h2 style="color: white; margin-bottom: 5px;">
                <span style="color: #00f3ff;">>_</span> Python Interactive Terminal
            </h2>
            <p style="color: #8899ac;">Practice your Python skills in real-time. Write your code on the left and see the output on the right!</p>
        </div>

        <div style="background: rgba(13, 25, 48, 0.85); padding: 20px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);">
            
            <iframe src="https://trinket.io/embed/python3?toggleCode=true&runOption=run" 
                    width="100%" 
                    height="500" 
                    frameborder="0" 
                    marginwidth="0" 
                    marginheight="0" 
                    allowfullscreen>
            </iframe>
            
        </div>
        
        <div style="margin-top: 15px; text-align: right;">
            <small style="color: #8899ac;">Powered by secure external sandbox compilation.</small>
        </div>
        
    </div>
</asp:Content>
