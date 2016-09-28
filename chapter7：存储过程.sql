/*--学时1--*/
/*--案例：执行常用的系统存储过程获得数据库对象的相关信息--*/
-- Purpose: 常用系统存储过程的使用
EXEC sp_databases  --列出当前系统中的数据库
EXEC sp_renamedb 'MyBank','Bank'--改变数据库名称(单用户访问)
USE MySchool
GO
EXEC sp_tables  --当前数据库中可查询对象的列表
EXEC sp_columns Student  --查看表Student中列的信息
EXEC sp_help Student  --查看表Student的所有信息
EXEC sp_helpconstraint Student --查看表Student的约束
--EXEC sp_helpindex Result  --查看表Result的索引
EXEC sp_helptext 'vw_student_result_Info' --查看视图的语句文本
EXEC sp_stored_procedures  --返回当前数据库中的存储过程列表

/*--案例：执行扩展存储过程创建文件夹，查看操作系统文件--*/
USE master
GO
/*---创建数据库bankDB，要求保存在D:\bank---*/
EXEC xp_cmdshell 'mkdir D:\bank', NO_OUTPUT  --创建文件夹D:\bank 
----创建建库bankDB
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

/*打开使用高级存储过程的配置*/
sp_configure 'show advanced options',1 
GO
RECONFIGURE
GO

EXEC xp_cmdshell 'dir D:\bank\' --查看文件
GO

/*--案例：使用存储过程查看Student表的相关信息--*/
USE MySchool
GO
EXEC sp_columns Student  --查看表Student中列的信息
EXEC sp_help Student  --查看表Student的所有信息
EXEC sp_helpconstraint Student --查看表Student的约束

/*--学时2--*/
/*--案例：
   利用存储过程查询Java Logic最近一次考试平均分以及未通过考试的学员名单
*/

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_GetAverageResult' ) --检测是否存在
  DROP PROCEDURE  usp_GetAverageResult
GO

CREATE PROCEDURE usp_GetAverageResult --创建存储过程
  AS
	DECLARE @subjectNo int  --课程编号
	DECLARE @date datetime  --最近考试时间

	SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName='java logic'

	SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	ON Result.SubjectNo=Subject.SubjectNo
	WHERE SubjectName=@subjectNo

    DECLARE @avg  decimal(18,2)      --平均分变量
    SELECT @avg=AVG(StudentResult)
    FROM Result WHERE ExamDate=@date and SubjectNo=@subjectNo

    PRINT '平均分：'+CONVERT(varchar(5),@avg)  

    IF (@avg>70)
       PRINT '考试成绩：优秀'
    ELSE
       PRINT '考试成绩：较差'

    PRINT '--------------------------------------------------'
    PRINT '参加本次考试没有通过的学员：'
    SELECT StudentName,Student.StudentNo,StudentResult FROM  Student
      INNER JOIN Result ON Student.StudentNo=Result.StudentNo
         WHERE StudentResult<60 AND ExamDate=@date and SubjectNo=@subjectNo
GO

/*---调用执行存储过程---*/
EXEC usp_GetAverageResult  --调用存储过程的语法：EXEC 过程名 [参数]
  
/*--案例：利用存储过程查询各学期开设的课程名称--*/
/*---检测是否存在：存储过程存放在系统表sysobjects中---*/
--10.26
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_grade_subject' )
  DROP PROCEDURE  usp_grade_subject
GO
/*---创建存储过程----*/
CREATE PROCEDURE usp_grade_subject
AS 
SELECT GradeName,SubjectName,ClassHour FROM Grade INNER JOIN Subject
ON Grade.GradeId=Subject.GradeId
ORDER BY Subject.GradeId,SubjectNo
GO
/*---调用执行存储过程---*/
EXEC usp_grade_subject  --调用存储过程的语法：EXEC 过程名 [参数]

/*--案例：利用存储过程根据输入的及格分数查询获得最近一次Java考试未通过的学生信息 --*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_unpass' ) --检测是否存在
  DROP PROCEDURE  usp_unpass
GO

CREATE PROCEDURE usp_unpass --创建存储过程
  @subName varchar(50),
  @score INT
AS
	DECLARE @subjectNo int  --课程编号
	DECLARE @date datetime  --最近考试时间
	SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName=@subName

	SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	ON Result.SubjectNo=Subject.SubjectNo
	WHERE Result.SubjectNo=@subjectNo

	PRINT '考试及格线是：'+CAST(@score AS varchar(10))+'分'
    PRINT '--------------------------------------------------'
    PRINT '参加最近一次'+@subName+'考试没有达到分数线的学员：'
    SELECT StudentName,Student.StudentNo,StudentResult FROM  Student
      INNER JOIN Result ON Student.StudentNo=Result.StudentNo
         WHERE StudentResult<@score AND ExamDate=@date and SubjectNo=@subjectNo
GO
EXEC usp_unpass 'C# OOP', 50 --调用存储过程的语法：EXEC 过程名 [参数]
GO

EXEC usp_unpass @subName='C# OOP', @score=50


/*--学时3--*/
/*--案例：利用存储过程查询指定学期开设的课程名称。如果没有指定学期名称，则输出所有学期的课程信息--*/
--10.26
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_query_subject' ) --检测是否存在
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

