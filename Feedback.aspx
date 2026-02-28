<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="WAPPAssignment.Feedback" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div style="text-align:center;" >
            <asp:Label ID="Label1" runat="server" Text="Feedback Submission" BorderColor="Black" Style="font-weight:bold; font-size:32px; color:#333;" ></asp:Label>
            <br />
        </div>
        <p style="text-align:center;" >
        <asp:Label ID="Label2" runat="server" Text="Feel free to give any opinions for our applications"></asp:Label>
        </p>
        <p style="text-align:center;" >
            <asp:TextBox ID="TextBox1" runat="server" OnTextChanged="TextBox1_TextChanged" style="margin-left: 0px" Width="505px"></asp:TextBox>
        </p>
        <p style="text-align:center;" >
            <asp:Label ID="Label3" runat="server" Text="Your feedback means a lot to us~" Style="font-weight:bold; font-size:16px; color:#0026ff" ></asp:Label>
        </p>
        
    </form>
</body>
</html>
