<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterPage.aspx.cs" Inherits="PythonAcademy.WebForm2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Register.PythonAcademy
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <div style="display: flex; justify-content: center; align-items: center; min-height: 50vh;">
        <div style="width: 100%; max-width: 400px; padding: 40px; border-radius: 24px; background: var(--surface); box-shadow: 0 20px 50px rgba(0,0,0,0.5); border: 1px solid var(--line);">
            
            <div style="margin-bottom: 30px;">
                <h1 style="font-size: 2.5rem; font-weight: 800; color: white; margin: 0; line-height: 1.2;">
                    Create <br />
                    new account<span style="color: var(--primary);">.</span>
                </h1>
                <p style="color: var(--muted); margin-top: 10px;">
                    Join the community to start learning.
                </p>
            </div>

            <%-- server-side message shown after form submit (success or error from code-behind) --%>
            <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:block; text-align:center; margin-bottom: 20px; font-weight:bold; padding: 10px; border-radius: 8px;"></asp:Label>
            
            <asp:Label ID="Label1" runat="server" Visible="false" style="display:block; text-align:center; margin-bottom: 20px; font-weight:bold; padding: 10px; border-radius: 8px;"></asp:Label>

            <%-- USERNAME --%>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Username</label>
                <asp:TextBox ID="txtUsername" runat="server"  
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
                <%-- inline error that lights up if username is invalid --%>
                <span id="errUsername" style="color:#ff4d4d; font-size:0.78rem; display:none; margin-top:4px; display:block;"></span>
            </div>

            <%-- FULL NAME --%>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Full Name</label>
                <asp:TextBox ID="txtName" runat="server"  
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
                <span id="errName" style="color:#ff4d4d; font-size:0.78rem; display:none; margin-top:4px; display:block;"></span>
            </div>

            <%-- EMAIL --%>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine"
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
                <span id="errEmail" style="color:#ff4d4d; font-size:0.78rem; display:none; margin-top:4px; display:block;"></span>
            </div>

            <%-- ROLE DROPDOWN --%>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">I am registering as a</label>
                <asp:DropDownList ID="ddlRole" runat="server" onchange="toggleLecturerFields()" style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                    <asp:ListItem Value="Student">Learner (Student)</asp:ListItem>
                    <asp:ListItem Value="Lecturer">Instructor (Lecturer)</asp:ListItem>
                </asp:DropDownList>
            </div>

            <%-- LECTURER EXTRA FIELDS - hidden unless Lecturer is selected --%>
            <div id="lecturerFields" style="display:none; padding:18px; background:rgba(0,194,255,.05); border:1px dashed rgba(0,194,255,.3); border-radius:12px; margin-bottom:20px;">
                <p style="margin:0 0 12px 0; color:#00c2ff; font-size:.9rem; font-weight:bold;">Instructor Verification</p>
                
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.85rem;">Upload CV (PDF/Word)</label>
                <asp:FileUpload ID="fuCV" runat="server" style="width: 100%; margin-bottom: 15px; color: white;" />

                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.85rem;">Or LinkedIn Profile URL</label>
                <asp:TextBox ID="txtLinkedIn" runat="server" placeholder="https://linkedin.com/in/..."
                    style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid rgba(255,255,255,.1); background: #0b1220; color: white; outline: none;">
                </asp:TextBox>
            </div>

            <%-- PASSWORD with show/hide checkbox --%>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>

                <%-- password strength bar - fills up and changes colour as you type --%>
                <div style="margin-top: 8px;">
                    <div style="height: 4px; background: #1a2235; border-radius: 4px; overflow: hidden;">
                        <div id="strengthBar" style="height: 100%; width: 0%; border-radius: 4px; transition: all 0.3s;"></div>
                    </div>
                    <span id="strengthText" style="font-size: 0.75rem; color: #8899aa; margin-top: 4px; display: block;"></span>
                </div>

                <%-- password rules shown as a checklist - each one turns green as you meet it --%>
                <div style="margin-top: 8px; font-size: 0.75rem; color: #8899aa;">
                    <div id="ruleLength"  style="margin-top:2px;">At least 8 characters</div>
                    <div id="ruleUpper"   style="margin-top:2px;">At least one uppercase letter</div>
                    <div id="ruleNumber"  style="margin-top:2px;">At least one number</div>
                    <div id="ruleSpecial" style="margin-top:2px;">At least one special character (!@#$...)</div>
                </div>

                <%-- show password checkbox --%>
                <div style="margin-top: 8px; display: flex; align-items: center; gap: 6px;">
                    <input type="checkbox" id="chkShowPassword" onchange="toggleShowPassword()" />
                    <label for="chkShowPassword" style="color: var(--muted); font-size: 0.8rem; cursor: pointer;">Show password</label>
                </div>
                <span id="errPassword" style="color:#ff4d4d; font-size:0.78rem; display:none; margin-top:4px; display:block;"></span>
            </div>

            <%-- VERIFY PASSWORD with live match check --%>
            <div style="margin-bottom: 30px;">
                <label style="display: block; margin-bottom: 8px; color: var(--muted); font-size: 0.9rem; font-weight: bold;">Verify Password</label>
                <asp:TextBox ID="txtVerifyPassword" runat="server" TextMode="Password"
                    style="width: 100%; padding: 16px; border-radius: 12px; border: 2px solid transparent; background: #0b1220; color: white; font-size: 1rem; outline: none; transition: 0.3s;">
                </asp:TextBox>
                <%-- shows a live "passwords match" or "do not match" message as they type --%>
                <span id="errVerify" style="font-size:0.78rem; display:none; margin-top:4px; display:block;"></span>
            </div>

            <%-- the button calls validateForm() first before allowing server submit --%>
            <asp:Button ID="btnRegister" runat="server" Text="Create Account" OnClick="btnRegister_Click"
                OnClientClick="return validateForm();"
                CssClass="btn" 
                style="width: 100%; background-color: var(--primary); color: white; border: none; padding: 16px; font-size: 1.1rem; border-radius: 50px; cursor: pointer; font-weight: 800; box-shadow: 0 4px 15px rgba(47, 125, 255, 0.4);" />
    
    <style>
        input:focus, select:focus {
            border-color: var(--primary) !important;
            background: #0f1829 !important;
        }
        /* red border on fields that fail validation */
        .field-error { border-color: #ff4d4d !important; }
    </style>

    <script>

        // --- show password checkbox ---
        // toggles both password fields visible/hidden when the checkbox is ticked
        function toggleShowPassword() {
            var chk    = document.getElementById('chkShowPassword');
            var pwd    = document.getElementById('<%= txtPassword.ClientID %>');
            var verify = document.getElementById('<%= txtVerifyPassword.ClientID %>');
            pwd.type    = chk.checked ? 'text' : 'password';
            verify.type = chk.checked ? 'text' : 'password';
        }

        // --- show/hide lecturer fields based on role dropdown ---
        function toggleLecturerFields() {
            var roleDropdown  = document.getElementById('<%= ddlRole.ClientID %>');
            var lecturerFields = document.getElementById('lecturerFields');
            lecturerFields.style.display = roleDropdown.value === 'Lecturer' ? 'block' : 'none';
        }

        // --- password strength checker - runs on every keyup ---
        document.addEventListener('DOMContentLoaded', function () {
            var pwdInput = document.getElementById('<%= txtPassword.ClientID %>');
            var verifyInput = document.getElementById('<%= txtVerifyPassword.ClientID %>');

            pwdInput.addEventListener('keyup', function () {
                checkStrength(this.value);
                checkMatch(this.value, verifyInput.value);
            });

            verifyInput.addEventListener('keyup', function () {
                checkMatch(pwdInput.value, this.value);
            });
        });

        function checkStrength(password) {
            var bar         = document.getElementById('strengthBar');
            var text        = document.getElementById('strengthText');
            // check each rule to calculate strength score
            var hasLength  = password.length >= 8;
            var hasUpper   = /[A-Z]/.test(password);
            var hasNumber  = /[0-9]/.test(password);
            var hasSpecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);

            // update each rule row - green if passing, grey if not
            toggleRule(document.getElementById('ruleLength'),  hasLength,  'At least 8 characters');
            toggleRule(document.getElementById('ruleUpper'),   hasUpper,   'At least one uppercase letter');
            toggleRule(document.getElementById('ruleNumber'),  hasNumber,  'At least one number');
            toggleRule(document.getElementById('ruleSpecial'), hasSpecial, 'At least one special character (!@#$...)');

            // count how many rules pass to decide the strength level
            var score = [hasLength, hasUpper, hasNumber, hasSpecial].filter(Boolean).length;

            if (password.length === 0) {
                bar.style.width = '0%';
                text.textContent = '';
                return;
            }

            if (score <= 1) {
                bar.style.width = '25%';
                bar.style.background = '#ff4d4d';
                text.style.color = '#ff4d4d';
                text.textContent = 'Weak';
            } else if (score === 2) {
                bar.style.width = '50%';
                bar.style.background = '#f5a623';
                text.style.color = '#f5a623';
                text.textContent = 'Fair';
            } else if (score === 3) {
                bar.style.width = '75%';
                bar.style.background = '#00c2ff';
                text.style.color = '#00c2ff';
                text.textContent = 'Good';
            } else {
                bar.style.width = '100%';
                bar.style.background = '#00ff88';
                text.style.color = '#00ff88';
                text.textContent = 'Strong';
            }
        }



        // marks a rule row green when passed, grey when not - no symbols used
        function toggleRule(el, passed, text) {
            if (passed) {
                el.textContent = text;
                el.style.color = '#00ff88';
            } else {
                el.textContent = text;
                el.style.color = '#8899aa';
            }
        }

        // live check if both password fields match
        function checkMatch(pwd, verify) {
            var errVerify = document.getElementById('errVerify');
            if (verify.length === 0) {
                errVerify.style.display = 'none';
                return;
            }
            errVerify.style.display = 'block';
            if (pwd === verify) {
                errVerify.style.color = '#00ff88';
                errVerify.innerHTML = '&#10003; Passwords match';
            } else {
                errVerify.style.color = '#ff4d4d';
                errVerify.innerHTML = '&#10007; Passwords do not match';
            }
        }

        // --- main client-side validation before form submits to server ---
        // returns false to stop the submit if anything fails
        function validateForm() {
            var valid = true;

            var username = document.getElementById('<%= txtUsername.ClientID %>').value.trim();
            var name     = document.getElementById('<%= txtName.ClientID %>').value.trim();
            var email    = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
            var password = document.getElementById('<%= txtPassword.ClientID %>').value;
            var verify   = document.getElementById('<%= txtVerifyPassword.ClientID %>').value;

            // reset all error spans first
            clearError('errUsername'); clearError('errName');
            clearError('errEmail');   clearError('errPassword');

            // username: required, 3-30 chars, no spaces
            if (username.length === 0) {
                showError('errUsername', 'Username is required.'); valid = false;
            } else if (username.length < 3 || username.length > 30) {
                showError('errUsername', 'Username must be between 3 and 30 characters.'); valid = false;
            } else if (/\s/.test(username)) {
                showError('errUsername', 'Username cannot contain spaces.'); valid = false;
            }

            // full name: required
            if (name.length === 0) {
                showError('errName', 'Full name is required.'); valid = false;
            }

            // email: required + basic format check
            if (email.length === 0) {
                showError('errEmail', 'Email is required.'); valid = false;
            } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                showError('errEmail', 'Please enter a valid email address.'); valid = false;
            }

            // password: must meet all 4 strength rules
            if (password.length === 0) {
                showError('errPassword', 'Password is required.'); valid = false;
            } else if (password.length < 8) {
                showError('errPassword', 'Password must be at least 8 characters.'); valid = false;
            } else if (!/[A-Z]/.test(password)) {
                showError('errPassword', 'Password must contain at least one uppercase letter.'); valid = false;
            } else if (!/[0-9]/.test(password)) {
                showError('errPassword', 'Password must contain at least one number.'); valid = false;
            } else if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
                showError('errPassword', 'Password must contain at least one special character.'); valid = false;
            }

            // verify password: must match
            if (password !== verify) {
                var errVerify = document.getElementById('errVerify');
                errVerify.style.display = 'block';
                errVerify.style.color   = '#ff4d4d';
                errVerify.textContent   = '✗ Passwords do not match';
                valid = false;
            }

            return valid;
        }

        function showError(id, message) {
            var el = document.getElementById(id);
            el.textContent     = message;
            el.style.display   = 'block';
            el.style.color     = '#ff4d4d';
        }

        function clearError(id) {
            var el = document.getElementById(id);
            el.textContent   = '';
            el.style.display = 'none';
        }

    </script>
</asp:Content>
