USE MASTER
GO
/*--ѧʱ1--*/
/*--������ʹ��SQL��䴴�����ݿ�MySchool����һ�������ļ���һ����־�ļ�*/
CREATE DATABASE MySchool
ON  PRIMARY  --Ĭ�Ͼ�����PRIMARY���ļ��飬��ʡ��
(
/*--�����ļ��ľ�������--*/
 NAME='MySchool_data',  --�������ļ����߼�����
 FILENAME='D:\project\MySchool_data.mdf',  --�������ļ�����������
 SIZE=10mb,  --�������ļ��ĳ�ʼ��С
 MAXSIZE=100mb,  --�������ļ����������ֵ
 FILEGROWTH=15%   --�������ļ���������
)
LOG ON
(
  /*--��־�ļ��ľ�������������������ͬ��--*/
  NAME='MySchool_log',
  FILENAME='D:\project\MySchool_log.ldf',
  SIZE=3mb,
  MAXSIZE=20mb,  --��־�ļ����������ֵ
  FILEGROWTH=1mb
)


/*--������ʹ��SQL��䴴�����ݿ�Employee���ж�������ļ��Ͷ����־�ļ�*/
CREATE  DATABASE  Employee
  ON   PRIMARY
 (
   /*-�������ļ��ľ�������-*/
   NAME = 'employee1', 
   FILENAME = 'D:\project\employee1.mdf' , 
   SIZE = 10, 
   FILEGROWTH = 10%
 
  ), 
  (
   /*-��Ҫ�����ļ��ľ�������-*/
   NAME = 'employee2', 
   FILENAME = 'D:\project\employee2.ndf' , 
   SIZE = 20, 
   MAXSIZE = 100, 
   FILEGROWTH = 1
  ) 
  LOG ON 
  (
   /*-��־�ļ�1�ľ�������-*/
   NAME = 'employeelog1', 
   FILENAME = 'D:\project\employeelog1_Log.ldf' , 
   SIZE = 10, 
   MAXSIZE=50,
   FILEGROWTH = 1
   ) ,
  (
   /*-��־�ļ�2�ľ�������-*/
   NAME = 'employeelog2', 
   FILENAME = 'D:\project\employeelog2_Log.ldf' , 
   SIZE = 10, 
   MAXSIZE = 50, 
   FILEGROWTH = 1
  )
/*--�ٴδ���MySchool���ݿ�-- */
USE master
GO

CREATE DATABASE MySchool
GO
/*--��ѯMySchool��Ϣ--*/
USE master
GO

SELECT * FROM sysdatabases

/*--������ʹ��SQL���ɾ�����ݿ�MySchool*/
  DROP DATABASE MySchool

/*--�������������ݿ�MySchool�����ж�ɾ���Ѵ��������ݿ�*/
	USE master  --���õ�ǰ���ݿ�Ϊmaster���Ա����sysdatabases��
	GO
	IF  EXISTS(SELECT * FROM  sysdatabases  WHERE  name ='MySchool')
	DROP DATABASE MySchool
	CREATE  DATABASE  MySchool
	ON (
	 ��
	)
	LOG ON
	(
	 ��
	)
	GO

/*--ѧʱ2--*/
/*--������ʹ��SQL��䴴��Student��--*/
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

/*--��ѯ�õ�Student�����Ϣ--*/
USE MySchool
GO

SELECT * FROM sysobjects

/*--������ʹ��SQL���ɾ����Student--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Student')
  DROP  TABLE  Student

/*--������ʹ��SQL��䴴��Subject��--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Subject')
  DROP  TABLE  Subject
CREATE TABLE [dbo].[Subject](
	[SubjectNo] [int] IDENTITY(1,1) NOT NULL,
	[SubjectName] [nchar](50) NOT NULL,
	[ClassHour] [int] NOT NULL,
	[GradeId] [int] NOT NULL
)

/*--������ʹ��SQL��䴴��Result��--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Result')
  DROP  TABLE  Result
CREATE TABLE [dbo].[Result](
	[StudentNo] [int] NOT NULL,
	[SubjectNo] [int] NOT NULL,
	[StudentResult] [int] NOT NULL,
	[ExamDate] [datetime] NOT NULL
)

/*--������ʹ��SQL�ű�����Student��--*/
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

