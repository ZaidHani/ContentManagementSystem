/****** Object:  UserDefinedFunction [Posting].[fn_CheckEditorPermission]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zaid Allawanseh
-- Create date: 18/3/2025
-- Description:	This function will return 1 if the user has the permission and 0 if he doesn't
-- =============================================
CREATE FUNCTION [Posting].[fn_CheckEditorPermission] 
(
	-- Add the parameters for the function here
    @EditorId INT,
    @PermissionId INT
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @HasPermission BIT = 0;

	-- Add the T-SQL statements to compute the return value here
	IF EXISTS (
        SELECT 1
        FROM Posting.Editor AS E
        JOIN Posting.Role AS R ON R.Id = E.RoleId
        JOIN Posting.RolePermission AS RP ON R.Id = RP.RoleId
        JOIN Posting.Permission AS P ON RP.PermissionId = P.Id
        WHERE 
            E.Id = @EditorId 
            AND P.Id = @PermissionId
            AND E.IsDeleted = 0
            AND R.IsDeleted = 0
            AND RP.IsDeleted = 0
            AND P.IsDeleted = 0
    )
    BEGIN
        SET @HasPermission = 1;
    END

	-- Return the result of the function
	RETURN @HasPermission

END
GO