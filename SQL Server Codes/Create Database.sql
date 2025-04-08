/****** Object:  Database [ContentManagementSystem]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE DATABASE [ContentManagementSystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ContentManagementSystem', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ContentManagementSystem.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [FilestreamData] CONTAINS FILESTREAM 
( NAME = N'FilestreamDataFile1', FILENAME = N'C:\CMS\Media' , MAXSIZE = UNLIMITED), 
 FILEGROUP [IndexFileGroup] 
( NAME = N'IndexData', FILENAME = N'C:\CMS\TablesFileGroup\Indexes.ndf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [MediaFileGroup] CONTAINS FILESTREAM  DEFAULT
( NAME = N'MediaData', FILENAME = N'C:\CMS\MediaFileGroup\MediaData.ndf' , MAXSIZE = UNLIMITED), 
 FILEGROUP [TablesFileGroup] 
( NAME = N'PostsData', FILENAME = N'C:\CMS\TablesFileGroup\PostsData.ndf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ContentManagementSystem_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ContentManagementSystem_log.ldf' , SIZE = 139264KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [ContentManagementSystem] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ContentManagementSystem].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
/****** Object:  Schema [Logging]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE SCHEMA [Logging]
GO
/****** Object:  Schema [Posting]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE SCHEMA [Posting]
GO