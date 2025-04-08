/****** Object:  Table [Logging].[ActionLog]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Logging].[ActionLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EditorId] [int] NOT NULL,
	[TimeStamp] [datetime2](7) NOT NULL,
	[ActionId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Logging].[ErrorLog]    Script Date: 4/8/2025 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Logging].[ErrorLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ErrorTime] [datetime2](7) NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorSeverity] [tinyint] NOT NULL,
	[ErrorState] [tinyint] NOT NULL,
	[ErrorProcedure] [varchar](200) NOT NULL,
	[ErrorLine] [smallint] NOT NULL,
	[ErrorMessage] [varchar](2000) NOT NULL,
	[EditorId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO