<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TakeAssessment.aspx.cs" Inherits="PythonAcademy.TakeAssessment" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Take Assessment
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        body { font-family: 'Outfit', sans-serif; }

        .error-alert {
            display: flex; align-items: center; gap: 10px;
            background: rgba(255,71,87,.12); border: 1px solid rgba(255,71,87,.4);
            border-radius: 12px; padding: 14px 18px;
            color: #ff4757; font-size: .92rem; margin-bottom: 20px;
        }

        .quiz-header { display: flex; align-items: center; gap: 16px; margin-bottom: 30px; flex-wrap: wrap; }
        .quiz-icon {
            width: 52px; height: 52px;
            background: linear-gradient(135deg, rgba(47,125,255,.3), rgba(0,194,255,.2));
            border: 1px solid rgba(47,125,255,.35);
            border-radius: 14px; display: flex; align-items: center;
            justify-content: center; font-size: 1.1rem; font-weight: 700;
        }
        .quiz-header h2 { margin: 0; font-size: 1.7rem; font-weight: 900; color: #e7eefc; }

        .quiz-progress { display: flex; align-items: center; gap: 10px; margin-bottom: 28px; }
        .qprog-track { flex: 1; height: 4px; background: rgba(255,255,255,.1); border-radius: 999px; overflow: hidden; }
        .qprog-fill { height: 100%; background: linear-gradient(90deg, #2f7dff, #00c2ff); border-radius: 999px; transition: width .6s ease; width: 0; }
        .qprog-label { font-size: .8rem; color: #a9b8d6; white-space: nowrap; }

        .question-list { display: flex; flex-direction: column; gap: 20px; margin-bottom: 32px; }
        .question-card {
            background: rgba(16,31,58,.7);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 16px; padding: 22px;
            animation: fadeUp .45s ease both;
            transition: border-color .2s;
        }
        .question-card:focus-within { border-color: rgba(47,125,255,.45); }
        .q-number { font-family: 'JetBrains Mono', monospace; font-size: .75rem; color: #2f7dff; font-weight: 600; margin-bottom: 8px; }
        .q-text { font-size: 1rem; font-weight: 600; color: #e7eefc; line-height: 1.5; margin-bottom: 18px; }

        .styled-rbl table { border-collapse: separate; border-spacing: 0 8px; width: 100%; }
        .styled-rbl td { padding: 0; }
        .styled-rbl label {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 16px; border: 1px solid rgba(255,255,255,.1);
            border-radius: 10px; cursor: pointer; color: #a9b8d6;
            font-size: .92rem; transition: background .2s, border-color .2s;
            width: 100%;
        }
        .styled-rbl label:hover { background: rgba(47,125,255,.1); border-color: rgba(47,125,255,.35); }
        .styled-rbl input[type="radio"] { accent-color: #2f7dff; width: 16px; height: 16px; flex-shrink: 0; }

        .submit-row { display: flex; justify-content: flex-end; margin-top: 8px; }
        .btn-submit-quiz {
            display: inline-flex; align-items: center; gap: 10px;
            padding: 14px 32px; border-radius: 14px;
            font-size: 1rem; font-weight: 700; cursor: pointer; border: none;
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            color: #fff; transition: opacity .2s, transform .2s;
            font-family: 'Outfit', sans-serif;
        }
        .btn-submit-quiz:hover { opacity: .88; transform: scale(1.02); }

        @keyframes fadeUp { from { opacity:0; transform: translateY(14px); } to { opacity:1; transform: none; } }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="error-alert">Warning: <asp:Label ID="lblError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlQuiz" runat="server" Visible="true">
        <div class="quiz-header">
            <div class="quiz-icon">QUIZ</div>
            <h2><asp:Label ID="lblQuizTitle" runat="server" /></h2>
        </div>

        <div class="quiz-progress">
            <div class="qprog-track"><div class="qprog-fill" id="qFill"></div></div>
            <span class="qprog-label" id="qLabel">0 answered</span>
        </div>

        <div class="question-list">
            <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                <ItemTemplate>
                    <div class="question-card" style='animation-delay: <%# Container.ItemIndex * 80 %>ms'>
                        <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("QuestionId") %>' />
                        <div class="q-number">QUESTION <%# Container.ItemIndex + 1 %></div>
                        <div class="q-text"><%#: Eval("QuestionText") %></div>
                        <asp:RadioButtonList ID="rblOptions" runat="server"
                            RepeatDirection="Vertical"
                            CssClass="styled-rbl" />
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="submit-row">
            <asp:Button ID="btnSubmit" runat="server"
                Text="Submit Assessment"
                OnClick="btnSubmit_Click"
                CssClass="btn-submit-quiz" />
        </div>
    </asp:Panel>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var fill = document.getElementById('qFill');
            var label = document.getElementById('qLabel');
            var cards = document.querySelectorAll('.question-card');
            var radios = document.querySelectorAll('.styled-rbl input[type="radio"]');
            var total = cards.length;

            label.textContent = '0 / ' + total + ' answered';
            if (total === 0) {
                fill.style.width = '0%';
                return;
            }

            radios.forEach(function (r) {
                r.addEventListener('change', function () {
                    var answered = 0;
                    cards.forEach(function (card) {
                        if (card.querySelector('input[type="radio"]:checked')) {
                            answered++;
                        }
                    });
                    fill.style.width = (answered / total * 100) + '%';
                    label.textContent = answered + ' / ' + total + ' answered';
                });
            });
        });
    </script>
</asp:Content>
