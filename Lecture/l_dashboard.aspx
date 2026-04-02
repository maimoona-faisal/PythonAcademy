<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="l_dashboard.aspx.cs"
    Inherits="PythonAcademy.Lecture.l_dashboard" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    </asp:Content>
    <asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    </asp:Content>
    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <h2 style="margin:0 0 6px 0;">Lecturer Dashboard</h2>
        <p class="muted" style="margin:0 0 18px 0;">
            Manage your content, assessments, grading, and profile from here.
        </p>

         <div class="announce-stack-wrapper" onclick="toggleAnnouncementStack()">
     <div id="announceStack" class="announce-stack">
         <asp:Repeater ID="rptAnnouncements" runat="server">
             <ItemTemplate>
                 <div class="announce-card">
                     <div class="a-top">
                         <span class="a-title">Announcement: <%#: Eval("Title") %></span>
                         <span class="a-date"><%#: Eval("CreatedAt", "{0:MMM dd, yyyy}") %></span>
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

        <div class="dash-grid">
            <a runat="server" class="dash-card" href="~/Lecture/UploadContent.aspx">
                <div class="dash-title">Upload Learning Content</div>
                <div class="dash-desc">Add PDFs, videos, images, or links for students.</div>
                <div class="dash-cta">Open &rarr;</div>
            </a>

            <a runat="server" class="dash-card" href="~/Lecture/CreateAssessment.aspx">
                <div class="dash-title">Create Assessment</div>
                <div class="dash-desc">Build assessments and publish them when ready.</div>
                <div class="dash-cta">Open &rarr;</div>
            </a>

            <a runat="server" class="dash-card" href="~/Lecture/grade.aspx">
                <div class="dash-title">Grade Learners</div>
                <div class="dash-desc">Review submissions and assign marks.</div>
                <div class="dash-cta">Open &rarr;</div>
            </a>

            <a runat="server" class="dash-card" href="~/Lecture/viewFeedback.aspx">
                <div class="dash-title">Check Feedback</div>
                <div class="dash-desc">View comments and suggestions from students.</div>
                <div class="dash-cta">Open &rarr;</div>
            </a>

            <a runat="server" class="dash-card" href="~/Lecture/editProfile.aspx">
                <div class="dash-title">Edit Profile</div>
                <div class="dash-desc">Update your lecturer information and details.</div>
                <div class="dash-cta">Open &rarr;</div>
            </a>
        </div>

        <style>
           /* ── iOS Stacked Announcements ── */
.announce-stack-wrapper { margin-bottom: 32px; cursor: pointer; position: relative; }

.announce-stack {
    position: relative;
    /* collapsed height = one card height + peek room */
    min-height: 100px;
    transition: min-height .45s cubic-bezier(.4,0,.2,1);
}

.announce-stack .announce-card {
    background: #0f1626;
    border: 1px solid rgba(0, 194, 255, 0.35); /* Neon Blue Border */
    border-left: 4px solid #00c2ff; /* Neon Blue Accent */
    border-radius: 14px;
    padding: 16px 20px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    position: relative;
    transition: transform .4s cubic-bezier(.4,0,.2,1),
                opacity .35s ease, box-shadow .35s ease, margin-bottom .4s cubic-bezier(.4,0,.2,1);
    box-shadow: 0 2px 12px rgba(0,0,0,.25);
    z-index: 1;
    margin-bottom: 0;
}

.announce-card .a-title { font-weight: 700; font-size: 1rem; color: #00c2ff; } /* Neon Blue Text */
.stack-hint {
    text-align: center; padding: 10px 0 0;
    font-size: .82rem; font-weight: 600;
    color: #00c2ff; /* Neon Blue Text */
    transition: opacity .3s;
}

/* ── Collapsed: stack the cards behind each other ── */
.announce-stack:not(.expanded) .announce-card { position: absolute; left: 0; right: 0; top: 0; }
.announce-stack:not(.expanded) .announce-card:nth-child(1) { z-index: 5; transform: translateY(0) scale(1);     opacity: 1; }
.announce-stack:not(.expanded) .announce-card:nth-child(2) { z-index: 4; transform: translateY(10px) scale(.97); opacity: .72; }
.announce-stack:not(.expanded) .announce-card:nth-child(3) { z-index: 3; transform: translateY(20px) scale(.94); opacity: .48; }
.announce-stack:not(.expanded) .announce-card:nth-child(n+4) { z-index: 2; transform: translateY(26px) scale(.91); opacity: 0; pointer-events: none; }

/* ── Expanded: fan out with spacing ── */
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

/* Stack hint badge */
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

            /* Existing Dashboard Grid Styles */
            .dash-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 12px;
                margin-top: 12px;
            }

            .dash-grid a:last-child {
                grid-column: 1 / -1;
            }

            .dash-card {
                display: block;
                padding: 16px;
                border-radius: 16px;
                text-decoration: none;
                border: 1px solid rgba(255, 255, 255, .12);
                background: rgba(255, 255, 255, .05);
                transition: transform .15s ease, background .15s ease, border-color .15s ease;
            }

            .dash-card:hover {
                transform: translateY(-2px);
                background: rgba(255, 255, 255, .07);
                border-color: rgba(255, 255, 255, .20);
            }

            .dash-title {
                font-weight: 900;
                font-size: 1.05rem;
                margin-bottom: 6px;
            }

            .dash-desc {
                color: rgba(255, 255, 255, .72);
                line-height: 1.35;
                margin-bottom: 14px;
            }

            .dash-cta {
                font-weight: 800;
                color: rgba(0, 194, 255, .95);
            }

            /* Mobile */
            @media (max-width: 720px) {
                .dash-grid {
                    grid-template-columns: 1fr;
                }

                .dash-grid a:last-child {
                    grid-column: auto;
                }
            }
        </style>
          <script>

              // ── iOS-style Announcement Stack Toggle ──
              function toggleAnnouncementStack() {
                  var stack = document.getElementById('announceStack');
                  if (!stack) return;
                  stack.classList.toggle('expanded');
              }
          </script>
    </asp:Content>