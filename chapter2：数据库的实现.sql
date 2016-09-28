USE MASTER
GO
/*--学时1--*/
/*--案例：使用SQL语句创建数据库MySchool具有一个数据文件和一个日志文件*/
CREATE DATABASE MySchool
ON  PRIMARY  --默认就属于PRIMARY主文件组，可省略
(
/*--数据文件的具体描述--*/
 NAME='MySchool_data',  --主数据文件的逻辑名称
 FILENAME='D:\project\MySchool_data.mdf',  --主数据文件的物理名称
 SIZE=10mb,  --主数据文件的初始大小
 MAXSIZE=100mb,  --主数据文件增长的最大值
 FILEGROWTH=15%   --主数据文件的增长率
)
LOG ON
(
  /*--日志文件的具体描述，各参数含义同上--*/
  NAME='MySchool_log',
  FILENAME='D:\project\MySchool_log.ldf',
  SIZE=3mb,
  MAXSIZE=20mb,  --日志文件增长的最大值
  FILEGROWTH=1mb
)


/*--案例：使用SQL语句创建数据库Employee具有多个数据文件和多个日志文件*/
CREATE  DATABASE  Employee
  ON   PRIMARY
 (
   /*-主数据文件的具体描述-*/
   NAME = 'employee1', 
   FILENAME = 'D:\project\employee1.mdf' , 
   SIZE = 10, 
   FILEGROWTH = 10%
 
  ), 
  (
   /*-次要数据文件的具体描述-*/
   NAME = 'employee2', 
   FILENAME = 'D:\project\employee2.ndf' , 
   SIZE = 20, 
   MAXSIZE = 100, 
   FILEGROWTH = 1
  ) 
  LOG ON 
  (
   /*-日志文件1的具体描述-*/
   NAME = 'employeelog1', 
   FILENAME = 'D:\project\employeelog1_Log.ldf' , 
   SIZE = 10, 
   MAXSIZE=50,
   FILEGROWTH = 1
   ) ,
  (
   /*-日志文件2的具体描述-*/
   NAME = 'employeelog2', 
   FILENAME = 'D:\project\employeelog2_Log.ldf' , 
   SIZE = 10, 
   MAXSIZE = 50, 
   FILEGROWTH = 1
  )
/*--再次创建MySchool数据库-- */
USE master
GO

CREATE DATABASE MySchool
GO
/*--查询MySchool信息--*/
USE master
GO

SELECT * FROM sysdatabases

/*--案例：使用SQL语句删除数据库MySchool*/
  DROP DATABASE MySchool

/*--案例：创建数据库MySchool——判断删除已创建的数据库*/
	USE master  --设置当前数据库为master，以便访问sysdatabases表
	GO
	IF  EXISTS(SELECT * FROM  sysdatabases  WHERE  name ='MySchool')
	DROP DATABASE MySchool
	CREATE  DATABASE  MySchool
	ON (
	 …
	)
	LOG ON
	(
	 …
	)
	GO

/*--学时2--*/
/*--案例：使用SQL语句创建Student表--*/
CREATE TABLE [dbo].[Student](
	[StudentNo] [int] NOT NULL,
	[LoginPwd] [nvarchar](50) NOT NULL,
	[StudentName] [nvarchar](50) NOT NULL,
	[Sex] bit NOT NULL,
	[GradeId] [int] NOT NULL,
	[Phone] [nvarchar](50) NULL,
	[Address] [nvarchar](255) NULL,
	[BornDate] [datetime] NOT NULL,
	[Email] [nvarchar](50) NULL,
	[IdentityCard] [varchar](18) NOT NULL
 )

/*--查询得到Student表的信息--*/
USE MySchool
GO

SELECT * FROM sysobjects

