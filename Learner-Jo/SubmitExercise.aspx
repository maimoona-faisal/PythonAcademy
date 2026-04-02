<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubmitExercise.aspx.cs" Inherits="PythonAcademy.SubmitExercise" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Submit Exercise
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    <style>
        body { font-family: 'Outfit', sans-serif; }

        .ex-header { margin-bottom: 32px; padding-bottom: 24px; border-bottom: 1px solid rgba(255,255,255,.1); }
        .ex-header .breadcrumb { font-size: .82rem; color: #a9b8d6; margin-bottom: 10px; display: flex; align-items: center; gap: 6px; }
        .ex-header .breadcrumb span { color: #2f7dff; font-weight: 600; }
        .ex-header h2 { margin: 0 0 6px; font-size: 1.75rem; font-weight: 900; color: #e7eefc; }
        .ex-header .meta { font-size: 1rem; color: #a9b8d6; }
        .ex-header .meta strong { color: #e7eefc; }

        .msg-alert {
            display: flex; align-items: flex-start; gap: 10px;
            border-radius: 12px; padding: 14px 18px;
            font-size: .9rem; margin-bottom: 24px;
        }
        .msg-alert.error { background: rgba(255,71,87,.12); border: 1px solid rgba(255,71,87,.4); color: #ff4757; }
        .msg-alert.success { background: rgba(0,230,118,.1); border: 1px solid rgba(0,230,118,.35); color: #00e676; }

        .question-list { display: flex; flex-direction: column; gap: 28px; }
        .question-card {
            background: rgba(16,31,58,.7);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 18px; overflow: hidden;
            animation: fadeUp .45s ease both;
            transition: border-color .2s;
        }
        .question-card:focus-within { border-color: rgba(47,125,255,.4); }

        .q-header { padding: 18px 22px; border-bottom: 1px solid rgba(255,255,255,.08); display: flex; gap: 14px; align-items: flex-start; }
        .q-num-pill {
            background: rgba(47,125,255,.2); border: 1px solid rgba(47,125,255,.4);
            color: #6fb0ff; font-family: 'JetBrains Mono', monospace;
            font-size: .75rem; font-weight: 600;
            padding: 4px 10px; border-radius: 999px; flex-shrink: 0; margin-top: 2px;
        }
        .q-text { font-size: 1rem; font-weight: 600; color: #e7eefc; line-height: 1.5; }

        .code-editor-wrap { position: relative; }
        .editor-bar {
            display: flex; align-items: center; gap: 8px;
            padding: 10px 18px; background: rgba(0,0,0,.3);
            border-bottom: 1px solid rgba(255,255,255,.07);
        }
        .editor-bar .dot { width: 11px; height: 11px; border-radius: 50%; }
        .dot-red { background: #ff5f57; }
        .dot-yellow { background: #febc2e; }
        .dot-green { background: #28c840; }
        .editor-bar .lang-tag { margin-left: auto; font-family: 'JetBrains Mono', monospace; font-size: .72rem; color: #a9b8d6; }
        .code-textarea {
            width: 100%; background: rgba(7,13,24,.65); border: none;
            color: #e7eefc; font-family: 'JetBrains Mono', monospace;
            font-size: .9rem; line-height: 1.75; padding: 18px 22px;
            resize: vertical; outline: none; min-height: 160px; transition: background .2s;
        }
        .code-textarea:focus { background: rgba(7,13,24,.85); }
        .code-textarea::placeholder { color: rgba(169,184,214,.4); }
        .char-count { padding: 8px 18px; font-family: 'JetBrains Mono', monospace; font-size: .72rem; color: #a9b8d6; text-align: right; background: rgba(0,0,0,.2); }

        .submit-row { display: flex; justify-content: flex-end; align-items: center; gap: 16px; margin-top: 32px; flex-wrap: wrap; }
        .hint-text { font-size: .82rem; color: #a9b8d6; }
        .btn-submit-ex {
            display: inline-flex; align-items: center; gap: 10px;
            padding: 14px 32px; border-radius: 14px;
            font-size: 1rem; font-weight: 700; cursor: pointer; border: none;
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            color: #fff; transition: opacity .2s, transform .2s;
            font-family: 'Outfit', sans-serif;
        }
        .btn-submit-ex:hover { opacity: .88; transform: scale(1.02); }

        @keyframes fadeUp { from { opacity:0; transform: translateY(14px); } to { opacity:1; transform: none; } }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="ex-header">
        <div class="breadcrumb">Dashboard / My Courses / <span>Exercise Submission</span></div>
        <h2>Exercise Submission</h2>
        <div class="meta">
            Assessment: <strong><asp:Label ID="lblAssessmentTitle" runat="server" /></strong>
            &nbsp;|&nbsp;
            Module: <strong><asp:Label ID="lblModuleTitle" runat="server" /></strong>
        </div>
    </div>

    <asp:Panel ID="pnlMsg" runat="server" Visible="false">
        <div class="msg-alert" id="msgBox" runat="server">
            <asp:Label ID="lblMessage" runat="server" />
        </div>
    </asp:Panel>

    <div class="question-list">
        <asp:Repeater ID="rptQuestions" runat="server">
            <ItemTemplate>
                <div class="question-card" style='animation-delay: <%# Container.ItemIndex * 90 %>ms'>
                    <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("QuestionId") %>' />

                    <div class="q-header">
                        <span class="q-num-pill">Q<%# Container.ItemIndex + 1 %></span>
                        <div class="q-text"><%#: Eval("QuestionText") %></div>
                    </div>

                    <div class="code-editor-wrap">
                        <div class="editor-bar">
                            <div class="dot dot-red"></div>
                            <div class="dot dot-yellow"></div>
                            <div class="dot dot-green"></div>
                            <span class="lang-tag">python</span>
                        </div>
                        <asp:TextBox ID="txtAnswer" runat="server"
                            TextMode="MultiLine" Rows="8"
                            CssClass="code-textarea"
                            placeholder="# Write your Python answer here..."
                            oninput="updateCount(this)" />
                        <div class="char-count">0 chars</div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <div class="submit-row">
        <span class="hint-text">Review your answers before submitting.</span>
        <asp:Button ID="btnSubmit" runat="server"
            Text="Submit Exercise"
            CssClass="btn-submit-ex"
            OnClick="btnSubmit_Click" />
    </div>

    <script>
        function updateCount(textarea) {
            var counter = textarea.closest('.code-editor-wrap').querySelector('.char-count');
            if (counter) {
                counter.textContent = textarea.value.length + ' chars';
            }
        }

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Tab' && document.activeElement.classList.contains('code-textarea')) {
                e.preventDefault();
                var ta = document.activeElement;
                var s = ta.selectionStart;
                ta.value = ta.value.substring(0, s) + '    ' + ta.value.substring(ta.selectionEnd);
                ta.selectionStart = ta.selectionEnd = s + 4;
            }
        });
    </script>
</asp:Content>
