/****** Object:  StoredProcedure [Posting].[uspCategory_AddCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 3/3/2025
-- Update date: 18/3/2025
-- Description:	Add a category to the Category table
-- =============================================
CREATE PROCEDURE [Posting].[uspCategory_AddCategory]
	@p_EditorId INT,
	@p_CategoryName VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0 
		   AND Posting.fn_CheckEditorPermission(@p_EditorId, 138) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1);
		END;

		INSERT INTO Posting.Category(Name, CreatedAt, CreatedBy, IsDeleted)
		VALUES(@p_CategoryName, GETDATE(), @p_EditorId, 0)

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspCategory_DeleteCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 4/3/2025
-- Update date: 18/3/2025
-- Description:	Deletes category from the category table by changing the 'IsDeleted' flag
-- =============================================
CREATE PROCEDURE [Posting].[uspCategory_DeleteCategory]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_CategoryId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
	-- Get the editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0 
		   AND Posting.fn_CheckEditorPermission(@p_EditorId, 138) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1);
		END;

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Category WHERE Id=@p_CategoryId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Category
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_CategoryId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspCategory_UpdateCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 18/3/2025
-- Description:	update a row in the Category table
-- =============================================
CREATE PROCEDURE [Posting].[uspCategory_UpdateCategory]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT, 
	@p_CategoryId INT,
	@p_UpdatedCategory VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 138) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Category WHERE Id=@p_CategoryId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Category
		SET Name=@p_UpdatedCategory, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_CategoryId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspEditor_AddEditor]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 3/3/2025
-- Update date: 18/3/2025
-- Description:	This procedure is used to add new editors to the Editors table, to add a manager that 
--					has no managers, you'll need to add him as a normal editor first, then you'll need to
--					promote him using an update procedure.
-- =============================================
CREATE PROCEDURE [Posting].[uspEditor_AddEditor]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,						-- id of the editor who wants to use the procedure
	@p_FirstName VARCHAR(100),			-- this and the following is the data of the employee to be inserted
	@p_MiddleName VARCHAR(100) = NULL,
	@p_Lastname VARCHAR(100) = NULL,
	@p_Email VARCHAR(100),
	@p_Phone VARCHAR(30),
	@p_RoleId INT,
	@p_Password VARCHAR(100),				-- this will be hashed later
	@p_ManagedBy INT = NULL				-- If null this means the one who inserted the employee will manage him


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 128) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END
		
		-- set the value of the manager if not provided
		IF @p_ManagedBy IS NULL
		BEGIN
			SET @p_ManagedBy = @p_EditorId;
		END

		-- insert the new editor
		INSERT INTO Posting.Editor
			(FirstName, MiddleName, LastName, Email, Phone, ManagedBy, RoleId, 
				PasswordHash, CreatedAt, CreatedBy, IsDeleted)
		VALUES
			(@p_FirstName, @p_MiddleName, @p_Lastname, @p_Email, @p_Phone, @p_ManagedBy, @p_RoleId, 
				HASHBYTES('SHA2_256', @p_Password), GETDATE(), @p_EditorId, 0);

		-- self explainatory code
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspEditor_DeleteEditor]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 18/3/2025
-- Description:	changes the deleted flag in the editor table
-- =============================================
CREATE PROCEDURE [Posting].[uspEditor_DeleteEditor]
	@p_EditorId INT,
	@p_TargetEditorId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 128) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Editor WHERE Id=@p_TargetEditorId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Editor
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_TargetEditorId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspEditor_EmployeeHierarchy]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Posting].[uspEditor_EmployeeHierarchy]
	-- Add the parameters for the stored procedure here
	@P_EditorId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Verify the user
		IF NOT EXISTS (SELECT 1 
					   FROM Posting.Post p
					   JOIN Posting.Editor e ON p.EditorId = e.Id
					   WHERE EditorId=@p_EditorId OR ManagedBy=@p_EditorId)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 159) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END;


		-- the main query
		-- the first part of the cte will be for the manager, so it's normal if some columns were null
		WITH RecursiveManager AS (
			SELECT
				Id,
				FirstName + ' ' + LastName AS EditorName,
				ManagedBy
			FROM Posting.Editor
			WHERE Id=@P_EditorId
			--
			UNION ALL
			--
			SELECT
				e.Id,
				e.FirstName + ' ' + e.LastName AS EditorName,
				e.ManagedBy
			FROM Posting.Editor e
			JOIN RecursiveManager rm ON e.ManagedBy = rm.Id 
		)
		SELECT * FROM RecursiveManager ORDER BY Id, ManagedBy;


		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspEditor_PromoteEditor]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 13/3/2025
-- Update date: 18/3/2025
-- Description:	Remove editor's manager
-- =============================================
CREATE PROCEDURE [Posting].[uspEditor_PromoteEditor]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_TargetEditorId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 128) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Editor WHERE Id=@p_EditorId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- save unique values into variables before deleting them from the table
		DECLARE @email VARCHAR(100), @phone VARCHAR(30), @passwordhash BINARY(64);

		SELECT @email=Email, @phone=Phone, @passwordhash=PasswordHash FROM Posting.Editor WHERE Id=@p_TargetEditorId;

		-- delete the old editor data
		UPDATE Posting.Editor
		SET 
			Email=NULL,
			Phone=NULL,
			PasswordHash=NULL,
			UpdatedAt=GETDATE(),
			UpdatedBy=@p_EditorId,
			IsDeleted=1
		WHERE Id=@p_TargetEditorId;

		-- insert the updated editor
		INSERT INTO Posting.Editor
			(FirstName, MiddleName, LastName, 
			Email, Phone, PasswordHash, RoleId, 
			ManagedBy, CreatedAt, CreatedBy, IsDeleted)
		SELECT 
			FirstName, MiddleName, LastName, @email, @phone, @passwordhash, RoleId, NULL, GETDATE(), @p_EditorId, 0
		FROM Posting.Editor 
		WHERE Id=@p_TargetEditorId;

		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspEditor_UpdateEditor]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 18/3/2025
-- Description:	update a row in the Editor table given the columns to chaged are provided.
--					this procedure works by first checking the permissions, check if the row was updated before,
--					save the unique values into variables, deleting them from the row and updating the row
--					inserting a new row with the same old data.
-- =============================================
CREATE PROCEDURE [Posting].[uspEditor_UpdateEditor]
	@p_EditorId INT, 
	@p_TargetEditorId INT,
	@p_UpdatedFirstName VARCHAR(100) = NULL,
	@p_UpdatedMiddleName VARCHAR(100) = NULL,
	@p_UpdatedLastName VARCHAR(100) = NULL,
	@p_UpdatedPhone VARCHAR(30) = NULL,
	@p_UpdatedEmail VARCHAR(100) = NULL,
	@p_UpdatedManagedBy INT = NULL,
	@p_UpdatedRoleId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 128) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Editor WHERE Id=@p_TargetEditorId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- save unique values into variables before deleting them from the table
		DECLARE @email VARCHAR(100), @phone VARCHAR(30), @passwordhash BINARY(64);
		SELECT @email=Email, @phone=Phone, @passwordhash=PasswordHash FROM Posting.Editor WHERE Id=@p_TargetEditorId;


		-- Update the columns of the old row
		UPDATE Posting.Editor
		SET 
			Email = CASE WHEN @p_UpdatedEmail IS NULL THEN NULL ELSE @email END,
			Phone = CASE WHEN @p_UpdatedPhone IS NULL THEN NULL ELSE @phone END,
			PasswordHash = NULL,
			UpdatedAt = GETDATE(), 
			UpdatedBy = @p_EditorId,
			IsDeleted = 1
		WHERE Id = @p_TargetEditorId;

		-- insert the new row
		INSERT INTO Posting.Editor
			(FirstName, MiddleName, LastName, 
			Phone, Email, PasswordHash, ManagedBy,
			RoleId, CreatedAt, CreatedBy, 
			UpdatedAt, UpdatedBy, IsDeleted)
		SELECT 
			COALESCE(@p_UpdatedFirstName, FirstName),
			COALESCE(@p_UpdatedMiddleName, MiddleName),
			COALESCE(@p_UpdatedLastName, LastName),
			COALESCE(@p_UpdatedPhone, @phone),
			COALESCE(@p_UpdatedEmail, @email),
			@passwordhash,
			COALESCE(@p_UpdatedManagedBy, ManagedBy),
			COALESCE(@p_UpdatedRoleId, RoleId), GETDATE(), @p_EditorId,
			NULL, NULL, 0
		FROM Posting.Editor
		WHERE Id=@p_TargetEditorId;


		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspMedia_AddMedia]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 3/3/2025
-- Update date: 20/3/2025
-- Description:	This procedure will be used to add media in the media table.
--					It will also establish a relationship between 
--					the posts and media using the PostMedia table if a PostId is provided.
-- =============================================
CREATE PROCEDURE [Posting].[uspMedia_AddMedia]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,								-- The editor's ID who wants to add an image
	@p_PostId INT = NULL,							-- The post ID that the editor want to add images to
	@p_FilePaths Posting.PostMediaTVP READONLY		-- Table-valued parameter for multiple file paths
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Declare attributes to use later
	DECLARE @Title VARCHAR(200);
	DECLARE @MediaTypeId INT;
	DECLARE @Extention VARCHAR(5);
	DECLARE @MediaFile VARBINARY(MAX);
	DECLARE @MediaId INT;						-- this one will be used for the MediaId

	-- Used to extract file data
	DECLARE @sql NVARCHAR(1000);
	DECLARE @params NVARCHAR(300);

	BEGIN TRY
		-- Validate the user
		-- Validate the post belongs to the editor
		IF NOT EXISTS (SELECT 1 FROM Posting.Post WHERE EditorId=@p_EditorId AND @p_PostId=Id)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 130) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 131) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END

		-- Loop through each row in the table-valued parameter
		DECLARE @FilePath VARCHAR(300);
		DECLARE media_cursor CURSOR FOR
		SELECT TVP_MediaFilePath FROM @p_FilePaths;

		OPEN media_cursor;
		FETCH NEXT FROM media_cursor INTO @FilePath;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Check weather the media inserted is an image or a video by extracting the extension from the filepath
			-- Extract extension
			SET @Extention = SUBSTRING(
				@FilePath,
				LEN(@FilePath) - CHARINDEX('.', REVERSE(@FilePath)) + 2, 
				LEN(@FilePath)
			)

			-- Check if the file is an image or a video or neither
			IF @Extention IN ('png', 'jpg', 'gif', 'jpeg', 'svg', 'webp')
			BEGIN
				SET @MediaTypeId = 1
			END
			ELSE IF @Extention IN ('mp4', 'mov', 'avi', 'wmv', 'gifv', 'webm')
			BEGIN
				SET @MediaTypeId = 2
			END
			ELSE
			BEGIN
				RAISERROR('Please enter a valid file (image or video)', 16, 1)
			END

			-- Extract title from filepath
			SET @Title = RIGHT(@FilePath, CHARINDEX('\', REVERSE(@FilePath)) - 1);

			-- Extract file data using dynamic sql
			SET @sql = 'SELECT @MediaFile = CAST(bulkcolumn AS VARBINARY(max))  
				FROM OPENROWSET(BULK ' + quotename(@FilePath,nchar(39)) + ', SINGLE_BLOB) as rs'
			SET @params = N'@p_FilePath VARCHAR(300), @MediaFile VARBINARY(MAX) OUTPUT'
			
			EXECUTE sp_executesql @sql, @params, @p_FilePath=@FilePath, @MediaFile=@MediaFile OUTPUT;

			-- Inserting the data extracted to the Media table
			INSERT INTO Posting.Media(Title, MediaFile, MediaTypeId, CreatedAt, CreatedBy, IsDeleted)
			VALUES (@Title, @MediaFile, @MediaTypeId, GETDATE(), @p_EditorId, 0);

			-- Inserting the ids of the media and post into the PostMedia table to establish the relationship
			SELECT @MediaId = Id FROM Posting.Media WHERE MediaFile=@MediaFile;
			INSERT INTO Posting.PostMedia(PostId, MediaId, CreatedAt, CreatedBy, IsDeleted)
			VALUES(@p_PostId, @MediaId, GETDATE(), @p_EditorId, 0);

			-- Inserting the action committed into the log table
			INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
			VALUES (@p_EditorId, @@PROCID, GETDATE());

			-- Fetch the next file path
			FETCH NEXT FROM media_cursor INTO @FilePath;
		END

		CLOSE media_cursor;
		DEALLOCATE media_cursor;

	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspMedia_DeleteMedia]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 18/3/2025
-- Description:	change the delete flag in the Media table
-- =============================================
CREATE PROCEDURE [Posting].[uspMedia_DeleteMedia]
	@p_EditorId INT,
	@p_MediaId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 131) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Media WHERE Id=@p_MediaId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Media
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_MediaId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspMediaType_AddMediaType]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 19/3/2025
-- Description:	Adds a media type to the MediaType table
-- =============================================
CREATE PROCEDURE [Posting].[uspMediaType_AddMediaType]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_MediaType CHAR(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0 
		BEGIN
			RAISERROR('Invalid User', 16, 1);
		END;

		INSERT INTO Posting.MediaType(Name, CreatedAt, CreatedBy, IsDeleted)
		VALUES(@p_MediaType, GETDATE(), @p_EditorId, 0)

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspMediaType_DeletedMediaType]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 19/3/2025
-- Description:	Deletes a media type
-- =============================================
CREATE PROCEDURE [Posting].[uspMediaType_DeletedMediaType]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_MediaTypeId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0 
		BEGIN
			RAISERROR('Invalid User', 16, 1);
		END;

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.MediaType WHERE Id=@p_MediaTypeId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- delete
		UPDATE Posting.MediaType
		SET 
			IsDeleted = 1,
			UpdatedAt = GETDATE(),
			UpdatedBy = @p_EditorId
		WHERE Id = @p_MediaTypeId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspMediaType_UpdateMediaType]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 19/3/2025
-- Description:	this procedure updates the mediatype 
-- =============================================
CREATE PROCEDURE [Posting].[uspMediaType_UpdateMediaType]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_MediaTypeId INT,
	@p_MediaType CHAR(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0 
		BEGIN
			RAISERROR('Invalid User', 16, 1);
		END;

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.MediaType WHERE Id=@p_MediaTypeId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- update
		UPDATE Posting.MediaType
		SET 
			Name = @p_MediaType,
			UpdatedAt = GETDATE(),
			UpdatedBy = @p_EditorId
		WHERE Id = @p_MediaTypeId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPermission_AddPermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 18/3/2025
-- Description:	This procedure adds new permissions to the Permission table
-- =============================================
CREATE PROCEDURE [Posting].[uspPermission_AddPermission]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_Permission VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 136) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		INSERT INTO Posting.Permission(Name, CreatedBy, CreatedAt, IsDeleted) 
		VALUES(@p_Permission, @p_EditorId, GETDATE(), 0)

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPermission_DeletePermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 18/3/2025
-- Description:	change the delete flag in the Permission table
-- =============================================
CREATE PROCEDURE [Posting].[uspPermission_DeletePermission]
	@p_EditorId INT,
	@p_PermissionId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 136) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Permission WHERE Id=@p_PermissionId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Permission
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PermissionId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPermission_UpdatePermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	this procedure updates the Permission table
-- =============================================
CREATE PROCEDURE [Posting].[uspPermission_UpdatePermission]
	@p_EditorId INT, 
	@p_PermissionId INT,
	@p_UpdatedPermission VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 136) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Permission WHERE Id=@p_PermissionId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Name column
		UPDATE Posting.Permission
		SET Name=@p_UpdatedPermission, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PermissionId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_AddPost]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 3/3/2025
-- Update date: 19/3/2025
-- Description:	This procedure will be used to insert the posts written by the editors
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_AddPost]
	-- Add the parameters for the stored procedure here
	@P_EditorId INT,					-- The ID of the editor
	@P_Title VARCHAR(100),				-- Title of the post
	@P_PostContent NVARCHAR(4000),		-- Content of the post
	@P_PostId INT OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	-- DECLARE @SubCategoryId INT;
    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@P_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@P_EditorId, 132) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- insert the post
		INSERT INTO Posting.Post
			(EditorId, PublishStatusId, Title, PostContent, CreatedAt, CreatedBy, IsDeleted)
		VALUES
			(@p_EditorId, 1, @P_Title, @P_PostContent, GETDATE(), @P_EditorId, 0);

		-- get the postId
		SET @P_PostId = SCOPE_IDENTITY();

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@P_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @P_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_AddPostFromTextFile]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 23/3/2025
-- Description:	This procedure will read the Post content form a text file, and store it using the
--					uspPost_AddPost procedure
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_AddPostFromTextFile]
	-- Add the parameters for the stored procedure here
	@P_EditorId INT, 
	@P_FilePath NVARCHAR(300),
	@P_PostId INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Title, and Content variables, that will be extracted from the text file
	DECLARE @RawContent VARCHAR(4200);
	DECLARE @Title NVARCHAR(200);
	DECLARE @Content VARCHAR(4000);
	DECLARE @PostId INT;

	DECLARE @SQL NVARCHAR(1000);
	DECLARE @PARAMS NVARCHAR(500);

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@P_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@P_EditorId, 132) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- Extract file data using dynamic sql
		SET @SQL = 'SELECT @RawContent = BulkColumn
			FROM OPENROWSET(BULK ' + quotename(@P_FilePath,nchar(39)) + ', SINGLE_BLOB) AS Contents'
		SET @PARAMS = N'@P_FilePath VARCHAR(300), @RawContent VARCHAR(4200) OUTPUT'
			
		EXECUTE sp_executesql @SQL, @PARAMS, @P_FilePath=@P_FilePath, @RawContent=@RawContent OUTPUT;

		-- Extract the title (First Line)
		SET @Title = LEFT(@RawContent, CHARINDEX(CHAR(13) + CHAR(10), @RawContent) - 1);

		-- Extract the content (Everything after the second line)
		SET @Content = SUBSTRING(@RawContent, CHARINDEX(CHAR(13) + CHAR(10), @RawContent, CHARINDEX(CHAR(13) + CHAR(10), @RawContent) + 2) + 2, LEN(@RawContent));

		-- Insert the data using the insert query.
		EXEC Posting.uspPost_AddPost 
			@P_EditorId=@P_EditorId, 
			@P_Title=@Title, 
			@P_PostContent=@Content, 
			@P_PostId=@PostId OUTPUT;

		SET @P_PostId = @PostId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@P_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @P_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_AddPostFromXMLFile]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 23/3/2025
-- Description:	This procedure will extract the data from an xml file, and add them to the Post table
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_AddPostFromXMLFile]
	-- Add the parameters for the stored procedure here
	@P_EditorId INT, 
	@P_FilePath NVARCHAR(300),
	@P_PostId INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Title, and Content variables, that will be extracted from the text file
	DECLARE @Title NVARCHAR(200);
	DECLARE @Content VARCHAR(4000);
	DECLARE @PostId INT;

	DECLARE @SQL NVARCHAR(1000);
	DECLARE @PARAMS NVARCHAR(500);
	DECLARE @XML XML;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@P_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@P_EditorId, 132) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- Extract file data using dynamic sql
		SET @SQL = 'SELECT @XML = CAST(BulkColumn AS XML)
					FROM OPENROWSET(BULK ' + quotename(@P_FilePath,nchar(39)) + ', SINGLE_BLOB) AS Contents;'
		SET @PARAMS = N'@P_FilePath NVARCHAR(300), @XML XML OUTPUT'
			
		EXECUTE sp_executesql @SQL, @PARAMS, @P_FilePath=@P_FilePath, @XML=@XML OUTPUT;


		-- Extract the title (First Line)
		SET @Title = @XML.value('(/article/title)[1]', 'VARCHAR(200)');

		-- Extract the content (Everything after the second line)
		SET @Content = @xml.value('(/article/content)[1]', 'VARCHAR(4000)');

		-- Or you can do this instead
		--SET @Title = @XML.value('(title)[1]', 'VARCHAR(200)');
		--SET @Content = @xml.value('(content)[1]', 'VARCHAR(4000)');

		-- Insert the data using the insert query.
		EXEC Posting.uspPost_AddPost 
			@P_EditorId=@P_EditorId, 
			@P_Title=@Title, 
			@P_PostContent=@Content, 
			@P_PostId=@PostId OUTPUT;

		
		SET @P_PostId = @PostId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@P_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @P_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_AddPostViaTVP]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 24/3/2025
-- Description:	This procedure will behave exactly like uspPost_AddPost, however,
--					the parameter inserted will be inserted via Table-Valued Parameters
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_AddPostViaTVP]
	-- Add the parameters for the stored procedure here
	@P_PostData Posting.PostTVP READONLY,
	@P_PostId INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
		@P_EditorId INT,
		@P_Title VARCHAR(200),
		@P_PostContent VARCHAR(4000);
    -- Insert statements for procedure here
	BEGIN TRY
		-- Get the user inserted data
		SELECT 
			@P_EditorId = TVP_EditorId,
			@P_Title = TVP_Title,
			@P_PostContent = TVP_Content
		FROM @P_PostData;

		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@P_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@P_EditorId, 132) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- insert the post
		INSERT INTO Posting.Post
			(EditorId, PublishStatusId, Title, PostContent, CreatedAt, CreatedBy, IsDeleted)
		VALUES
			(@p_EditorId, 1, @P_Title, @P_PostContent, GETDATE(), @P_EditorId, 0);

		-- get the postId
		SET @P_PostId = SCOPE_IDENTITY();

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@P_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @P_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_DeletePost]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	change the delete flag in the Post table
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_DeletePost]
	@p_EditorId INT,
	@p_PostId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 134) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Post WHERE Id=@p_PostId AND UpdatedAt IS NOT NULL)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Post
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PostId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_UpdatePost]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 4/3/2025
-- Update date: 19/3/2025
-- Description:	update an article in the Post table, you won't be able to edit the status of it 
--					for that, use the procedure uspPost_UpdateStatus
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_UpdatePost]
	@p_EditorId INT, 
	@p_PostId INT,
	@p_UpdatedTitle VARCHAR(200) = NULL,
	@p_UpdatedPostContent NVARCHAR(4000) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Posting.Post WHERE EditorId=@p_EditorId AND @p_PostId=Id)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 133) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END;

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Post WHERE Id=@p_PostId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- save unique values into variables before deleting them from the table
		DECLARE @title VARCHAR(200), @content VARCHAR(4000);
		SELECT @title=Title, @content=PostContent FROM Posting.Post WHERE Id=@p_PostId;

		-- Delete the old row
		UPDATE Posting.Post
		SET 
			Title = CASE WHEN @p_UpdatedTitle IS NULL THEN NULL ELSE @title END,
			PostContent = CASE WHEN @p_UpdatedPostContent IS NULL THEN NULL ELSE @content END,
			UpdatedAt = GETDATE(), 
			UpdatedBy = @p_EditorId,
			IsDeleted = 1
		WHERE Id = @p_PostId;

		-- insert the new row with updated data
		INSERT INTO Posting.Post
			(Title, PostContent, CreatedAt, CreatedBy, IsDeleted)
		SELECT 
			COALESCE(@p_UpdatedTitle, @title), 
			COALESCE(@p_UpdatedPostContent, @content), 
			GETDATE(), 
			@p_EditorId, 
			0 
		FROM Posting.Post WHERE Id=@p_PostId;
		
		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());

	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPost_UpdateStatus]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 13/3/2025
-- Update date: 19/3/2025
-- Description: This procedure will only update the post status.
-- =============================================
CREATE PROCEDURE [Posting].[uspPost_UpdateStatus]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostId INT,
	@p_StatusId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 140) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 141) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Post WHERE Id=@p_PostId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the columns using COALESCE
		UPDATE Posting.Post
		SET 
			PublishStatusId = COALESCE(@p_StatusId, PublishStatusId),
			UpdatedAt = GETDATE(), 
			UpdatedBy = @p_EditorId
		WHERE Id = @p_PostId;
		
		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPostCategory_AddSubCategoryToPost]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 4/3/2025
-- Update date: 19/3/2025
-- Description:	Add categories(sub-categories) AKA tags to a post in the PostCategory table
-- =============================================
CREATE PROCEDURE [Posting].[uspPostCategory_AddSubCategoryToPost]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostId INT,
	@p_SubCategoryIds Posting.PostCategoryTVP READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate the user
		-- Make sure the post belongs to the user
		IF NOT EXISTS (SELECT 1 FROM Posting.Post WHERE EditorId=@p_EditorId AND Id=@p_PostId)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 139) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 142) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END

		-- the real insert statement (with TVP)
		INSERT INTO Posting.PostCategory(PostId, SubCategoryId, CreatedAt, CreatedBy, IsDeleted)
		SELECT @p_PostId, TVP_SubCategoryId, GETDATE(), @p_EditorId, 0 FROM @p_SubCategoryIds

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPostCategory_DeletePostCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	change the delete flag in the PostCategory table
-- =============================================
CREATE PROCEDURE [Posting].[uspPostCategory_DeletePostCategory]
	@p_EditorId INT,
	@p_PostCategoryId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 142) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.PostCategory WHERE Id=@p_PostCategoryId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.PostCategory
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PostCategoryId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPostCategory_UpdatePostCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	update a row in the PostCategory table
-- =============================================
CREATE PROCEDURE [Posting].[uspPostCategory_UpdatePostCategory]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostCategoryId INT,
	@p_SubCategoryId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate the user
		-- Validate the post belongs to the editor
		DECLARE @PostId INT = (SELECT PostId FROM Posting.PostCategory WHERE Id=@p_PostCategoryId);
		IF NOT EXISTS (SELECT 1 FROM Posting.Post WHERE @p_EditorId=EditorId AND @PostId=Id)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 142) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.PostCategory WHERE Id=@p_PostCategoryId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Category for the post
		UPDATE Posting.PostCategory
		SET  
			SubCategoryId = @p_SubCategoryId,
			UpdatedAt = GETDATE(),
			UpdatedBy = @p_EditorId
		WHERE Id=@p_PostCategoryId

		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPostMedia_AddPostMedia]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	This procedure links (add relationship) an image and a post in the PostImage table
-- =============================================
CREATE PROCEDURE [Posting].[uspPostMedia_AddPostMedia]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostId INT,
	@p_MediaId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate the user
		-- Validate the post belongs to the editor
		IF NOT EXISTS (SELECT 1 FROM Posting.Post WHERE EditorId=@p_EditorId AND @p_PostId=Id AND IsDeleted=0)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 131) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END

		INSERT INTO Posting.PostMedia(PostId, MediaId, CreatedBy, CreatedAt, IsDeleted) 
		VALUES(@p_PostId, @p_MediaId, @p_EditorId, GETDATE(), 0)

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPostMedia_DeletePostMedia]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	change the delete flag in the PostMedia table
-- =============================================
CREATE PROCEDURE [Posting].[uspPostMedia_DeletePostMedia]
	@p_EditorId INT,
	@p_PostMediaId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 131) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.PostMedia WHERE Id=@p_PostMediaId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.PostMedia
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PostMediaId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPostMedia_UpdatePostMedia]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 4/3/2025
-- Description:	This procedure will update the relationship between posts and media
--					it will not update the media directly, and it will not update the PostId,
--					only the MediaId
-- =============================================
CREATE PROCEDURE [Posting].[uspPostMedia_UpdatePostMedia]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostMediaId INT,
	@p_MediaId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate the user
		-- Validate the post belongs to the editor
		DECLARE @PostId INT = (SELECT PostId FROM Posting.PostMedia WHERE Id=@p_PostMediaId);
		IF NOT EXISTS (SELECT 1 FROM Posting.Post WHERE @p_EditorId=EditorId AND @PostId=Id)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 131) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.PostMedia WHERE Id=@p_PostMediaId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Media for the post
		UPDATE Posting.PostMedia
		SET 
			MediaId = @p_MediaId,
			UpdatedAt = GETDATE(),
			UpdatedBy = @p_EditorId
		WHERE Id=@p_PostMediaId

		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPublishStatus_AddAdHocStatus]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 3/3/2025
-- Update date: 19/3/2025
-- Description:	Add ad-hoc status for the Status table
-- =============================================
CREATE PROCEDURE [Posting].[uspPublishStatus_AddAdHocStatus]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_Status VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 141) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		INSERT INTO Posting.PublishStatus(Name, CreatedBy, CreatedAt, IsDeleted) 
		VALUES(@p_Status, @p_EditorId, GETDATE(), 0)

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPublishStatus_DeletePublishStatus]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	change the delete flag in the PublishStatus table
-- =============================================
CREATE PROCEDURE [Posting].[uspPublishStatus_DeletePublishStatus]
	@p_EditorId INT,
	@p_PublishStatusId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 141) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.PublishStatus WHERE Id=@p_PublishStatusId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.PublishStatus
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PublishStatusId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_Editorid, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_Editorid)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspPublishStatus_UpdatePublishStatus]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	update a row in the PublishStatus table
-- =============================================
CREATE PROCEDURE [Posting].[uspPublishStatus_UpdatePublishStatus]
	@p_EditorId INT, 
	@p_PublishStatusId INT,
	@p_UpdatedPublishStatus VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 141) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.PublishStatus WHERE Id=@p_PublishStatusId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Name column
		UPDATE Posting.PublishStatus
		SET Name=@p_UpdatedPublishStatus, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_PublishStatusId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspQueryLatestNPosts]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 5/3/2025
-- Update date: 26/3/2025
-- Description:	A dynamic SQL query that returns the latest n published posts for x category or subcategory
--		and if no category or subcategory was specified, it will return at general
-- =============================================
CREATE PROCEDURE [Posting].[uspQueryLatestNPosts]
	-- Add the parameters for the stored procedure here
    @P_EditorId INT,
    @P_PageNumber INT = 1,
    @P_RowsPerPage INT = 5,
    @P_CategoryId INT = NULL,
    @P_SubCategoryId INT = NULL,
	@P_PublishStatusId INT = 2,
	@P_MinDate DATETIME2 = '1/1/2025',
	@P_MaxDate DATETIME2 = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(1000);
	DECLARE @params NVARCHAR(200);
    -- Insert statements for procedure here
	BEGIN TRY
		-- we use the window function to get the first picture inserted by ther user and making it into
		-- the feature image of the post (thumbnail)
		SET @sql = N'
			SELECT
				p.Title,
				e.FirstName + '' '' + e.LastName AS Writer,
				STRING_AGG(c.Name, '' | '') Category,
				STRING_AGG(sc.Name, '', '') SubCategory,
				p.CreatedAt
			FROM Posting.Post p
				JOIN Posting.PostCategory pc ON p.Id=pc.PostId
				JOIN Posting.SubCategory sc ON sc.Id=pc.SubCategoryId
				JOIN Posting.Category c ON c.Id=sc.CategoryId
				JOIN Posting.Editor e ON e.Id = p.EditorId
			WHERE 
				p.IsDeleted = 0
				AND p.PublishStatusId = @P_PublishStatusId
				AND p.CreatedAt >= @P_MinDate
				AND p.CreatedAt < @P_MaxDate
				AND (@P_CategoryId IS NULL OR c.Id=@P_CategoryId)
				AND (@P_SubCategoryId IS NULL OR sc.Id=@P_SubCategoryId)
			GROUP BY 
				p.Title, 
				e.FirstName, 
				e.LastName, 
				p.CreatedAt
			ORDER BY 
				p.CreatedAt DESC
			OFFSET 
				(@P_PageNumber - 1) * @P_RowsPerPage ROWS 
			FETCH NEXT 
				@P_RowsPerPage ROWS ONLY;
		'
		SET @params = N'@P_PageNumber INT, @P_RowsPerPage INT, @P_CategoryId INT, @P_SubCategoryId INT,
						@P_MinDate DATETIME2, @P_MaxDate DATETIME2, @P_PublishStatusId INT'
		EXEC sp_executesql 
			@sql, 
			@params, 
			@P_PageNumber=@P_PageNumber, 
			@P_RowsPerPage=@P_RowsPerPage, 
			@P_CategoryId=@P_CategoryId, 
			@P_SubCategoryId=@P_SubCategoryId,
			@P_MinDate=@P_MinDate,
			@P_MaxDate=@P_MaxDate,
			@P_PublishStatusId=@P_PublishStatusId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@P_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @P_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspQueryLatestNPostsWithImages]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 5/3/2025
-- Update date: 17/3/2025
-- Description:	A dynamic SQL query that returns the latest n published posts with thier thumbnail 
--					for x category or subcategory and if no category or subcategory was specified, 
--					it will return at general.
-- =============================================
CREATE PROCEDURE [Posting].[uspQueryLatestNPostsWithImages]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_NumberOfPosts INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(1000);
	DECLARE @params NVARCHAR(200);
    -- Insert statements for procedure here
	BEGIN TRY
		-- we use the window function to get the first picture inserted by ther user and making it into
		-- the feature image of the post (thumbnail)
		SET @sql = N'

			WITH RankedResults AS (
				SELECT 
					p.Title,
					e.FirstName + '' '' + e.LastName AS Writer,
					MediaFile,
					p.CreatedAt AS CreatedAt,
					ROW_NUMBER() OVER (PARTITION BY p.Id ORDER BY m.CreatedAt) AS rn
				FROM Posting.Post p
					JOIN Posting.PostMedia pm ON p.Id = pm.PostId
					JOIN Posting.Editor e ON e.Id = p.EditorId
					JOIN Posting.Media m ON m.Id = pm.MediaId
				WHERE MediaTypeId = 1
			)
			SELECT TOP (@p_NumberOfPosts)
				Title, 
				Writer,
				MediaFile,
				CreatedAt
			FROM RankedResults 
			WHERE rn=1
			ORDER BY CreatedAt DESC;

		'
		SET @params = N'@p_NumberOfPosts INT'
		EXEC sp_executesql @sql, @params, 
			@p_NumberOfPosts=@p_NumberOfPosts

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspReadFullTable]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 13/3/2025
-- Update date: 19/3/2025
-- Description:	Full read of the tables across the database
-- =============================================
CREATE PROCEDURE [Posting].[uspReadFullTable]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@Table VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 161) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		DECLARE @SQL NVARCHAR(MAX);

		-- Securely construct dynamic SQL
		SET @SQL = N'SELECT * FROM ' + QUOTENAME(PARSENAME(@Table, 2)) + '.' + QUOTENAME(PARSENAME(@Table, 1));

		-- Execute without unnecessary parameters
		EXEC sp_executesql @SQL;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_Editorid, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspReadTable]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 12/3/2025
-- Description:	This procedure will partially let read tables data across the database
-- =============================================
CREATE PROCEDURE [Posting].[uspReadTable]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_Table VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 159) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		IF @p_Table='Posting.Editor' OR @p_Table='Logging.ActionLog' OR @p_Table='Logging.ErrorLog'
		BEGIN
			RAISERROR('This table cannot be accessed', 16, 1)
		END

		DECLARE @SQL NVARCHAR(MAX);
		DECLARE @cols NVARCHAR(MAX);

		-- sepcify the columns we don't want the user to see
		SELECT @cols = STRING_AGG(name, ', ') WITHIN GROUP (ORDER BY column_id)
		FROM sys.columns 
		WHERE object_id = OBJECT_ID(@p_Table) 
		AND name NOT IN ('CreatedAt', 'UpdatedAt', 'CreatedBy', 'UpdatedBy', 'IsDeleted');

		-- Securely construct dynamic SQL
		SET @SQL = N'SELECT ' + @cols + 
				   ' FROM ' + QUOTENAME(PARSENAME(@p_Table, 2)) + '.' + QUOTENAME(PARSENAME(@p_Table, 1))
				 + ' WHERE IsDeleted=0';

		-- Execute without unnecessary parameters
		EXEC sp_executesql @SQL;
			
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspReviewEditorPostMedia]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 16/3/2025
-- Description:	Review images of posts, decicated by the EditorId and PostId (optional)
-- =============================================
CREATE PROCEDURE [Posting].[uspReviewEditorPostMedia]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostId INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Verify the user
		IF NOT EXISTS (SELECT 1 
					   FROM Posting.Post p
					   JOIN Posting.Editor e ON p.EditorId = e.Id
					   WHERE EditorId=@p_EditorId OR ManagedBy=@p_EditorId)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 159) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END

		SELECT 
			e.Id EditorId,
			e.FirstName + ' ' + e.LastName AS EditorName,
			p.Id PostId,
			p.Title PostTitle,
			m.Title MediaTitile,
			mt.Name MediaType,
			m.MediaFile
		FROM Posting.Editor e
		JOIN Posting.Post p ON e.Id=p.EditorId
		JOIN Posting.PostMedia pm ON p.Id = pm.PostId
		JOIN Posting.Media m ON pm.MediaId = m.Id
		JOIN Posting.MediaType mt ON mt.Id = m.MediaTypeId
		WHERE
			PublishStatusId=1
			AND p.IsDeleted=0
			AND (ManagedBy=@p_EditorId OR e.Id=@p_EditorId)
			AND p.Id = COALESCE(@p_PostId, p.Id)
		ORDER BY EditorId, PostId;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspReviewEditorPosts]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 13/3/2025
-- Update date: 16/3/2025
-- Description:	This procedure will be used by the managers to see their subordinates pending posts.
--					It also allows an editor to see his pending posts.
--					It also showcase the post's categories and subcategories.
-- =============================================
CREATE PROCEDURE [Posting].[uspReviewEditorPosts]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_PostId INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Verify the user
		IF NOT EXISTS (SELECT 1 
					   FROM Posting.Post p
					   JOIN Posting.Editor e ON p.EditorId = e.Id
					   WHERE EditorId=@p_EditorId OR ManagedBy=@p_EditorId)
		BEGIN
			-- Get all editor permissions
			IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
				AND Posting.fn_CheckEditorPermission(@p_EditorId, 159) = 0
			BEGIN
				RAISERROR('Invalid User', 16, 1)
			END
		END;

		WITH RecursiveManager AS (
			-- Anchor member: select the manager and their direct subordinates
			SELECT 
				e.Id EditorId,
				e.ManagedBy,
				e.FirstName + ' ' + e.LastName AS EditorName,
				p.Id PostId,
				p.Title,
				e.Id AS ManagerId -- ManagerId for tracking hierarchy
			FROM Posting.Editor e
			JOIN Posting.Post p ON e.Id = p.EditorId
			WHERE 
				PublishStatusId = 1
				AND p.IsDeleted = 0
				AND (ManagedBy = @p_EditorId OR e.Id = @p_EditorId)  -- Manager or Subordinate check
				AND p.Id = COALESCE(@p_PostId, p.Id)

			UNION ALL

			-- Recursive member: select subordinates of the previously selected editors
			SELECT 
				e.Id EditorId,
				e.ManagedBy,
				e.FirstName + ' ' + e.LastName AS EditorName,
				p.Id PostId,
				p.Title,
				rm.ManagerId -- Maintain the ManagerId for recursive tracking
			FROM Posting.Editor e
			JOIN Posting.Post p ON e.Id = p.EditorId
			JOIN RecursiveManager rm ON e.ManagedBy = rm.EditorId -- Join with recursive CTE to get subordinates
			WHERE 
				PublishStatusId = 1
				AND p.IsDeleted = 0
				AND p.Id = COALESCE(@p_PostId, p.Id)
		)

		-- Final query to select the results from the CTE and perform aggregation
		SELECT 
			EditorId, 
			ManagedBy,
			EditorName, 
			PostId, 
			Title, 
			STRING_AGG(Category, ' | ') AS Category,
			STRING_AGG(SubCategory, ', ') AS SubCategory
		FROM (
			SELECT 
				rm.EditorId, 
				rm.ManagedBy,
				rm.EditorName, 
				rm.PostId, 
				rm.Title, 
				c.Name AS Category,
				sc.Name AS SubCategory
			FROM RecursiveManager rm
			LEFT JOIN Posting.PostCategory pc ON rm.PostId = pc.PostId
			LEFT JOIN Posting.SubCategory sc ON sc.Id = pc.SubCategoryId
			LEFT JOIN Posting.Category c ON c.Id = sc.CategoryId
			GROUP BY 
				rm.EditorId, 
				rm.ManagedBy,
				rm.EditorName, 
				rm.PostId, 
				rm.Title, 
				c.Name, 
				sc.Name
		) AS UniqueCategories
		GROUP BY 
			EditorId, 
			ManagedBy,
			EditorName, 
			PostId, 
			Title;


		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspRole_AddRole]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	This procedure will add a new role to the Role table
-- =============================================
CREATE PROCEDURE [Posting].[uspRole_AddRole]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_Role VARCHAR(100),
	@p_Description VARCHAR(500),
	@p_RoleId INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 135) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- inserting the new role
		INSERT INTO Posting.Role(Name, Description, CreatedBy, CreatedAt, IsDeleted) 
		VALUES(@p_Role, @p_Description, @p_EditorId, GETDATE(), 0)

		SET @p_RoleId = SCOPE_IDENTITY();

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspRole_DeleteRole]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Update date: 19/3/2025
-- Description:	change the delete flag in the Role table
-- =============================================
CREATE PROCEDURE [Posting].[uspRole_DeleteRole]
	@p_EditorId INT,
	@p_RoleId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 135) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Role WHERE Id=@p_RoleId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.Role
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_RoleId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspRole_UpdateRole]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	update a row in the Role table.
-- =============================================
CREATE PROCEDURE [Posting].[uspRole_UpdateRole]
	@p_EditorId INT, 
	@p_RoleId INT,
	@p_UpdatedRole VARCHAR(100) = NULL,
	@p_UpdatedDescription VARCHAR(500) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 135) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.Role WHERE Id=@p_RoleId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Name and Description columns
		UPDATE Posting.Role
		SET
			Name = COALESCE(@p_UpdatedRole, Name), 
			Description = COALESCE(@p_UpdatedDescription, Description),
			UpdatedAt=GETDATE(), 
			UpdatedBy=@p_EditorId
		WHERE Id=@p_RoleId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspRolePermission_AddRolePermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	This procedure adds new permissions to roles
-- =============================================
CREATE PROCEDURE [Posting].[uspRolePermission_AddRolePermission]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_RoleId INT,
	@p_PermissionIds Posting.RolePermission READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Validate user
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 137) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		--***************THIS WAS COMMENTED BECAUSE IT USED TO USE MAGIC STRINGS***************
		---- extract role and permission
		--DECLARE @IRoleId INT;					-- The letter I refers to Inserted
		--DECLARE @PermissionId INT;
		--SELECT @IRoleId = Id FROM Posting.Role WHERE Name=@Role AND Deleted=0;
		--IF @IRoleId IS NULL
		--BEGIN
		--	RAISERROR('Invalid role name', 16, 1)
		--END 
		--SELECT @PermissionId = Id FROM Posting.Permission WHERE Name=@Permission AND Deleted=0;
		--IF @PermissionId IS NULL
		--BEGIN
		--	RAISERROR('Invalid permission name', 16, 1)
		--END 

		INSERT INTO Posting.RolePermission(RoleId, PermissionId, CreatedBy, CreatedAt, IsDeleted) 
		SELECT @p_RoleId, TVP_Permission, @p_Editorid, GETDATE(), 0 FROM @p_PermissionIds;

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_Editorid, @@PROCID, GETDATE());
	END TRY
	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_Editorid)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspRolePermission_DeleteRolePermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	change the delete flag in the RolePermission table
-- =============================================
CREATE PROCEDURE [Posting].[uspRolePermission_DeleteRolePermission]
	@p_EditorId INT,
	@p_RolePermissionId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 137) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.RolePermission WHERE Id=@p_RolePermissionId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.RolePermission
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_RolePermissionId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspRolePermission_UpdateRolePermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	update/change a premission from the table RolePermission
-- =============================================
CREATE PROCEDURE [Posting].[uspRolePermission_UpdateRolePermission]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_RolePermissionId INT,
	@p_PermisssionId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 137) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.RolePermission WHERE Id=@p_RolePermissionId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Media for the post
		UPDATE Posting.RolePermission
		SET 
			PermissionId = @p_PermisssionId,
			UpdatedAt = GETDATE(),
			UpdatedBy = @p_EditorId
		WHERE Id=@p_RolePermissionId

		-- Inserting the action committed into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspSubCategory_AddSubCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 3/3/2025
-- Update date: 19/3/2025
-- Description:	Adding sub-categories to the SubCategory table
-- =============================================
CREATE PROCEDURE [Posting].[uspSubCategory_AddSubCategory]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT,
	@p_CategoryId INT,
	@p_SubCategory VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 138) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		INSERT INTO Posting.SubCategory(CategoryId, Name, CreatedAt, CreatedBy, IsDeleted)
		VALUES(@p_CategoryId, @p_SubCategory, GETDATE(), @p_EditorId, 0)

		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES
			(ERROR_NUMBER(), @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
		RAISERROR(@ErrorMessage, @ErrorState, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspSubCategory_DeleteSubCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	change the delete flag in the SubCategory table
-- =============================================
CREATE PROCEDURE [Posting].[uspSubCategory_DeleteSubCategory]
	@p_EditorId INT,
	@p_SubCategoryId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 138) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.SubCategory WHERE Id=@p_SubCategoryId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- changing the flag
		UPDATE Posting.SubCategory
		SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@p_EditorId
		WHERE Id=@p_SubCategoryId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
/****** Object:  StoredProcedure [Posting].[uspSubCategory_UpdateSubCategory]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 10/3/2025
-- Description:	update a row in the SubCategory table.
-- =============================================
CREATE PROCEDURE [Posting].[uspSubCategory_UpdateSubCategory]
	-- Add the parameters for the stored procedure here
	@p_EditorId INT, 
	@p_SubCategoryId INT,
	@p_UpdatedSubCategory VARCHAR(100) = NULL,
	@p_UpdatedCategoryId INT = NULL

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Get all editor permissions
		IF Posting.fn_CheckEditorPermission(@p_EditorId, 127) = 0
			AND Posting.fn_CheckEditorPermission(@p_EditorId, 138) = 0
		BEGIN
			RAISERROR('Invalid User', 16, 1)
		END

		-- check if the row was updated before
		IF EXISTS(SELECT 1 FROM Posting.SubCategory WHERE Id=@p_SubCategoryId AND UpdatedAt IS NOT NULL AND IsDeleted=0)
		BEGIN
			RAISERROR('This row was updated already', 16, 1)
		END;

		-- Update the Name column
		UPDATE Posting.SubCategory
		SET 
			CategoryId = COALESCE(@p_UpdatedCategoryId, CategoryId),
			Name = COALESCE(@p_UpdatedSubCategory, Name),
			UpdatedAt=GETDATE(), 
			UpdatedBy=@p_EditorId
		WHERE Id=@p_SubCategoryId;
		
		-- Inserting the action commited into the log table
		INSERT INTO Logging.ActionLog(EditorId, ActionId, TimeStamp)
		VALUES (@p_EditorId, @@PROCID, GETDATE());
	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage VARCHAR(1000) = ERROR_MESSAGE(),
			@ERROR_SEVERITY INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()
		INSERT INTO Logging.ErrorLog
			(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, EditorId)
		VALUES(ERROR_NUMBER(), @ERROR_SEVERITY, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage, @p_EditorId)
			RAISERROR(@ErrorMessage, @ERROR_SEVERITY, @ErrorState)
	END CATCH
END
GO
USE [master]
GO
ALTER DATABASE [ContentManagementSystem] SET  READ_WRITE 
GO
