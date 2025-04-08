/****** Object:  UserDefinedTableType [Posting].[PostCategoryTVP]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE TYPE [Posting].[PostCategoryTVP] AS TABLE(
	[TVP_SubCategoryId] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [Posting].[PostMediaTVP]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE TYPE [Posting].[PostMediaTVP] AS TABLE(
	[TVP_MediaFilePath] [nvarchar](300) NULL
)
GO
/****** Object:  UserDefinedTableType [Posting].[PostTVP]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE TYPE [Posting].[PostTVP] AS TABLE(
	[TVP_EditorId] [int] NOT NULL,
	[TVP_Title] [varchar](200) NOT NULL,
	[TVP_Content] [varchar](4000) NOT NULL
)
GO
/****** Object:  UserDefinedTableType [Posting].[RolePermission]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE TYPE [Posting].[RolePermission] AS TABLE(
	[TVP_Permission] [int] NULL
)
GO