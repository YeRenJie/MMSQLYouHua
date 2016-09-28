USE MySchool
GO

/*--学时1--*/
/*--案例：查找“李文才”及他的相邻学号学员--*/
/*--查找“李文才”的信息--*/
DECLARE @name nvarchar(50)  --学员姓名
SET @name='李文才'          --使用SET赋值
SELECT StudentNo, StudentName, BornDate, Address FROM Student WHERE StudentName = @name

/*--查找“李文才”的相邻学号学员--*/
DECLARE @StudentNo int  --学号
SELECT @StudentNo=StudentNo from Student WHERE StudentName=@name  --使用SELECT赋值
SELECT StudentNo, StudentName, BornDate, Address FROM Student WHERE (StudentNo = @StudentNo+1) or (StudentNo = @StudentNo-1)


/*--案例：输出服务器名称、版本--*/
PRINT  '服务器的名称: ' + @@SERVERNAME    
SELECT  @@SERVERNAME  AS  '服务器名称'

PRINT 'SQL Server的版本' + @@VERSION 
SELECT  @@VERSION  AS  'SQL Server的版本'

/*--案例：显示新插入或更新数据的学生记录、@ERROR值--*/

INSERT INTO Student(StudentName,StudentNo,LoginPwd,GradeId,Sex,BornDate,IdentityCard)   
     VALUES('武松', 10011, '123456', 1, 1, '1980-12-31','11010119791231001x')
--如果@@ERROR大于0，表示上一条语句执行有错误
print '当前错误号' + convert(varchar(5),@@ERROR)

UPDATE Student SET BornDate='1970-7-8' WHERE StudentNo=10011
PRINT '当前错误号:'+CONVERT(varchar(5),@@ERROR) 
GO

/*--案例：使用局部变量显示★字符拼成的三角形图形（5行）--*/
DECLARE @tag nvarchar(1)  
SET @tag='★'
PRINT @tag
PRINT @tag+@tag
PRINT @tag+@tag+@tag
PRINT @tag+@tag+@tag+@tag
PRINT @tag+@tag+@tag+@tag+@tag

/*--学时2--*/
/*--案例：查询学号是12003学生参加2009年6月10日举办的“Java Logic”课程考试的成绩，
        使用Print语句输出学生姓名和成绩 --*/
DECLARE @NAME varchar(50)           --姓名
DECLARE @Result decimal(5,2)        --考试成绩
DECLARE @NO int
SET @NO = 10000
SELECT @NAME = StudentName FROM Student WHERE StudentNo=@NO 
SELECT @Result = StudentResult FROM Student 
INNER JOIN Result  ON Student.StudentNo=Result.StudentNo 
INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName='Java Logic' AND Student.StudentNo=@NO  AND ExamDate>='2009-2-15' AND ExamDate<'2009-2-16'  
PRINT '姓名：'+@NAME
--PRINT '成绩：'+ @Result
PRINT '成绩：'+ Cast(@Result as varchar(10))

/*--案例：查询学号是20011学生的姓名和年龄，并输出比他大1岁和小1岁的学生信息--*/

DECLARE @NO int
SET @NO = 20011
-- 获得学号是20011的学生姓名和年龄
SELECT StudentName 姓名,FLOOR(DATEDIFF(DY, BornDate, GETDATE())/365) 年龄
   FROM student  WHERE StudentNo=@NO
-- 查询输出比学号是20011的学生大1岁和小1岁的学生信息
DECLARE @date datetime,@year int  --出生日期
SELECT  @date=BornDate FROM Student WHERE StudentNo=@NO  --使用SELECT赋值
print @date
SET @year = DATEPART(YY,@date)
SELECT *  FROM Student WHERE DATEPART(YY,BornDate)=@year+1 or DATEPART(YY,BornDate)=@year-1

/*--案例：按年月日格式显示系统当前日期 --*/
PRINT CONVERT(varchar(4),DATEPART(year,GETDATE()))+'年'+CONVERT(varchar(2),DATEPART(month,GETDATE()))+'月'+CONVERT(varchar(2),DATEPART(day,GETDATE()))+'日'

