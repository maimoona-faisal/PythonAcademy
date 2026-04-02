<%@ Page Title="Browse Courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="browseCourses.aspx.cs" Inherits="PythonAcademy.BrowseCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Browse Courses
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        /* ===================================================
           browsecourses.aspx — public catalogue page
           theme: dark navy, blue/cyan gradients, Outfit font,
           18px rounded cards, pill badges — matches site style
           =================================================== */

        body { font-family: 'Outfit', sans-serif; }

        /* ---- hero ---- */
        .bc-hero {
            text-align: center;
            padding: 60px 20px 40px;
        }
        .bc-hero-badge {
            display: inline-block;
            background: rgba(47,125,255,.15);
            border: 1px solid rgba(47,125,255,.35);
            color: #2f7dff;
            border-radius: 999px;
            padding: 6px 18px;
            font-size: .85rem;
            font-weight: 700;
            margin-bottom: 20px;
        }
        .bc-hero h1 {
            font-size: clamp(1.8rem, 5vw, 3.2rem);
            font-weight: 900;
            line-height: 1.15;
            margin: 0 0 16px;
            background: linear-gradient(135deg, #e7eefc 30%, #00c2ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .bc-hero p {
            font-size: 1.05rem;
            color: #a9b8d6;
            max-width: 520px;
            margin: 0 auto 28px;
            line-height: 1.65;
        }

        /* guest nudge */
        .guest-nudge {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: rgba(0,194,255,.08);
            border: 1px solid rgba(0,194,255,.22);
            border-radius: 999px;
            padding: 8px 20px;
            font-size: .875rem;
            color: #a9b8d6;
        }
        .guest-nudge a { color: #00c2ff; font-weight: 700; text-decoration: none; }
        .guest-nudge a:hover { text-decoration: underline; }
        .nudge-dot {
            width: 7px; height: 7px;
            border-radius: 50%;
            background: #00c2ff;
            animation: pulse 1.6s ease-in-out infinite;
        }
        @keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.4;transform:scale(.8)} }

        /* ---- stats row ---- */
        .bc-stats {
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap;
            padding: 8px 20px 40px;
        }
        .bc-stat { text-align: center; }
        .bc-stat strong {
            display: block;
            font-size: 2rem;
            font-weight: 900;
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .bc-stat span { color: #a9b8d6; font-size: .88rem; }

        /* ---- filter bar ---- */
        .bc-filter-bar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            padding: 0 20px 28px;
        }
        .bc-search-wrap {
            position: relative;
            flex: 1;
            min-width: 220px;
        }
        .bc-search-wrap svg {
            position: absolute;
            left: 12px; top: 50%;
            transform: translateY(-50%);
            color: #a9b8d6;
            pointer-events: none;
        }
        .bc-search-input {
            width: 100%;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.12);
            border-radius: 12px;
            color: #e7eefc;
            font-size: .9rem;
            padding: 10px 14px 10px 40px;
            outline: none;
            transition: border-color .2s;
            font-family: 'Outfit', sans-serif;
        }
        .bc-search-input:focus { border-color: #2f7dff; }
        .bc-search-input::placeholder { color: #a9b8d6; }

        /* difficulty pills */
        .diff-pills { display: flex; gap: 8px; flex-wrap: wrap; }
        .diff-pill {
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.12);
            border-radius: 999px;
            padding: 7px 18px;
            font-family: 'Outfit', sans-serif;
            font-size: .82rem;
            font-weight: 700;
            color: #a9b8d6;
            cursor: pointer;
            transition: all .2s;
        }
        .diff-pill:hover { border-color: rgba(47,125,255,.4); color: #e7eefc; }
        .diff-pill.active {
            background: rgba(47,125,255,.18);
            border-color: rgba(47,125,255,.5);
            color: #2f7dff;
        }

        .bc-count { font-size: .85rem; color: #a9b8d6; margin-left: auto; }
        .bc-count span { color: #2f7dff; font-weight: 700; }

        /* ---- course grid ---- */
        .bc-grid-section { padding: 0 20px 80px; }
        .bc-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
            gap: 22px;
        }

        /* ---- course card ---- */
        .bc-card {
            background: rgba(16,31,58,.65);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 18px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: transform .2s, border-color .2s, box-shadow .2s;
            animation: fadeUp .5s ease both;
            position: relative;
        }
        .bc-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, #2f7dff, #00c2ff);
            border-radius: 18px 18px 0 0;
            opacity: 0;
            transition: opacity .25s;
        }
        .bc-card:hover { transform: translateY(-5px); border-color: rgba(47,125,255,.4); box-shadow: 0 16px 40px rgba(0,0,0,.45); }
        .bc-card:hover::before { opacity: 1; }
        @keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:none} }

        /* thumbnail */
        .bc-thumb {
            height: 170px;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            position: relative;
        }
        .bc-thumb-placeholder {
            background: linear-gradient(135deg, rgba(47,125,255,.2), rgba(0,194,255,.12));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.6rem;
            font-weight: 900;
            color: rgba(255,255,255,.12);
        }
        .bc-thumb::after {
            content: '';
            position: absolute; inset: 0;
            background: linear-gradient(180deg, transparent 50%, rgba(10,20,40,.9) 100%);
        }

        /* lock badge */
        .bc-lock {
            position: absolute;
            top: 12px; right: 12px;
            background: rgba(7,13,24,.78);
            border: 1px solid rgba(255,255,255,.15);
            border-radius: 50%;
            width: 36px; height: 36px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; z-index: 2;
        }

        /* difficulty badge */
        .bc-diff {
            position: absolute;
            bottom: 10px; left: 12px;
            border-radius: 999px;
            padding: 3px 12px;
            font-size: .72rem;
            font-weight: 700;
            z-index: 2;
            text-transform: capitalize;
        }
        .bc-diff.beginner     { background: rgba(0,230,118,.15); border: 1px solid rgba(0,230,118,.3); color: #00e676; }
        .bc-diff.intermediate { background: rgba(255,215,64,.12); border: 1px solid rgba(255,215,64,.3); color: #ffd740; }
        .bc-diff.advanced     { background: rgba(188,19,254,.12); border: 1px solid rgba(188,19,254,.3); color: #bc13fe; }

        /* card body */
        .bc-card-body {
            padding: 18px 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .bc-cat-badge {
            display: inline-flex;
            align-items: center;
            background: rgba(0,194,255,.1);
            border: 1px solid rgba(0,194,255,.28);
            color: #00c2ff;
            border-radius: 999px;
            padding: 4px 14px;
            font-size: .74rem;
            font-weight: 700;
            width: fit-content;
            text-transform: uppercase;
            letter-spacing: .3px;
        }
        .bc-title { font-size: 1.05rem; font-weight: 800; color: #e7eefc; line-height: 1.35; }
        .bc-desc {
            font-size: .85rem;
            color: #a9b8d6;
            line-height: 1.55;
            flex: 1;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .bc-meta { display: flex; gap: 16px; font-size: .78rem; color: #a9b8d6; flex-wrap: wrap; }
        .bc-meta-item { display: flex; align-items: center; gap: 5px; }

        /* card footer */
        .bc-card-footer {
            padding: 14px 20px;
            border-top: 1px solid rgba(255,255,255,.07);
        }
        .btn-view-details {
            display: block;
            width: 100%;
            text-align: center;
            background: rgba(47,125,255,.12);
            border: 1px solid rgba(47,125,255,.3);
            color: #2f7dff;
            border-radius: 12px;
            padding: 10px;
            font-family: 'Outfit', sans-serif;
            font-size: .88rem;
            font-weight: 700;
            cursor: pointer;
            transition: background .2s;
        }
        .btn-view-details:hover { background: rgba(47,125,255,.22); }

        /* ---- empty state ---- */
        .bc-empty {
            grid-column: 1 / -1;
            text-align: center;
            padding: 70px 20px;
            color: #a9b8d6;
        }
        .bc-empty p { font-size: .95rem; margin-top: 14px; }

        /* ================================================================
           DETAIL MODAL
           ================================================================ */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,.65);
            backdrop-filter: blur(6px);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open { display: flex; }

        .detail-modal-box {
            background: #0f1829;
            border: 1px solid rgba(47,125,255,.25);
            border-radius: 24px;
            max-width: 540px;
            width: 92%;
            max-height: 88vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0,0,0,.6);
            position: relative;
            animation: popIn .25s ease;
        }
        @keyframes popIn { from{transform:scale(.93);opacity:0} to{transform:scale(1);opacity:1} }

        .modal-close {
            position: absolute; top: 14px; right: 18px;
            background: none; border: none;
            color: #a9b8d6; font-size: 1.4rem;
            cursor: pointer; z-index: 3;
            transition: color .2s;
        }
        .modal-close:hover { color: #ff6b6b; }

        .detail-thumb {
            height: 180px;
            border-radius: 24px 24px 0 0;
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            font-weight: 900;
            color: rgba(255,255,255,.15);
        }

        .detail-body { padding: 24px 28px 30px; }

        .detail-tag {
            display: inline-block;
            background: rgba(0,194,255,.12);
            border: 1px solid rgba(0,194,255,.3);
            color: #00c2ff;
            border-radius: 999px;
            padding: 4px 14px;
            font-size: .78rem;
            font-weight: 700;
            margin-bottom: 6px;
            margin-right: 6px;
        }
        .detail-tag.diff-beginner     { background: rgba(0,230,118,.12); border-color: rgba(0,230,118,.3); color: #00e676; }
        .detail-tag.diff-intermediate { background: rgba(255,215,64,.1);  border-color: rgba(255,215,64,.3);  color: #ffd740; }
        .detail-tag.diff-advanced     { background: rgba(188,19,254,.1);  border-color: rgba(188,19,254,.3);  color: #bc13fe; }

        .detail-body h3 {
            font-size: 1.4rem;
            font-weight: 900;
            margin: 10px 0 8px;
            color: #e7eefc;
            line-height: 1.3;
        }
        .detail-desc {
            font-size: .9rem;
            color: #a9b8d6;
            line-height: 1.65;
            margin-bottom: 18px;
        }

        /* meta strip in modal */
        .detail-meta-row {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-bottom: 20px;
            padding: 14px 18px;
            background: rgba(47,125,255,.07);
            border: 1px solid rgba(47,125,255,.15);
            border-radius: 12px;
        }
        .detail-meta-item { display: flex; align-items: center; gap: 7px; font-size: .84rem; color: #a9b8d6; }

        /* learn list */
        .learn-section-label {
            font-size: .8rem;
            font-weight: 700;
            color: #2f7dff;
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 10px;
        }
        .learn-list {
            list-style: none;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
            margin-bottom: 22px;
        }
        .learn-list li {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            font-size: .84rem;
            color: #a9b8d6;
            line-height: 1.5;
        }
        .learn-list li::before { 
            content: '\25B8'; 
            color: #2f7dff; 
            font-size: .8rem; 
            margin-top: 2px;
            flex-shrink: 0; 
        }

        /* enroll CTA */
        .enroll-cta {
            background: rgba(47,125,255,.08);
            border: 1px solid rgba(47,125,255,.2);
            border-radius: 16px;
            padding: 20px;
            text-align: center;
        }
        .enroll-cta p { font-size: .88rem; color: #a9b8d6; margin-bottom: 16px; line-height: 1.6; }
        .enroll-cta p strong { color: #e7eefc; }
        .enroll-actions { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; }

        .btn-enroll-primary {
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            color: #fff;
            border: none;
            padding: 11px 26px;
            border-radius: 50px;
            font-family: 'Outfit', sans-serif;
            font-size: .9rem;
            font-weight: 800;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            box-shadow: 0 4px 18px rgba(47,125,255,.35);
            transition: opacity .2s, transform .2s;
        }
        .btn-enroll-primary:hover { opacity: .88; transform: translateY(-2px); }

        .btn-enroll-secondary {
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.18);
            color: #e7eefc;
            padding: 11px 26px;
            border-radius: 50px;
            font-family: 'Outfit', sans-serif;
            font-size: .9rem;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background .2s;
        }
        .btn-enroll-secondary:hover { background: rgba(255,255,255,.11); }

        @media (max-width: 600px) {
            .learn-list { grid-template-columns: 1fr; }
            .enroll-actions { flex-direction: column; }
        }

        .cta-banner {
            margin: 0 20px 60px;
            background: linear-gradient(135deg,rgba(47,125,255,.18),rgba(0,194,255,.1));
            border: 1px solid rgba(47,125,255,.3);
            border-radius: 22px; padding: 50px 30px; text-align: center;
        }
        .cta-banner h2 { font-size: 1.8rem; font-weight: 900; margin: 0 0 12px; color: #e7eefc; }
        .cta-banner p  { color: #a9b8d6; margin: 0 0 28px; font-size: 1rem; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- =====================================================
         HERO
         ===================================================== --%>
    <div class="bc-hero">
        <div class="bc-hero-badge"> Course Catalogue</div>
        <h1>Browse Our Python Courses</h1>
        <p>Explore everything we offer - from total beginner to advanced. Create a free account to get full access.</p>
        <div class="guest-nudge">
            <span class="nudge-dot"></span>
            Free to browse &nbsp;|&nbsp;
            <a href="LoginPage.aspx">Sign in</a> or
            <a href="Register.aspx">create an account</a> to enroll
        </div>
    </div>

    <%-- =====================================================
         STATS
         ===================================================== --%>
    <div class="bc-stats">
        <div class="bc-stat">
            <strong><asp:Label ID="lblCourseCount"  runat="server" Text="12" />+</strong>
            <span>Courses</span>
        </div>
        <div class="bc-stat">
            <strong><asp:Label ID="lblStudentCount" runat="server" Text="80" />+</strong>
            <span>Students</span>
        </div>
        <div class="bc-stat">
            <strong><asp:Label ID="lblLessonCount"  runat="server" Text="30" />+</strong>
            <span>Lessons</span>
        </div>
        <div class="bc-stat">
            <strong>100%</strong>
            <span>Free to Browse</span>
        </div>
    </div>

    <%-- =====================================================
         FILTER BAR
         ===================================================== --%>
    <div class="bc-filter-bar">
        <div class="bc-search-wrap">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
            </svg>
            <input type="text" class="bc-search-input" placeholder="Search courses..." oninput="filterCourses(this.value)" />
        </div>

        <div class="diff-pills">
            <button class="diff-pill active" onclick="setDiffFilter('all', this)">All</button>
            <button class="diff-pill" onclick="setDiffFilter('beginner', this)">Beginner</button>
            <button class="diff-pill" onclick="setDiffFilter('intermediate', this)">Intermediate</button>
            <button class="diff-pill" onclick="setDiffFilter('advanced', this)">Advanced</button>
        </div>

        <span class="bc-count"><span id="visibleCount">0</span> courses</span>
    </div>

    <%-- =====================================================
         COURSE GRID
         ===================================================== --%>
    <div class="bc-grid-section">
        <div class="bc-grid">

            <asp:Repeater ID="rptCourses" runat="server" OnItemDataBound="rptCourses_ItemDataBound">
                <ItemTemplate>
                    <div class="bc-card searchable"
                         data-title='<%# (Eval("CourseName") ?? "").ToString().ToLower() %>'
                         data-difficulty='<%# (Eval("Difficulty") ?? "").ToString().ToLower() %>'
                         style='animation-delay: <%# Container.ItemIndex * 60 %>ms'>

                        <%-- thumbnail --%>
                        <div class='bc-thumb <%# string.IsNullOrWhiteSpace((Eval("ThumbnailPath") ?? "").ToString()) ? "bc-thumb-placeholder" : "" %>'
                             style='<%# !string.IsNullOrWhiteSpace((Eval("ThumbnailPath") ?? "").ToString()) ? "background-image:url(" + ResolveUrl((Eval("ThumbnailPath") ?? "").ToString()) + ");" : "" %>'>
                            <%# string.IsNullOrWhiteSpace((Eval("ThumbnailPath") ?? "").ToString()) ? "PY" : "" %>
                            <div class="bc-lock">🔒</div>
                            <asp:Label ID="lblDiff" runat="server"
                                CssClass='<%# "bc-diff " + (Eval("Difficulty") ?? "").ToString().ToLower() %>'
                                Text='<%# Eval("Difficulty") %>' />
                        </div>

                        <%-- body --%>
                        <div class="bc-card-body">
                            <span class="bc-cat-badge"><%# Eval("Category") %></span>
                            <div class="bc-title"><%# Eval("CourseName") %></div>
                            <div class="bc-desc"><%# Eval("Description") %></div>
                           <div class="bc-meta">
                                <span class="bc-meta-item">&#9201; <%# Eval("Duration") %></span>
                                <span class="bc-meta-item">&#128218; <%# Eval("LessonCount") %> lessons</span>
                            </div>
                        </div>

                        <%-- footer button --%>
                        <div class="bc-card-footer">
                            <button type="button" class="btn-view-details"
                                onclick='openDetail(
                                    "<%# HttpUtility.JavaScriptStringEncode((Eval("CourseName") ?? "").ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode((Eval("Description") ?? "").ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode((Eval("Category") ?? "").ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode((Eval("Difficulty") ?? "").ToString()) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode((Eval("Duration") ?? "").ToString()) %>",
                                    <%# Eval("LessonCount") %>,
                                    "<%# HttpUtility.JavaScriptStringEncode(GetLearnPoints(Eval("CourseID"))) %>",
                                    "<%# HttpUtility.JavaScriptStringEncode(string.IsNullOrWhiteSpace((Eval("ThumbnailPath") ?? "").ToString()) ? "" : ResolveUrl((Eval("ThumbnailPath") ?? "").ToString())) %>"
                                )'>
                                View Details
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <div class="bc-empty" id="noResults" style="display:none;">
                <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="#a9b8d6" stroke-width="1.3">
                    <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
                </svg>
                <p>No courses match your search. Try a different keyword.</p>
            </div>
        </div>
    </div>

    <%-- =====================================================
         BOTTOM CTA BANNER — reuses site's .cta-banner class
         ===================================================== --%>
    <div class="cta-banner">
        <h2>Ready to Start Learning?</h2>
        <p>Join hundreds of students already mastering Python — it's completely free to sign up.</p>
        <div class="hero-actions">
            <a href="/LoginandRegister/RegisterPage.aspx" class="btn-primary">Create Free Account</a>
            <a href="/LoginandRegister/LoginPage.aspx" class="btn-ghost">Already have an account? Log In</a>
        </div>
    </div>

</div>

    <%-- =====================================================
         COURSE DETAIL MODAL
         ===================================================== --%>
    <div id="courseDetailModal" class="modal-overlay" onclick="closeDetailOnOverlay(event)">
        <div class="detail-modal-box">
            <button type="button" class="modal-close" onclick="closeCourseDetail()">&#10005;</button>

            <div id="detailThumb" class="detail-thumb">PY</div>

            <div class="detail-body">
                <span id="detailCategory" class="detail-tag"></span>
                <span id="detailDiff"     class="detail-tag"></span>
                <h3 id="detailTitle"></h3>
                <p id="detailDesc" class="detail-desc"></p>

                <div class="detail-meta-row">
                    <div class="detail-meta-item">&#9201; &nbsp;<span id="detailDuration"></span></div>
                    <div class="detail-meta-item">&#128218; &nbsp;<span id="detailLessons"></span></div>
                    <div class="detail-meta-item">&#128274; &nbsp;<span>Enroll to access</span></div>
                </div>

                <div class="learn-section-label" id="learnLabel" style="display:none;">What You'll Learn</div>
                <ul class="learn-list" id="learnList"></ul>

                <div class="enroll-cta">
                    <p><strong>Want full access?</strong><br />Create a free account or sign in to enroll and unlock all lessons, exercises, and quizzes.</p>
                    <div class="enroll-actions">
                        <a href="Register.aspx" class="btn-enroll-primary">Create Free Account</a>
                        <a href="LoginPage.aspx" class="btn-enroll-secondary">Sign In</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // ============================================================
        // filter — search + difficulty pills, all client-side
        // ============================================================
        var activeFilter = 'all';

        function filterCourses(query) {
            applyFilters(query.toLowerCase().trim(), activeFilter);
        }

        function setDiffFilter(filter, btn) {
            activeFilter = filter;
            document.querySelectorAll('.diff-pill').forEach(function(p) { p.classList.remove('active'); });
            btn.classList.add('active');
            var q = (document.querySelector('.bc-search-input') || { value: '' }).value.toLowerCase().trim();
            applyFilters(q, filter);
        }

        function applyFilters(query, diff) {
            var cards = document.querySelectorAll('.bc-card.searchable');
            var visible = 0;
            cards.forEach(function(card) {
                var title = card.dataset.title || '';
                var d     = card.dataset.difficulty || '';
                var ok    = (!query || title.includes(query)) && (diff === 'all' || d === diff);
                card.style.display = ok ? '' : 'none';
                if (ok) visible++;
            });
            document.getElementById('visibleCount').textContent = visible;
            document.getElementById('noResults').style.display  = visible === 0 ? 'block' : 'none';
        }

        window.addEventListener('DOMContentLoaded', function() { applyFilters('', 'all'); });

        // ============================================================
        // detail modal
        // ============================================================
        function openDetail(title, desc, category, diff, duration, lessons, learnRaw, thumbUrl) {
            document.getElementById('detailTitle').textContent    = title;
            document.getElementById('detailDesc').textContent     = desc;
            document.getElementById('detailCategory').textContent = category;
            document.getElementById('detailDuration').textContent = duration;
            document.getElementById('detailLessons').textContent  = lessons + ' lessons';

            var diffEl = document.getElementById('detailDiff');
            diffEl.textContent = diff;
            diffEl.className   = 'detail-tag diff-' + diff.toLowerCase();

            var thumbEl = document.getElementById('detailThumb');
            if (thumbUrl && thumbUrl.trim()) {
                thumbEl.style.background = 'url(' + thumbUrl + ') center/cover no-repeat';
                thumbEl.textContent = '';
            } else {
                thumbEl.style.background = 'linear-gradient(135deg, rgba(47,125,255,.2), rgba(0,194,255,.12))';
                thumbEl.textContent = 'PY';
            }

            var learnList  = document.getElementById('learnList');
            var learnLabel = document.getElementById('learnLabel');
            learnList.innerHTML = '';
            var points = learnRaw ? learnRaw.split('|').filter(function(p) { return p.trim(); }) : [];
            learnLabel.style.display = points.length ? 'block' : 'none';
            points.forEach(function(p) {
                var li = document.createElement('li');
                li.textContent = p.trim();
                learnList.appendChild(li);
            });

            document.getElementById('courseDetailModal').classList.add('open');
        }

        function closeCourseDetail() { document.getElementById('courseDetailModal').classList.remove('open'); }
        function closeDetailOnOverlay(e) { if (e.target === document.getElementById('courseDetailModal')) closeCourseDetail(); }
        document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeCourseDetail(); });
    </script>

</asp:Content>
