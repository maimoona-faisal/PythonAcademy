using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using System.Web;

namespace PythonAcademy
{
    public static class EmailManager
    {
        public static async Task SendLecturerApprovalAsync(string toEmail, string lecturerName)
        {
            try
            {
                // 1. Read the HTML template
                string templatePath = System.Web.Hosting.HostingEnvironment.MapPath("~/EmailTemplates/LecturerApproved.html");
                string emailBody = File.ReadAllText(templatePath);

                // 2. Swap the placeholders with real data
                string loginUrl = "https://localhost:44309/LoginandRegister/LoginPage.aspx"; // Check port number
                emailBody = emailBody.Replace("{LecturerName}", lecturerName);
                emailBody = emailBody.Replace("{LoginUrl}", loginUrl);

                // 3. secure credentials from Web.config
                string senderEmail = ConfigurationManager.AppSettings["PlatformEmail"];
                string senderPass = ConfigurationManager.AppSettings["PlatformEmailAppPassword"];

                // 4. Construct the Email
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(senderEmail, "Python Academy Admin");
                mail.To.Add(toEmail);
                mail.Subject = "Your Lecturer Account is Approved! 🎉";
                mail.Body = emailBody;
                mail.IsBodyHtml = true;

                // 5. Connect to Google and Send
                using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
                {
                    smtp.Credentials = new NetworkCredential(senderEmail, senderPass);
                    smtp.EnableSsl = true;
                    await smtp.SendMailAsync(mail);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine("EMAIL ERROR: " + ex.Message);
            }
        }

        public static async Task SendLecturerRejectionAsync(string toEmail, string lecturerName, string rejectionReason)
        {
            try
            {
                string templatePath = System.Web.Hosting.HostingEnvironment.MapPath("~/EmailTemplates/LecturerRejected.html");
                string emailBody = File.ReadAllText(templatePath);

                emailBody = emailBody.Replace("{LecturerName}", lecturerName);
                emailBody = emailBody.Replace("{RejectionReason}", rejectionReason);

                string senderEmail = ConfigurationManager.AppSettings["PlatformEmail"];
                string senderPass = ConfigurationManager.AppSettings["PlatformEmailAppPassword"];

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(senderEmail, "Python Academy Admin");
                mail.To.Add(toEmail);
                mail.Subject = "Update on your Lecturer Application";
                mail.Body = emailBody;
                mail.IsBodyHtml = true;

                using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
                {
                    smtp.Credentials = new NetworkCredential(senderEmail, senderPass);
                    smtp.EnableSsl = true;
                    await smtp.SendMailAsync(mail);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine("EMAIL ERROR: " + ex.Message);
            }
        }
    }
}