<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs"
    Inherits="PythonAcademy.MemberDashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Student Dashboard
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --green: #00e676;
            --yellow: #ffd740;
            --red: #ff4757;
            --purple: #bc13fe;
        }

        body { font-family: 'Outfit', sans-serif; }

        .dash-header {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 28px;
        }

        .dash-header h2 {
            margin: 0;
            font-size: 1.9rem;
            font-weight: 900;
            background: linear-gradient(90deg, #fff 40%, #2f7dff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .dash-header p { margin: 4px 0 0; color: #a9b8d6; font-size: .95rem; }


        .announce-stack-wrapper { margin-bottom: 32px; cursor: pointer; position: relative; }

        .announce-stack {
            position: relative;

            min-height: 100px;
            transition: min-height .45s cubic-bezier(.4,0,.2,1);
        }

        .announce-stack .announce-card {
 
            background: #0f1626; 
    
            border: 1px solid rgba(188, 19, 254, .35);
            border-left: 4px solid var(--purple);
            border-radius: 14px;
            padding: 16px 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            position: relative;
            transition: transform .4s cubic-bezier(.4,0,.2,1),
                        opacity .35s ease,
                        box-shadow .35s ease,
                        margin-bottom .4s cubic-bezier(.4,0,.2,1);
            box-shadow: 0 2px 12px rgba(0,0,0,.25);
            z-index: 1;
            margin-bottom: 0;
        }

        .announce-stack:not(.expanded) .announce-card { position: absolute; left: 0; right: 0; top: 0; }
        .announce-stack:not(.expanded) .announce-card:nth-child(1) { z-index: 5; transform: translateY(0) scale(1);     opacity: 1; }
        .announce-stack:not(.expanded) .announce-card:nth-child(2) { z-index: 4; transform: translateY(10px) scale(.97); opacity: .72; }
        .announce-stack:not(.expanded) .announce-card:nth-child(3) { z-index: 3; transform: translateY(20px) scale(.94); opacity: .48; }
        .announce-stack:not(.expanded) .announce-card:nth-child(n+4) { z-index: 2; transform: translateY(26px) scale(.91); opacity: 0; pointer-events: none; }

        .announce-stack.expanded .announce-card {
            position: relative;
            transform: none;
            opacity: 1;
            margin-bottom: 14px;
            animation: stackFanOut .35s ease both;
        }
        .announce-stack.expanded .announce-card:nth-child(1) { animation-delay: 0s; }
        .announce-stack.expanded .announce-card:nth-child(2) { animation-delay: .04s; }
        .announce-stack.expanded .announce-card:nth-child(3) { animation-delay: .08s; }
        .announce-stack.expanded .announce-card:nth-child(4) { animation-delay: .12s; }
        .announce-stack.expanded .announce-card:nth-child(5) { animation-delay: .16s; }

        @keyframes stackFanOut {
            from { opacity: 0; transform: translateY(-8px) scale(.97); }
            to   { opacity: 1; transform: none; }
        }

        .announce-card .a-top { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .announce-card .a-title { font-weight: 700; font-size: 1rem; color: var(--purple); }
        .announce-card .a-date { font-size: .78rem; color: #a9b8d6; }
        .announce-card .a-body { font-size: .92rem; color: #e7eefc; line-height: 1.55; margin: 0; }

        .stack-hint {
            text-align: center; padding: 10px 0 0;
            font-size: .82rem; font-weight: 600; color: var(--purple);
            transition: opacity .3s;
        }
        .announce-stack.expanded + .stack-hint { opacity: .5; }
        .stack-hint .hint-icon {
            display: inline-block;
            transition: transform .3s;
        }
        .announce-stack.expanded ~ .stack-hint .hint-icon { transform: rotate(180deg); }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .course-card {
            background: rgba(16, 31, 58, .7);
            border: 1px solid rgba(255, 255, 255, .1);
            border-radius: 16px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            transition: transform .2s, border-color .2s, box-shadow .2s;
            animation: fadeUp .5s ease both;
        }

        .course-card:hover {
            transform: translateY(-4px);
            border-color: rgba(47, 125, 255, .5);
            box-shadow: 0 12px 30px rgba(0, 0, 0, .4);
        }

        .c-id { font-family: 'JetBrains Mono', monospace; font-size: .75rem; color: #a9b8d6; }
        .c-title { font-size: 1.1rem; font-weight: 700; color: #e7eefc; line-height: 1.3; }
        .c-desc { font-size: .88rem; color: #a9b8d6; line-height: 1.5; flex: 1; }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: .78rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 999px;
            width: fit-content;
        }

        .status-badge::before {
            content: '';
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: currentColor;
        }

        .status-not-started { color: #a9b8d6; background: rgba(169, 184, 214, .12); }
        .status-not-enrolled { color: #a9b8d6; background: rgba(169, 184, 214, .12); }
        .status-in-progress { color: var(--yellow); background: rgba(255, 215, 64, .1); }
        .status-completed { color: var(--green); background: rgba(0, 230, 118, .1); }

        .prog-wrap { display: flex; flex-direction: column; gap: 6px; }
        .prog-label { display: flex; justify-content: space-between; font-size: .78rem; color: #a9b8d6; }

        .prog-track {
            height: 6px;
            background: rgba(255, 255, 255, .1);
            border-radius: 999px;
            overflow: hidden;
        }

        .prog-fill {
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, #2f7dff, #00c2ff);
            width: 0;
            transition: width 1s cubic-bezier(.4, 0, .2, 1);
        }

        .c-actions { display: flex; gap: 10px; flex-wrap: wrap; }

        .btn-view {
            flex: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 9px 14px;
            border-radius: 10px;
            font-size: .88rem;
            font-weight: 700;
            font-family: 'Outfit', sans-serif;
            cursor: pointer;
            border: 1px solid rgba(47, 125, 255, .5);
            background: rgba(47, 125, 255, .15);
            color: #6fb0ff;
            transition: all .2s;
        }

        .btn-view:hover { background: rgba(47, 125, 255, .3); border-color: #2f7dff; color: #fff; }

        .btn-quiz {
            flex: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 9px 14px;
            border-radius: 10px;
            font-size: .88rem;
            font-weight: 700;
            font-family: 'Outfit', sans-serif;
            cursor: pointer;
            border: 1px solid rgba(0, 230, 118, .4);
            background: rgba(0, 230, 118, .1);
            color: var(--green);
            transition: all .2s;
        }

        .btn-quiz:hover { background: rgba(0, 230, 118, .2); border-color: var(--green); color: #fff; }

        .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            color: #a9b8d6;
        }

        .empty-state svg { opacity: .3; display: block; margin: 0 auto 16px; }
        .empty-state p { font-size: 1rem; margin-top: 0; }
        .empty-state a { color: #2f7dff; }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(-12px); }
            to { opacity: 1; transform: none; }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to { opacity: 1; transform: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="announce-stack-wrapper" onclick="toggleAnnouncementStack()">
        <div id="announceStack" class="announce-stack">
            <asp:Repeater ID="rptAnnouncements" runat="server">
                <ItemTemplate>
                    <div class="announce-card">
                        <div class="a-top">
                            <span class="a-title">Announcement: <%#: Eval("Title") %></span>
                            <span class="a-date"><%#: FormatAnnouncementDate(Eval("CreatedAt")) %></span>
                        </div>
                        <p class="a-body"><%#: Eval("Message") %></p>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="stack-hint">
            <span class="hint-icon">&#9660;</span>
            <asp:Label ID="lblStackCount" runat="server" Text="" />
            &mdash; tap to expand
        </div>
    </div>

    <div class="dash-header">
        <div>
            <h2>My Learning Dashboard</h2>
            <p>Track your enrolled modules and progress below.</p>
        </div>
    </div>

    <div class="course-grid">
        <asp:Repeater ID="rptDashboard" runat="server" OnItemCommand="rptDashboard_ItemCommand">
            <ItemTemplate>
                <div class="course-card" style='animation-delay: <%# Container.ItemIndex * 80 %>ms'>
                    <div class="c-id">MODULE #<%#: Eval("ContentId") %></div>
                    <div class="c-title"><%#: Eval("Title") %></div>
                    <div class="c-desc"><%#: Eval("Description") %></div>

                    <asp:Label runat="server"
                        CssClass='<%# "status-badge " + GetStatusClass(Eval("ProgressStatus")) %>'
                        Text='<%# Convert.ToString(Eval("ProgressStatus")) %>' />

                    <div class="prog-wrap">
                        <div class="prog-label">
                            <span>Progress</span>
                            <span><%# GetProgressPercentage(Eval("ProgressPercentage")) %>%</span>
                        </div>
                        <div class="prog-track">
                            <div class="prog-fill" data-progress='<%# GetProgressPercentage(Eval("ProgressPercentage")) %>'></div>
                        </div>
                    </div>

                    <div class="c-actions">
                        <asp:Button runat="server"
                            Text="View Module"
                            CssClass="btn-view"
                            CommandName="ViewModule"
                            CommandArgument='<%# Eval("ContentId") %>'
                            CausesValidation="false"
                            UseSubmitBehavior="false" />

                        <asp:Button runat="server"
                            Text="Take Quiz"
                            CssClass="btn-quiz"
                            CommandName="TakeQuiz"
                            CommandArgument='<%# Eval("ContentId") %>'
                            CausesValidation="false"
                            UseSubmitBehavior="false" />
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="#a9b8d6" stroke-width="1.5">
                    <path d="M12 2L2 7l10 5 10-5-10-5z" />
                    <path d="M2 17l10 5 10-5" />
                    <path d="M2 12l10 5 10-5" />
                </svg>
                <p>No modules available yet. Browse <a href="LearningMaterials.aspx">Learning Materials</a> to get started.</p>
            </div>
        </asp:Panel>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            document.querySelectorAll(".prog-fill[data-progress]").forEach(function (el) {
                var p = Math.max(0, Math.min(100, parseFloat(el.dataset.progress) || 0));
                requestAnimationFrame(function () { el.style.width = p + "%"; });
            });
        });

        function toggleAnnouncementStack() {
            var stack = document.getElementById('announceStack');
            if (!stack) return;
            stack.classList.toggle('expanded');
        }
    </script>
</asp:Content>
