/*--ѧʱ1--*/
/*--������ִ�г��õ�ϵͳ�洢���̻�����ݿ����������Ϣ--*/
-- Purpose: ����ϵͳ�洢���̵�ʹ��
EXEC sp_databases  --�г���ǰϵͳ�е����ݿ�
EXEC sp_renamedb 'MyBank','Bank'--�ı����ݿ�����(���û�����)
USE MySchool
GO
EXEC sp_tables  --��ǰ���ݿ��пɲ�ѯ������б�
EXEC sp_columns Student  --�鿴��Student���е���Ϣ
EXEC sp_help Student  --�鿴��Student��������Ϣ
EXEC sp_helpconstraint Student --�鿴��Student��Լ��
--EXEC sp_helpindex Result  --�鿴��Result������
EXEC sp_helptext 'vw_student_result_Info' --�鿴��ͼ������ı�
EXEC sp_stored_procedures  --���ص�ǰ���ݿ��еĴ洢�����б�

/*--������ִ����չ�洢���̴����ļ��У��鿴����ϵͳ�ļ�--*/
USE master
GO
/*---�������ݿ�bankDB��Ҫ�󱣴���D:\bank---*/
EXEC xp_cmdshell 'mkdir D:\bank', NO_OUTPUT  --�����ļ���D:\bank 
----��������bankDB
IF exists(SELECT * FROM sysdatabases WHERE name='bankDB')
  DROP DATABASE bankDB
GO
CREATE DATABASE bankDB
 ON
 (
  NAME='bankDB_data',
  FILENAME='D:\bank\bankDB_data.mdf',
  SIZE=3mb,
  FILEGROWTH=15%
 )
 LOG ON
 (
  NAME= 'bankDB_log',
  FILENAME='D:\bank\bankDB_log.ldf',
  SIZE=3mb,
  FILEGROWTH=15%
 )
GO

/*��ʹ�ø߼��洢���̵�����*/
sp_configure 'show advanced options',1 
GO
RECONFIGURE
GO

EXEC xp_cmdshell 'dir D:\bank\' --�鿴�ļ�
GO

/*--������ʹ�ô洢���̲鿴Student��������Ϣ--*/
USE MySchool
GO
EXEC sp_columns Student  --�鿴��Student���е���Ϣ
EXEC sp_help Student  --�鿴��Student��������Ϣ
EXEC sp_helpconstraint Student --�鿴��Student��Լ��

/*--ѧʱ2--*/
/*--������
   ���ô洢���̲�ѯJava Logic���һ�ο���ƽ�����Լ�δͨ�����Ե�ѧԱ����
*/

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_GetAverageResult' ) --����Ƿ����
  DROP PROCEDURE  usp_GetAverageResult
GO

CREATE PROCEDURE usp_GetAverageResult --�����洢����
  AS
	DECLARE @subjectNo int  --�γ̱��
	DECLARE @date datetime  --�������ʱ��

	SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName='java logic'

	SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	ON Result.SubjectNo=Subject.SubjectNo
	WHERE SubjectName=@subjectNo

    DECLARE @avg  decimal(18,2)      --ƽ���ֱ���
    SELECT @avg=AVG(StudentResult)
    FROM Result WHERE ExamDate=@date and SubjectNo=@subjectNo

    PRINT 'ƽ���֣�'+CONVERT(varchar(5),@avg)  

    IF (@avg>70)
       PRINT '���Գɼ�������'
    ELSE
       PRINT '���Գɼ����ϲ�'

    PRINT '--------------------------------------------------'
    PRINT '�μӱ��ο���û��ͨ����ѧԱ��'
    SELECT StudentName,Student.StudentNo,StudentResult FROM  Student
      INNER JOIN Result ON Student.StudentNo=Result.StudentNo
         WHERE StudentResult<60 AND ExamDate=@date and SubjectNo=@subjectNo
GO

/*---����ִ�д洢����---*/
EXEC usp_GetAverageResult  --���ô洢���̵��﷨��EXEC ������ [����]
  
/*--���������ô洢���̲�ѯ��ѧ�ڿ���Ŀγ�����--*/
/*---����Ƿ���ڣ��洢���̴����ϵͳ��sysobjects��---*/
--10.26
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_grade_subject' )
  DROP PROCEDURE  usp_grade_subject
GO
/*---�����洢����----*/
CREATE PROCEDURE usp_grade_subject
AS 
SELECT GradeName,SubjectName,ClassHour FROM Grade INNER JOIN Subject
ON Grade.GradeId=Subject.GradeId
ORDER BY Subject.GradeId,SubjectNo
GO
/*---����ִ�д洢����---*/
EXEC usp_grade_subject  --���ô洢���̵��﷨��EXEC ������ [����]