/*--������ʹ��SQL�ű�����Grade��--*/
IF EXISTS(SELECT * FROM  sysobjects  WHERE  name='Grade')
  DROP  TABLE  Grade
CREATE TABLE [dbo].[Grade](
	[GradeId] [int] IDENTITY(1,1) NOT NULL,
	[GradeName] [nvarchar](50) NOT NULL
)

/*--ѧʱ3--*/
/*--������ʹ��SQL�����Grade��Student�����Լ��*/

ALTER TABLE Grade --����Լ��
ADD CONSTRAINT PK_GradeID PRIMARY KEY(GradeID)

ALTER TABLE Student --����Լ��
ADD CONSTRAINT PK_StuNo PRIMARY KEY (StudentNo)

ALTER TABLE Student --ΨһԼ�������֤��Ψһ��
ADD CONSTRAINT UQ_stuID UNIQUE (IdentityCard)

ALTER TABLE Student --Ĭ��Լ������ַ���꣩
ADD CONSTRAINT DF_stuAddress DEFAULT ('��ַ����') FOR Address

ALTER TABLE Student --���Լ����������������1980��1��1���Ժ�
ADD CONSTRAINT CK_stuBornDate CHECK(BornDate>='1980-1-1')

/*--��Grade ����������Լ��������Grade�ʹӱ�Student������ϵ��
   �ڽ���Grade ������Լ��֮ǰ���뽨��Grade�������Լ��  --*/
ALTER TABLE Student --������Լ��
ADD CONSTRAINT FK_Grade          
    FOREIGN KEY(GradeID) REFERENCES Grade(GradeID)

/*--������ʹ��SQL���ɾ��Student��Ĭ��Լ��(��ַ����)--*/
ALTER  TABLE  Student  
DROP  CONSTRAINT  DF_stuAddress

/*--������ʹ��SQL��䴴��Subject���Լ��--*/
ALTER TABLE Subject --����Լ������Ŀ��ţ�
ADD CONSTRAINT PK_Subject PRIMARY KEY(SubjectNo)

ALTER TABLE Subject --�ǿ�Լ������Ŀ���ƣ�
ADD CONSTRAINT CK_SubjectName CHECK(SubjectName is not null)

ALTER TABLE Subject --���Լ����ѧʱ������ڵ���0��
ADD CONSTRAINT CK_ClassHour CHECK(ClassHour>=0)

ALTER TABLE Subject --���Լ��������Grade�ʹӱ�Subject�������ù�ϵ��
ADD CONSTRAINT FK_GradeId          
    FOREIGN KEY(GradeId) REFERENCES Grade(GradeId)

/*--ѧʱ 4--*/
/*--������ʹ��SQL��䴴��Result���Լ��--*/
ALTER TABLE Result --����Լ����ѧ�š���Ŀ�š����ڣ�
ADD CONSTRAINT PK_Result PRIMARY KEY(StudentNo,SubjectNo,ExamDate)

ALTER TABLE Result --Ĭ��Լ��������Ϊϵͳ��ǰ���ڣ�
ADD CONSTRAINT CK_ExamDate DEFAULT (getdate()) FOR ExamDate

ALTER TABLE Result --���Լ�����������ܴ���100��С��0��
ADD CONSTRAINT CK_StudentResult CHECK(StudentResult BETWEEN 0 AND 100)

ALTER TABLE Result --���Լ��������Student�ʹӱ�Result������ϵ��
ADD CONSTRAINT FK_StudentNo          
    FOREIGN KEY(StudentNo) REFERENCES Student(StudentNo)

ALTER TABLE Result --���Լ��������Subject�ʹӱ�Result������ϵ��
ADD CONSTRAINT FK_SubjectNo          
    FOREIGN KEY(SubjectNo) REFERENCES Subject(SubjectNo)


