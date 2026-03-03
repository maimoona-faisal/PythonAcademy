<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewResults.aspx.cs" Inherits="PythonAcademy.ViewResults" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    View Assessment Results
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblError" runat="server" ForeColor="Red"></asp:Label>

    <asp:Panel ID="pnlResults" runat="server" Visible="false">
        <h2>Assessment Results</h2>

        <asp:Label ID="lblAssessmentTitle" runat="server" Font-Bold="true" Font-Size="Large" />
        <br /><br />

        <asp:Label ID="lblTotalScore" runat="server" Font-Bold="true" />
        <hr />
        <asp:Button ID="btnBackDashboard" runat="server" Text="Back to Dashboard" CssClass="btn" 
    OnClick="btnBackDashboard_Click" style="margin-top:20px;"/>

        <asp:Repeater ID="rptResults" runat="server">
            <ItemTemplate>
                <div style="margin-bottom:15px;">
                    <p><b>Q: <%# Eval("QuestionText") %></b></p>

                    <p>
                        Selected Answer: 
                        <%# Eval("SelectedAnswer") ?? "Not Answered" %>
                    </p>

                    <p>
                        Status:
                        <span style="color:<%# (bool)Eval("IsCorrect") ? "green" : "red" %>;">
                            <%# (bool)Eval("IsCorrect") ? "Correct" : "Incorrect" %>
                        </span>
                    </p>
                </div>
                <hr />
            </ItemTemplate>
        </asp:Repeater>

    </asp:Panel>

</asp:Content>