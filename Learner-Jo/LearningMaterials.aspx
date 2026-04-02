<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningMaterials.aspx.cs" Inherits="PythonAcademy.LearningMaterials" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Learning Modules
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        body { font-family: 'Outfit', sans-serif; }

        .lm-hero { margin-bottom: 32px; }
        .lm-hero h2 {
            margin: 0 0 6px;
            font-size: 1.9rem;
            font-weight: 900;
            background: linear-gradient(90deg, #fff 30%, #2f7dff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .lm-hero p { margin: 0; color: #a9b8d6; font-size: .95rem; }

        .filter-bar { display: flex; gap: 12px; margin-bottom: 28px; flex-wrap: wrap; align-items: center; }
        .search-wrap { position: relative; flex: 1; min-width: 200px; }
        .search-wrap svg {
            position: absolute; left: 12px; top: 50%;
            transform: translateY(-50%); color: #a9b8d6; pointer-events: none;
        }
        .search-input {
            width: 100%;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.12);
            border-radius: 10px;
            color: #e7eefc;
            font-size: .9rem;
            padding: 10px 14px 10px 40px;
            outline: none;
            transition: border-color .2s;
            font-family: 'Outfit', sans-serif;
        }
        .search-input:focus { border-color: #2f7dff; }
        .search-input::placeholder { color: #a9b8d6; }

        .module-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 22px;
        }
        .module-card {
            background: rgba(16,31,58,.72);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 18px;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: 0;
            transition: transform .25s, border-color .25s, box-shadow .25s;
            animation: fadeUp .5s ease both;
            position: relative;
            overflow: hidden;
        }
        .module-card-body {
            padding: 20px 24px 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        /* ── Course Thumbnail ── */
        .module-thumb {
            width: 100%; height: 160px;
            background-size: cover; background-position: center;
            background-repeat: no-repeat;
            position: relative;
        }
        .module-thumb::after {
            content: '';
            position: absolute; inset: 0;
            background: linear-gradient(180deg, transparent 40%, rgba(16,31,58,.95) 100%);
        }
        .module-thumb-placeholder {
            background: linear-gradient(135deg, rgba(47,125,255,.2), rgba(0,194,255,.12));
            display: flex; align-items: center; justify-content: center;
            font-size: 2.4rem; font-weight: 900; color: rgba(255,255,255,.12);
        }

        /* ── Category Badge ── */
        .category-badge {
            display: inline-flex; align-items: center; gap: 5px;
            background: rgba(0,194,255,.1); border: 1px solid rgba(0,194,255,.28);
            color: #00c2ff; border-radius: 999px;
            padding: 4px 14px; font-size: .76rem; font-weight: 700;
            width: fit-content; letter-spacing: .3px; text-transform: uppercase;
        }
        .module-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, #2f7dff, #00c2ff);
            border-radius: 18px 18px 0 0;
            opacity: 0;
            transition: opacity .25s;
        }
        .module-card:hover { transform: translateY(-5px); border-color: rgba(47,125,255,.45); box-shadow: 0 16px 40px rgba(0,0,0,.45); }
        .module-card:hover::before { opacity: 1; }

        .module-icon {
            width: 44px; height: 44px; border-radius: 12px;
            background: linear-gradient(135deg, rgba(47,125,255,.3), rgba(0,194,255,.2));
            border: 1px solid rgba(47,125,255,.3);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem;
        }
        .module-id { font-family: 'JetBrains Mono', monospace; font-size: .72rem; color: #a9b8d6; }
        .module-title { font-size: 1.1rem; font-weight: 700; color: #e7eefc; line-height: 1.35; }
        .module-desc { font-size: .88rem; color: #a9b8d6; line-height: 1.55; flex: 1; }

        .mod-status {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: .78rem; font-weight: 600;
            padding: 4px 10px; border-radius: 999px; width: fit-content;
        }
        .mod-status::before { content: ''; width: 7px; height: 7px; border-radius: 50%; background: currentColor; }
        .mod-status-new { color: #a9b8d6; background: rgba(169,184,214,.12); }
        .mod-status-inprogress { color: #ffd740; background: rgba(255,215,64,.1); }
        .mod-status-done { color: #00e676; background: rgba(0,230,118,.1); }

        .btn-start {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 8px; padding: 11px 18px; border-radius: 12px;
            font-size: .9rem; font-weight: 700; cursor: pointer; border: none;
            background: linear-gradient(135deg, #2f7dff, #00c2ff);
            color: #fff; transition: opacity .2s, transform .2s;
            font-family: 'Outfit', sans-serif;
        }
        .btn-start:hover { opacity: .88; transform: scale(1.02); }

        .empty-state { grid-column: 1 / -1; text-align: center; padding: 60px 20px; color: #a9b8d6; }
        .empty-state p { font-size: 1rem; margin-top: 16px; }

        @keyframes fadeUp { from { opacity:0; transform: translateY(16px); } to { opacity:1; transform: none; } }

        /* ── Course Detail Modal ── */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.65); backdrop-filter: blur(6px); z-index: 9999; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .detail-modal-box { background: #0f1829; border: 1px solid rgba(47,125,255,.25); border-radius: 24px; max-width: 520px; width: 92%; box-shadow: 0 20px 60px rgba(0,0,0,.6); position: relative; animation: popIn .25s ease; overflow: hidden; text-align: left; }
        @keyframes popIn { from{transform:scale(.9);opacity:0} to{transform:scale(1);opacity:1} }
        .detail-thumb { height: 160px; background: linear-gradient(135deg, rgba(47,125,255,.2), rgba(0,194,255,.1)); display: flex; align-items: center; justify-content: center; font-size: 3rem; font-weight: 900; color: rgba(255,255,255,0.2); }
        .detail-body { padding: 28px 30px 32px; }
        .detail-tag { display: inline-block; background: rgba(0,194,255,.12); border: 1px solid rgba(0,194,255,.3); color: #00c2ff; border-radius: 999px; padding: 4px 14px; font-size: .8rem; font-weight: 700; margin-bottom: 14px; }
        .detail-body h3 { font-size: 1.5rem; font-weight: 900; margin: 0 0 10px; color: #e7eefc; }
        .detail-body .detail-desc { color: #a9b8d6; font-size: .95rem; line-height: 1.65; margin: 0 0 24px; }
        .detail-actions { display: flex; gap: 12px; }
        .detail-btn-start { flex: 1; padding: 12px; border-radius: 50px; font-weight: 800; font-size: 1rem; text-align: center; border: none; cursor: pointer; background: linear-gradient(135deg,#2f7dff,#00c2ff); color: #fff; transition: opacity .2s; font-family: 'Outfit', sans-serif; }
        .detail-btn-start:hover { opacity: .88; }
        .detail-btn-cancel { padding: 12px 22px; border-radius: 50px; font-weight: 700; font-size: 1rem; text-align: center; background: rgba(255,255,255,.07); border: 1px solid rgba(255,255,255,.18); color: #e7eefc; cursor: pointer; transition: background .2s; font-family: 'Outfit', sans-serif; }
        .detail-btn-cancel:hover { background: rgba(255,255,255,.13); }
        .modal-close { position: absolute; top: 14px; right: 18px; background: none; border: none; color: #a9b8d6; font-size: 1.4rem; cursor: pointer; z-index: 3; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="lm-hero">
        <h2>Available Learning Modules</h2>
        <p>Choose a module to begin your Python learning journey.</p>
    </div>

    <div class="filter-bar">
        <div class="search-wrap">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" />
            </svg>
            <input type="text" class="search-input" placeholder="Search modules..." oninput="filterCards(this.value)" />
        </div>
    </div>

    <div class="module-grid">
        <asp:Repeater ID="rptModules" runat="server" OnItemCommand="rptModules_ItemCommand">
            <ItemTemplate>
                <div class="module-card searchable"
                     data-title='<%# GetSearchTitle(Eval("Title")) %>'
                     style='animation-delay: <%# Container.ItemIndex * 70 %>ms'>

                    <%-- ── Thumbnail ── --%>
                    <div class='module-thumb <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ThumbnailPath"))) ? "module-thumb-placeholder" : "" %>'
                         style='<%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ThumbnailPath"))) ? "background-image:url(" + GetThumbnailUrl(Eval("ThumbnailPath")) + ");" : "" %>'>
                        <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ThumbnailPath"))) ? "PY" : "" %>
                    </div>

                    <div class="module-card-body">
                        <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
                            <span class="category-badge"><%#: GetCategoryLabel(Eval("Category")) %></span>
                            <span class="module-id">MODULE #<%#: Eval("ContentId") %></span>
                        </div>

                        <div class="module-title"><%#: Eval("Title") %></div>
                        <div class="module-desc"><%#: Eval("Description") %></div>

                        <asp:Label runat="server"
                            CssClass='<%# "mod-status " + GetStatusClass(Eval("Status")) %>'
                            Text='<%# Convert.ToString(Eval("Status")) %>' />

                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToString(Eval("Status")) == "Not Enrolled" %>'>
                            <button type="button" class="btn-start"
                                    onclick='showCourseDetail("<%# Eval("ContentId") %>",
                                              "<%# HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("Title"))) %>",
                                              "<%# HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("Description"))) %>",
                                              "<%# Convert.ToString(Eval("ContentType")) %>",
                                              "<%# HttpUtility.JavaScriptStringEncode(GetThumbnailUrl(Eval("ThumbnailPath"))) %>",
                                              "<%# HttpUtility.JavaScriptStringEncode(GetCategoryLabel(Eval("Category"))) %>")'>
                                View Details
                            </button>
                        </asp:PlaceHolder>

                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToString(Eval("Status")) != "Not Enrolled" %>'>
                            <asp:Button runat="server"
                                Text="Go to Module"
                                CssClass="btn-start"
                                CommandName="StartCourse"
                                CommandArgument='<%# Eval("ContentId") %>'
                                CausesValidation="false"
                                UseSubmitBehavior="false" />
                        </asp:PlaceHolder>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#a9b8d6" stroke-width="1.3">
                    <path d="M12 2L2 7l10 5 10-5-10-5z" /><path d="M2 17l10 5 10-5" /><path d="M2 12l10 5 10-5" />
                </svg>
                <p>No modules available right now. Check back soon!</p>
            </div>
        </asp:Panel>
    </div>


    <asp:HiddenField ID="hfSelectedModule" runat="server" />

    <div id="courseDetailModal" class="modal-overlay" onclick="closeDetailOnOverlay(event)">
        <div class="detail-modal-box">
            <button type="button" class="modal-close" onclick="closeCourseDetail()">&#10005;</button>

            <div id="detailThumb" class="detail-thumb" style="height:180px; background-size:cover; background-position:center; background-repeat:no-repeat;"></div>

            <div class="detail-body">
                <span id="detailCategory" class="detail-tag"></span>
                <span id="detailTag" class="detail-tag" style="margin-left:6px;"></span>
                <h3 id="detailTitle"></h3>
                <p id="detailDesc" class="detail-desc"></p>

                <div class="detail-actions">
                    <asp:Button ID="btnModalEnroll" runat="server" Text="Enroll Now" CssClass="detail-btn-start" OnClick="btnModalEnroll_Click" CausesValidation="false" UseSubmitBehavior="false" />
                    <button type="button" class="detail-btn-cancel" onclick="closeCourseDetail()">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function filterCards(query) {
            query = query.toLowerCase().trim();
            document.querySelectorAll('.searchable').forEach(function (card) {
                card.style.display = (card.dataset.title || '').includes(query) ? '' : 'none';
            });
        }

        // Modal Logic — now accepts thumbnailUrl and category
        function showCourseDetail(id, title, desc, type, thumbUrl, category) {
            document.getElementById('detailTitle').textContent = title;
            document.getElementById('detailDesc').textContent = desc;
            document.getElementById('detailTag').textContent = type ? type : 'Module';

            // Thumbnail
            var thumbEl = document.getElementById('detailThumb');
            if (thumbUrl && thumbUrl.trim() !== '') {
                thumbEl.style.backgroundImage = 'url(' + thumbUrl + ')';
            } else {
                thumbEl.style.backgroundImage = 'none';
                thumbEl.style.background = 'linear-gradient(135deg, rgba(47,125,255,.2), rgba(0,194,255,.1))';
            }

            // Category
            var catEl = document.getElementById('detailCategory');
            catEl.textContent = category ? category : 'General';

            // Give the C# backend the ID of the course we are looking at
            document.getElementById('<%= hfSelectedModule.ClientID %>').value = id;

            document.getElementById('courseDetailModal').classList.add('open');
        }

        function closeCourseDetail() {
            document.getElementById('courseDetailModal').classList.remove('open');
        }

        function closeDetailOnOverlay(e) {
            if (e.target === document.getElementById('courseDetailModal')) closeCourseDetail();
        }

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeCourseDetail();
        });
    </script>
</asp:Content>
