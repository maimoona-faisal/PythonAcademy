<%@ Page Title="Lecturer Dashboard" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <h2 style="margin:0 0 6px 0;">Lecturer Dashboard</h2>
    <p class="muted" style="margin:0 0 18px 0;">
        Manage your content, assessments, grading, and profile from here.
    </p>

    <div class="dash-grid">

        <a runat="server" class="dash-card" href="~/UploadContent.aspx">
            <div class="dash-title">Upload Learning Content</div>
            <div class="dash-desc">Add PDFs, videos, images, or links for students.</div>
            <div class="dash-cta">Open →</div>
        </a>

        <a runat="server" class="dash-card" href="~/CreateAssessment.aspx">
            <div class="dash-title">Create Assessment</div>
            <div class="dash-desc">Build assessments and publish them when ready.</div>
            <div class="dash-cta">Open →</div>
        </a>

        <a runat="server" class="dash-card" href="~/Lecturer/Grade.aspx">
            <div class="dash-title">Grade Learners</div>
            <div class="dash-desc">Review submissions and assign marks.</div>
            <div class="dash-cta">Open →</div>
        </a>

        <a runat="server" class="dash-card" href="~/Lecturer/Feedback.aspx">
            <div class="dash-title">Check Feedback</div>
            <div class="dash-desc">View comments and suggestions from students.</div>
            <div class="dash-cta">Open →</div>
        </a>

        <a runat="server" class="dash-card" href="~/Lecturer/Profile.aspx">
            <div class="dash-title">Edit Profile</div>
            <div class="dash-desc">Update your lecturer information and details.</div>
            <div class="dash-cta">Open →</div>
        </a>

    </div>

    <!-- Internal CSS -->
    <style>
        .dash-grid{
            display:grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            margin-top: 12px;
        }

        /* Full-width card on last row if odd count */
        .dash-grid a:last-child{
            grid-column: 1 / -1;
        }

        .dash-card{
            display:block;
            padding: 16px;
            border-radius: 16px;
            text-decoration:none;
            border: 1px solid rgba(255,255,255,.12);
            background: rgba(255,255,255,.05);
            transition: transform .15s ease, background .15s ease, border-color .15s ease;
        }

        .dash-card:hover{
            transform: translateY(-2px);
            background: rgba(255,255,255,.07);
            border-color: rgba(255,255,255,.20);
        }

        .dash-title{
            font-weight: 900;
            font-size: 1.05rem;
            margin-bottom: 6px;
        }

        .dash-desc{
            color: rgba(255,255,255,.72);
            line-height: 1.35;
            margin-bottom: 14px;
        }

        .dash-cta{
            font-weight: 800;
            color: rgba(0,194,255,.95);
        }

        /* Mobile */
        @media (max-width: 720px){
            .dash-grid{
                grid-template-columns: 1fr;
            }
            .dash-grid a:last-child{
                grid-column: auto;
            }
        }
    </style>

</asp:Content>
