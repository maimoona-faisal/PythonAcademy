#  Python Academy

A modern, full-stack e-learning platform built with ASP.NET Web Forms and C#. Python Academy is designed to provide an interactive, gamified learning experience with structured courses, automated assessments, and a real-time messaging system.

##  Key Features

###  Role-Based Access Control (RBAC)
* **Learners:** Can browse courses, track progress, take quizzes, submit exercises, and earn dynamic certificates.
* **Lecturers:** Can upload module content (PDFs, PPTs, Videos, Links), create quizzes, grade exercises, and respond to student feedback.
* **Administrators:** Full oversight with a secure dashboard to manage users, approve/reject instructor registrations, toggle system maintenance mode, and review activity logs.

###  Interactive Learning Engine
* **Multimedia Support:** Native rendering for PDFs, YouTube embeds, Google Slides, and standard text/code snippets.
* **Automated Assessments:** Auto-graded multiple-choice quizzes and instructor-graded coding exercises.
* **Dynamic Certificates:** Automatically generates personalized, downloadable PDF certificates upon 100% module completion.

###  Integrated Communication
* **Direct Messaging:** A WhatsApp-style, database-driven messaging system allowing students and lecturers to communicate securely.
* **Feedback Loops:** Built-in module feedback forms for continuous course improvement.

###  Advanced Backend Systems
* **Asynchronous Email Automation:** Uses `QueueBackgroundWorkItem` to send registration approval/rejection emails in the background without freezing the UI.
* **Security-First Architecture:** Implements SHA-256 password hashing, parameterized SQL queries to prevent SQL injection, and strict server-side form validation.
* **Global Kill-Switches:** Admins can instantly lock down the platform via Maintenance Mode or disable the messaging system platform-wide.

##  Tech Stack

* **Frontend:** HTML5, CSS3, Vanilla JavaScript
* **UI/UX:** Custom "Dark-Neon / Glassmorphism" aesthetic with smooth CSS animations.
* **Backend:** C# (.NET Framework)
* **Framework:** ASP.NET Web Forms
* **Database:** Microsoft SQL Server (ADO.NET)

## Getting Started

### Prerequisites
* Visual Studio 2019 or later (with ASP.NET and web development workload)
* Microsoft SQL Server Management Studio (SSMS)


---
*Developed as a Web Application Development project focusing on secure, scalable, and user-centric software design.*