EXEC usp_query_subject 'S2'  --调用存储过程的语法：EXEC 过程名 [参数]
GO

/*--案例：
  利用存储过程根据输入的及格分数查询获得本次考试未通过的学员信息，
  返回未通过学员的人数
*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_query_num' )
  DROP PROCEDURE  usp_query_num
GO
/*---创建存储过程---*/
CREATE PROCEDURE usp_query_num 
  @UnPassNum INT OUTPUT, --输出参数,未通过人数
  @TotalNum INT OUTPUT,   --输出参数,参加考试总人数
  @SubjectName NCHAR(10), --输入参数，课程名称
  @Pass INT = 60        --输入参数：及格线
 AS
   DECLARE @date datetime  --最近考试时间
   DECLARE @subjectNo int  --课程编号
   SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	ON Result.SubjectNo=Subject.SubjectNo
	WHERE SubjectName=@SubjectName
   SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName=@SubjectName
   
   PRINT @SubjectName+'课程在'+CONVERT(varchar(20),@date,102)+'考试的及格线是'+CAST(@Pass AS varchar(10))

   /*未通过的学员信息*/
   PRINT '---------未通过学员的信息如下------------'
   SELECT Result.StudentNo,StudentName,StudentResult  FROM  Result
    INNER JOIN Student ON Result.StudentNo = Student.StudentNo
    WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*获得未通过的学员人数*/
  SELECT @UnPassNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*获得参加考试的学员总人数*/  
  SELECT @TotalNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo
GO

--执行存储过程获得输出参数值,并计算及格率
  DECLARE @UnPassNum int   --定义变量，用于存放调用存储过程时返回的结果
  DECLARE @TotalNum int    --定义变量，用于存放调用存储过程时返回的结果
  EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,'Java Logic'  --调用时也带OUTPUT关键字，机试及格线默认为60
  
/**---
  DECLARE @SubjectName varchar(50)
  DECLARE @Pass  int 
  --EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,@Pass=default,@SubjectName='Java Logic'
--EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,@Pass=default,'Java Logic'
 EXEC usp_query_num @UnPassNum OUTPUT ,@TotalNum OUTPUT,	,
---**/
  DECLARE @ratio decimal(10,2)
  SET @ratio = CONVERT(decimal,(@TotalNum - @UnPassNum))/ @TotalNum * 100
  PRINT '未通过人数:' + CAST(@UnPassNum AS varchar(10)) +
        '人，及格率是' + CAST(@ratio AS varchar(10)) + '%'
  IF @UnPassNum > 0	
   BEGIN
      IF @ratio > 60
         PRINT '及格分数线不需下调'
      ELSE
         PRINT '及格分数线应下调'
   END
  ELSE
      PRINT '恭喜！本次考试成绩优良'
GO



/*--案例：利用存储过程查询指定学期开设的课程信息，返回课程数、课时数--*/
--10.26
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_query_subject' )
  DROP PROCEDURE usp_query_subject
GO
CREATE PROCEDURE usp_query_subject
 @CourseNum INT OUTPUT, --输出参数
 @HourNum INT OUTPUT, --输出参数
 @GradeName VARCHAR(50)
AS 
  IF LEN(@GradeName) = 0
	BEGIN
		PRINT '学期名称不能为空'
		RETURN
	END
  PRINT '---------学期课程信息如下------------'
  SELECT GradeName,SubjectName,ClassHour FROM Grade LEFT JOIN Subject
  ON Grade.GradeId=Subject.GradeId 
  WHERE GradeName=@GradeName

  SELECT @CourseNum=COUNT(0),@HourNum=SUM(ClassHour) FROM  Grade INNER JOIN Subject
  ON Grade.GradeId=Subject.GradeId 
  WHERE GradeName=@GradeName
GO

