<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningMaterials.aspx.cs" Inherits="PythonAcademy.LearningMaterials" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Available Learning Modules
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Available Learning Modules</h2>

    <asp:GridView ID="gvModules" runat="server" AutoGenerateColumns="False"
        OnRowCommand="gvModules_RowCommand" GridLines="Both"
        HeaderStyle-BackColor="#2f7dff" HeaderStyle-ForeColor="White">

        <Columns>
            <asp:BoundField DataField="ContentId" HeaderText="ID" />
            <asp:BoundField DataField="Title" HeaderText="Title" />
            <asp:BoundField DataField="Description" HeaderText="Description" />
            <asp:BoundField DataField="Status" HeaderText="Progress Status" />

            <asp:ButtonField Text="Start Course"
                CommandName="StartCourse"
                ButtonType="Button" />
        </Columns>

    </asp:GridView>

</asp:Content>
