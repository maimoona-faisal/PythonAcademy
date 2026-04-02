using System;
using System.Collections.Generic;
using System.IO;
using System.Web;

namespace PythonAcademy.Helpers
{
    public static class ContentFileStorage
    {
        private const string StorageFolderName = "Content";
        private const string ContentEndpointVirtualPath = "~/Lecture/ContentFile.aspx";

        private static readonly ISet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf",
            ".png",
            ".jpg",
            ".jpeg",
            ".gif",
            ".mp4",
            ".webm",
            ".ppt",
            ".pptx",
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

        public static string EnsureStorageFolder(HttpServerUtility server)
        {
            string folder = GetStorageFolder();
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }

            return folder;
        }

        public static string GetPhysicalPath(HttpServerUtility server, string fileName)
        {
            if (server == null)
            {
                throw new ArgumentNullException("server");
            }

            if (!IsSafeFileName(fileName))
            {
                throw new ArgumentException("Invalid file name.", "fileName");
            }

            return Path.Combine(EnsureStorageFolder(server), fileName);
        }

        public static string BuildUniqueFileName(string originalName)
        {
            string extension = (Path.GetExtension(originalName) ?? string.Empty).ToLowerInvariant();
            string baseName = Path.GetFileNameWithoutExtension(originalName) ?? string.Empty;

            foreach (char invalidChar in Path.GetInvalidFileNameChars())
            {
                baseName = baseName.Replace(invalidChar, '_');
            }

            baseName = baseName.Trim();
            if (string.IsNullOrWhiteSpace(baseName))
            {
                baseName = "file";
            }

            return baseName + "_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + extension;
        }

        public static string BuildPublicPath(string fileName)
        {
            if (!IsSafeFileName(fileName))
            {
                throw new ArgumentException("Invalid file name.", "fileName");
            }

            return ContentEndpointVirtualPath + "?name=" + HttpUtility.UrlEncode(fileName);
        }

        public static bool TryResolvePhysicalPath(HttpServerUtility server, string storedPath, out string physicalPath)
        {
            physicalPath = null;

            if (server == null || string.IsNullOrWhiteSpace(storedPath))
            {
                return false;
            }

            if (storedPath.StartsWith(ContentEndpointVirtualPath, StringComparison.OrdinalIgnoreCase))
            {
                int queryIndex = storedPath.IndexOf('?');
                if (queryIndex < 0 || queryIndex == storedPath.Length - 1)
                {
                    return false;
                }

                string query = storedPath.Substring(queryIndex + 1);
                string fileName = HttpUtility.ParseQueryString(query)["name"];
                if (!IsSafeFileName(fileName))
                {
                    return false;
                }

                physicalPath = GetPhysicalPath(server, fileName);
                return true;
            }

            return false;
        }

        private static string GetStorageFolder()
        {
            string root = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "PythonAcademy",
                "Uploads",
                StorageFolderName);

            return root;
        }
    }
}