DECLARE @sum int   --定义变量，用于存放调用存储过程时返回的课程数
DECLARE @Hours INT --定义变量，用于存放调用存储过程时返回的课时数
DECLARE @subName varchar(10)
SET @subName = 'S1'
EXEC usp_query_subject @sum OUTPUT ,@Hours OUTPUT, @subName  --调用时也带OUTPUT关键字
SELECT @subName '学期名称', CAST(@sum AS varchar(10)) '课程数目' ,CAST(@Hours AS VARCHAR(10)) '总课时'
GO

/*--学时4--*/
/*案例：存储过程中判断输入参数值。
        如果传入的及格线不在0~100之间时，弹出错误警告，终止存储过程的执行 使用RAISERROR语句
*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'usp_stu' )
  DROP PROCEDURE  usp_stu
GO
/*---创建存储过程---*/
CREATE PROCEDURE usp_stu 
  @UnPassNum int OUTPUT,  --输出参数：未通过人数
  @TotalNum INT OUTPUT,   --输出参数,参加考试总人数
  @SubjectName NCHAR(10), --输入参数：课程名称
  @Pass int = 60          --输入参数：及格线
AS
  DECLARE @date datetime  --最近考试时间
  DECLARE @subjectNo int  --课程编号
  SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
	  ON Result.SubjectNo=Subject.SubjectNo
	  WHERE SubjectName=@SubjectName

  SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName=@SubjectName

  IF (NOT @Pass BETWEEN 0 AND 100)
    BEGIN
      RAISERROR ('及格线错误，请指定0－100之间的分数，统计中断退出',16,1)
      RETURN  ---立即返回，退出存储过程
    END
  
  PRINT @SubjectName+'课程在'+CONVERT(varchar(20),@date,102)+'考试的及格线是'+CAST(@Pass AS varchar(10))

  PRINT '--------------------------------------------------'
  PRINT '该课程最近一次考试没有通过的学员成绩：'
  SELECT Result.StudentNo,StudentName,StudentResult  FROM  Result
    INNER JOIN Student ON Result.StudentNo = Student.StudentNo
    WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*获得未通过的学员人数*/
  SELECT @UnPassNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo AND StudentResult<@Pass

  /*获得参加考试的学员总人数*/  
  SELECT @TotalNum=COUNT(*) FROM Result  
  WHERE ExamDate=@date AND subjectNo=@subjectNo
GO

/*调用存储过程
  假定Java Logic课程最近一次考试的试题偏容易，及格线定为109分
*/

  DECLARE @UnPassNum int   --定义变量，用于存放调用存储过程时返回的结果
  DECLARE @TotalNum int    --定义变量，用于存放调用存储过程时返回的结果
  EXEC usp_stu @UnPassNum OUTPUT ,@TotalNum OUTPUT,'Java Logic',109  --调用时也带OUTPUT关键字，机试及格线默认为60

  DECLARE @err int
  SET @err = @@ERROR
  IF @err <> 0
    BEGIN
      print  '错误号：'+convert(varchar(5),@err )
      RETURN  --退出批处理，后续语句不再执行
    END
 
  DECLARE @ratio decimal(10,2)
  SET @ratio = CONVERT(decimal,(@TotalNum - @UnPassNum))/ @TotalNum * 100
  PRINT '未通过人数:' + CAST(@UnPassNum AS varchar(10)) +
        '人，及格率是' + CAST(@ratio AS varchar(10)) + '%'
  IF @UnPassNum > 0	
    BEGIN
      IF @ratio > 60
         PRINT '及格分数线不需下调'
      ELSE
         PRINT '及格分数线应下调'
    END
  ELSE
    PRINT '恭喜！本次考试成绩优良'
GO

/*--案例：增加新课程记录--*/
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

--调用存储过程
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
	PRINT '增加课程'+@SubjectName+'记录成功'
	PRINT '学期编号是' + CAST(@GradeId AS varchar(10)) + '，学期名称是' + @GradeName
	PRINT '课程编号是' + CAST(@SubjectNo AS varchar(10)) + '，课程名称是' + @SubjectName
  END
ELSE if (@rt = 0)
	PRINT '增加课程记录失败！'
ELSE
	PRINT '学期名称或课程名称不能为空，请重新执行！'
GO

/*--案例：利用存储过程和事务实现删除指定学员记录的功能--*/
--实用性较低，暂不用
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
		IF @errorSum<>0  --如果有错误
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
		RAISERROR ('该学员编号不存在！',16,1)
	END
GO

--调用存储过程
DECLARE @IsSuccess bit 
EXEC usp_delete_student @IsSuccess OUTPUT,11002
IF(@IsSuccess=1)
  PRINT '删除学生记录成功'
ELSE
  PRINT '删除学生记录失败'