/*--案例：使用SQL语句删除表Student--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Student')
  DROP  TABLE  Student

/*--案例：使用SQL语句创建Subject表--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Subject')
  DROP  TABLE  Subject
CREATE TABLE [dbo].[Subject](
	[SubjectNo] [int] IDENTITY(1,1) NOT NULL,
	[SubjectName] [nchar](50) NOT NULL,
	[ClassHour] [int] NOT NULL,
	[GradeId] [int] NOT NULL
)

/*--案例：使用SQL语句创建Result表--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Result')
  DROP  TABLE  Result
CREATE TABLE [dbo].[Result](
	[StudentNo] [int] NOT NULL,
	[SubjectNo] [int] NOT NULL,
	[StudentResult] [int] NOT NULL,
	[ExamDate] [datetime] NOT NULL
)

/*--案例：使用SQL脚本创建Student表--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Student')
  DROP  TABLE  Student
CREATE TABLE [dbo].[Student](
	[StudentNo] [int] NOT NULL,
	[LoginPwd] [nvarchar](50) NOT NULL,
	[StudentName] [nvarchar](50) NOT NULL,
	[Sex] [bit] NOT NULL,
	[GradeId] [int] NOT NULL,
	[Phone] [varchar](50) NULL,
	[Address] [nvarchar](255) NULL,
	[BornDate] [datetime] NOT NULL,
	[Email] [varchar](50) NULL,
	[IdentityCard] [varchar](18) NOT NULL,
 )

/*--案例：使用SQL脚本创建Grade表--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Grade')
  DROP  TABLE  Grade
CREATE TABLE [dbo].[Grade](
	[GradeId] [int] IDENTITY(1,1) NOT NULL,
	[GradeName] [nvarchar](50) NOT NULL
)

/*--学时3--*/
/*--案例：使用SQL语句在Grade和Student表添加约束*/

ALTER TABLE Grade --主键约束
ADD CONSTRAINT PK_GradeID PRIMARY KEY(GradeID)

ALTER TABLE Student --主键约束
ADD CONSTRAINT PK_StuNo PRIMARY KEY (StudentNo)

ALTER TABLE Student --唯一约束（身份证号唯一）
ADD CONSTRAINT UQ_stuID UNIQUE (IdentityCard)

ALTER TABLE Student --默认约束（地址不详）
ADD CONSTRAINT DF_stuAddress DEFAULT ('地址不详') FOR Address

ALTER TABLE Student --检查约束（出生日期是自1980年1月1日以后）
ADD CONSTRAINT CK_stuBornDate CHECK(BornDate>='1980-1-1')

/*--在Grade 表中添加外键约束（主表Grade和从表Student建立关系）
   在建对Grade 表的外键约束之前必须建立Grade表的主键约束  --*/
ALTER TABLE Student --添加外键约束
ADD CONSTRAINT FK_Grade          
    FOREIGN KEY(GradeID) REFERENCES Grade(GradeID)

/*--案例：使用SQL语句删除Student表默认约束(地址不详)--*/
ALTER  TABLE  Student  
DROP  CONSTRAINT  DF_stuAddress

/*--案例：使用SQL语句创建Subject表的约束--*/
ALTER TABLE Subject --主键约束（科目编号）
ADD CONSTRAINT PK_Subject PRIMARY KEY(SubjectNo)

ALTER TABLE Subject --非空约束（科目名称）
ADD CONSTRAINT CK_SubjectName CHECK(SubjectName is not null)

ALTER TABLE Subject --检查约束（学时必须大于等于0）
ADD CONSTRAINT CK_ClassHour CHECK(ClassHour>=0)

ALTER TABLE Subject --外键约束（主表Grade和从表Subject建立引用关系）
ADD CONSTRAINT FK_GradeId          
    FOREIGN KEY(GradeId) REFERENCES Grade(GradeId)

/*--学时 4--*/
/*--案例：使用SQL语句创建Result表的约束--*/
ALTER TABLE Result --主键约束（学号、科目号、日期）
ADD CONSTRAINT PK_Result PRIMARY KEY(StudentNo,SubjectNo,ExamDate)

ALTER TABLE Result --默认约束（日期为系统当前日期）
ADD CONSTRAINT CK_ExamDate DEFAULT (getdate()) FOR ExamDate

ALTER TABLE Result --检查约束（分数不能大于100，小于0）
ADD CONSTRAINT CK_StudentResult CHECK(StudentResult BETWEEN 0 AND 100)

ALTER TABLE Result --外键约束（主表Student和从表Result建立关系）
ADD CONSTRAINT FK_StudentNo          
    FOREIGN KEY(StudentNo) REFERENCES Student(StudentNo)

ALTER TABLE Result --外键约束（主表Subject和从表Result建立关系）
ADD CONSTRAINT FK_SubjectNo          
    FOREIGN KEY(SubjectNo) REFERENCES Subject(SubjectNo)


