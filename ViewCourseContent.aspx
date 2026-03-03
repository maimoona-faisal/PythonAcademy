<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewCourseContent.aspx.cs" Inherits="PythonAcademy.ViewCourseContent" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    View Module
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblError" runat="server" ForeColor="Red"></asp:Label>

    <asp:Panel ID="pnlContent" runat="server">
        <h2><asp:Label ID="lblTitle" runat="server"></asp:Label></h2>
        <p><asp:Label ID="lblDescription" runat="server"></asp:Label></p>

        <h3>Module Topics</h3>
        <asp:GridView ID="gvTopics" runat="server" AutoGenerateColumns="False">
            <Columns>
                <asp:BoundField DataField="Title" HeaderText="Topic" />
                <asp:BoundField DataField="Description" HeaderText="Description" />
                <asp:TemplateField HeaderText="Progress">
                    <ItemTemplate>
                        <div class="progress-container">
                            <div class="progress-bar" style='width:<%# Eval("ProgressPercentage") %>%;'>
                                <%# Eval("ProgressPercentage") %>%
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <asp:Button ID="btnTakeQuiz" runat="server" Text="Take Quiz" OnClick="btnTakeQuiz_Click" Visible="false" />
        <asp:Button ID="btnSubmitExercise" runat="server" 
    Text="Submit Exercise" 
    OnClick="btnSubmitExercise_Click" 
    Visible="false" 
    CssClass="btn btn-primary" />
    </asp:Panel>

</asp:Content>