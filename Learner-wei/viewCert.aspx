<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="viewCert.aspx.cs" Inherits="PythonAcademy.viewCert" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Certificate of Completion
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .cert-wrapper { display: flex; justify-content: center; padding: 40px 20px; }
        .cert-container {
            width: 900px; height: 650px;
            background: #060d1a;
            border: 10px solid #00f3ff;
            outline: 2px solid #ffffff; outline-offset: -20px;
            padding: 50px; text-align: center; position: relative;
            box-shadow: 0 20px 50px rgba(0, 243, 255, 0.2);
            font-family: 'Outfit', sans-serif; color: white;
        }
        .cert-logo { width: 100px; margin-bottom: 20px; }
        .cert-header { font-size: 2.5rem; font-weight: 900; letter-spacing: 2px; color: #00f3ff; text-transform: uppercase; margin-bottom: 10px; }
        .cert-sub { font-size: 1.2rem; color: #a9b8d6; margin-bottom: 40px; }
        .cert-name { font-size: 3.5rem; font-weight: bold; color: white; margin-bottom: 30px; font-family: 'Times New Roman', serif; font-style: italic; border-bottom: 2px solid rgba(255,255,255,0.2); display: inline-block; padding: 0 40px; }
        .cert-course { font-size: 2rem; color: #ffd740; font-weight: 700; margin-top: 10px; margin-bottom: 50px; }
        .cert-footer { display: flex; justify-content: space-between; margin-top: 60px; padding: 0 50px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 30px; }
        .cert-sig-block { text-align: center; }
        .cert-sig-line { width: 200px; height: 1px; background: white; margin-bottom: 5px; }
        .cert-id { position: absolute; bottom: 20px; right: 20px; font-size: 0.7rem; color: #556677; font-family: monospace; }
        
        .print-btn { background: #00f3ff; color: black; border: none; padding: 15px 30px; border-radius: 8px; font-weight: bold; font-size: 1.1rem; cursor: pointer; display: block; margin: 0 auto 30px auto; }
        
        @media print {
            body * { visibility: hidden; }
            .topbar, .sidebar, .footer { display: none !important; }
            .cert-container, .cert-container * { visibility: visible; }
            .cert-container { position: absolute; left: 0; top: 0; margin: 0; border: 10px solid black; background: white; color: black; box-shadow: none; width: 100%; height: 100%; }
            .cert-header { color: black; } .cert-course { color: #333; }
            .cert-name, .cert-sig-line { border-color: black; }
        }
    </style>

    <asp:Panel ID="pnlError" runat="server" Visible="false" style="text-align:center; padding: 50px; color: red; font-size: 1.5rem;">
        Invalid or missing Certificate ID.
    </asp:Panel>

    <asp:Panel ID="pnlCert" runat="server">
        <button type="button" class="print-btn" onclick="window.print()">🖨️ Print / Save as PDF</button>
        
        <div class="cert-wrapper">
            <div class="cert-container">
                <img src="<%= ResolveUrl("~/Uploads/Python Academy Logo.png") %>" class="cert-logo" alt="Logo" />
                <div class="cert-header">Certificate of Completion</div>
                <div class="cert-sub">This is to proudly certify that</div>
                
                <div class="cert-name"><asp:Label ID="lblStudentName" runat="server" /></div>
                
                <div class="cert-sub" style="margin-bottom: 10px;">has successfully completed the module</div>
                <div class="cert-course"><asp:Label ID="lblCourseName" runat="server" /></div>
                
                <div class="cert-footer">
                    <div class="cert-sig-block">
                        <div class="cert-sig-line"></div>
                        <span style="color: #a9b8d6;">Issue Date:</span> <br />
                        <asp:Label ID="lblDate" runat="server" Font-Bold="true" />
                    </div>
                    <div class="cert-sig-block">
                        <div class="cert-sig-line"></div>
                        <span style="color: #a9b8d6;">Authorized by:</span> <br />
                        <strong>Python Academy Admins</strong>
                    </div>
                </div>

                <div class="cert-id">Credential ID: <asp:Label ID="lblHash" runat="server" /></div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>
