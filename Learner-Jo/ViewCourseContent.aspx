<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewCourseContent.aspx.cs" Inherits="PythonAcademy.ViewCourseContent" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    View Module
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

        .course-header-img {
            width: 100%;
            height: 280px;
            object-fit: cover;
            border-radius: 16px;
            border: 2px solid rgba(255,255,255,0.1);
            margin-bottom: 24px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            display: block;
        }

        .module-hero {
            display: flex; flex-direction: column;
            margin-bottom: 36px; padding-bottom: 28px;
            border-bottom: 1px solid rgba(255,255,255,.1); 
        }

        .hero-text h2 { margin: 0 0 8px; font-size: 2.2rem; font-weight: 900; color: #e7eefc; text-shadow: 0 0 20px rgba(0, 216, 255, 0.2); }
        .hero-text p { margin: 0; color: #a9b8d6; font-size: 1rem; line-height: 1.55; }

        .lecturer-badge {
            display: inline-block;
            background: rgba(0, 216, 255, 0.1);
            color: #00d8ff;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: bold;
            border: 1px solid rgba(0, 216, 255, 0.2);
            margin-top: 15px;
        }

        .section-title {
            font-size: 1.1rem; font-weight: 700; color: #e7eefc;
            margin: 0 0 16px; display: flex; align-items: center; gap: 8px;
        }
        .section-title::after { content: ''; flex: 1; height: 1px; background: rgba(255,255,255,.1); }

        .topic-list { 
            display: flex; flex-direction: column; 
            gap: 14px; margin-bottom: 32px; width: 100%;
        }
        
        .topic-card {
            width: 100%;
            background: rgba(16,31,58,.65); border: 1px solid rgba(255,255,255,.09);
            border-radius: 14px; padding: 18px 20px;
            display: flex; justify-content: space-between; align-items: center;
            transition: border-color .2s, transform .2s;
            animation: fadeUp .45s ease both;
        }
        .topic-card:hover { border-color: rgba(47,125,255,.35); transform: translateX(4px); }
        .topic-name { font-weight: 700; font-size: 1rem; color: #e7eefc; }

        /* Buttons */
        .action-row { display: flex; gap: 14px; flex-wrap: wrap; padding-top: 4px; }
        
        .btn-quiz-act {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px; border-radius: 12px;
            font-size: .95rem; font-weight: 700; cursor: pointer; border: none;
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            color: #fff; transition: opacity .2s, transform .2s;
            font-family: 'Outfit', sans-serif;
        }
        .btn-quiz-act:hover { opacity: .88; transform: scale(1.02); }
        
        .btn-ex-act {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px; border-radius: 12px;
            font-size: .95rem; font-weight: 700; cursor: pointer;
            border: 1px solid rgba(0,230,118,.45);
            background: rgba(0,230,118,.1); color: #00e676;
            transition: all .2s; font-family: 'Outfit', sans-serif;
        }
        .btn-ex-act:hover { background: rgba(0,230,118,.2); border-color: #00e676; color: #fff; }

        .btn-outline {
            display: inline-flex; align-items: center; justify-content: center;
            padding: 12px 24px; border-radius: 12px; font-size: .95rem; font-weight: 700;
            border: 1px solid rgba(255,255,255,.2); color: white; background: transparent; text-decoration: none;
            transition: 0.2s ease; cursor: pointer;
        }
        .btn-outline:hover { background: rgba(255,255,255,.05); border-color: white; }

        .no-topics { padding: 28px; text-align: center; color: #a9b8d6; font-size: .92rem; border-radius: 12px;
            background: rgba(16,31,58,.5); border: 1px dashed rgba(255,255,255,.1); }

        .feedback-panel {
            background: rgba(13, 25, 48, 0.85); backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px;
            padding: 30px; margin-top: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .neon-input { 
            width: 100%; padding: 14px; border-radius: 12px; 
            border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(0, 0, 0, 0.2); 
            color: white; font-size: 1rem; outline: none; transition: 0.3s; 
            margin-bottom: 20px; resize: vertical; box-sizing: border-box;
        }
        .neon-input:focus { border-color: #00d8ff; box-shadow: 0 0 10px rgba(0, 216, 255, 0.15); }

        @keyframes fadeUp { from { opacity:0; transform: translateY(14px); } to { opacity:1; transform: none; } }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="error-alert">Warning: <asp:Label ID="lblError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server">
        
       <div class="module-hero">
            <asp:Image ID="imgThumbnail" runat="server" CssClass="course-header-img" />

            <div class="hero-text">
                <h2><asp:Label ID="lblTitle" runat="server" /></h2>
                <p><asp:Label ID="lblDescription" runat="server" /></p>
               <div class="lecturer-badge">&#127891; Module Uploaded by: <asp:Label ID="lblLecturer" runat="server" /></div>

                <asp:Panel ID="pnlAdminControls" runat="server" Visible="false" style="margin-top: 20px; display: flex; gap: 10px;">
                    <asp:LinkButton ID="btnEditContent" runat="server" CssClass="btn-outline" OnClick="btnEditContent_Click">
                        &#9999;&#65039; Edit Course Shell
                    </asp:LinkButton>
                    
                    <asp:LinkButton ID="btnManageTopics" runat="server" CssClass="btn-outline" 
                        style="border-color: #ffd740; color: #ffd740; background: rgba(255, 215, 64, 0.1);" 
                        OnClick="btnManageTopics_Click">
                         &#9881;&#65039; Manage Topics
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnDeleteContent" runat="server" CssClass="btn-quiz-act" 
                         style="background: linear-gradient(135deg, #ff4d4d, #cc0000); border: none;" 
                         OnClientClick="return confirm('Are you sure you want to unpublish this module?');" 
                         OnClick="btnDeleteContent_Click">
                        Unpublish Content
                    </asp:LinkButton>
                </asp:Panel>
            </div>
        </div>

        <div class="section-title">Module Topics</div>

        <div class="topic-list">
            <asp:Repeater ID="rptTopics" runat="server" OnItemCommand="rptTopics_ItemCommand">
                <ItemTemplate>
                    <div class="topic-card" style='animation-delay: <%# Container.ItemIndex * 80 %>ms;'>
                                
                        <div class="topic-name" style="font-size: 1.1rem;">
                            <span style='margin-right: 10px; font-size: 1.2rem;'>
                                <%# Convert.ToInt32(Eval("IsCompleted")) == 1 ? "&#x2705;" : "&#x23F3;" %>
                            </span>
                            <%# Eval("OrderIndex") %>. <%#: Eval("TopicTitle") %>
                        </div>

                        <div>
                            <asp:LinkButton runat="server"
                                CommandName="START_LESSON"
                                CommandArgument='<%# Eval("TopicId") %>'
                                CssClass='<%# Convert.ToInt32(Eval("IsCompleted")) == 1 ? "btn-outline" : "btn-quiz-act" %>'
                                Text='<%# GetLessonButtonText(Eval("IsCompleted")) %>'
                                style="padding: 8px 16px; font-size: 0.9rem;">
                            </asp:LinkButton>
                        </div>
                        
                    </div> 
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Panel ID="pnlNoTopics" runat="server" Visible="false" CssClass="no-topics">
            The instructor has not added any lessons to this module yet.
        </asp:Panel>

        <div class="action-row" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid rgba(255,255,255,0.1);">
            <asp:Button ID="btnViewCert" runat="server" Text="Download Certificate" OnClick="btnViewCert_Click" Visible="false" CssClass="btn-quiz-act" style="background: linear-gradient(135deg, #ffd740, #f39c12); color: #000;" CausesValidation="false" UseSubmitBehavior="false" />
            <asp:Button ID="btnTakeQuiz" runat="server" Text="Take Quiz" OnClick="btnTakeQuiz_Click" Visible="false" CssClass="btn-quiz-act" CausesValidation="false" UseSubmitBehavior="false" />
            <asp:Button ID="btnSubmitExercise" runat="server" Text="Submit Exercise" OnClick="btnSubmitExercise_Click" Visible="false" CssClass="btn-ex-act" CausesValidation="false" UseSubmitBehavior="false" />
        </div>

        <asp:Panel ID="pnlFeedback" runat="server" CssClass="feedback-panel" Visible="false">
<h3 style="color: white; margin-top: 0; margin-bottom: 5px; font-size: 1.3rem;">&#128172; Module Feedback</h3>
            <p style="color: #8fa4c4; font-size: 0.95rem; margin-bottom: 20px;">Did you enjoy this module? Found an error? Let the instructor know!</p>
            
            <asp:TextBox ID="txtFeedback" runat="server" TextMode="MultiLine" Rows="4" 
                CssClass="neon-input" placeholder="Type your thoughts here..."></asp:TextBox>
            
            <div style="display: flex; align-items: center; gap: 15px;">
                <asp:Button ID="btnSubmitFeedback" runat="server" Text="Send Feedback" 
                    OnClick="btnSubmitFeedback_Click" CssClass="btn-quiz-act" 
                    style="background: linear-gradient(90deg, #00d8ff, #0a67ff); border: none;" />
                
                <asp:Label ID="lblFeedbackMsg" runat="server" Visible="false" style="font-weight: bold;"></asp:Label>
            </div>
        </asp:Panel>

    </asp:Panel>

</asp:Content>