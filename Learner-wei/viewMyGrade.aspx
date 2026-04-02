<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="viewMyGrade.aspx.cs" Inherits="PythonAcademy.Learner_wei.viewMyGrade" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Grade Report
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .report-card { background: rgba(13, 25, 48, 0.85); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px; padding: 30px; max-width: 800px; margin: 0 auto; }
        .q-box { border-bottom: 1px solid rgba(255,255,255,0.1); padding: 20px 0; }
        .q-box:last-child { border-bottom: none; }
        .q-title { font-size: 1.1rem; color: #e7eefc; font-weight: bold; margin-bottom: 10px; }
        .q-answer { color: #a9b8d6; font-size: 0.95rem; background: rgba(0,0,0,0.2); padding: 12px; border-radius: 8px; margin-bottom: 10px; }
        .q-score { font-weight: bold; font-size: 0.9rem; }
        .score-good { color: #00e676; }
        .score-bad { color: #ff4757; }
        .btn-back { display: inline-block; margin-bottom: 20px; color: #00c2ff; text-decoration: none; font-weight: bold; }
        .btn-back:hover { text-decoration: underline; }
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div style="max-width: 800px; margin: 0 auto;">
        <a href="javascript:history.back()" class="btn-back">← Back to Course</a>
        
        <div class="report-card">
            <h2 style="color: #00f3ff; margin-top: 0;">Assessment Results</h2>
            <p style="color: #a9b8d6; font-size: 1.1rem; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 20px;">
                Total Score: <asp:Label ID="lblTotalScore" runat="server" Font-Bold="true" ForeColor="White" />
            </p>

            <asp:Repeater ID="rptAnswers" runat="server">
                <ItemTemplate>
                    <div class="q-box">
                        <div class="q-title">Q: <%# Eval("QuestionText") %></div>
                        
                        <div class="q-answer">
                            <strong>Your Answer:</strong><br />
                            <%# string.IsNullOrEmpty(Eval("OptionText").ToString()) ? Eval("AnswerText") : Eval("OptionText") %>
                        </div>
                        
                        <div class="q-score <%# Convert.ToInt32(Eval("MarksAwarded")) == Convert.ToInt32(Eval("MaxMarks")) ? "score-good" : "score-bad" %>">
                            Marks Awarded: <%# Eval("MarksAwarded") %> / <%# Eval("MaxMarks") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Content>