/*--���������ô洢���̸�������ļ��������ѯ������һ��Java����δͨ����ѧ����Ϣ --*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_unpass' ) --����Ƿ����
  DROP PROCEDURE  usp_unpass
GO

CREATE PROCEDURE usp_unpass --�����洢����
  @subName varchar(50),
  @score INT
AS
	DECLARE @subjectNo int  --�γ̱��
	DECLARE @date datetime  --�������ʱ��
	SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName=@subName

	SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	ON Result.SubjectNo=Subject.SubjectNo
	WHERE Result.SubjectNo=@subjectNo

	PRINT '���Լ������ǣ�'+CAST(@score AS varchar(10))+'��'
    PRINT '--------------------------------------------------'
    PRINT '�μ����һ��'+@subName+'����û�дﵽ�����ߵ�ѧԱ��'
    SELECT StudentName,Student.StudentNo,StudentResult FROM  Student
      INNER JOIN Result ON Student.StudentNo=Result.StudentNo
         WHERE StudentResult<@score AND ExamDate=@date and SubjectNo=@subjectNo
GO
EXEC usp_unpass 'C# OOP', 50 --���ô洢���̵��﷨��EXEC ������ [����]
GO

EXEC usp_unpass @subName='C# OOP', @score=50


/*--ѧʱ3--*/
/*--���������ô洢���̲�ѯָ��ѧ�ڿ���Ŀγ����ơ����û��ָ��ѧ�����ƣ����������ѧ�ڵĿγ���Ϣ--*/
--10.26
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_query_subject' ) --����Ƿ����
  DROP PROCEDURE  usp_query_subject
GO

CREATE PROCEDURE usp_query_subject
  @GradeName VARCHAR(50) = NULL
AS 
  IF @GradeName IS NULL
    SELECT GradeName,SubjectName,ClassHour FROM Grade LEFT JOIN Subject
    ON Grade.GradeId=Subject.GradeId 
    UNION 
    SELECT GradeName,' ',SUM(ClassHour)FROM Grade LEFT JOIN Subject
    ON Grade.GradeId=Subject.GradeId 
    GROUP BY GradeName
  ELSE
    SELECT GradeName,SubjectName,ClassHour FROM Grade LEFT JOIN Subject
    ON Grade.GradeId=Subject.GradeId 
    WHERE GradeName=@GradeName
    UNION
    SELECT GradeName,' ',SUM(ClassHour)FROM Grade LEFT JOIN Subject
    ON Grade.GradeId=Subject.GradeId 
    WHERE GradeName=@GradeName
    GROUP BY GradeName
GO

EXEC usp_query_subject 'S2'  --���ô洢���̵��﷨��EXEC ������ [����]
GO

/*--������
  ���ô洢���̸�������ļ��������ѯ��ñ��ο���δͨ����ѧԱ��Ϣ��
  ����δͨ��ѧԱ������
*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_query_num' )
  DROP PROCEDURE  usp_query_num
GO
/*---�����洢����---*/
CREATE PROCEDURE usp_query_num 
  @UnPassNum INT OUTPUT, --�������,δͨ������
  @TotalNum INT OUTPUT,   --�������,�μӿ���������
  @SubjectName NCHAR(10), --����������γ�����
  @Pass INT = 60        --���������������
 AS
   DECLARE @date datetime  --�������ʱ��
   DECLARE @subjectNo int  --�γ̱��
   SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	ON Result.SubjectNo=Subject.SubjectNo
	WHERE SubjectName=@SubjectName
   SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName=@SubjectName
   
   PRINT @SubjectName+'�γ���'+CONVERT(varchar(20),@date,102)+'���Եļ�������'+CAST(@Pass AS varchar(10))

   /*δͨ����ѧԱ��Ϣ*/
   PRINT '---------δͨ��ѧԱ����Ϣ����------------'
   SELECT Result.StudentNo,StudentName,StudentResult  FROM  Result
    INNER JOIN Student ON Result.StudentNo = Student.StudentNo
    WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*���δͨ����ѧԱ����*/
  SELECT @UnPassNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*��òμӿ��Ե�ѧԱ������*/  
  SELECT @TotalNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo
GO

--ִ�д洢���̻���������ֵ,�����㼰����
  DECLARE @UnPassNum int   --������������ڴ�ŵ��ô洢����ʱ���صĽ��
  DECLARE @TotalNum int    --������������ڴ�ŵ��ô洢����ʱ���صĽ��
  EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,'Java Logic'  --����ʱҲ��OUTPUT�ؼ��֣����Լ�����Ĭ��Ϊ60
  
