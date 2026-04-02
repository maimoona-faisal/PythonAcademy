<%@ Page Title="Learner Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="LearnersProfile.aspx.cs" Inherits="WAPPAssignment.LearnersProfile" %>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <style>
            :root {
                --bg-color: #070d18;
                --card-bg: rgba(16, 31, 58, 0.65);
                --card-border: rgba(47, 125, 255, 0.2);
                --text-main: #e7eefc;
                --text-muted: #a9b8d6;
                --primary-accent: #2f7dff;
                --primary-gradient: linear-gradient(135deg, #2f7dff, #00c2ff);
                --input-bg: rgba(7, 13, 24, 0.5);
                --input-border: rgba(255, 255, 255, 0.12);
                --input-focus: rgba(47, 125, 255, 0.6);
            }

            .profile-wrapper {
                display: flex;
                justify-content: center;
                align-items: flex-start;
                padding: 80px 20px;
                min-height: calc(100vh - 200px);
            }

            .profile-card {
                background: var(--card-bg);
                border: 1px solid var(--card-border);
                border-radius: 24px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
                padding: 50px 40px;
                max-width: 650px;
                width: 100%;
                backdrop-filter: blur(10px);
                -webkit-backdrop-filter: blur(10px);
                animation: popIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            }

            @keyframes popIn {
                from {
                    transform: scale(0.95);
                    opacity: 0;
                }

                to {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            .profile-header {
                text-align: center;
                margin-bottom: 40px;
            }

            .profile-header .badge {
                display: inline-block;
                background: rgba(47, 125, 255, .15);
                border: 1px solid rgba(47, 125, 255, .35);
                color: #2f7dff;
                border-radius: 999px;
                padding: 6px 18px;
                font-size: .85rem;
                font-weight: 700;
                margin-bottom: 16px;
            }

            .profile-header h2 {
                font-size: 2.2rem;
                font-weight: 900;
                margin: 0 0 10px;
                background: var(--primary-gradient);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .profile-header p {
                color: var(--text-muted);
                font-size: 1rem;
                margin: 0;
                line-height: 1.6;
            }

            .profile-grid {
                display: grid;
                grid-template-columns: 140px 1fr;
                row-gap: 20px;
                column-gap: 20px;
                align-items: center;
                margin-bottom: 35px;
            }

            .profile-grid .label-cell {
                font-weight: 700;
                color: var(--text-muted);
                font-size: 0.95rem;
                text-align: right;
            }

            .profile-grid input[type="text"],
            .profile-grid input[type="password"] {
                width: 100% !important;
                max-width: 380px;
                background: var(--input-bg);
                border: 1px solid var(--input-border);
                border-radius: 12px;
                padding: 12px 16px;
                color: var(--text-main);
                font-size: 1rem;
                transition: all 0.3s ease;
                box-sizing: border-box;
                outline: none;
                font-family: inherit;
            }

            .profile-grid input[type="text"]:focus:not([readonly]),
            .profile-grid input[type="password"]:focus:not([readonly]) {
                border-color: var(--primary-accent);
                box-shadow: 0 0 0 3px rgba(47, 125, 255, 0.25);
                background: rgba(16, 31, 58, 0.9);
            }

            .profile-grid input[readonly] {
                opacity: 0.65;
                cursor: not-allowed;
                background: rgba(255, 255, 255, 0.03);
                border-color: transparent;
            }

            .profile-actions {
                display: flex;
                flex-wrap: wrap;
                gap: 14px;
                justify-content: center;
                padding-top: 30px;
                border-top: 1px solid rgba(255, 255, 255, 0.08);
            }

            .btn-action {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 26px;
                border-radius: 50px;
                font-size: 0.95rem;
                font-weight: 800;
                text-decoration: none;
                cursor: pointer;
                transition: all 0.2s ease;
                border: none;
            }

            .btn-primary {
                background: var(--primary-gradient);
                color: #fff;
                box-shadow: 0 4px 15px rgba(47, 125, 255, 0.4);
            }

            .btn-primary:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(47, 125, 255, 0.55);
            }

            .btn-primary:disabled {
                background: rgba(47, 125, 255, 0.15);
                color: rgba(255, 255, 255, 0.4);
                box-shadow: none;
                cursor: not-allowed;
                transform: none;
                border: 1px solid rgba(47, 125, 255, 0.3);
            }

            .btn-secondary {
                background: rgba(255, 255, 255, 0.06);
                border: 1px solid rgba(255, 255, 255, 0.18);
                color: var(--text-main);
            }

            .btn-secondary:hover:not(:disabled) {
                background: rgba(255, 255, 255, 0.12);
                border-color: rgba(255, 255, 255, 0.3);
                transform: translateY(-2px);
            }

            @media (max-width: 650px) {
                .profile-card {
                    padding: 40px 24px;
                }

                .profile-grid {
                    grid-template-columns: 1fr;
                    row-gap: 8px;
                }

                .profile-grid .label-cell {
                    text-align: left;
                    margin-top: 12px;
                }

                .profile-grid input[type="text"],
                .profile-grid input[type="password"] {
                    max-width: 100%;
                }

                .profile-actions {
                    flex-direction: column;
                }

                .btn-action {
                    width: 100%;
                }
            }

            .profile-pic-section {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 32px;
            }

            .profile-pic-frame {
                width: 120px;
                height: 120px;
                border-radius: 50%;
                border: 3px solid rgba(47, 125, 255, 0.4);
                overflow: hidden;
                box-shadow: 0 0 25px rgba(47, 125, 255, 0.2);
                margin-bottom: 16px;
                background: rgba(16, 31, 58, 0.8);
                transition: border-color 0.3s, box-shadow 0.3s;
            }

            .profile-pic-frame:hover {
                border-color: rgba(47, 125, 255, 0.7);
                box-shadow: 0 0 35px rgba(47, 125, 255, 0.35);
            }

            .profile-pic-frame img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .upload-area {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 10px;
            }

            .upload-hint {
                font-size: .82rem;
                color: var(--text-muted);
            }

            .upload-error {
                color: #ff4757;
                font-size: .85rem;
                font-weight: 600;
                margin-top: 6px;
            }

            .upload-success {
                color: #00e676;
                font-size: .85rem;
                font-weight: 600;
                margin-top: 6px;
            }
        </style>

        <div class="profile-wrapper">
            <div class="profile-card">
                <div class="profile-header">
                    <div class="badge">My Account</div>
                    <h2>Learner Profile</h2>
                    <p>Manage your account details and track your learning progress.</p>
                </div>

                <%-- ── Profile Picture Section ── --%>
                <div class="profile-pic-section">
                    <div class="profile-pic-frame">
                        <asp:Image ID="imgProfilePic" runat="server" AlternateText="Profile Picture"
                            ImageUrl="~/Images/default-avatar.png" />
                    </div>

                    <div class="upload-area">
                        <asp:FileUpload ID="fuProfilePic" runat="server" accept=".jpg,.jpeg,.png,.gif"
                            onchange="previewProfilePic(this)" style="display:none;" />
                        <asp:Button ID="btnChooseFile" runat="server" Text="Choose Photo"
                            CssClass="btn-action btn-secondary" OnClientClick="document.getElementById(fuProfilePicId).click(); return false;" />
                        <span class="upload-hint">JPG, PNG, or GIF — max 2 MB</span>
                        <asp:Label ID="lblPicMessage" runat="server" Visible="false" />
                    </div>
                </div>

                <div class="profile-grid">
                    <div class="label-cell">User ID</div>
                    <div>
                        <asp:TextBox ID="TextBox1" runat="server" CssClass="input-box"
                            OnTextChanged="TextBox1_TextChanged" AutoPostBack="true"></asp:TextBox>
                    </div>

                    <div class="label-cell">Username</div>
                    <div>
                        <asp:TextBox ID="TextBox2" runat="server" CssClass="input-box"></asp:TextBox>
                    </div>

                    <div class="label-cell">Email</div>
                    <div>
                        <asp:TextBox ID="TextBox4" runat="server" CssClass="input-box"></asp:TextBox>
                    </div>

                    <div class="label-cell">Password</div>
                    <div>
                        <asp:TextBox ID="TextBox5" runat="server" CssClass="input-box" TextMode="Password">
                        </asp:TextBox>
                    </div>

                    <div class="label-cell">Role</div>
                    <div>
                        <asp:TextBox ID="TextBox6" runat="server" CssClass="input-box"></asp:TextBox>
                    </div>
                </div>

                <div class="profile-actions">
                    <asp:Button ID="Button1" runat="server" Text="Edit" CssClass="btn-action btn-primary"
                        OnClick="btnEdit_Click" />
                    <asp:Button ID="Button2" runat="server" Text="Confirm" CssClass="btn-action btn-primary"
                        OnClick="btnConfirm_Click" Enabled="False" />
                    <asp:Button ID="btnProgressCheck" runat="server" Text="Progress Check"
                        CssClass="btn-action btn-secondary" OnClick="btnProgressCheck_Click" />
                    <asp:Button ID="btnFeedback" runat="server" Text="Feedback" CssClass="btn-action btn-secondary"
                        OnClick="btnFeedback_Click" />
                </div>
            </div>
        </div>

        <script>
            // ── Client-side Profile Picture Preview ──
            var fuProfilePicId = '<%= fuProfilePic.ClientID %>';
            var imgProfilePicId = '<%= imgProfilePic.ClientID %>';

            // Wire up the "Choose Photo" button
            document.addEventListener('DOMContentLoaded', function () {
                var chooseBtnId = '<%= btnChooseFile.ClientID %>';
                var chooseBtn = document.getElementById(chooseBtnId);
                if (chooseBtn) {
                    chooseBtn.onclick = function (e) {
                        e.preventDefault();
                        document.getElementById(fuProfilePicId).click();
                        return false;
                    };
                }
            });

            function previewProfilePic(input) {
                if (input.files && input.files[0]) {
                    var file = input.files[0];

                    // Validate file type
                    var allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
                    if (allowedTypes.indexOf(file.type) === -1) {
                        alert('Please select a JPG, PNG, or GIF image.');
                        input.value = '';
                        return;
                    }

                    // Validate file size (2 MB max)
                    if (file.size > 2 * 1024 * 1024) {
                        alert('Image must be under 2 MB.');
                        input.value = '';
                        return;
                    }

                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var img = document.getElementById(imgProfilePicId);
                        if (img) img.src = e.target.result;
                    };
                    reader.readAsDataURL(file);
                }
            }
        </script>

    </asp:Content>