/*--案例：统计学生“Java Logic”课最近一次考试的平均分并显示后3名学生成绩--*/
DECLARE @date datetime  --最近考试时间
SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName='Java Logic'

DECLARE @myavg decimal(5,2)    --平均分
SELECT  @myavg=AVG(StudentResult) FROM Student 
INNER JOIN Result  ON Student.StudentNo=Result.StudentNo 
INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName='Java Logic' AND ExamDate=@date

PRINT '平均分：'+CONVERT(varchar(5),@myavg)
IF (@myavg>70)
  BEGIN
    PRINT '考试成绩优秀，前三名的成绩为'
    SELECT TOP 3 StudentNo, StudentResult FROM Result 
    INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo 
    WHERE SubjectName='Java Logic' AND ExamDate=@date  
    ORDER BY StudentResult DESC
  END
ELSE
  BEGIN
    PRINT '考试成绩较差，后三名的成绩为'
    SELECT TOP 3 StudentNo, StudentResult FROM Result 
    INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo 
    WHERE SubjectName='Java Logic' AND ExamDate=@date
    ORDER BY StudentResult 
  END

/*--案例：查询学号是20012学生Java课程最近一次考试成绩。输出学生姓名和考试等级。
          如果成绩大于85分，显示“优秀”；否则，如果大于70分，显示“良好”；
          如果大于60分，显示“中等”；否则显示“差”-- 
*/
DECLARE @name nvarchar(50) --姓名
DECLARE @score decimal(5,2)       --分数
SELECT TOP 1  @score=StudentResult,@name=stu.StudentName 
   FROM Result r	
   INNER JOIN Student stu ON r.StudentNo=stu.StudentNo
   INNER JOIN Subject sub ON r.SubjectNo=sub.SubjectNo
   WHERE r.StudentNo='20012' AND sub.SubjectName='Java Logic'
ORDER BY ExamDate DESC

PRINT '学生姓名:'+ @name
IF(@score>85)
begin
  PRINT '考试等级:'+'优秀'
end
ELSE IF(@score>70)
begin
  PRINT '考试等级:'+'良好'
end 
ELSE IF(@score>60)
begin
  PRINT '考试等级:'+'中等'
end
ELSE
begin
  PRINT '考试等级:'+'差'
end

/*--学时3--*/
/*--案例：检查学生“Winforms”课最近一次考试是否有不及格的学生，
如有，每人加2分，高于95分的学生不在加分  WHILE语句语法
*/
DECLARE @date datetime  --考试时间
DECLARE @subNO int      --课程编号
SELECT  @subNo=SubjectNo FROM Subject
WHERE SubjectName='Winforms'

SELECT  @date=max(ExamDate) FROM Result 
WHERE SubjectNo=@subNO

DECLARE @n int
WHILE(1=1) --条件永远成立
  BEGIN
    SELECT @n=COUNT(*) FROM Result 
    WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<60 --统计不及格人数
    IF (@n>0) --每人加2分
       UPDATE Result SET StudentResult=StudentResult+2 FROM Result 
       WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<95
    ELSE
       BREAK  --退出循环
  END
PRINT '加分后的成绩如下：'
SELECT StudentName,StudentResult FROM Result
 INNER JOIN Student ON Result.StudentNo=Student.StudentNo
 WHERE SubjectNo=@subNO AND ExamDate=@date 

/*--案例：采用美国的ABCDE五级打分制显示学生“java”课最近一次考试成绩 CASE语句语法--*/
DECLARE @date datetime  --考试时间
SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
  ON Result.SubjectNo=Subject.SubjectNo
  WHERE SubjectName='Java Logic'
SELECT 学号=StudentNo,成绩=CASE  WHEN StudentResult<60 THEN 'E'
							 WHEN StudentResult BETWEEN 60 AND 69 THEN 'D'
							 WHEN StudentResult BETWEEN 70 AND 79 THEN 'C'
							 WHEN StudentResult BETWEEN 80 AND 89 THEN 'B'
							 ELSE 'A'
  END  
  FROM Result INNER JOIN  Subject ON Result.SubjectNo=Subject.SubjectNo
  WHERE SubjectName='Java Logic' AND ExamDate=@date 