/**---
  DECLARE @SubjectName varchar(50)
  DECLARE @Pass  int 
  --EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,@Pass=default,@SubjectName='Java Logic'
--EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,@Pass=default,'Java Logic'
 EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,	,
---**/
  DECLARE @ratio decimal(10,2)
  SET @ratio = CONVERT(decimal,(@TotalNum - @UnPassNum))/ @TotalNum * 100
  PRINT 'δͨ������:' + CAST(@UnPassNum AS varchar(10)) +
        '�ˣ���������' + CAST(@ratio AS varchar(10)) + '%'
  IF @UnPassNum > 0	
   BEGIN
      IF @ratio > 60
         PRINT '��������߲����µ�'
      ELSE
         PRINT '���������Ӧ�µ�'
   END
  ELSE
      PRINT '��ϲ�����ο��Գɼ�����'
GO



/*--���������ô洢���̲�ѯָ��ѧ�ڿ���Ŀγ���Ϣ�����ؿγ�������ʱ��--*/
--10.26
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_query_subject' )
  DROP PROCEDURE usp_query_subject
GO
CREATE PROCEDURE usp_query_subject
 @CourseNum INT OUTPUT, --�������
 @HourNum INT OUTPUT, --�������
 @GradeName VARCHAR(50)
AS 
  IF LEN(@GradeName) = 0
	BEGIN
		PRINT 'ѧ�����Ʋ���Ϊ��'
		RETURN
	END
  PRINT '---------ѧ�ڿγ���Ϣ����------------'
  SELECT GradeName,SubjectName,ClassHour FROM Grade LEFT JOIN Subject
  ON Grade.GradeId=Subject.GradeId 
  WHERE GradeName=@GradeName

  SELECT @CourseNum=COUNT(0),@HourNum=SUM(ClassHour) FROM  Grade INNER JOIN Subject
  ON Grade.GradeId=Subject.GradeId 
  WHERE GradeName=@GradeName
GO

DECLARE @sum int   --������������ڴ�ŵ��ô洢����ʱ���صĿγ���
DECLARE @Hours INT --������������ڴ�ŵ��ô洢����ʱ���صĿ�ʱ��
DECLARE @subName varchar(10)
SET @subName = 'S1'
EXEC usp_query_subject @sum OUTPUT ,@Hours OUTPUT, @subName  --����ʱҲ��OUTPUT�ؼ���
SELECT @subName 'ѧ������', CAST(@sum AS varchar(10)) '�γ���Ŀ' ,CAST(@Hours AS VARCHAR(10)) '�ܿ�ʱ'
GO

/*--ѧʱ4--*/
/*�������洢�������ж��������ֵ��
        �������ļ����߲���0~100֮��ʱ���������󾯸棬��ֹ�洢���̵�ִ�� ʹ��RAISERROR���
*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_stu' )
  DROP PROCEDURE  usp_stu
GO
/*---�����洢����---*/
CREATE PROCEDURE usp_stu 
  @UnPassNum int OUTPUT,  --���������δͨ������
  @TotalNum INT OUTPUT,   --�������,�μӿ���������
  @SubjectName NCHAR(10), --����������γ�����
  @Pass int = 60          --���������������
AS
  DECLARE @date datetime  --�������ʱ��
  DECLARE @subjectNo int  --�γ̱��
  SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	  ON Result.SubjectNo=Subject.SubjectNo
	  WHERE SubjectName=@SubjectName

  SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName=@SubjectName

  IF (NOT @Pass BETWEEN 0 AND 100)
    BEGIN
      RAISERROR ('�����ߴ�����ָ��0��100֮��ķ�����ͳ���ж��˳�',16,1)
      RETURN  ---�������أ��˳��洢����
    END
  
  PRINT @SubjectName+'�γ���'+CONVERT(varchar(20),@date,102)+'���Եļ�������'+CAST(@Pass AS varchar(10))

  PRINT '--------------------------------------------------'
  PRINT '�ÿγ����һ�ο���û��ͨ����ѧԱ�ɼ���'
  SELECT Result.StudentNo,StudentName,StudentResult  FROM  Result
    INNER JOIN Student ON Result.StudentNo = Student.StudentNo
    WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*���δͨ����ѧԱ����*/
  SELECT @UnPassNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*��òμӿ��Ե�ѧԱ������*/  
  SELECT @TotalNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo
GO

/*���ô洢����
  �ٶ�Java Logic�γ����һ�ο��Ե�����ƫ���ף������߶�Ϊ109��
*/

  DECLARE @UnPassNum int   --������������ڴ�ŵ��ô洢����ʱ���صĽ��
  DECLARE @TotalNum int    --������������ڴ�ŵ��ô洢����ʱ���صĽ��
  EXEC usp_stu @UnPassNum OUTPUT ,@TotalNum OUTPUT,'Java Logic',109  --����ʱҲ��OUTPUT�ؼ��֣����Լ�����Ĭ��Ϊ60

  DECLARE @err int
  SET @err = @@ERROR
  IF @err <> 0
    BEGIN
      print  '����ţ�'+convert(varchar(5),@err )
      RETURN  --�˳�������������䲻��ִ��
    END
 
  DECLARE @ratio decimal(10,2)
  SET @ratio = CONVERT(decimal,(@TotalNum - @UnPassNum))/ @TotalNum * 100
  PRINT 'δͨ������:' + CAST(@UnPassNum AS varchar(10)) +
        '�ˣ���������' + CAST(@ratio AS varchar(10)) + '%'
  IF @UnPassNum > 0	
    BEGIN
      IF @ratio > 60
         PRINT '��������߲����µ�'
      ELSE
         PRINT '���������Ӧ�µ�'
    END
  ELSE
    PRINT '��ϲ�����ο��Գɼ�����'
