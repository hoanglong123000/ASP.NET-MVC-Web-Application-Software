USE [master]
GO
/****** Object:  Database [Original]    Script Date: 1/12/2023 1:12:34 PM ******/
CREATE DATABASE [Original]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Feedback', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Original.mdf' , SIZE = 8896KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Feedback_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Original_log.ldf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Original] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Original].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Original] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Original] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Original] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Original] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Original] SET ARITHABORT OFF 
GO
ALTER DATABASE [Original] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Original] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Original] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Original] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Original] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Original] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Original] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Original] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Original] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Original] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Original] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Original] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Original] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Original] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Original] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Original] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Original] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Original] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Original] SET  MULTI_USER 
GO
ALTER DATABASE [Original] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Original] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Original] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Original] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [Original] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Original] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [Original] SET QUERY_STORE = OFF
GO
USE [Original]
GO
/****** Object:  User [ori]    Script Date: 1/12/2023 1:12:34 PM ******/
CREATE USER [ori] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [dev]    Script Date: 1/12/2023 1:12:34 PM ******/
CREATE USER [dev] FOR LOGIN [dev] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [ori]
GO
ALTER ROLE [db_owner] ADD MEMBER [dev]
GO
/****** Object:  UserDefinedFunction [dbo].[func_GetAddress]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_GetAddress]
(
   @duong nvarchar(250) null,
   @phuong int null,
   @quan int null,
   @tinh int null
)
RETURNS nvarchar(500)
AS 
begin 
	 
	declare @result nvarchar(500)
	declare @text nvarchar(250)

	if @duong is not null
	begin
		set @result = @duong
	end

	if @phuong is not null
	begin 
		select @text = Name from Wards
		where Id = @phuong

		set @result = CONCAT(@result, ', ', @text) 
	end

	if @quan is not null
	begin 
		select @text = Name from Districts
		where Id = @quan

		set @result = CONCAT(@result, ', ', @text) 
	end
	if @tinh is not null
	begin 
		select @text = Name from Countries
		where Id = @tinh

		set @result = CONCAT(@result, ', ', @text) 
	end
	return @result
end 
GO
/****** Object:  Table [dbo].[EmployeeOrganizations]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeOrganizations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Organizations] [varchar](100) NOT NULL,
	[OrganizationId] [int] NOT NULL,
	[JobPositionId] [int] NULL,
	[OrgLevel] [int] NOT NULL,
	[Concurrently] [bit] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_EmployeeOrganizations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OrganizationOwners]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrganizationOwners]
AS
SELECT   op.OrganizationId, eo.EmployeeId, op.JobPositionId
FROM      dbo.OrganizationPositions AS op INNER JOIN
                dbo.EmployeeOrganizations AS eo ON eo.OrganizationId = op.OrganizationId AND op.JobPositionId = eo.JobPositionId
WHERE   (op.IsOwner = 1)


GO
/****** Object:  View [dbo].[OrganizationListViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrganizationListViews]
AS
SELECT   o.Id, o.ParentId, o.ParentStr, o.Name, o.Keyword, o.Code, o.NgayThanhLap, o.DirectManager, o.IndirectManagers, o.Type, o.OrgLevelId, o.LoaiHinhDuAn, o.Priority, o.Stopped, o.Status, o.TotalEmployee, o.PrivateCount, 
                oo.EmployeeId AS OwnerId, o.KhuVuc
FROM      dbo.Organizations AS o LEFT OUTER JOIN
                dbo.OrganizationOwners AS oo ON oo.EmployeeId =
                    (SELECT   TOP (1) EmployeeId
                     FROM      dbo.OrganizationOwners
                     WHERE   (OrganizationId = o.Id))
WHERE   (o.Status >= 0)


GO
/****** Object:  View [dbo].[OrganizationViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrganizationViews]
AS
SELECT   o.Id, o.ParentId, o.ParentStr, o.Name, o.Keyword, o.Code, o.NgayThanhLap, o.DirectManager, o.IndirectManagers, o.Type, o.OrgLevelId, o.LoaiHinhDuAn, o.Priority, o.Stopped, o.Status, o.TotalEmployee, o.PrivateCount, 
                oo.EmployeeId AS OwnerId, o.KhuVuc, o.QuyetDinh_So, o.QuyetDinh_Attach, o.DiaChi, o.InvestorId, o.SupervisionConsultantId, o.KhoangCach_Trung, o.KhoangCach_Bac, o.KhoangCach_Nam, o.NhiemVu, o.CaLamViec, o.ChucNang, 
                o.TGTC_Den, o.TGTC_Tu, o.GiaTriDuAn, o.UpdatedBy, o.UpdatedDate, o.CreatedBy, o.CreatedDate, o.RID, o.QuyMo, o.DienTichSan, o.TongCanDo, o.TienDoThucHien, o.SoBietThu, o.SoPhong
FROM      dbo.Organizations AS o LEFT OUTER JOIN
                dbo.OrganizationOwners AS oo ON oo.EmployeeId =
                    (SELECT   TOP (1) EmployeeId
                     FROM      dbo.OrganizationOwners
                     WHERE   (OrganizationId = o.Id))
WHERE   (o.Status >= 0)


GO
/****** Object:  Table [dbo].[Employees]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[Id] [uniqueidentifier] NOT NULL,
	[Keyword] [nvarchar](500) NULL,
	[StaffCode] [varchar](250) NULL,
	[Color] [varchar](10) NULL,
	[FullName] [nvarchar](256) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[DiDong] [varchar](50) NULL,
	[Avatar] [varchar](250) NULL,
	[Groups] [varchar](100) NULL,
	[GioiTinh] [int] NOT NULL,
	[TrangThaiCongViec] [int] NOT NULL,
	[IsCustomer] [bit] NOT NULL,
	[Developer] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[Status] [int] NOT NULL,
	[Priority] [int] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[EmployeeOrganizationViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[EmployeeOrganizationViews]
AS
SELECT   e.Id, eo.JobPositionId, eo.OrganizationId, eo.Organizations, jt.Id AS JobTitleId, jt.Priority, jt.[Group] AS GroupTitle, eo.Concurrently, eo.OrgLevel, e.MEP, o.Type AS OrgType, jt.Code AS JobTitleCode, jp.GroupId
FROM      dbo.Employees AS e LEFT OUTER JOIN
                dbo.EmployeeOrganizations AS eo ON e.Id = eo.EmployeeId LEFT OUTER JOIN
                dbo.Organizations AS o ON eo.OrganizationId = o.Id LEFT OUTER JOIN
                dbo.JobPositions AS jp ON jp.Id = eo.JobPositionId LEFT OUTER JOIN
                dbo.JobTitles AS jt ON jt.Id = jp.JobTitleId
WHERE   (e.TrangThaiCongViec = 1) AND (e.Status >= 0)


GO
/****** Object:  View [dbo].[EmployeeViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[EmployeeViews]
AS
SELECT        Id, StaffCode, FullName, Keyword, Color, Email, DiDong, Avatar, Groups, GioiTinh, TrangThaiCongViec, Developer, IsCustomer, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate, Status, Priority
FROM            dbo.Employees AS e
GO
/****** Object:  Table [dbo].[LocalJobPositions]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalJobPositions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[JobTitleId] [int] NULL,
	[Jobs] [nvarchar](max) NULL,
	[ExternalTitle] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[Priority] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[RequestRecruitment] [nvarchar](max) NULL,
	[GroupId] [int] NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.LocalJobPositions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalJobTitles]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalJobTitles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Priority] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[Status] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LocalJobTitles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalOrganizations]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalOrganizations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Keyword] [nvarchar](max) NULL,
	[Code] [nvarchar](max) NULL,
	[OwnerId] [uniqueidentifier] NULL,
	[InOwnerId1] [uniqueidentifier] NULL,
	[InOwnerId2] [uniqueidentifier] NULL,
	[InOwnerId3] [uniqueidentifier] NULL,
	[InOwnerId4] [uniqueidentifier] NULL,
	[Type] [int] NOT NULL,
	[KhuVuc] [int] NOT NULL,
	[Priority] [float] NULL,
	[Stopped] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_dbo.LocalOrganizations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalEmployees]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalEmployees](
	[Id] [uniqueidentifier] NOT NULL,
	[Keyword] [nvarchar](max) NULL,
	[StaffCode] [nvarchar](max) NULL,
	[FullName] [nvarchar](max) NULL,
	[EmailCongTy] [nvarchar](max) NULL,
	[DiDong] [nvarchar](max) NULL,
	[Avatar] [nvarchar](max) NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[Status] [int] NOT NULL,
	[Locked] [bit] NOT NULL,
	[LoginName] [nvarchar](max) NULL,
	[Password] [nvarchar](max) NULL,
	[JobPositionId] [int] NULL,
	[OrganizationId] [int] NULL,
	[IsAdmin] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.LocalEmployees] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[LocalEmployeeBaseViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LocalEmployeeBaseViews]
AS
SELECT        e.Id, e.StaffCode, e.FullName, e.EmailCongTy, e.Avatar, e.JobPositionId, e.OrganizationId, jp.JobTitleId, jp.Name AS JobPositionname, o.Name AS OrganizationName, jt.Name AS JobTitleName
FROM            dbo.LocalEmployees AS e LEFT OUTER JOIN
                         dbo.LocalJobPositions AS jp ON jp.Id = e.JobPositionId LEFT OUTER JOIN
                         dbo.LocalOrganizations AS o ON o.Id = e.OrganizationId LEFT OUTER JOIN
                         dbo.LocalJobTitles AS jt ON jt.Id = jp.JobTitleId
WHERE        (e.Status >= 0)
 
GO
/****** Object:  View [dbo].[OrganizationChartViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrganizationChartViews]
AS
SELECT   o.Id, o.Code, o.ParentId, o.ParentStr, o.Name, o.DirectManager, o.Type, o.OrgLevelId, o.Priority, o.Stopped, oo.EmployeeId AS OwnerId, oo.JobPositionId
FROM      dbo.Organizations AS o LEFT OUTER JOIN
                    (SELECT   op.OrganizationId, eo.EmployeeId, op.JobPositionId
                     FROM      dbo.OrganizationPositions AS op INNER JOIN
                                     dbo.EmployeeOrganizations AS eo ON eo.OrganizationId = op.OrganizationId AND op.JobPositionId = eo.JobPositionId
                     WHERE   (op.IsOwner = 1)) AS oo ON oo.OrganizationId = o.Id


GO
/****** Object:  View [dbo].[LocalEmployeeViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LocalEmployeeViews]
AS
SELECT        e.Id, e.Keyword, e.StaffCode, e.FullName, e.EmailCongTy, e.DiDong, e.Avatar, e.CreatedBy, e.CreatedDate, e.UpdatedBy, e.UpdatedDate, e.Status, e.Locked, e.LoginName, e.Password, e.JobPositionId, e.OrganizationId, 
                         jp.Name AS JobPositionname, o.Name AS OrganizationName, jt.Name AS JobTitleName, jp.GroupId, e.IsAdmin, jp.JobTitleId
FROM            dbo.LocalEmployees AS e LEFT OUTER JOIN
                         dbo.LocalJobPositions AS jp ON jp.Id = e.JobPositionId LEFT OUTER JOIN
                         dbo.LocalOrganizations AS o ON o.Id = e.OrganizationId LEFT OUTER JOIN
                         dbo.LocalJobTitles AS jt ON jt.Id = jp.JobTitleId
GO
/****** Object:  View [dbo].[ProjectFeatureConfirmViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ProjectFeatureConfirmViews]
AS
SELECT        c.Id, e.FullName, c.FeatureId, c.Type, c.Date, c.Status, e.StaffCode, e.Color
FROM            dbo.ProjectFeatureConfirms AS c INNER JOIN
                         dbo.Employees AS e ON e.Id = c.EmployeeId
GO
/****** Object:  Table [dbo].[Students]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [varchar](1000) NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[Avatar] [varchar](250) NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Email] [varchar](250) NULL,
	[NgaySinh] [date] NULL,
	[GioiTinh] [int] NOT NULL,
	[GroupId] [int] NULL,
	[MoTa] [nvarchar](3000) NULL,
	[TomTat] [nvarchar](1000) NULL,
 CONSTRAINT [PK_epOjNyn6dd] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StudentViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StudentViews]
AS
SELECT        s.Id, s.Keyword, s.Status, s.CreatedBy, s.CreatedDate, s.UpdatedDate, s.UpdatedBy, s.Avatar, s.Name, s.Email, s.NgaySinh, s.GioiTinh, s.GroupId, s.MoTa, s.TomTat, e.FullName AS NguoiTao
FROM            dbo.Students AS s INNER JOIN
                         dbo.Employees AS e ON e.Id = s.CreatedBy
GO
/****** Object:  View [dbo].[PaymentPeriodViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PaymentPeriodViews]
AS
SELECT        p.Id, pr.CompanyId, c.SortName AS CompanyName, pr.Id AS ProjectId, pr.Name AS ProjectName, pc.Id AS ContractId, pc.Name AS ContractName, pc.TongGiaTri, pc.Code AS SoHD, p.Ngay, p.Status, p.SoTien, p.GhiChu, 
                         p.DinhKem
FROM            dbo.PaymentPeriods AS p INNER JOIN
                         dbo.ProContracts AS pc ON pc.Id = p.ContractId INNER JOIN
                         dbo.Projects AS pr ON pr.Id = pc.ProjectId INNER JOIN
                         dbo.Companies AS c ON c.Id = pr.CompanyId
WHERE        (p.Status >= 0) AND (pc.Status >= 0) AND (pr.Status >= 0) AND (c.Status >= 0)
GO
/****** Object:  View [dbo].[ProjectFeatureViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ProjectFeatureViews]
AS
SELECT        f.Id, f.Keyword, f.Name, f.ProjectId, f.GroupId, g.Name AS GroupName, f.Groups, f.STT, f.Type, f.NgayCong, f.NhanCong, f.TG_BatDau, f.TG_KetThuc, f.ChiPhi, f.Status, f.CreatedBy, f.CreatedDate, f.UpdatedDate, f.UpdatedBy, 
                         f.TyLe, f.DonGia, f.Note
FROM            dbo.ProjectFeatures AS f LEFT OUTER JOIN
                         dbo.ProjectGroups AS g ON g.Id = f.GroupId
GO
/****** Object:  View [dbo].[ProjectTaskViews]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ProjectTaskViews]
AS
SELECT   t.Id, t.STT, f.ProjectId, f.ModuleId, f.Id AS FeatureId, f.Status
FROM      dbo.ProjectTasks AS t INNER JOIN
                dbo.ProjectFeatures AS f ON f.Id = t.FeatureId
GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppSettings]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Tab] [varchar](250) NOT NULL,
	[Section] [varchar](250) NULL,
	[Value] [nvarchar](3000) NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Note] [nvarchar](1000) NULL,
 CONSTRAINT [PK_SystemSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Brands]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brands](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Keyword] [nvarchar](255) NULL,
 CONSTRAINT [PK__Brands__27BC72A9CDA25D10] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Clothes]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clothes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[SizeId] [int] NOT NULL,
	[BrandId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[Status] [int] NOT NULL,
	[Keyword] [nvarchar](255) NULL,
	[Price] [decimal](18, 0) NULL,
	[Amount] [int] NULL,
 CONSTRAINT [PK_Clothes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Keyword] [nvarchar](300) NULL,
	[Name] [nvarchar](100) NULL,
	[PhoneNumber] [varchar](10) NULL,
	[Email] [nvarchar](100) NULL,
	[Address] [nvarchar](150) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DetailReceipts]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetailReceipts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NULL,
	[Keyword] [nvarchar](300) NULL,
	[ClothesId] [int] NULL,
	[UnitMeasure] [nvarchar](30) NULL,
	[Ammount] [int] NULL,
	[Price] [decimal](18, 0) NULL,
	[FinalPrice] [decimal](18, 0) NULL,
	[CouponId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmailTasks]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailTasks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Subject] [nvarchar](1000) NOT NULL,
	[ReceiverType] [int] NOT NULL,
	[Receivers] [varchar](max) NOT NULL,
	[CCType] [int] NULL,
	[CC] [varchar](max) NULL,
	[BodyPath] [varchar](250) NOT NULL,
	[Attachs] [varchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Remind] [bit] NOT NULL,
	[Module] [varchar](50) NULL,
	[EmailType] [varchar](250) NULL,
	[ObjectId] [int] NULL,
	[ObjectGuid] [uniqueidentifier] NULL,
	[SentDate] [datetime] NULL,
	[SentNumber] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Error] [nvarchar](3000) NULL,
	[AlternateViews] [nvarchar](3000) NULL,
	[Note] [nvarchar](3000) NULL,
 CONSTRAINT [PK_EmailTasks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeAuths]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeAuths](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[LoginName] [varchar](250) NOT NULL,
	[PasswordHash] [varchar](max) NULL,
	[AccessFailedCount] [int] NOT NULL,
	[LoginLastTime] [datetime] NULL,
	[Locked] [bit] NOT NULL,
	[ActiveCode] [varchar](250) NULL,
	[ResetPassNumber] [varchar](50) NULL,
 CONSTRAINT [PK_UserAuths] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeWorkLogs]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeWorkLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[PerformBy] [uniqueidentifier] NULL,
	[ObjectType] [varchar](50) NULL,
	[ObjectId] [varchar](3000) NULL,
	[Message] [nvarchar](max) NOT NULL,
	[IP] [varchar](50) NULL,
	[UserAgent] [nvarchar](250) NULL,
	[Note] [nvarchar](max) NULL,
 CONSTRAINT [PK_WorkingLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FeatureGroups]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeatureGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[FeatureId] [int] NOT NULL,
	[AllowView] [bit] NOT NULL,
	[AllowUpdate] [bit] NOT NULL,
	[AllowDelete] [bit] NOT NULL,
	[AllowCreate] [bit] NOT NULL,
	[Emails] [varchar](250) NULL,
 CONSTRAINT [PK_SidebarRoleDefaults] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Features]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Features](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](250) NOT NULL,
	[SidebarName] [nvarchar](250) NOT NULL,
	[Icon] [varchar](50) NULL,
	[ProcessCode] [varchar](50) NULL,
	[ParentId] [int] NULL,
	[HasApproval] [bit] NOT NULL,
	[HasView] [bit] NOT NULL,
	[HasAdd] [bit] NOT NULL,
	[HasEdit] [bit] NOT NULL,
	[HasDelete] [bit] NOT NULL,
	[ViewAction] [varchar](250) NULL,
	[RelateActions] [varchar](1000) NULL,
	[Priority] [float] NOT NULL,
	[Visible] [bit] NOT NULL,
	[Sidebar] [bit] NOT NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_Features] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Groups]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Groups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Keyword] [varchar](250) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Priority] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[AllowHrm] [bit] NOT NULL,
	[AllowPortal] [bit] NOT NULL,
	[AllowData] [int] NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalCountries]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalCountries](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [varchar](200) NULL,
	[MaTinh] [varchar](50) NULL,
	[Name] [nvarchar](200) NULL,
	[Code] [varchar](200) NULL,
	[Lat] [decimal](9, 6) NOT NULL,
	[Lng] [decimal](10, 6) NOT NULL,
	[Priority] [datetime] NULL,
	[MapName] [nvarchar](250) NULL,
	[Nation] [int] NOT NULL,
	[MaThue] [varchar](50) NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalDistricts]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalDistricts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](200) NULL,
	[Keyword] [varchar](150) NULL,
	[Name] [nvarchar](200) NULL,
	[CountryId] [int] NOT NULL,
	[Lat] [decimal](9, 6) NOT NULL,
	[Lng] [decimal](10, 6) NOT NULL,
	[Priority] [datetime] NULL,
	[MapName] [nvarchar](200) NULL,
	[MaHuyen] [varchar](50) NULL,
	[MaThue] [varchar](50) NULL,
 CONSTRAINT [PK_Districts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalEmailTasks]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalEmailTasks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Subject] [nvarchar](max) NULL,
	[ReceiverType] [int] NOT NULL,
	[Receivers] [nvarchar](max) NULL,
	[CCType] [int] NULL,
	[CC] [nvarchar](max) NULL,
	[BodyPath] [nvarchar](max) NULL,
	[Attachs] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Remind] [bit] NOT NULL,
	[Module] [nvarchar](max) NULL,
	[EmailType] [nvarchar](max) NULL,
	[ObjectId] [int] NULL,
	[ObjectGuid] [uniqueidentifier] NULL,
	[SentDate] [datetime] NULL,
	[SentNumber] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Error] [nvarchar](max) NULL,
	[AlternateViews] [nvarchar](max) NULL,
	[Note] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.LocalEmailTasks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalEmailTemplates]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalEmailTemplates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](max) NULL,
	[Keyword] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Detail] [nvarchar](max) NULL,
	[Attributes] [nvarchar](max) NULL,
	[Subject] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.LocalEmailTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalEmpWorkLogs]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalEmpWorkLogs](
	[Id] [uniqueidentifier] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Type] [nvarchar](max) NULL,
	[PerformBy] [uniqueidentifier] NULL,
	[ObjectType] [nvarchar](max) NULL,
	[ObjectId] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NULL,
	[IP] [nvarchar](max) NULL,
	[UserAgent] [nvarchar](max) NULL,
	[Note] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.LocalEmpWorkLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalFeatureGroups]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalFeatureGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[FeatureId] [int] NOT NULL,
	[AllowView] [bit] NOT NULL,
	[AllowUpdate] [bit] NOT NULL,
	[AllowDelete] [bit] NOT NULL,
	[AllowCreate] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.LocalFeatureGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalFeatures]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalFeatures](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[SidebarName] [nvarchar](max) NULL,
	[Icon] [nvarchar](max) NULL,
	[ProcessCode] [nvarchar](max) NULL,
	[ParentId] [int] NULL,
	[HasApproval] [bit] NOT NULL,
	[HasView] [bit] NOT NULL,
	[HasAdd] [bit] NOT NULL,
	[HasEdit] [bit] NOT NULL,
	[HasDelete] [bit] NOT NULL,
	[ViewAction] [nvarchar](max) NULL,
	[RelateActions] [nvarchar](max) NULL,
	[Priority] [float] NOT NULL,
	[Visible] [bit] NOT NULL,
	[Sidebar] [bit] NOT NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_dbo.LocalFeatures] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalGroups]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](max) NULL,
	[Keyword] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Priority] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Allow] [bit] NOT NULL,
	[AllowData] [int] NOT NULL,
 CONSTRAINT [PK_dbo.LocalGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalNations]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalNations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [varchar](200) NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Priority] [int] NOT NULL,
	[MaThue] [varchar](50) NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_Nations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalOptionValues]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalOptionValues](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [varchar](250) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[MoRong1] [nvarchar](250) NULL,
	[MoRong2] [nvarchar](250) NULL,
	[MoRong3] [nvarchar](250) NULL,
	[MoRong4] [nvarchar](250) NULL,
	[MoRong5] [nvarchar](250) NULL,
	[Note] [nvarchar](250) NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Status] [int] NOT NULL,
	[Priority] [int] NOT NULL,
	[AllowChange] [bit] NOT NULL,
 CONSTRAINT [PK_ConstantValues] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalSettings]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Tab] [nvarchar](max) NULL,
	[Section] [nvarchar](max) NULL,
	[Value] [nvarchar](max) NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Note] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.LocalSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocalWards]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocalWards](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [varchar](250) NULL,
	[Code] [varchar](200) NULL,
	[MaPhuong] [varchar](50) NULL,
	[Name] [nvarchar](200) NULL,
	[DistrictId] [int] NOT NULL,
	[MaThue] [varchar](50) NULL,
 CONSTRAINT [PK_Wards_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResourceDemos]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResourceDemos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Type] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ResourceDemos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SizeTabs]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SizeTabs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[Name] [nvarchar](255) NULL,
	[Keyword] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SoldCoupons]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SoldCoupons](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[Keyword] [nvarchar](300) NULL,
	[SoldDate] [datetime] NULL,
	[BuyerName] [int] NULL,
	[IsOnlineShop] [int] NULL,
	[TotalPrice] [decimal](18, 0) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Test]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ammount] [int] NULL,
	[Price] [int] NULL,
	[TotalPrice]  AS ([Ammount]*[Price])
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TypeClothes]    Script Date: 1/12/2023 1:12:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeClothes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[Name] [nvarchar](255) NULL,
	[Keyword] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmailTasks] ADD  CONSTRAINT [DF_EmailTasks_Remind]  DEFAULT ((0)) FOR [Remind]
GO
ALTER TABLE [dbo].[EmailTasks] ADD  CONSTRAINT [DF_EmailTasks_SentNumber]  DEFAULT ((0)) FOR [SentNumber]
GO
ALTER TABLE [dbo].[EmailTasks] ADD  CONSTRAINT [DF_EmailTasks_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[EmployeeAuths] ADD  CONSTRAINT [DF_UserAuths_AccessFailedCount]  DEFAULT ((0)) FOR [AccessFailedCount]
GO
ALTER TABLE [dbo].[EmployeeAuths] ADD  CONSTRAINT [DF_UserAuths_Locked]  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[EmployeeOrganizations] ADD  CONSTRAINT [DF_EmployeeOrganizations_IsPrimary]  DEFAULT ((0)) FOR [Concurrently]
GO
ALTER TABLE [dbo].[EmployeeOrganizations] ADD  CONSTRAINT [DF_EmployeeOrganizations_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[Employees] ADD  CONSTRAINT [DF_AspNetUsers_Male]  DEFAULT ((0)) FOR [GioiTinh]
GO
ALTER TABLE [dbo].[Employees] ADD  CONSTRAINT [DF_Employees_TrangThaiCongViec]  DEFAULT ((0)) FOR [TrangThaiCongViec]
GO
ALTER TABLE [dbo].[Employees] ADD  CONSTRAINT [DF_Employees_Developer]  DEFAULT ((0)) FOR [Developer]
GO
ALTER TABLE [dbo].[Employees] ADD  CONSTRAINT [DF_AspNetUsers_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[Employees] ADD  CONSTRAINT [DF_Employees_Priority]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [dbo].[FeatureGroups] ADD  CONSTRAINT [DF_SidebarRoleDefaults_AllowView]  DEFAULT ((0)) FOR [AllowView]
GO
ALTER TABLE [dbo].[FeatureGroups] ADD  CONSTRAINT [DF_SidebarRoleDefaults_AllowCommand]  DEFAULT ((0)) FOR [AllowUpdate]
GO
ALTER TABLE [dbo].[FeatureGroups] ADD  CONSTRAINT [DF_SidebarRoleDefaults_AllowDelete]  DEFAULT ((0)) FOR [AllowDelete]
GO
ALTER TABLE [dbo].[FeatureGroups] ADD  CONSTRAINT [DF_SidebarRoleDefaults_AllowCreate]  DEFAULT ((0)) FOR [AllowCreate]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_HasPerform]  DEFAULT ((0)) FOR [HasApproval]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_HasView]  DEFAULT ((0)) FOR [HasView]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_HasAdd]  DEFAULT ((0)) FOR [HasAdd]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_HasEdit]  DEFAULT ((0)) FOR [HasEdit]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_HasDelete]  DEFAULT ((0)) FOR [HasDelete]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_Type]  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [dbo].[Groups] ADD  CONSTRAINT [DF_Groups_Priority]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [dbo].[Groups] ADD  CONSTRAINT [DF_Groups_AllowHrm]  DEFAULT ((0)) FOR [AllowHrm]
GO
ALTER TABLE [dbo].[Groups] ADD  CONSTRAINT [DF_Groups_AllowPortal]  DEFAULT ((0)) FOR [AllowPortal]
GO
ALTER TABLE [dbo].[Groups] ADD  CONSTRAINT [DF_Groups_AllowData]  DEFAULT ((0)) FOR [AllowData]
GO
ALTER TABLE [dbo].[LocalNations] ADD  CONSTRAINT [DF_Nations_Priority]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [dbo].[LocalNations] ADD  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [dbo].[LocalOptionValues] ADD  CONSTRAINT [DF_OptionValues_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[LocalOptionValues] ADD  CONSTRAINT [DF_OptionValues_Priority]  DEFAULT ((2100000000)) FOR [Priority]
GO
ALTER TABLE [dbo].[Students] ADD  CONSTRAINT [DF_tWZSS6E89Y_Status]  DEFAULT ((0)) FOR [Status]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 148
               Right = 248
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "eo"
            Begin Extent = 
               Top = 6
               Left = 290
               Bottom = 148
               Right = 467
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "o"
            Begin Extent = 
               Top = 6
               Left = 509
               Bottom = 148
               Right = 739
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "jp"
            Begin Extent = 
               Top = 6
               Left = 781
               Bottom = 148
               Right = 988
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "jt"
            Begin Extent = 
               Top = 6
               Left = 1030
               Bottom = 148
               Right = 1206
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'EmployeeOrganizationViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'EmployeeOrganizationViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 304
               Right = 248
            End
            DisplayFlags = 280
            TopColumn = 5
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'EmployeeViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'EmployeeViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "o"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 248
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "oo"
            Begin Extent = 
               Top = 6
               Left = 314
               Bottom = 223
               Right = 491
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationChartViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationChartViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "o"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 148
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "oo"
            Begin Extent = 
               Top = 6
               Left = 314
               Bottom = 129
               Right = 491
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationListViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationListViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "op"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 148
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "eo"
            Begin Extent = 
               Top = 6
               Left = 261
               Bottom = 148
               Right = 438
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationOwners'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationOwners'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "o"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 148
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "oo"
            Begin Extent = 
               Top = 6
               Left = 314
               Bottom = 129
               Right = 491
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrganizationViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 249
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "pc"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pr"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 136
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PaymentPeriodViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PaymentPeriodViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[27] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 244
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 189
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ProjectFeatureConfirmViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ProjectFeatureConfirmViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "f"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 202
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 223
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ProjectFeatureViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ProjectFeatureViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "t"
            Begin Extent = 
               Top = 6
               Left = 42
               Bottom = 148
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "f"
            Begin Extent = 
               Top = 6
               Left = 260
               Bottom = 148
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ProjectTaskViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ProjectTaskViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[38] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "s"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 438
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StudentViews'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StudentViews'
GO
USE [master]
GO
ALTER DATABASE [Original] SET  READ_WRITE 
GO
