<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs" 
    Inherits="PythonAcademy.MemberDashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Student Dashboard
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>My Learning Dashboard</h2>
    <p class="muted">Track your enrolled modules and progress below.</p>

    <asp:GridView ID="gvDashboard" runat="server"
        AutoGenerateColumns="False"
        OnRowCommand="gvDashboard_RowCommand"
        GridLines="None"
        CssClass="table">

        <Columns>

            <asp:BoundField DataField="ContentId" HeaderText="ID" />

            <asp:BoundField DataField="Title" HeaderText="Title" />

            <asp:BoundField DataField="Description" HeaderText="Description" />

            <asp:BoundField DataField="ProgressStatus" HeaderText="Status" />

            <asp:TemplateField HeaderText="Progress">
                <ItemTemplate>
                    <div style="background:#1a2b4c; border-radius:12px; overflow:hidden;">
                        <div style='background:#2f7dff; padding:4px; width:<%# Eval("ProgressPercentage") %>% ; color:white; text-align:center;'>
                            <%# Eval("ProgressPercentage") %>%
                        </div>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:ButtonField Text="View"
                CommandName="ViewModule"
                ButtonType="Button" />

            <asp:ButtonField Text="Quiz"
                CommandName="TakeQuiz"
                ButtonType="Button" />

        </Columns>
    </asp:GridView>

</asp:Content>