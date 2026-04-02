<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="PythonAcademy.About" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    About
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        /* ===================================================
           about.aspx — who we are / mission / features
           theme: dark navy, blue/cyan gradient, Outfit font,
           rounded cards — matches site style exactly
           =================================================== */

        body { font-family: 'Outfit', sans-serif; }

        /* ---- hero ---- */
        .ab-hero {
            text-align: center;
            padding: 70px 20px 50px;
        }
        .ab-hero-badge {
            display: inline-block;
            background: rgba(47,125,255,.15);
            border: 1px solid rgba(47,125,255,.35);
            color: #2f7dff;
            border-radius: 999px;
            padding: 6px 18px;
            font-size: .85rem;
            font-weight: 700;
            margin-bottom: 22px;
        }
        .ab-hero h1 {
            font-size: clamp(2rem, 5.5vw, 3.6rem);
            font-weight: 900;
            line-height: 1.12;
            margin: 0 0 20px;
            background: linear-gradient(135deg, #e7eefc 30%, #00c2ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .ab-hero p {
            font-size: 1.1rem;
            color: #a9b8d6;
            max-width: 560px;
            margin: 0 auto 36px;
            line-height: 1.7;
        }
        .ab-hero-actions { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }

        /* ---- stats row ---- */
        .ab-stats {
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap;
            padding: 10px 20px 50px;
        }
        .ab-stat { text-align: center; }
        .ab-stat strong {
            display: block;
            font-size: 2.2rem;
            font-weight: 900;
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .ab-stat span { color: #a9b8d6; font-size: .88rem; }

        /* ---- section layout ---- */
        .ab-section {
            padding: 0 20px 60px;
            max-width: 1100px;
            margin: 0 auto;
        }

        .ab-section-header { margin-bottom: 36px; }
        .ab-section-header h2 {
            font-size: clamp(1.4rem, 3vw, 2rem);
            font-weight: 900;
            color: #e7eefc;
            margin: 0 0 8px;
        }
        .ab-section-header p { color: #a9b8d6; font-size: .95rem; line-height: 1.65; max-width: 540px; margin: 0; }
        .ab-eyebrow {
            display: inline-block;
            font-size: .78rem;
            font-weight: 700;
            color: #2f7dff;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }

        /* ---- divider ---- */
        .ab-divider {
            height: 1px;
            background: rgba(255,255,255,.07);
            margin: 0 20px 60px;
        }

        /* ================================================================
           STORY — two column
           ================================================================ */
        .story-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
        }
        .story-text p {
            font-size: .95rem;
            color: #a9b8d6;
            line-height: 1.8;
            margin-bottom: 16px;
        }
        .story-text p:last-child { margin-bottom: 0; }
        .story-text p strong { color: #e7eefc; }

        /* info card — terminal style but rounded to match site */
        .story-info-card {
            background: rgba(16,31,58,.65);
            border: 1px solid rgba(47,125,255,.2);
            border-radius: 20px;
            overflow: hidden;
        }
        .info-card-header {
            background: rgba(47,125,255,.1);
            border-bottom: 1px solid rgba(47,125,255,.18);
            padding: 14px 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .info-card-dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: rgba(47,125,255,.3);
        }
        .info-card-dot.active { background: #00c2ff; animation: dotBlink 2s infinite; }
        @keyframes dotBlink { 0%,100%{opacity:1} 50%{opacity:.3} }

        .info-card-title {
            font-family: 'JetBrains Mono', monospace;
            font-size: .78rem;
            color: #a9b8d6;
            margin-left: auto;
        }
        .info-card-body { padding: 20px 24px; }
        .info-row {
            display: flex;
            gap: 12px;
            padding: 6px 0;
            border-bottom: 1px solid rgba(255,255,255,.05);
            font-family: 'JetBrains Mono', monospace;
            font-size: .8rem;
        }
        .info-row:last-child { border-bottom: none; }
        .info-key  { color: #2f7dff; min-width: 110px; }
        .info-val  { color: #a9b8d6; }
        .info-val.hi { color: #00c2ff; }

        /* ================================================================
           FEATURES GRID — 3 col matching site's feature-card style
           ================================================================ */
        .ab-features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
        }
        .ab-feature-card {
            background: rgba(16,31,58,.6);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 18px;
            padding: 28px 22px;
            text-align: center;
            transition: transform .2s, border-color .2s;
        }
        .ab-feature-card:hover { transform: translateY(-4px); border-color: rgba(47,125,255,.4); }
        .ab-feature-icon { font-size: 2.4rem; margin-bottom: 14px; }
        .ab-feature-card h3 { font-size: 1.05rem; font-weight: 800; margin: 0 0 8px; color: #e7eefc; }
        .ab-feature-card p  { color: #a9b8d6; font-size: .88rem; margin: 0; line-height: 1.6; }

        /* ================================================================
           HOW IT WORKS — step cards
           ================================================================ */
        .steps-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
        }
        .step-card {
            background: rgba(16,31,58,.6);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 18px;
            padding: 28px 22px;
            transition: transform .2s, border-color .2s;
            position: relative;
        }
        .step-card:hover { transform: translateY(-4px); border-color: rgba(47,125,255,.4); }
        .step-num {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 42px; height: 42px;
            background: linear-gradient(135deg, rgba(47,125,255,.25), rgba(0,194,255,.15));
            border: 1px solid rgba(47,125,255,.3);
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 900;
            color: #2f7dff;
            margin-bottom: 16px;
        }
        .step-card h3 { font-size: 1.05rem; font-weight: 800; margin: 0 0 8px; color: #e7eefc; }
        .step-card p  { color: #a9b8d6; font-size: .88rem; margin: 0; line-height: 1.6; }

        /* ================================================================
           VALUES — 2-col cards
           ================================================================ */
        .values-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
        }
        .value-card {
            background: rgba(16,31,58,.55);
            border: 1px solid rgba(255,255,255,.09);
            border-radius: 18px;
            padding: 24px;
            display: flex;
            gap: 16px;
            align-items: flex-start;
            transition: border-color .2s;
        }
        .value-card:hover { border-color: rgba(47,125,255,.35); }
        .value-num {
            font-size: .8rem;
            font-weight: 900;
            color: #2f7dff;
            opacity: .6;
            min-width: 28px;
            padding-top: 2px;
        }
        .value-card h4 { font-size: 1rem; font-weight: 800; margin: 0 0 6px; color: #e7eefc; }
        .value-card p  { font-size: .87rem; color: #a9b8d6; margin: 0; line-height: 1.65; }

        @media (max-width: 768px) {
            .story-grid { grid-template-columns: 1fr; gap: 36px; }
            .ab-section { padding: 0 20px 50px; }
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
    <div class="ab-hero">
        <div class="ab-hero-badge">About PythonAcademy</div>
        <h1>We're On A Mission To Make<br />Python Click For Everyone.</h1>
        <p>PythonAcademy is a structured, hands-on learning platform built for students who want to go further than syntax - and actually build things with Python.</p>
        <div class="ab-hero-actions">
            <a href="Register.aspx" class="btn-primary">Start Learning Free</a>
            <a href="browseCourses.aspx" class="btn-ghost">Browse Courses</a>
        </div>
    </div>

    <%-- =====================================================
         STATS
         ===================================================== --%>
    <div class="ab-stats">
        <div class="ab-stat">
            <strong><asp:Label ID="lblCourses"  runat="server" Text="12" />+</strong>
            <span>Courses</span>
        </div>
        <div class="ab-stat">
            <strong><asp:Label ID="lblStudents" runat="server" Text="500" />+</strong>
            <span>Students Enrolled</span>
        </div>
        <div class="ab-stat">
            <strong><asp:Label ID="lblLessons"  runat="server" Text="80" />+</strong>
            <span>Lessons &amp; Modules</span>
        </div>
        <div class="ab-stat">
            <strong>100%</strong>
            <span>Project-Based</span>
        </div>
    </div>

    <div class="ab-divider"></div>

    <%-- =====================================================
         OUR STORY
         ===================================================== --%>
    <div class="ab-section">
        <div class="story-grid">
            <div>
                <div class="ab-section-header">
                    <span class="ab-eyebrow">Our Story</span>
                    <h2>Built By People Who Learned The Hard Way</h2>
                    <p>We were tired of tutorials that taught syntax without context and platforms that forgot what it felt like to be a beginner.</p>
                </div>
                <div class="story-text">
                    <p>
                        PythonAcademy started as a simple idea: what if learning Python felt less like following instructions
                        and more like <strong>actually building something you care about</strong>? We wanted a space where every
                        lesson connects to a real concept, every exercise has a purpose, and every student can see exactly how far they've come.
                    </p>
                    <p>
                        So we built this — a structured learning environment with real assessments, hands-on exercises,
                        proper progress tracking, and content that actually explains <em>why</em>, not just <em>what</em>.
                        From your first <strong>print("Hello World")</strong> to building data pipelines, we're here the whole way.
                    </p>
                    <p>
                        Whether you're a complete beginner, brushing up on the fundamentals, or pushing into advanced territory —
                        PythonAcademy meets you where you are.
                    </p>
                </div>
            </div>

            <%-- info panel — terminal look but rounded to fit site style --%>
            <div class="story-info-card">
                <div class="info-card-header">
                    <div class="info-card-dot active"></div>
                    <div class="info-card-dot"></div>
                    <div class="info-card-dot"></div>
                    <div class="info-card-title">python_academy.config</div>
                </div>
                <div class="info-card-body">
                    <div class="info-row"><span class="info-key">platform</span><span class="info-val hi">PythonAcademy v1.0</span></div>
                    <div class="info-row"><span class="info-key">focus</span><span class="info-val">Python Programming</span></div>
                    <div class="info-row"><span class="info-key">audience</span><span class="info-val">All Skill Levels</span></div>
                    <div class="info-row"><span class="info-key">mode</span><span class="info-val hi">Structured + Self-Paced</span></div>
                    <div class="info-row"><span class="info-key">assessments</span><span class="info-val">Quizzes + Exercises</span></div>
                    <div class="info-row"><span class="info-key">progress</span><span class="info-val hi">Tracked + Visualised</span></div>
                    <div class="info-row"><span class="info-key">content</span><span class="info-val">Video, PDF, Code</span></div>
                    <div class="info-row"><span class="info-key">access</span><span class="info-val hi">Free to Enroll</span></div>
                    <div class="info-row"><span class="info-key">roles</span><span class="info-val">Student &middot; Lecturer &middot; Admin</span></div>
                    <div class="info-row"><span class="info-key">status</span><span class="info-val hi">Online &#10003;</span></div>
                </div>
            </div>
        </div>
    </div>

    <div class="ab-divider"></div>

    <%-- =====================================================
         WHAT WE OFFER — features
         ===================================================== --%>
    <div class="ab-section">
        <div class="ab-section-header" style="text-align:center; max-width:600px; margin:0 auto 36px;">
            <span class="ab-eyebrow">What We Offer</span>
            <h2>Everything You Need To Go From Zero To Python Developer</h2>
            <p>Our platform covers the full learning loop — not just content, but feedback, tracking, and real exercises.</p>
        </div>

        <div class="ab-features-grid">
            <div class="ab-feature-card">
                <div class="ab-feature-icon">&#128218;</div>
                <h3>Structured Course Paths</h3>
                <p>Every course is broken into clear, progressive modules. Know exactly what you're learning, why it matters, and what's next.</p>
            </div>
            <div class="ab-feature-card">
                <div class="ab-feature-icon">&#128221;</div>
                <h3>Assessments &amp; Quizzes</h3>
                <p>Auto-graded assessments after each module give you instant feedback on what you know and where to revisit.</p>
            </div>
            <div class="ab-feature-card">
                <div class="ab-feature-icon">&#128187;</div>
                <h3>Hands-On Exercises</h3>
                <p>Submit code and written responses. No passive reading — you learn by actually writing Python and solving real problems.</p>
            </div>
            <div class="ab-feature-card">
                <div class="ab-feature-icon">&#128202;</div>
                <h3>Progress Tracking</h3>
                <p>Your dashboard shows completion percentage, recent scores, and what to tackle next — always know where you stand.</p>
            </div>
            <div class="ab-feature-card">
                <div class="ab-feature-icon">&#127909;</div>
                <h3>Rich Content Types</h3>
                <p>Lessons come as videos, PDFs, embedded code examples, and more. Learn the way that works for you.</p>
            </div>
            <div class="ab-feature-card">
                <div class="ab-feature-icon">&#128227;</div>
                <h3>Announcements</h3>
                <p>Lecturers post announcements directly to your dashboard so you never miss a course update or deadline.</p>
            </div>
        </div>
    </div>

    <div class="ab-divider"></div>

    <%-- =====================================================
         HOW IT WORKS — 4 steps
         ===================================================== --%>
    <div class="ab-section">
        <div class="ab-section-header" style="text-align:center; max-width:560px; margin:0 auto 36px;">
            <span class="ab-eyebrow">How It Works</span>
            <h2>Four Steps To Getting Started</h2>
            <p>Takes less than two minutes to sign up and start your first lesson.</p>
        </div>

        <div class="steps-grid">
            <div class="step-card">
                <div class="step-num">01</div>
                <h3>Create a Free Account</h3>
                <p>Sign up with your name and email. No payment or credit card — just pick a username and you're in.</p>
            </div>
            <div class="step-card">
                <div class="step-num">02</div>
                <h3>Browse &amp; Enroll</h3>
                <p>Explore the full catalogue, check out what's covered, and enroll in anything that interests you.</p>
            </div>
            <div class="step-card">
                <div class="step-num">03</div>
                <h3>Learn, Practice &amp; Submit</h3>
                <p>Work through lessons at your own pace. Watch videos, read material, and submit exercises when ready.</p>
            </div>
            <div class="step-card">
                <div class="step-num">04</div>
                <h3>Track Your Progress</h3>
                <p>See your scores, completion rates, and keep momentum going module by module from your dashboard.</p>
            </div>
        </div>
    </div>

    <div class="ab-divider"></div>

    <%-- =====================================================
         VALUES
         ===================================================== --%>
    <div class="ab-section">
        <div class="ab-section-header" style="margin-bottom:28px;">
            <span class="ab-eyebrow">What We Believe</span>
            <h2>Our Core Values</h2>
        </div>

        <div class="values-grid">
            <div class="value-card">
                <div class="value-num">01</div>
                <div>
                    <h4>Learning By Doing</h4>
                    <p>Reading about loops doesn't make you a programmer. Writing them does. Every lesson is designed to end with your hands on a keyboard.</p>
                </div>
            </div>
            <div class="value-card">
                <div class="value-num">02</div>
                <div>
                    <h4>Accessible to Everyone</h4>
                    <p>No background in maths or engineering required. If you can use a browser and you're willing to think, you can learn Python here.</p>
                </div>
            </div>
            <div class="value-card">
                <div class="value-num">03</div>
                <div>
                    <h4>Honest Progress Tracking</h4>
                    <p>We show you exactly where you stand — real completion data, real scores, real feedback. You should always know how you're doing.</p>
                </div>
            </div>
            <div class="value-card">
                <div class="value-num">04</div>
                <div>
                    <h4>Structure Without Rigidity</h4>
                    <p>We give you a clear path to follow, but you move at your own pace. No deadlines breathing down your neck — just the road forward.</p>
                </div>
            </div>
        </div>
    </div>

    <%-- =====================================================
         BOTTOM CTA — reuses site's .cta-banner class
         ===================================================== --%>
    <div class="cta-banner">
        <h2>Your First Line Of Python Is One Click Away.</h2>
        <p>Join hundreds of students already learning on PythonAcademy. Free to sign up, free to enroll, free to start building.</p>
        <div class="hero-actions">
            <a href="/LoginandRegister/RegisterPage.aspx" class="btn-primary">Create Free Account</a>
            <a href="browseCourses.aspx" class="btn-ghost">Explore Courses</a>
        </div>
    </div>

</asp:Content>
