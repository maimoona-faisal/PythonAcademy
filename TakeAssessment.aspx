<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TakeAssessment.aspx.cs" Inherits="PythonAcademy.TakeAssessment" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Take Assessment
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Label ID="lblError" runat="server" ForeColor="Red" />

    <asp:Panel ID="pnlQuiz" runat="server" Visible="true" Style="margin-top:20px;">
        <h2><asp:Label ID="lblQuizTitle" runat="server" Font-Bold="true" Font-Size="Large" /></h2>

        <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
            <ItemTemplate>
                <div style="margin-bottom:20px;">
                    <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("QuestionId") %>' />
                    <p><b>Q: <%# Eval("QuestionText") %></b></p>
                    <asp:RadioButtonList ID="rblOptions" runat="server" RepeatDirection="Vertical" />
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" CssClass="btn" Style="margin-top:20px;" />
    </asp:Panel>

    <asp:Panel ID="pnlResults" runat="server" Visible="false" Style="margin-top:30px; border:1px solid #ccc; padding:20px; border-radius:8px;">
        <h2>Assessment Results</h2>
        <asp:Label ID="lblTotalScore" runat="server" Font-Bold="true" Font-Size="Large" />
        <hr />
        <asp:Repeater ID="rptResults" runat="server">
            <ItemTemplate>
                <div style="margin-bottom:15px;">
                    <p><b>Q: <%# Eval("QuestionText") %></b></p>
                    <p>Selected Answer: <%# Eval("SelectedAnswer") ?? "Not Answered" %></p>
                    <p>Status: <span style="color:<%# (bool)Eval("IsCorrect") ? "green" : "red" %>;">
                        <%# (bool)Eval("IsCorrect") ? "Correct" : "Incorrect" %>
                    </span></p>
                </div>
                <hr />
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
</asp:Content>
