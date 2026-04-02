-- =============================================
-- PythonAcademy Feature Upgrade — SQL Migrations
-- Run this script against your PythonAcademyDB
-- =============================================

-- Task 2: Add ThumbnailPath and Category to LearningContent
IF COL_LENGTH('LearningContent', 'ThumbnailPath') IS NULL
BEGIN
    ALTER TABLE LearningContent ADD ThumbnailPath NVARCHAR(500) NULL;
END
GO

IF COL_LENGTH('LearningContent', 'Category') IS NULL
BEGIN
    ALTER TABLE LearningContent ADD Category NVARCHAR(100) NULL;
END
GO

-- Task 3: Add ProfilePic to Users
IF COL_LENGTH('Users', 'ProfilePic') IS NULL
BEGIN
    ALTER TABLE Users ADD ProfilePic NVARCHAR(500) NULL;
END
GO
