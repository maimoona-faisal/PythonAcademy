<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubmitExercise.aspx.cs" Inherits="PythonAcademy.SubmitExercise" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Submit Exercise
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="submit-exercise-container">

        <h2>Exercise Submission</h2>

        <h2>Assessment: <asp:Label ID="lblAssessmentTitle" runat="server" Font-Bold="true"></asp:Label></h2>

        <div class="module-title">
            <asp:Label ID="lblModuleTitle" runat="server" Font-Bold="true" Font-Size="Large"></asp:Label>
        </div>

        <asp:Label ID="lblMessage" runat="server" ForeColor="Red"></asp:Label>

        <asp:Repeater ID="rptQuestions" runat="server">
            <ItemTemplate>
                <div class="question-item">
                    <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("QuestionId") %>' />
                    <p><b>Q<%# Container.ItemIndex + 1 %>: <%# Eval("QuestionText") %></b></p>
                    <asp:TextBox ID="txtAnswer" runat="server" TextMode="MultiLine" Rows="4" Columns="80" CssClass="answer-box"></asp:TextBox>
                </div>
                <hr />
            </ItemTemplate>
        </asp:Repeater>

        <div class="submit-btn-wrapper">
            <asp:Button ID="btnSubmit" runat="server" Text="Submit Answers" CssClass="btn btn-primary" OnClick="btnSubmit_Click" />
        </div>
    </div>

    <style>
        .submit-exercise-container { margin: 20px 0; }
        .module-title { margin-bottom: 20px; font-size: 1.5rem; }
        .question-item { margin-bottom: 25px; }
        .answer-box { margin-top: 8px; }
        .submit-btn-wrapper { margin-top: 15px; }
    </style>

</asp:Content>