GO

/*--�����������¿γ̼�¼--*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_insert_subject' )
  DROP PROCEDURE  usp_insert_subject
GO
CREATE PROCEDURE usp_insert_subject
    @SubjectNo int OUTPUT,
    @GradeId int OUTPUT,
	@GradeName varchar(50),
	@SubjectName varchar(50),
    @ClassHour int = 36
AS 
    DECLARE @errNum int
	SET @errNum = 0
	
	IF (LEN(RTRIM(@SubjectName))=0 OR LEN(RTRIM(@GradeName))=0)
		RETURN -1

    BEGIN TRANSACTION
    IF NOT EXISTS(SELECT * FROM Grade WHERE GradeName = @GradeName)
	  BEGIN
		INSERT INTO Grade (GradeName) VALUES (@GradeName)
		SET @errNum = @errNum + @@ERROR
		SELECT @GradeId=@@IDENTITY
	  END
	ELSE
		SELECT @GradeId=GradeId FROM Grade WHERE GradeName = @GradeName

	INSERT INTO Subject (SubjectName,ClassHour,GradeId) 
		VALUES (@SubjectName,@ClassHour,@GradeId)
	SET @errNum = @errNum + @@ERROR

	SELECT @SubjectNo=@@IDENTITY

	IF (@errNum > 0)
	  BEGIN
		ROLLBACK TRANSACTION
		RETURN 0 
	  END
	ELSE
	  BEGIN
		COMMIT TRANSACTION
		RETURN 1
	  END
GO

--���ô洢����
DECLARE @SubjectNo int
DECLARE @GradeId int
DECLARE @GradeName varchar(50)
DECLARE @SubjectName varchar(50)
DECLARE @ClassHour int
DECLARE @rt int

SET @GradeName = 'Y2'
SET @SubjectName = 'Linux'
SET @ClassHour = -10
EXEC @rt=usp_insert_subject @SubjectNo OUTPUT,@GradeId OUTPUT,@GradeName,@SubjectName,@ClassHour
IF (@rt = 1)
  BEGIN
	PRINT '���ӿγ�'+@SubjectName+'��¼�ɹ�'
	PRINT 'ѧ�ڱ����' + CAST(@GradeId AS varchar(10)) + '��ѧ��������' + @GradeName
	PRINT '�γ̱����' + CAST(@SubjectNo AS varchar(10)) + '���γ�������' + @SubjectName
  END
ELSE if (@rt = 0)
	PRINT '���ӿγ̼�¼ʧ�ܣ�'
ELSE
	PRINT 'ѧ�����ƻ�γ����Ʋ���Ϊ�գ�������ִ�У�'
GO

/*--���������ô洢���̺�����ʵ��ɾ��ָ��ѧԱ��¼�Ĺ���--*/
--ʵ���Խϵͣ��ݲ���
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_delete_student' )
  DROP PROCEDURE  usp_delete_student
GO
CREATE PROCEDURE usp_delete_student
	@IsSuccess BIT=0 OUTPUT,
	@StudentNo INT
AS 
	DECLARE @errorSum INT
	SET @errorSum=0
	if EXISTS(SELECT * FROM Student WHERE StudentNo=@StudentNo)
	BEGIN
		BEGIN TRANSACTION
		DELETE  FROM Result  WHERE StudentNo=@StudentNo
		SET @errorSum=@errorSum+@@error
		DELETE  FROM Student WHERE StudentNo=@StudentNo
		SET @errorSum=@errorSum+@@error
		IF @errorSum<>0  --����д���
		  BEGIN
			ROLLBACK TRANSACTION 
			SELECT @IsSuccess=0
		  END  
		ELSE
		  BEGIN
			COMMIT TRANSACTION   
			SELECT @IsSuccess=1
		  END
	END
	ELSE
	BEGIN
		RAISERROR ('��ѧԱ��Ų����ڣ�',16,1)
	END
GO

--���ô洢����
DECLARE @IsSuccess bit 
EXEC usp_delete_student @IsSuccess OUTPUT,11002
IF(@IsSuccess=1)
  PRINT 'ɾ��ѧ����¼�ɹ�'
ELSE
  PRINT 'ɾ��ѧ����¼ʧ��'

