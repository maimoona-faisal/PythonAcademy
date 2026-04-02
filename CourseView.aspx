<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseView.aspx.cs" Inherits="PythonAcademy.CourseView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Course View
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .course-wrap {
            max-width: 900px;
            margin: 0 auto;
        }

        .course-box {
            background: rgba(16,31,58,.65);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 18px;
            padding: 28px;
            margin-bottom: 24px;
        }

        .course-box h1, .course-box h2, .course-box h3 {
            color: #e7eefc;
        }

        .course-box p, .course-box li {
            color: #cdd8ef;
            line-height: 1.8;
        }

        .locked-section {
            margin-top: 30px;
            border: 1px solid rgba(255,255,255,.12);
            background: rgba(7,13,24,.82);
            border-radius: 18px;
            padding: 32px;
            text-align: center;
        }

        .locked-section h3 {
            margin-bottom: 10px;
            color: #e7eefc;
        }

        .locked-section p {
            color: #a9b8d6;
            margin-bottom: 20px;
        }

        .locked-actions {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .locked-actions a,
        .locked-actions button {
            padding: 12px 20px;
            border-radius: 999px;
            text-decoration: none;
            border: none;
            cursor: pointer;
            font-weight: 800;
        }

        .btn-login {
            background: linear-gradient(135deg,#2f7dff,#00c2ff);
            color: #fff;
        }

        .btn-signup {
            background: rgba(255,255,255,.08);
            border: 1px solid rgba(255,255,255,.16);
            color: #e7eefc;
        }
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="course-wrap">

        <div class="course-box">
            <h1><asp:Literal ID="litTitle" runat="server"></asp:Literal></h1>
            <p><asp:Literal ID="litDescription" runat="server"></asp:Literal></p>
        </div>

        <asp:PlaceHolder ID="phGuestPreview" runat="server" Visible="false">
            <div class="course-box">
                <h2>Introduction</h2>
                <asp:Literal ID="litPreviewContent" runat="server"></asp:Literal>

                <div class="locked-section">
                    <h3>This section is locked</h3>
                    <p>
                        You have reached the end of the free preview.
                        Log in or create an account to continue reading the full lesson,
                        attempt quizzes, and access exercises.
                    </p>

                    <div class="locked-actions">
                        <a href="/LoginandRegister/LoginPage.aspx" class="btn-login">Log In</a>
                        <a href="/LoginandRegister/RegisterPage.aspx" class="btn-signup">Create Account</a>
                    </div>
                </div>
            </div>
        </asp:PlaceHolder>

        <asp:PlaceHolder ID="phFullAccess" runat="server" Visible="false">
            <div class="course-box">
                <h2>Full Course Content</h2>
                <asp:Literal ID="litFullContent" runat="server"></asp:Literal>
            </div>
        </asp:PlaceHolder>

    </div>
</asp:Content>
