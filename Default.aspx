<%@ Page Title="Default" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PythonAcademy.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
    .main > .landing-root {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
    }
    .hero { text-align: center; padding: 80px 20px 60px; }
    .hero-badge {
        display: inline-block;
        background: rgba(47,125,255,.15); border: 1px solid rgba(47,125,255,.35);
        color: #2f7dff; border-radius: 999px;
        padding: 6px 18px; font-size: .85rem; font-weight: 700; margin-bottom: 24px;
    }
    .hero h1 {
        font-size: clamp(2rem,5vw,3.6rem); 
        font-weight: 900; 
        line-height: 1.15; 
        margin: 0 0 20px;
        
        background: linear-gradient(135deg, #ffffff 20%, #00d8ff 80%);
        -webkit-background-clip: text;
        background-clip: text;
        -webkit-text-fill-color: transparent;
        
        filter: drop-shadow(0px 0px 15px rgba(0, 216, 255, 0.2)); 
    }
    .hero p { font-size: 1.15rem; color: #a9b8d6; max-width: 560px; margin: 0 auto 36px; line-height: 1.7; }
    .hero-actions { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }
    .btn-primary {
        background: linear-gradient(135deg,#2f7dff,#00c2ff); color: #fff; border: none;
        padding: 14px 32px; border-radius: 50px; font-size: 1rem; font-weight: 800;
        text-decoration: none; box-shadow: 0 4px 20px rgba(47,125,255,.4);
        transition: transform .2s,box-shadow .2s; display: inline-block;
    }
    .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(47,125,255,.55); }
    .btn-ghost {
        background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.18); color: #e7eefc;
        padding: 14px 32px; border-radius: 50px; font-size: 1rem; font-weight: 700;
        text-decoration: none; transition: background .2s; display: inline-block;
    }
    .btn-ghost:hover { background: rgba(255,255,255,.11); }
    .stats-row { display: flex; justify-content: center; gap: 40px; flex-wrap: wrap; padding: 20px 20px 40px; }
    .stat-item { text-align: center; }
    .stat-item strong {
        display: block; font-size: 2rem; font-weight: 900;
        color: #00c2ff;
        text-shadow: 0 0 18px rgba(47,125,255,.22);
    }
    .stat-item span { color: #a9b8d6; font-size: .9rem; }

    .section-title { text-align: center; margin-bottom: 36px; position: relative; }
    .section-title h2 { font-size: 1.9rem; font-weight: 800; margin: 0 0 8px; color: #e7eefc; }
    .section-title p { color: #a9b8d6; margin: 0; }

    .courses-carousel-wrapper {
        display: flex;
        align-items: center;
        gap: 24px;
    }
    .courses-carousel-wrapper .courses-grid {
        flex: 1;
        min-width: 0;
    }

    .browse-card-cta {
        display: flex !important;
        flex-direction: row !important; 
        align-items: center !important; 
        justify-content: center !important; 
        gap: 16px !important;
        text-decoration: none !important; 
        height: 100% !important; 
        min-height: 380px; 
    }
    .browse-card-cta .browse-all-cta-label {
        font-size: 1.3rem;
        font-weight: 800;
        line-height: 1.35;
        text-align: right;
        color: #e7eefc;
        text-shadow: 0 0 18px rgba(0,194,255,.18);
        text-decoration: none !important;
    }
    .browse-card-cta .browse-all-cta-circle {
        width: 60px; height: 60px;
        background: rgba(47,125,255,.15);
        border: 1px solid rgba(47,125,255,.4);
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        color: #2f7dff; font-size: 2.2rem; line-height: 1;
        padding-bottom: 4px;
        transition: background .2s, transform .2s;
    }
   
    .browse-card-cta:hover .browse-all-cta-circle { 
        background: rgba(47,125,255,.3);
        transform: translateX(8px);
    }

    .features-grid {
        display: grid; grid-template-columns: repeat(auto-fit,minmax(220px,1fr));
        gap: 20px; padding: 0 20px 50px;
    }
    .feature-card {
        background: rgba(16,31,58,.6); border: 1px solid rgba(255,255,255,.1);
        border-radius: 18px; padding: 28px 22px; text-align: center;
        transition: transform .2s,border-color .2s;
    }
    .feature-card:hover { transform: translateY(-4px); border-color: rgba(47,125,255,.4); }
    .feature-icon { font-size: 2.4rem; margin-bottom: 14px; }
    .feature-card h3 { font-size: 1.05rem; font-weight: 800; margin: 0 0 8px; color: #e7eefc; }
    .feature-card p { color: #a9b8d6; font-size: .88rem; margin: 0; line-height: 1.6; }
    .course-section { padding: 0 20px 80px; }
    .courses-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(280px,1fr)); gap: 22px; }
    .course-card {
        background: rgba(16,31,58,.65); border: 1px solid rgba(255,255,255,.1);
        border-radius: 18px; overflow: hidden; position: relative;
        transition: transform .2s,border-color .2s;
    }
    .course-card:hover { transform: translateY(-4px); border-color: rgba(47,125,255,.35); }
    .course-thumb {
        height: 180px;
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        font-size: 0;
    }
    .course-body { padding: 18px; }
    .course-tag {
        display: inline-block; background: rgba(47,125,255,.15);
        border: 1px solid rgba(47,125,255,.3); color: #2f7dff;
        border-radius: 999px; padding: 3px 12px; font-size: .75rem; font-weight: 700; margin-bottom: 10px;
    }
    .course-tag.inter { background: rgba(0,194,255,.12); border-color: rgba(0,194,255,.3); color: #00c2ff; }
    .course-tag.adv   { background: rgba(188,19,254,.12); border-color: rgba(188,19,254,.3); color: #bc13fe; }
    .course-body h4 { font-size: 1rem; font-weight: 800; margin: 0 0 6px; color: #e7eefc; }
    .course-body p  { color: #a9b8d6; font-size: .83rem; margin: 0 0 14px; line-height: 1.5; }
    .course-meta { display: flex; justify-content: space-between; font-size: .78rem; color: #a9b8d6; }


    .lock-badge {
        position: absolute; top: 12px; right: 12px;
        background: rgba(7,13,24,.75); border: 1px solid rgba(255,255,255,.15);
        border-radius: 50%; width: 36px; height: 36px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.1rem; z-index: 2;
    }

    .btn-unlock {
        display: block; width: 100%;
        background: rgba(47,125,255,.12); border: 1px solid rgba(47,125,255,.3);
        color: #2f7dff; border-radius: 10px; padding: 9px;
        font-size: .85rem; font-weight: 700; cursor: pointer;
        transition: background .2s; text-align: center; margin-top: 10px;
        text-decoration: none;
    }
    .btn-unlock:hover { background: rgba(47,125,255,.22); }

    .modal-overlay {
        display: none; position: fixed; inset: 0;
        background: rgba(0,0,0,.65); backdrop-filter: blur(6px);
        z-index: 9999; align-items: center; justify-content: center;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
        background: #0f1829; border: 1px solid rgba(255,255,255,.12);
        border-radius: 24px; padding: 40px 36px;
        max-width: 400px; width: 90%; text-align: center;
        box-shadow: 0 20px 60px rgba(0,0,0,.5); position: relative;
        animation: popIn .25s ease;
    }
    @keyframes popIn { from{transform:scale(.9);opacity:0} to{transform:scale(1);opacity:1} }
    .modal-icon { font-size: 3rem; margin-bottom: 16px; }
    .modal-box h3 { font-size: 1.4rem; font-weight: 900; margin: 0 0 10px; color: #e7eefc; }
    .modal-box p  { color: #a9b8d6; font-size: .95rem; margin: 0 0 28px; line-height: 1.6; }
    .modal-actions { display: flex; gap: 12px; }
    .modal-actions a {
        flex: 1; padding: 12px; border-radius: 50px; font-weight: 800;
        text-decoration: none; font-size: .95rem; text-align: center;
        display: inline-block; transition: opacity .2s;
    }
    .modal-actions a:hover { opacity: .85; }
    .modal-btn-login  { background: linear-gradient(135deg,#2f7dff,#00c2ff); color: #fff; }
    .modal-btn-signup { background: rgba(255,255,255,.07); border: 1px solid rgba(255,255,255,.18); color: #e7eefc; }
    .modal-close {
        position: absolute; top: 14px; right: 18px;
        background: none; border: none; color: #a9b8d6; font-size: 1.4rem; cursor: pointer;
    }


    .detail-modal-box {
        background: #0f1829; border: 1px solid rgba(47,125,255,.25);
        border-radius: 24px; max-width: 520px; width: 92%;
        box-shadow: 0 20px 60px rgba(0,0,0,.6); position: relative;
        animation: popIn .25s ease; overflow: hidden;
    }
    .detail-thumb {
        height: 200px; background-size: cover; background-position: center;
        background-repeat: no-repeat;
    }
    .detail-body { padding: 28px 30px 32px; }
    .detail-tag {
        display: inline-block; background: rgba(0,194,255,.12);
        border: 1px solid rgba(0,194,255,.3); color: #00c2ff;
        border-radius: 999px; padding: 3px 14px; font-size: .78rem; font-weight: 700; margin-bottom: 14px;
    }
    .detail-body h3 { font-size: 1.45rem; font-weight: 900; margin: 0 0 10px; color: #e7eefc; }
    .detail-body .detail-desc { color: #a9b8d6; font-size: .93rem; line-height: 1.65; margin: 0 0 20px; }
    .detail-meta-row {
        display: flex; gap: 18px; flex-wrap: wrap; margin-bottom: 22px;
    }
    .detail-meta-item {
        display: flex; align-items: center; gap: 6px;
        font-size: .82rem; color: #a9b8d6;
    }
    .detail-meta-item .meta-icon { font-size: 1rem; }
    .detail-meta-item strong { color: #e7eefc; }
    .detail-actions { display: flex; gap: 12px; }
    .detail-btn-start {
        flex: 1; padding: 12px; border-radius: 50px; font-weight: 800;
        font-size: .95rem; text-align: center; display: inline-block;
        background: linear-gradient(135deg,#2f7dff,#00c2ff); color: #fff;
        text-decoration: none; transition: opacity .2s;
    }
    .detail-btn-start:hover { opacity: .85; }
    .detail-btn-cancel {
        padding: 12px 22px; border-radius: 50px; font-weight: 700;
        font-size: .95rem; text-align: center;
        background: rgba(255,255,255,.07); border: 1px solid rgba(255,255,255,.18); color: #e7eefc;
        cursor: pointer; transition: background .2s;
    }
    .detail-btn-cancel:hover { background: rgba(255,255,255,.13); }

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

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

<div class="landing-root">


    <section class="hero">
        <div class="hero-badge">Python Learning Platform</div>
        <h1>Master Python.<br/>Build Your Future.</h1>
        <p>From beginner basics to advanced concepts - Python Academy gives you structured courses, quizzes, and real-world exercises to level up your skills.</p>
        <div class="hero-actions">
            <a href="/LoginandRegister/LoginPage.aspx" class="btn-primary">Log In</a>
            <a href="/LoginandRegister/RegisterPage.aspx" class="btn-ghost">Create Free Account</a>
        </div>
    </section>


    <div class="stats-row">
        <div class="stat-item"><strong>20+</strong><span>Courses</span></div>
        <div class="stat-item"><strong>20+</strong><span>Certifications</span></div>
        <div class="stat-item"><strong>50+</strong><span>Exercises</span></div>
        <div class="stat-item"><strong>100%</strong><span>Free to Join</span></div>
    </div>


    <div class="section-title">
        <h2>Everything You Need to Learn Python</h2>
        <p>A complete learning experience in one place</p>
    </div>
    <div class="features-grid">
        <div class="feature-card">
            <h3>Structured Courses</h3>
            <p>Step-by-step modules from beginner to advanced, so you always know what to learn next.</p>
        </div>
        <div class="feature-card">
            <h3>Quizzes &amp; Assessments</h3>
            <p>Test your knowledge with auto-graded quizzes designed by experienced instructors.</p>
        </div>
        <div class="feature-card">
            <h3>Hands-On Exercises</h3>
            <p>Submit real coding exercises and get feedback to sharpen your practical skills.</p>
        </div>
        <div class="feature-card">
            <h3>Track Your Progress</h3>
            <p>Visual dashboards show how far you've come and what to tackle next.</p>
        </div>
    </div>

    <div class="section-title">
        <h2>Browse Our Courses</h2>
        <p>Get a peek at what's waiting - sign up to unlock full access</p>
    </div>

    <div class="course-section">
        <div class="courses-carousel-wrapper">
            <div class="courses-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>

                    <div class='<%# GetCourseCardCss(Eval("IsPreviewFree")) %>'>

                       <%-- Lock badge fixed with HTML Entity so it doesn't break --%>
                        <asp:PlaceHolder ID="phLockBadge" runat="server"
                            Visible='<%# ShowLockedBadge(Eval("IsPreviewFree")) %>'>
                            <div class="lock-badge">&#128274;</div>
                        </asp:PlaceHolder>

                        <%-- Apply the thumbnail with JavaScript so the validator does not parse server-side CSS. --%>
                        <div class="course-thumb"
                            data-background-image='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ThumbnailPath"))) ? ResolveUrl("~/Images/contentImage.jpg") : ResolveUrl(Convert.ToString(Eval("ThumbnailPath"))) %>'>
                        </div>

                        <div class="course-body">
                            <span class="course-tag"><%# Eval("ContentType") %></span>
                            <h4><%# Eval("Title") %></h4>
                            <p><%# Eval("Description") %></p>

                            <%-- Free preview course → open detail card; others → login modal or page --%>
                            <asp:PlaceHolder ID="phPreviewBtn" runat="server"
                                Visible='<%# (bool)IsPreviewFree(Eval("IsPreviewFree")) && !UserIsLoggedIn() %>'>
                                <button type="button" class="btn-unlock"
                                    onclick='showCourseDetail(
                                        <%# Eval("ContentId") %>,
                                        <%# HttpUtility.JavaScriptStringEncode((string)(Eval("Title") ?? ""), true) %>,
                                        <%# HttpUtility.JavaScriptStringEncode((string)(Eval("Description") ?? ""), true) %>,
                                        <%# HttpUtility.JavaScriptStringEncode((string)(Eval("ContentType") ?? ""), true) %>,
                                        <%# HttpUtility.JavaScriptStringEncode(GetResourceLink(Eval("Url"), Eval("FilePath")), true) %>
                                    )'>
                                    View Preview
                                </button>
                            </asp:PlaceHolder>

                            <asp:PlaceHolder ID="phNormalBtn" runat="server"
                                Visible='<%# !(bool)IsPreviewFree(Eval("IsPreviewFree")) || UserIsLoggedIn() %>'>
                                <a href='<%# GetCourseUrl(Eval("ContentId"), Eval("IsPreviewFree")) %>'
                                   class="btn-unlock"
                                   onclick='<%# GetCourseOnClick(Eval("IsPreviewFree")) %>'>
                                    <%# GetCourseButtonText(Eval("IsPreviewFree")) %>
                                </a>
                            </asp:PlaceHolder>

                        </div>
                    </div>

                </ItemTemplate>
            </asp:Repeater>

            <a href="browseCourses.aspx" class="course-card browse-card-cta" title="Browse All Courses">
                <span class="browse-all-cta-circle">&#8250;</span>
                <span class="browse-all-cta-label">Browse All<br/>Our Courses</span>
            </a>

            </div>
        </div>
    </div>

    <!-- CTA BANNER -->
    <div class="cta-banner">
        <h2>Ready to Start Learning?</h2>
        <p>Join hundreds of students already mastering Python — it's completely free to sign up.</p>
        <div class="hero-actions">
            <a href="/LoginandRegister/RegisterPage.aspx" class="btn-primary">Create Free Account</a>
            <a href="/LoginandRegister/LoginPage.aspx" class="btn-ghost">Already have an account? Log In</a>
        </div>
    </div>

</div>

<!-- LOGIN MODAL -->
<div id="loginModal" class="modal-overlay" onclick="closeModalOnOverlay(event)">
    <div class="modal-box">
        <button class="modal-close" onclick="closeModal()">&#10005;</button>
        <div class="modal-icon">&#128272;</div>
        <h3>Members Only</h3>
        <p>This course is available to registered members. Log in or create a free account to unlock full access.</p>
        <div class="modal-actions">
            <a href="/LoginandRegister/LoginPage.aspx" class="modal-btn-login">Log In</a>
            <a href="/LoginandRegister/RegisterPage.aspx" class="modal-btn-signup">Sign Up Free</a>
        </div>
    </div>
</div>

<!-- COURSE DETAIL MODAL -->
<div id="courseDetailModal" class="modal-overlay" onclick="closeDetailOnOverlay(event)">
    <div class="detail-modal-box">
        <button class="modal-close" onclick="closeCourseDetail()" style="z-index:3;position:absolute;top:14px;right:18px;">&#10005;</button>

        <div id="detailThumb" class="detail-thumb"
             data-background-image='<%= ResolveUrl("~/Images/contentImage.jpg") %>'>
        </div>

        <div class="detail-body">
            <span id="detailTag" class="detail-tag"></span>
            <h3 id="detailTitle"></h3>
            <p id="detailDesc" class="detail-desc"></p>

            <div class="detail-meta-row">
                <div class="detail-meta-item">
                    <span class="meta-icon">✅</span>
                    <span>Free Preview</span>
                </div>
                <div class="detail-meta-item" id="detailResourceRow" style="display:none">
                    <span class="meta-icon">🔗</span>
                    <strong id="detailResourceLabel"></strong>
                </div>
            </div>

            <div class="detail-actions">
                <a id="detailStartBtn" href="#" class="detail-btn-start">Start Preview</a>
                <button type="button" class="detail-btn-cancel" onclick="closeCourseDetail()">Maybe Later</button>
            </div>
        </div>
    </div>
</div>

<script>
    /* ── Login modal ── */
    function showLoginModal() { document.getElementById('loginModal').classList.add('open'); }
    function closeModal()     { document.getElementById('loginModal').classList.remove('open'); }
    function closeModalOnOverlay(e) { if (e.target === document.getElementById('loginModal')) closeModal(); }

    function setBackgroundImage(element, imageUrl) {
        if (!element || !imageUrl) {
            return;
        }

        var safeUrl = String(imageUrl)
            .replace(/\\/g, '\\\\')
            .replace(/"/g, '\\"');

        element.style.backgroundImage = 'url("' + safeUrl + '")';
    }

    function initializeBackgroundImages() {
        var elements = document.querySelectorAll('[data-background-image]');

        for (var i = 0; i < elements.length; i++) {
            setBackgroundImage(elements[i], elements[i].getAttribute('data-background-image'));
        }
    }

    /* ── Course detail modal ── */
    function showCourseDetail(id, title, desc, type, resource) {
        document.getElementById('detailTitle').textContent = title;
        document.getElementById('detailDesc').textContent  = desc;
        document.getElementById('detailTag').textContent   = type;
        document.getElementById('detailStartBtn').href     = 'CourseView.aspx?id=' + id;

        var resRow = document.getElementById('detailResourceRow');
        var resLabel = document.getElementById('detailResourceLabel');
        if (resource && resource.trim() !== '') {
            resLabel.textContent = resource.length > 40 ? resource.substring(0, 40) + '…' : resource;
            resRow.style.display = 'flex';
        } else {
            resRow.style.display = 'none';
        }

        document.getElementById('courseDetailModal').classList.add('open');
    }

    function closeCourseDetail()  { document.getElementById('courseDetailModal').classList.remove('open'); }
    function closeDetailOnOverlay(e) { if (e.target === document.getElementById('courseDetailModal')) closeCourseDetail(); }

    initializeBackgroundImages();

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') { closeModal(); closeCourseDetail(); }
    });
</script>
</asp:Content>
