<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrackProgress.aspx.cs" Inherits="WAPPAssignment.TrackProgress" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .progress-card {
            background: rgba(13, 25, 48, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .prog-bar-bg {
            width: 100%;
            height: 10px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            margin-top: 10px;
            overflow: hidden;
        }
        .prog-bar-fill {
            height: 100%;
            background: #00f3ff; 
            border-radius: 10px;
            transition: width 1s ease-in-out;
        }
        .cert-btn {
            background: #ffd740;
            color: #000;
            padding: 10px 15px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            display: inline-block;
        }
    </style>

    <div style="max-width: 900px; margin: 0 auto; padding: 20px;">
        <h1 style="color: white;">My Learning Progress</h1>
        <p style="color: #8899ac; margin-bottom: 30px;">Track your course completion and download your certificates.</p>

        <asp:Repeater ID="rptProgress" runat="server">
            <ItemTemplate>
                <div class="progress-card">
                    <div style="flex: 1; margin-right: 30px;">
                        <h3 style="color: white; margin: 0 0 5px 0;"><%# Eval("Title") %></h3>
                        <span style="color: #8899ac; font-size: 0.9rem;">
                            Progress: <%# Eval("ProgressPercentage") %>%
                        </span>
                        
                        <div class="prog-bar-bg">
                            <div class="prog-bar-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                        </div>
                    </div>

                    <div>
                        <asp:HyperLink ID="lnkCert" runat="server" 
                            NavigateUrl='<%# "~/Learner-wei/viewCert.aspx?hash=" + Eval("CertificateHash") %>'
                            CssClass="cert-btn"
                            Visible='<%# Convert.ToInt32(Eval("ProgressPercentage")) == 100 %>'>
                            🏆 View Certificate
                        </asp:HyperLink>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>
