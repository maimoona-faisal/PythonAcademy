-- =============================================
-- PythonAcademy Full Database Script
-- Run this on a fresh .mdf file in App_Data
-- =============================================

-- =============================================
-- 1. USERS (no dependencies)
-- =============================================
CREATE TABLE Users (
    UserId      INT IDENTITY(1,1) PRIMARY KEY,
    Username    NVARCHAR(50)  NOT NULL,
    Email       NVARCHAR(100) NOT NULL,
    Password    NVARCHAR(255) NOT NULL,
    Role        NVARCHAR(20)  NOT NULL,
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'Active',
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 2. PLATFORM SETTINGS (no dependencies)
-- =============================================
CREATE TABLE PlatformSettings (
    SettingKey   NVARCHAR(100) NOT NULL PRIMARY KEY,
    SettingValue NVARCHAR(500) NULL,
    UpdatedAt    DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 3. ACTIVITY LOGS (depends on Users)
-- =============================================
CREATE TABLE ActivityLogs (
    LogId       INT IDENTITY(1,1) PRIMARY KEY,
    UserID      INT           NULL FOREIGN KEY REFERENCES Users(UserId),
    Action      NVARCHAR(100) NOT NULL,
    Details     NVARCHAR(MAX) NULL,
    Timestamp   DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 4. ANNOUNCEMENTS (depends on Users)
-- =============================================
CREATE TABLE Announcements (
    AnnouncementID  INT IDENTITY(1,1) PRIMARY KEY,
    AdminID         INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    Title           NVARCHAR(200) NOT NULL,
    Message         NVARCHAR(MAX) NOT NULL,
    TargetAudience  NVARCHAR(50)  NOT NULL,
    CreatedAt       DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 5. VERIFICATION LOG (depends on Users)
-- =============================================
CREATE TABLE VerificationLog (
    ModerationId  INT IDENTITY(1,1) PRIMARY KEY,
    TargetID      INT           NOT NULL,
    TargetType    NVARCHAR(50)  NOT NULL,
    AdminID       INT           NULL FOREIGN KEY REFERENCES Users(UserId),
    Status        NVARCHAR(20)  NOT NULL,
    Comments      NVARCHAR(MAX) NULL,
    ReviewedAt    DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 6. USER REPORTS (depends on Users)
-- =============================================
CREATE TABLE UserReports (
    ReportId          INT IDENTITY(1,1) PRIMARY KEY,
    ReporterId        INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ReportedEntityId  NVARCHAR(50)  NOT NULL,
    Reason            NVARCHAR(MAX) NULL,
    Status            NVARCHAR(20)  NOT NULL DEFAULT 'Pending',
    CreatedAt         DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 7. LEARNING CONTENT (depends on Users)
-- =============================================
CREATE TABLE LearningContent (
    ContentId    INT IDENTITY(1,1) PRIMARY KEY,
    LecturerId   INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    Title        NVARCHAR(200) NOT NULL,
    Description  NVARCHAR(MAX) NULL,
    ContentType  NVARCHAR(50)  NULL,
    FilePath     NVARCHAR(300) NULL,
    Url          NVARCHAR(500) NULL,
    IsPublished  BIT           NOT NULL DEFAULT 0,
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 8. ASSESSMENT (depends on Users + LearningContent)
-- =============================================
CREATE TABLE Assessment (
    AssessmentId       INT IDENTITY(1,1) PRIMARY KEY,
    LecturerId         INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ContentId          INT           NOT NULL FOREIGN KEY REFERENCES LearningContent(ContentId),
    Title              NVARCHAR(200) NOT NULL,
    AssessmentType     NVARCHAR(50)  NOT NULL,
    Instructions       NVARCHAR(MAX) NULL,
    TotalMarks         INT           NOT NULL DEFAULT 0,
    TimeLimitMinutes   INT           NULL,
    DueDate            DATETIME      NULL,
    IsPublished        BIT           NOT NULL DEFAULT 0,
    CreatedAt          DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 9. QUESTION (depends on Assessment)
-- =============================================
CREATE TABLE Question (
    QuestionId    INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentId  INT           NOT NULL FOREIGN KEY REFERENCES Assessment(AssessmentId),
    QuestionText  NVARCHAR(MAX) NOT NULL,
    QuestionType  NVARCHAR(50)  NOT NULL,
    Marks         INT           NOT NULL DEFAULT 1
);

-- =============================================
-- 10. QUESTION OPTION (depends on Question)
-- =============================================
CREATE TABLE QuestionOption (
    OptionId     INT IDENTITY(1,1) PRIMARY KEY,
    QuestionId   INT           NOT NULL FOREIGN KEY REFERENCES Question(QuestionId),
    OptionText   NVARCHAR(500) NOT NULL,
    IsCorrect    BIT           NOT NULL DEFAULT 0
);

-- =============================================
-- 11. ENROLMENT (depends on Users + LearningContent)
-- =============================================
CREATE TABLE Enrolment (
    EnrolmentID  INT IDENTITY(1,1) PRIMARY KEY,
    StudentId    INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ModuleID     INT           NOT NULL FOREIGN KEY REFERENCES LearningContent(ContentId),
    Status       NVARCHAR(20)  NOT NULL DEFAULT 'In Progress',
    EnrolledAt   DATETIME      NOT NULL DEFAULT GETDATE(),
    CompletedAt  DATETIME      NULL
);

-- =============================================
-- 12. PROGRESS (depends on Users + LearningContent)
-- =============================================
CREATE TABLE Progress (
    ProgressID          INT IDENTITY(1,1) PRIMARY KEY,
    StudentId           INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ModuleID            INT NOT NULL FOREIGN KEY REFERENCES LearningContent(ContentId),
    TopicsCompleted     INT NOT NULL DEFAULT 0,
    TotalTopics         INT NOT NULL DEFAULT 0,
    ProgressPercentage  INT NOT NULL DEFAULT 0
);

-- =============================================
-- 13. FEEDBACK (depends on Users)
-- =============================================
CREATE TABLE Feedback (
    FeedbackID       INT IDENTITY(1,1) PRIMARY KEY,
    StudentId        INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    FeedbackMessage  NVARCHAR(MAX) NOT NULL,
    CreatedAt        DATETIME      NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- 14. CERTIFICATES (depends on Users + LearningContent)
-- =============================================
CREATE TABLE Certificates (
    CertificateID   INT IDENTITY(1,1) PRIMARY KEY,
    StudentId       INT           NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ModuleID        INT           NOT NULL FOREIGN KEY REFERENCES LearningContent(ContentId),
    IssuedDate      DATETIME      NOT NULL DEFAULT GETDATE(),
    CertificateCode NVARCHAR(100) NOT NULL,
    FinalScore      INT           NOT NULL DEFAULT 0
);

-- =============================================
-- 15. ASSESSMENT SUBMISSION (depends on Assessment + Users)
-- =============================================
CREATE TABLE AssessmentSubmission (
    SubmissionId  INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentId  INT      NOT NULL FOREIGN KEY REFERENCES Assessment(AssessmentId),
    StudentId     INT      NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    SubmittedAt   DATETIME NOT NULL DEFAULT GETDATE(),
    TotalScore    INT      NOT NULL DEFAULT 0
);

-- =============================================
-- 16. SUBMISSION ANSWER (depends on AssessmentSubmission + Question)
-- =============================================
CREATE TABLE SubmissionAnswer (
    AnswerId          INT IDENTITY(1,1) PRIMARY KEY,
    SubmissionId      INT           NOT NULL FOREIGN KEY REFERENCES AssessmentSubmission(SubmissionId),
    QuestionId        INT           NOT NULL FOREIGN KEY REFERENCES Question(QuestionId),
    SelectedOptionId  INT           NULL,
    AnswerText        NVARCHAR(MAX) NULL,
    MarksAwarded      INT           NULL
);

-- =============================================
-- =============================================
-- SEED DATA
-- =============================================
-- =============================================

-- =============================================
-- USERS
-- 1 Admin, 1 Lecturer, 2 Students
-- =============================================
INSERT INTO Users (Username, Email, Password, Role, Status) VALUES
('Maimoona',  'admin@pythonacademy.com',    'admin123',    'Admin',    'Active'),
('Khawlah',   'lecturer@pythonacademy.com', 'lecture123',  'Lecturer', 'Active'),
('Joseph',    'joseph@pythonacademy.com',   'student123',  'Student',  'Active'),
('WeiHan',    'weihan@pythonacademy.com',   'student123',  'Student',  'Active');

-- UserId: Maimoona=1, Khawlah=2, Joseph=3, WeiHan=4

-- =============================================
-- PLATFORM SETTINGS
-- =============================================
INSERT INTO PlatformSettings (SettingKey, SettingValue) VALUES
('SiteName',         'Python Academy'),
('MaintenanceMode',  'false'),
('MaxUploadSizeMB',  '50'),
('ContactEmail',     'support@pythonacademy.com');

-- =============================================
-- LEARNING CONTENT
-- 3 modules uploaded by Khawlah (LecturerId=2)
-- =============================================
INSERT INTO LearningContent (LecturerId, Title, Description, ContentType, Url, IsPublished) VALUES
(2, 'Python Basics',       'Introduction to Python programming, variables and data types.',  'Article', 'https://docs.python.org/3/tutorial/', 1),
(2, 'Control Flow',        'Learn about if statements, loops and conditional expressions.',  'Video',   'https://www.youtube.com/watch?v=example1', 1),
(2, 'Functions & Modules', 'Understanding functions, scope, imports and Python modules.',    'PDF',     NULL, 1);

-- ContentId: Python Basics=1, Control Flow=2, Functions & Modules=3

-- =============================================
-- ASSESSMENTS
-- One Quiz and one Exercise per module
-- =============================================
INSERT INTO Assessment (LecturerId, ContentId, Title, AssessmentType, Instructions, TotalMarks, IsPublished) VALUES
(2, 1, 'Python Basics Quiz',            'Quiz',     'Answer all MCQ questions. Each correct answer = 1 mark.',  3, 1),
(2, 1, 'Python Basics Exercise',        'Exercise', 'Write short answers to the questions below.',              2, 1),
(2, 2, 'Control Flow Quiz',             'Quiz',     'Answer all MCQ questions. Each correct answer = 1 mark.',  3, 1),
(2, 2, 'Control Flow Exercise',         'Exercise', 'Write short answers to the questions below.',              2, 1),
(2, 3, 'Functions & Modules Quiz',      'Quiz',     'Answer all MCQ questions. Each correct answer = 1 mark.',  3, 1),
(2, 3, 'Functions & Modules Exercise',  'Exercise', 'Write short answers to the questions below.',              2, 1);

-- AssessmentId: 1=Basics Quiz, 2=Basics Exercise, 3=CF Quiz, 4=CF Exercise, 5=FM Quiz, 6=FM Exercise

-- =============================================
-- QUESTIONS
-- MCQ for quizzes, Text for exercises
-- =============================================

-- Python Basics Quiz (AssessmentId=1) - MCQ
INSERT INTO Question (AssessmentId, QuestionText, QuestionType, Marks) VALUES
(1, 'What is the correct way to declare a variable in Python?',     'MCQ', 1),
(1, 'Which of the following is a valid Python data type?',          'MCQ', 1),
(1, 'What does the print() function do?',                           'MCQ', 1);

-- Python Basics Exercise (AssessmentId=2) - Written
INSERT INTO Question (AssessmentId, QuestionText, QuestionType, Marks) VALUES
(2, 'Explain the difference between a list and a tuple in Python.', 'Text', 1),
(2, 'What is a variable and how do you assign a value to it?',      'Text', 1);

-- Control Flow Quiz (AssessmentId=3) - MCQ
INSERT INTO Question (AssessmentId, QuestionText, QuestionType, Marks) VALUES
(3, 'Which keyword is used to start an if statement in Python?',    'MCQ', 1),
(3, 'What does a for loop do?',                                     'MCQ', 1),
(3, 'Which statement exits a loop immediately?',                    'MCQ', 1);

-- Control Flow Exercise (AssessmentId=4) - Written
INSERT INTO Question (AssessmentId, QuestionText, QuestionType, Marks) VALUES
(4, 'Write a Python loop that prints numbers 1 to 5.',              'Text', 1),
(4, 'Explain when you would use a while loop vs a for loop.',       'Text', 1);

-- Functions Quiz (AssessmentId=5) - MCQ
INSERT INTO Question (AssessmentId, QuestionText, QuestionType, Marks) VALUES
(5, 'Which keyword is used to define a function in Python?',        'MCQ', 1),
(5, 'What does the return statement do?',                           'MCQ', 1),
(5, 'How do you import a module in Python?',                        'MCQ', 1);

-- Functions Exercise (AssessmentId=6) - Written
INSERT INTO Question (AssessmentId, QuestionText, QuestionType, Marks) VALUES
(6, 'Write a Python function that takes two numbers and returns their sum.', 'Text', 1),
(6, 'What is the difference between a local and global variable?',           'Text', 1);

-- QuestionId reference:
-- Q1-3   = Basics Quiz MCQ
-- Q4-5   = Basics Exercise Written
-- Q6-8   = Control Flow Quiz MCQ
-- Q9-10  = Control Flow Exercise Written
-- Q11-13 = Functions Quiz MCQ
-- Q14-15 = Functions Exercise Written

-- =============================================
-- QUESTION OPTIONS (MCQ only)
-- =============================================

-- Q1: What is correct way to declare variable
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(1, 'var x = 5',   0),
(1, 'x = 5',       1),
(1, 'int x = 5',   0),
(1, 'x := 5',      0);

-- Q2: Valid Python data type
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(2, 'integer',  0),
(2, 'int',      1),
(2, 'number',   0),
(2, 'decimal',  0);

-- Q3: What does print() do
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(3, 'Reads input from user',             0),
(3, 'Displays output to the console',    1),
(3, 'Saves data to a file',              0),
(3, 'Deletes a variable',                0);

-- Q6: Keyword for if statement
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(6, 'when',  0),
(6, 'if',    1),
(6, 'check', 0),
(6, 'case',  0);

-- Q7: What does a for loop do
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(7, 'Stops the program',                          0),
(7, 'Repeats a block of code for each item',      1),
(7, 'Declares a function',                        0),
(7, 'Checks a condition once',                    0);

-- Q8: Which statement exits loop
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(8, 'stop',     0),
(8, 'exit',     0),
(8, 'break',    1),
(8, 'return',   0);

-- Q11: Keyword to define a function
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(11, 'function', 0),
(11, 'def',      1),
(11, 'func',     0),
(11, 'define',   0);

-- Q12: What does return do
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(12, 'Prints a value',                    0),
(12, 'Exits the program',                 0),
(12, 'Sends a value back to the caller',  1),
(12, 'Declares a variable',               0);

-- Q13: How to import a module
INSERT INTO QuestionOption (QuestionId, OptionText, IsCorrect) VALUES
(13, 'include math',   0),
(13, 'import math',    1),
(13, 'using math',     0),
(13, 'require math',   0);

-- =============================================
-- ENROLMENT
-- Joseph enrolled in all 3, WeiHan in first 2
-- =============================================
INSERT INTO Enrolment (StudentId, ModuleID, Status, EnrolledAt) VALUES
(3, 1, 'In Progress', GETDATE()),
(3, 2, 'In Progress', GETDATE()),
(3, 3, 'In Progress', GETDATE()),
(4, 1, 'In Progress', GETDATE()),
(4, 2, 'Completed',   GETDATE());

-- =============================================
-- PROGRESS
-- =============================================
INSERT INTO Progress (StudentId, ModuleID, TopicsCompleted, TotalTopics, ProgressPercentage) VALUES
(3, 1, 8,  10, 80),
(3, 2, 5,  10, 50),
(3, 3, 2,  10, 20),
(4, 1, 10, 10, 100),
(4, 2, 10, 10, 100);

-- =============================================
-- FEEDBACK
-- =============================================
INSERT INTO Feedback (StudentId, FeedbackMessage, CreatedAt) VALUES
(3, 'Really enjoying the Python Basics module, very clear explanations!', GETDATE()),
(4, 'The interface is clean and easy to navigate. Love the progress tracking feature.', GETDATE()),
(3, 'Would love to see more video content added to the platform.', GETDATE());

-- =============================================
-- ANNOUNCEMENTS
-- =============================================
INSERT INTO Announcements (AdminID, Title, Message, TargetAudience, CreatedAt) VALUES
(1, 'Welcome to Python Academy!',       'Welcome to our new learning platform. We hope you enjoy your learning journey with us.', 'All',      GETDATE()),
(1, 'New Modules Available',            'Three new Python modules have been added. Check them out in your learning dashboard.',    'Students', GETDATE()),
(1, 'Lecturer Submission Reminder',     'Please ensure all content is uploaded and published before end of this week.',            'Lecturers', GETDATE());

-- =============================================
-- ACTIVITY LOGS
-- =============================================
INSERT INTO ActivityLogs (UserID, Action, Details, Timestamp) VALUES
(1, 'Admin Login',          'Admin Maimoona logged in',                     GETDATE()),
(2, 'Content Uploaded',     'Lecturer uploaded: Python Basics',             GETDATE()),
(3, 'Student Enrolled',     'Joseph enrolled in Python Basics module',      GETDATE()),
(4, 'Student Enrolled',     'WeiHan enrolled in Control Flow module',       GETDATE()),
(3, 'Assessment Submitted', 'Joseph submitted Python Basics Quiz',          GETDATE()),
(1, 'User Approved',        'Admin approved lecturer account for Khawlah',  GETDATE());

-- =============================================
-- VERIFICATION LOG
-- =============================================
INSERT INTO VerificationLog (TargetID, TargetType, AdminID, Status, Comments, ReviewedAt) VALUES
(2, 'InstructorRegistration', 1, 'Approved',  'Verified lecturer credentials, account approved.', GETDATE()),
(1, 'LearningContent',        1, 'Approved',  'Content reviewed and approved for publishing.',     GETDATE()),
(2, 'LearningContent',        1, 'Approved',  'Content reviewed and approved for publishing.',     GETDATE()),
(3, 'LearningContent',        1, 'Approved',  'Content reviewed and approved for publishing.',     GETDATE());

-- =============================================
-- ASSESSMENT SUBMISSION (Joseph took Basics Quiz)
-- =============================================
INSERT INTO AssessmentSubmission (AssessmentId, StudentId, SubmittedAt, TotalScore) VALUES
(1, 3, GETDATE(), 2);

-- SubmissionId = 1

-- =============================================
-- SUBMISSION ANSWERS (Joseph's answers to Basics Quiz)
-- =============================================
INSERT INTO SubmissionAnswer (SubmissionId, QuestionId, SelectedOptionId, AnswerText, MarksAwarded) VALUES
(1, 1, 2, NULL, 1),   -- correct (x = 5)
(1, 2, 6, NULL, 1),   -- correct (int)
(1, 3, 9, NULL, 0);   -- wrong

-- =============================================
-- CERTIFICATES (WeiHan completed Module 1 and 2)
-- =============================================
INSERT INTO Certificates (StudentId, ModuleID, IssuedDate, CertificateCode, FinalScore) VALUES
(4, 1, GETDATE(), 'PYAC-2025-WH-001', 90),
(4, 2, GETDATE(), 'PYAC-2025-WH-002', 85);

-- =============================================
-- PLATFORM SETTINGS
-- =============================================
INSERT INTO PlatformSettings (SettingKey, SettingValue) VALUES
('AllowRegistration',  'true'),
('DefaultUserRole',    'Student');