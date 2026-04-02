<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewResults.aspx.cs" Inherits="PythonAcademy.ViewResults" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Assessment Results
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        body { font-family: 'Outfit', sans-serif; }

        .error-alert {
            display: flex; align-items: center; gap: 10px;
            background: rgba(255,71,87,.12); border: 1px solid rgba(255,71,87,.4);
            border-radius: 12px; padding: 14px 18px;
            color: #ff4757; font-size: .92rem; margin-bottom: 24px;
        }

        .score-hero {
            text-align: center; padding: 36px 20px 32px; margin-bottom: 32px;
            position: relative;
        }
        .score-hero::after {
            content: ''; position: absolute;
            bottom: 0; left: 10%; right: 10%;
            height: 1px; background: rgba(255,255,255,.1);
        }
        .score-ring { width: 140px; height: 140px; margin: 0 auto 20px; position: relative; }
        .score-ring svg { transform: rotate(-90deg); }
        .srb { fill: none; stroke: rgba(255,255,255,.1); stroke-width: 9; }
        .srf {
            fill: none; stroke: url(#sg); stroke-width: 9;
            stroke-linecap: round; stroke-dasharray: 283; stroke-dashoffset: 283;
            transition: stroke-dashoffset 1.6s cubic-bezier(.4,0,.2,1);
        }
        .ring-center { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px; }
        .ring-pct { font-size: 2rem; font-weight: 900; color: #e7eefc; line-height: 1; }
        .ring-word { font-size: .72rem; color: #a9b8d6; font-family: 'JetBrains Mono', monospace; }

        .score-hero h2 { margin: 0 0 6px; font-size: 1.6rem; font-weight: 900; color: #e7eefc; }
        .score-hero .sub { margin: 0 0 24px; color: #a9b8d6; font-size: .95rem; }

        .score-chips { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
        .chip { display: flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 999px; font-size: .85rem; font-weight: 600; }
        .chip-score { background: rgba(47,125,255,.15); border: 1px solid rgba(47,125,255,.4); color: #6fb0ff; }
        .chip-correct { background: rgba(0,230,118,.1); border: 1px solid rgba(0,230,118,.35); color: #00e676; }
        .chip-wrong { background: rgba(255,71,87,.1); border: 1px solid rgba(255,71,87,.35); color: #ff4757; }

        .section-title { font-size: 1.05rem; font-weight: 700; color: #e7eefc; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
        .section-title::after { content: ''; flex: 1; height: 1px; background: rgba(255,255,255,.1); }

        .result-list { display: flex; flex-direction: column; gap: 14px; margin-bottom: 32px; }
        .result-card {
            background: rgba(16,31,58,.7);
            border: 1px solid rgba(255,255,255,.09);
            border-radius: 14px; border-left: 4px solid transparent;
            padding: 18px 22px; display: flex; flex-direction: column; gap: 8px;
            animation: fadeUp .4s ease both;
        }
        .result-card.correct { border-left-color: #00e676; }
        .result-card.incorrect { border-left-color: #ff4757; }

        .rc-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 14px; flex-wrap: wrap; }
        .rc-q { font-weight: 700; color: #e7eefc; font-size: .97rem; line-height: 1.45; flex: 1; }
        .rc-badge { font-size: .78rem; font-weight: 700; padding: 4px 10px; border-radius: 999px; flex-shrink: 0; }
        .rc-badge.correct { background: rgba(0,230,118,.15); color: #00e676; }
        .rc-badge.incorrect { background: rgba(255,71,87,.15); color: #ff4757; }
        .rc-answer { font-size: .87rem; color: #a9b8d6; }
        .rc-answer strong { color: #e7eefc; font-weight: 600; }

        .back-row { display: flex; justify-content: flex-start; }
        .btn-back {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px; border-radius: 12px;
            font-size: .95rem; font-weight: 700; cursor: pointer;
            border: 1px solid rgba(255,255,255,.15);
            background: rgba(255,255,255,.06); color: #e7eefc;
            transition: all .2s; font-family: 'Outfit', sans-serif;
        }
        .btn-back:hover { background: rgba(255,255,255,.1); border-color: rgba(255,255,255,.25); }

        @keyframes fadeUp { from { opacity:0; transform: translateY(14px); } to { opacity:1; transform: none; } }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="error-alert">Warning: <asp:Label ID="lblError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlResults" runat="server" Visible="false">
        <svg width="0" height="0" style="position:absolute">
            <defs>
                <linearGradient id="sg" x1="0%" y1="0%" x2="100%" y2="0%">
                    <stop offset="0%" stop-color="#2f7dff" />
                    <stop offset="100%" stop-color="#00c2ff" />
                </linearGradient>
            </defs>
        </svg>

        <div class="score-hero">
            <div class="score-ring">
                <svg viewBox="0 0 100 100" width="140" height="140">
                    <circle class="srb" cx="50" cy="50" r="45" />
                    <circle class="srf" cx="50" cy="50" r="45" id="srf" />
                </svg>
                <div class="ring-center">
                    <span class="ring-pct" id="ringPct">0%</span>
                    <span class="ring-word">SCORE</span>
                </div>
            </div>

            <h2><asp:Label ID="lblAssessmentTitle" runat="server" /></h2>
            <p class="sub"><asp:Label ID="lblTotalScore" runat="server" /></p>
            <div class="score-chips" id="scoreChips"></div>
        </div>

        <div class="section-title">Question Breakdown</div>

        <div class="result-list">
            <asp:Repeater ID="rptResults" runat="server">
                <ItemTemplate>
                    <div class='result-card <%# GetResultCardCss(Eval("IsCorrect")) %>'
                         style='animation-delay: <%# Container.ItemIndex * 60 %>ms'>

                        <div class="rc-top">
                            <div class="rc-q"><%#: Eval("QuestionText") %></div>
                            <span class='rc-badge <%# GetResultCardCss(Eval("IsCorrect")) %>'>
                                <%# GetResultBadgeText(Eval("IsCorrect")) %>
                            </span>
                        </div>

                        <div class="rc-answer">
                            Your answer: <strong><%#: FormatSubmittedAnswer(Eval("SelectedAnswer"), Eval("AnswerText")) %></strong>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="back-row">
            <asp:Button ID="btnBackDashboard" runat="server"
                Text="Back to Dashboard"
                CssClass="btn-back"
                OnClick="btnBackDashboard_Click"
                CausesValidation="false"
                UseSubmitBehavior="false" />
        </div>
    </asp:Panel>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var ring = document.getElementById('srf');
            var pctEl = document.getElementById('ringPct');
            var chips = document.getElementById('scoreChips');
            if (!ring || !pctEl || !chips) {
                return;
            }

            var label = document.querySelector('.sub');
            if (!label) {
                return;
            }

            var m = (label.textContent || '').match(/(\d+)\D+(\d+)/);
            if (!m) {
                return;
            }

            var got = parseInt(m[1], 10);
            var total = parseInt(m[2], 10);
            var pct = total > 0 ? Math.round(got / total * 100) : 0;
            var circ = 2 * Math.PI * 45;

            pctEl.textContent = pct + '%';
            ring.style.strokeDasharray = circ;
            ring.style.strokeDashoffset = circ;

            requestAnimationFrame(function () {
                ring.style.strokeDashoffset = circ * (1 - pct / 100);
            });

            chips.innerHTML =
                '<div class="chip chip-score">' + got + ' / ' + total + ' pts</div>' +
                '<div class="chip chip-correct">' + got + ' Correct</div>' +
                '<div class="chip chip-wrong">' + (total - got) + ' Incorrect</div>';
        });
    </script>
</asp:Content>
