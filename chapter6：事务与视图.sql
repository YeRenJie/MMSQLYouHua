/*--学时2--*/
/*--案例：为什么需要事务--*/
--同一银行，如都是农行的帐号，可以直接转账
/*－--------------建表-----------------*/
USE MySchool
GO

--创建农行帐户表bank
IF EXISTS(SELECT * FROM sysobjects WHERE name='bank')
   DROP TABLE bank
GO
 
CREATE TABLE bank
(
    customerName CHAR(10), --顾客姓名
    currentMoney MONEY     --当前余额
)
GO

/*---添加约束：根据银行规定，帐户余额不能少于1元，除非销户----*/
ALTER TABLE bank
  ADD CONSTRAINT CK_currentMoney CHECK(currentMoney>=1)
GO

/*--插入测试数据：张三开户，开户金额为800 ；李四开户，开户金额1 ---*/
INSERT INTO bank(customerName,currentMoney) VALUES('张三',1000)
INSERT INTO bank(customerName,currentMoney) VALUES('李四',1)
GO
--查看结果
SELECT * FROM bank
GO

/*--转帐测试：张三希望通过转账，直接汇钱给李四1000元--*/
--我们可能会这样这样写代码
--张三的帐户少1000元，李四的帐户多1000元
UPDATE bank SET currentMoney=currentMoney-1000 
     WHERE customerName='张三'
UPDATE bank SET currentMoney=currentMoney+1000 
     WHERE customerName='李四'
GO
--再次查看结果，结果发现了什么严重的错误?如何解决呢？
SELECT * FROM bank
GO

/*--学时3--*/
/*--案例：
批量向Result表中插入今天参加Java考试的10个学员的成绩，
其中一个学员的成绩大于100分，违反了成绩小于等于100分的约束
 */
--delete from Result where examdate=GETDATE()
BEGIN TRANSACTION;
DECLARE @errorSum INT
SET @errorSum=0
/*--插入数据--*/
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(10000,1,GETDATE(),90)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(10001,1,GETDATE(),70)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(10002,1,GETDATE(),67)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(10011,1,GETDATE(),55)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(10012,1,GETDATE(),102)--分数违反约束
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(20011,4,GETDATE(),90)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(20012,4,GETDATE(),56)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(20015,4,GETDATE(),88)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(30021,4,GETDATE(),40)
SET @errorSum=@errorSum+@@error
INSERT INTO Result(StudentNo,SubjectNo,ExamDate,StudentResult)
            VALUES(30023,4,GETDATE(),65)
SET @errorSum=@errorSum+@@error

/*--根据是否有错误，确定事务是提交还是撤销--*/
IF(@errorSum<>0) --如果有错误
  BEGIN
    PRINT '插入失败，回滚事务'
    ROLLBACK TRANSACTION 
  END  
ELSE
  BEGIN
    PRINT '插入成功，提交事务'
    COMMIT TRANSACTION   
  END
GO

/*--案例：为毕业学员办理离校手续--*/
BEGIN TRANSACTION
DECLARE @errorSum INT
SET @errorSum=0
/*--查询Result表中所有Y2学员的考试成绩，保存到新表HistoreResult*/
SELECT Result.* INTO HistoreResult 
FROM Result INNER JOIN Student ON Result.StudentNo=Student.StudentNo
INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--删除Result表中所有Y2学员的考试成绩*/
DELETE  Result FROM  Result JOIN Student ON Result.StudentNo=Student.StudentNo
INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--将Student表中所有Y2的学员记录，保存到新表HistoryStudent*/
SELECT Student.* INTO HistoryStudent
FROM Student INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--删除Studet表中所有Y2学员记录*/
DELETE Student FROM Student 
INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--根据是否有错误，确定事务是提交还是撤销--*/
IF (@errorSum<>0) --如果有错误
  BEGIN
    PRINT '插入失败，回滚事务'
    ROLLBACK TRANSACTION 
  END  
ELSE
  BEGIN
    PRINT '插入成功，提交事务'
    COMMIT TRANSACTION   
  END
GO

/*--学时4--*/
/*--案例：创建视图：查看学员的成绩--*/
--较容易,暂不用
--创建视图
CREATE VIEW vw_student_result
  AS
    SELECT 姓名=StudentName,学号=Student.StudentNo,成绩=StudentResult,
           科目=SubjectName,考试日期=ExamDate
    FROM Student INNER JOIN Result ON Student.StudentNo=Result.StudentNo
                 INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
GO
--执行视图
SELECT * FROM vw_student_result


--从高至低输出Java Logic课程最近一次考试的学生成绩 
--教师关注的视图
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_subject_result')
   DROP VIEW vw_student_subject_result
GO

CREATE VIEW vw_student_subject_result
AS
  SELECT 姓名=StudentName,学号=Student.StudentNo,成绩=StudentResult,
           课程名称=SubjectName,考试日期=ExamDate
    FROM Student INNER JOIN Result ON Student.StudentNo=Result.StudentNo
                 INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
  WHERE Subject.SubjectNo = (
          SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')--科目
    AND ExamDate =(       --最近考试时间
	      SELECT MAX(ExamDate) FROM Result,Subject WHERE Result.SubjectNo = Subject.SubjectNo
          AND SubjectName='Java logic' )
  --ORDER BY StudentResult DESC  --ORDER BY子句在视图、子查询中无效
GO

--执行视图
SELECT * FROM vw_student_subject_result

--输出学生各门课程的总成绩
--班主任关注的视图数据
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_result_info')
BEGIN
  DROP VIEW vw_student_result_info
END
GO
CREATE VIEW vw_student_result_info
AS
  --查学生信息和总成绩
  SELECT 姓名=StudentName,学号=Student.StudentNo,联系电话=Phone,学期=GradeName,成绩=Total
  FROM Student
  LEFT OUTER JOIN (
      --查每个学生各学期的所有课程总成绩
	  SELECT r.StudentNo,GradeName,SUM(StudentResult) Total 
	  FROM Result r 
	  INNER JOIN (
        --查每个学生参加每门课程考试的最后日期
        SELECT StudentNo,SubjectNo,MAX(ExamDate) AS ExamDate FROM Result 
	    GROUP BY StudentNo,SubjectNo) tmp 
        ON r.ExamDate=tmp.ExamDate
		AND r.SubjectNo = tmp.SubjectNo AND r.StudentNo = tmp.StudentNo
	  INNER JOIN Subject sub ON sub.SubjectNo = r.SubjectNo
	  INNER JOIN Grade g ON g.GradeId = sub.GradeId
	  GROUP By r.StudentNo,GradeName
    ) TmpResult2 ON Student.StudentNo = TmpResult2.StudentNo
 GROUP BY StudentName,Student.StudentNo,Phone,GradeName,Total
GO

SELECT * FROM  vw_student_result_info
/*--使用视图：视图是一个虚拟表，可以像物理表一样打开--*/
SELECT * FROM vw_student_result

/*--案例：删除查看学员成绩的视图--*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_result')
   DROP VIEW vw_student_result
GO

/*--案例：创建视图：查看各学期学员名单--*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_grade')
   DROP VIEW vw_student_grade
GO
CREATE VIEW vw_student_grade
  AS
    SELECT 学期=GradeName,姓名=StudentName,学号=StudentNo
    FROM Grade INNER JOIN Student ON Student.GradeId=Grade.GradeId
GO

/*--使用视图：视图是一个虚拟表，可以像物理表一样打开--*/
SELECT * FROM vw_student_grade
SELECT 学期,姓名,学号 FROM vw_student_grade