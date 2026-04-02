<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="PythonAcademy.Helpers" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string fileName = Request.QueryString["name"];
        if (!ContentFileStorage.IsSafeFileName(fileName))
        {
            Response.StatusCode = 400;
            Response.Write("Invalid file name.");
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        string physicalPath = ContentFileStorage.GetPhysicalPath(Server, fileName);
        if (!File.Exists(physicalPath))
        {
            Response.StatusCode = 404;
            Response.Write("File not found.");
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        Response.Clear();
        Response.ContentType = MimeMapping.GetMimeMapping(fileName);
        Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName.Replace("\"", string.Empty) + "\"");
        Response.TransmitFile(physicalPath);
        Context.ApplicationInstance.CompleteRequest();
    }
</script>
