
IF OBJECT_ID('dbo.Announcements', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Announcements (
        AnnouncementID INT IDENTITY(1,1) PRIMARY KEY,
        AdminID INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(UserID),
        Title NVARCHAR(200) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        TargetAudience NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END;

IF OBJECT_ID('dbo.PlatformSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlatformSettings (
        SettingKey NVARCHAR(100) NOT NULL PRIMARY KEY,
        SettingValue NVARCHAR(500) NULL,
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
END;

IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Users', 'Status') IS NULL
    BEGIN
        ALTER TABLE dbo.Users
        ADD Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'Pending';
    END;
END;

IF OBJECT_ID('dbo.LearningContent', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.LearningContent', 'IsPublished') IS NULL
    BEGIN
        ALTER TABLE dbo.LearningContent
        ADD IsPublished BIT NOT NULL CONSTRAINT DF_LearningContent_IsPublished DEFAULT 0;
    END;

    IF COL_LENGTH('dbo.LearningContent', 'CreatedAt') IS NULL
    BEGIN
        ALTER TABLE dbo.LearningContent
        ADD CreatedAt DATETIME NOT NULL CONSTRAINT DF_LearningContent_CreatedAt DEFAULT GETDATE();
    END;
END;
