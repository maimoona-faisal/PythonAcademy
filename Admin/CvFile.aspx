<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="PythonAcademy.Helpers" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        // block anyone who isn't an admin — 403 = "Forbidden"
        if (!string.Equals(Convert.ToString(Session["Role"]), "Admin", StringComparison.OrdinalIgnoreCase))
        {
            Response.StatusCode = 403;
            Response.Write("Forbidden.");
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        // "name" comes from the query string, e.g. CvFile.aspx?name=cv_123.pdf
        string fileName = Request.QueryString["name"];

        // validate the filename before touching the filesystem — prevents path traversal attacks 
        if (!CvFileStorage.IsSafeFileName(fileName))
        {
            Response.StatusCode = 400;
            Response.Write("Invalid file name.");
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        string physicalPath = CvFileStorage.GetPhysicalPath(Server, fileName);
        if (!File.Exists(physicalPath))
        {
            Response.StatusCode = 404;
            Response.Write("File not found.");
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        Response.Clear();
        // GetMimeMapping figures out the Content-Type from the file extension 
        Response.ContentType = MimeMapping.GetMimeMapping(fileName);
        // "inline" tells the browser to display the file in-tab rather than force a download
        Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName.Replace("\"", string.Empty) + "\"");
        Response.TransmitFile(physicalPath); // streams the file directly from disk to the browser
        Context.ApplicationInstance.CompleteRequest();
    }
</script>