/*案例：
使用While和Case-End语句查询学生出生日期，计算出每个学生的年龄。
如果学生年龄大于等于18岁，输出"恭喜，你已经是成年人了。"，否则显示"希望你早日长大"。
*/
SELECT 姓名=StudentName, CASE  WHEN FLOOR(DATEDIFF(DY,BornDate,GETDATE())/365.25)>=18 THEN '恭喜，你已经是成年人了。'
						 ElSE '希望你早日长大。'
                         END  FROM Student

/*案例：
使用Case-End语句最终显示学生成绩等级。
使用While和IF语句检查是否出不及格的学生。
如果有，则每人加2分直至全部学生都及格。
如果学生成绩大于100，则按100分计算。
*/
DECLARE @date datetime  --考试时间
DECLARE @subNO int      --课程编号
SELECT @subNO=SubjectNo FROM Subject
WHERE SubjectName='C# OOP'
SELECT  @date=max(ExamDate) FROM Result 
WHERE SubjectNo=@subNO

PRINT '加分前学生的考试成绩如下：'
SELECT 学号=StudentNo,成绩等级=CASE  
								 WHEN StudentResult BETWEEN 0 AND 59 THEN '你要努力了！！！'
								 WHEN StudentResult BETWEEN 60 AND 69 THEN '★'
								 WHEN StudentResult BETWEEN 70 AND 79 THEN '★★'
								 WHEN StudentResult BETWEEN 80 AND 89 THEN '★★★'
								 ElSE '★★★★'
                                END  
       FROM Result 
       WHERE SubjectNo=@subNO AND ExamDate=@date 

DECLARE @n int
WHILE(1=1) --条件永远成立
   BEGIN
    SELECT @n=COUNT(*) FROM Result 
    WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<60 --统计不及格人数
    IF (@n>0)
       UPDATE Result SET StudentResult=StudentResult+2 FROM Result
       WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<=98
  --每人加2分
    ELSE
       BREAK  --退出循环
  END


/*--学时4--*/
/*--案例：查询所有不及格的记录，批量插入的新表punish中--*/
USE MyMySchool  
GO
IF  EXISTS(SELECT * FROM  sysobjects  WHERE  name ='punish')
	DROP TABLE punish
GO

CREATE TABLE punish(  --创建表
学号 int,
不及格次数 int,
处理意见 varchar(50)
)
GO

INSERT INTO punish --插入数据
SELECT  StudentNo 学号,COUNT(0) 不及格次数,'' 处理意见 from Result where StudentResult<60 GROUP BY StudentNo
GO
UPDATE punish SET 处理意见='警告' WHERE 不及格次数=1 --更新
UPDATE punish SET 处理意见='肄业' WHERE 不及格次数 BETWEEN 2 AND 3 --更新
UPDATE punish SET 处理意见='开除' WHERE 不及格次数>3 --更新
SELECT * FROM punish --查询
GO



/*--案例：创建管理员表Admin，插入2条管理员记录，随后变更一个管理员的密码 go --*/
USE MySchool  
GO
IF  EXISTS(SELECT * FROM  sysobjects  WHERE  name ='Admin')
	DROP TABLE Admin
GO
CREATE TABLE Admin(  --创建表
	[LoginId]  [nvarchar](50) NOT NULL,
	[LoginPwd] [nvarchar](50) NOT NULL
)

ALTER TABLE Admin    --添加主健约束
ADD CONSTRAINT PK_Admin PRIMARY KEY (LoginId)
GO
INSERT INTO Admin([LoginId],[LoginPwd]) VALUES('TEST1','123')    --插入数据
INSERT INTO Admin([LoginId],[LoginPwd]) VALUES('TEST2','123456') --插入数据
GO
UPDATE Admin SET [LoginPwd]='1234567' WHERE [LoginId]='TEST2' --更新数据
GO
