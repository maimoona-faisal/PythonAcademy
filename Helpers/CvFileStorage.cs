using System;
using System.Collections.Generic;
using System.IO;
using System.Web;

namespace PythonAcademy.Helpers
{
    public static class CvFileStorage
    {
        private const string StorageFolderName = "CVs";
        private const string CvEndpointVirtualPath = "~/Admin/CvFile.aspx";

        private static readonly ISet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf",
            ".doc",
            ".docx"
        };

        public static bool IsAllowedExtension(string extension)
        {
            return !string.IsNullOrWhiteSpace(extension) && AllowedExtensions.Contains(extension);
        }

        public static bool IsSafeFileName(string fileName)
        {
            return !string.IsNullOrWhiteSpace(fileName) && string.Equals(fileName, Path.GetFileName(fileName), StringComparison.Ordinal);
        }

        public static string GetPhysicalPath(HttpServerUtility server, string fileName)
        {
            if (!IsSafeFileName(fileName))
            {
                throw new ArgumentException("Invalid file name.", "fileName");
            }

            string folder = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "PythonAcademy",
                "Uploads",
                StorageFolderName);

            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }

            return Path.Combine(folder, fileName);
        }

        public static string BuildPublicPath(string fileName)
        {
            if (!IsSafeFileName(fileName))
            {
                throw new ArgumentException("Invalid file name.", "fileName");
            }

            return CvEndpointVirtualPath + "?name=" + HttpUtility.UrlEncode(fileName);
        }
    }
}
