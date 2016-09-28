use MySchool
go
/*--学时1--*/
/*--案例：查询年龄比“李斯文”大的学员，显示这些学员的信息--*/
--使用局部变量实现
DECLARE @Birthday datetime  --定义变量，存放李斯文的出生日期
SELECT @Birthday=BornDate FROM student
     WHERE studentName='李斯文'      --求出李斯文的出生日期
SELECT StudentNo, StudentName,  Sex, BornDate, Address FROM student 
     WHERE BornDate>@Birthday  --筛选出生日期比李斯文大的学员
GO 

--使用子查询实现
SELECT StudentNo, StudentName,  Sex, BornDate, Address FROM Student WHERE BornDate >
 (SELECT BornDate FROM Student WHERE StudentName='李斯文')

/*--案例：“Java Logic”课程至少一次考试刚好等于60分的唯一一个学生信息--*/
--使用表连接实现
SELECT Stu.StudentNo, StudentName FROM Student stu 
  INNER JOIN Result r ON stu.StudentNO = r.StudentNo
  INNER JOIN Subject sub ON r.SubjectNo = sub.SubjectNo 
  WHERE StudentResult = 60 AND SubjectName = 'Java Logic'

--使用子查询实现
SELECT StudentNo, StudentName FROM Student WHERE StudentNo =
  (SELECT StudentNo FROM Result
    INNER JOIN Subject ON Result.SubjectNo = Subject.SubjectNo 
	WHERE StudentResult=60 AND SubjectName='Java Logic')

/*--案例：“Java Logic”课程至少一次考试刚好等于60分的多个学生信息--*/
SELECT StudentNo, StudentName FROM Student 
WHERE StudentNo IN (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo = (
     SELECT SubjectNo FROM Subject 
     WHERE SubjectName='Java Logic' )  --课程
   AND StudentResult=60                --成绩
)


/*--案例：查询参加最近一次“C# OOP”考试成绩最高分和最低分--*/
SELECT MAX(StudentResult)  AS 最高分,MIN(StudentResult) AS 最低分 FROM Result
Where SubjectNo=(
                  SELECT SubjectNo FROM Subject WHERE SubjectName='C# OOP'
                ) 

/*案例：
   使用子查询获得所有参加2009年8月10日“Java Logic”课程考试的所有学员的考试成绩，
   要求输出学员姓名、课程名称和考试成绩
*/
SELECT StudentName,'Java logic' AS SubjectName,StudentResult FROM Student 
INNER JOIN  Result  ON Result.StudentNo=Student.StudentNo
WHERE  SubjectNo =(
                    SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
                  )
       AND ExamDate='2009-6-10 15:30:00' 

/*--学时2--*/
--案例：查询“Java Logic”课程考试成绩刚好是60分的学员信息
INSERT INTO Result VALUES (20011,2,60,'2009-9-18')
INSERT INTO Result VALUES (20015,2,60,'2009-9-18')
SELECT StudentName FROM Student WHERE StudentNo = 
 (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')--科目
     AND StudentResult=60  --成绩     
 )
--案例：查询“Java Logic”课程最近一次考试成绩为60分的学员信息 太难了，暂不讲

INSERT INTO Result VALUES (20011,2,60,'2009-9-18')
INSERT INTO Result VALUES (20015,2,60,'2009-9-18')
SELECT StudentName FROM Student WHERE StudentNo IN 
--SELECT StudentName FROM Student WHERE StudentNo -- 如果子查询返回多个值而父查询使用比较运算符时会出错
 (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')--科目
     AND StudentResult=60  --成绩
     AND ExamDate =(       --最近考试时间
					  SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =
						(SELECT SubjectNo FROM Subject 
						  WHERE SubjectName='Java logic')
                   )
 )


/*--案例：查询参加“Java Logic”课程最近一次考试的学员名单--*/
SELECT StudentNo,StudentName FROM Student WHERE StudentNo IN (
	SELECT StudentNo FROM Result 
	WHERE SubjectNo = (
        SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')
    AND ExamDate =(
         SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =( 
             SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
         ) 
    )
)

/*--案例：查询每门课程最近一次考试成绩在90分以上的学员名单--?????????????*/
--没有使用IN关键字暂不用
--方法一：
SELECT D.SubjectName,C.StudentName,A.ExamDate, B.StudentResult FROM (
   SELECT MAX(ExamDate) ExamDate, SubjectNo FROM Result GROUP BY SubjectNo
                                         ) A,
                                    Result B,
                                   Student C,
                                   Subject D
									WHERE C.StudentNo=B.StudentNo 
									AND D.SubjectNo=B.SubjectNo
									AND A.ExamDate=B.ExamDate 
									AND A.SubjectNo=B.SubjectNo 
									AND B.StudentResult>=90
ORDER BY B.SubjectNo,B.StudentNo

--方法二：
SELECT D.SubjectName,C.StudentName,A.ExamDate, A.StudentResult
FROM Result A, Student C, Subject D
where StudentResult >= 90 
and Examdate = (SELECT MAX(ExamDate) FROM Result 
where Subjectno=D.subjectno
GROUP BY SubjectNo) 
and C.StudentNo=A.StudentNo AND D.SubjectNo=A.SubjectNo
ORDER BY A.SubjectNo,a.StudentNo
								
/*--案例：查询S1学期开设的课程--*/
SELECT SubjectName FROM Subject WHERE GradeId IN(
                                                  SELECT GradeId FROM Grade WHERE GradeName='S1'
                                                 )

/*--案例：查询未参加“Java Logic”课程最近一次考试的学员名单*/
SELECT  StudentNo, StudentName,GradeID FROM Student WHERE StudentNo NOT IN (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo = (
      SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
   )
   AND ExamDate =(
      SELECT MAX(ExamDate) FROM Result WHERE SubjectNo = (
          SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
      ) 
   )
)


--查询同年级未参加“Java Logic”课程最近一次考试的学员名单
SELECT  StudentNo, StudentName FROM Student WHERE StudentNo NOT IN (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo = (
      SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
   )
   AND ExamDate =(
      SELECT MAX(ExamDate) FROM Result WHERE SubjectNo = (
          SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
      ) 
   )
)
AND GradeId = (SELECT GradeId FROM Subject WHERE SubjectName='Java Logic')

/*--案例：查询未参加“SQL Base”课程最近一次考试的学员名单*/
SELECT StudentName FROM Student WHERE StudentNo 
NOT IN(
        SELECT StudentNo FROM Result 
        WHERE SubjectNo = (
                             SELECT SubjectNo FROM Subject WHERE SubjectName='SQL Base'
                            )
             AND ExamDate =(
                              SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='SQL Base') 
                            )
)

/*--学时3--*/
/*案例：
  检查“Java Logic”课程最近一次考试，本班如果有人考试成绩达到80分以上，则每人提2分；
  否则，每人允许提5分。最终的学生成绩不得大于100分 
*/
PRINT '本次Java Logic课程考试学生原始成绩是：'
SELECT ExamDate AS 考试日期, StudentNo AS 学号, StudentResult AS 成绩
FROM Result
WHERE SubjectNo = (
  SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
)
AND ExamDate =(
  SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(
     SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
  ) 
)

IF EXISTS(
           SELECT * FROM Result 
           WHERE SubjectNo = (
                                SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
                              )
           AND ExamDate =(
                            SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic') 
                         )
           AND StudentResult>80
         )
  BEGIN
	UPDATE Result SET StudentResult=StudentResult+2 
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic') )	
    AND StudentResult<=98					  
    PRINT '本次Java Logic课程考试部分学生成绩高于80分，每人只加2分，加分后的成绩是：'
  END
ELSE
  BEGIN
    UPDATE Result SET StudentResult=StudentResult+5 
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic') )	
    AND StudentResult<=95	 
    PRINT '本次Java Logic课程考试没有学生成绩高于80分，每人可以加5分，加分后的成绩是：'
  END
SELECT ExamDate AS 考试日期, StudentNo AS 学号, StudentResult AS 成绩
FROM Result
WHERE SubjectNo = (
  SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
)
AND ExamDate =(
  SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(
     SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
  ) 
)

/*--案例：
检查“Java Logic”课程最近一次考试，本班如果全部没有通过考试，则试题偏难，每人加3分，否则，每人只加1分  
使用 EXISTS
*/
IF EXISTS(SELECT * FROM Result 
               WHERE SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
               AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
               AND StudentResult>=60
          )
BEGIN
--如果存在考试成绩高于60分的学生，那么每个参加本次考试的学生每人加1分
--加分后的最高成绩不得高于99分
    PRINT '本次Java Logic课程考试有部分学生成绩高于60分，每人加1分，加分后的成绩是：'
    UPDATE Result SET StudentResult=StudentResult+1
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
    AND StudentResult<=99
END                
ELSE
BEGIN
--如果考试成绩都低于60分，那么每个参加本次考试的学生每人加3分
--加分后的最高成绩不得高于97分
    PRINT '本次Java Logic课程考试学生成绩都低于60分，每人加3分，加分后的成绩是：'
	UPDATE Result SET StudentResult=StudentResult+3
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))  
    AND StudentResult<=97
END 

/*--案例：
检查“Java Logic”课程最近一次考试，本班如果全部没有通过考试，则试题偏难，每人加3分，否则，每人只加1分  
使用 NOT EXISTS
*/
IF NOT EXISTS(SELECT * FROM Result 
               WHERE SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
               AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
               AND StudentResult>=60
          )
BEGIN
    PRINT '本次Java Logic课程考试学生成绩都低于60分，每人加3分，加分后的成绩是：'
    UPDATE Result SET StudentResult=StudentResult+3
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
    AND StudentResult<=97
END                
ELSE
BEGIN
    PRINT '本次Java Logic课程考试有部分学生成绩高于60分，每人加1分，加分后的成绩是：'
	UPDATE Result SET StudentResult=StudentResult+1
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))  
    AND StudentResult<=99
END

/*--案例：检查是否有S1的学员。如果有，将他在读年级更新为S2--*/
if EXISTS(
           SELECT * FROM Student INNER JOIN Grade ON Student.GradeId=Grade.GradeId WHERE GradeName='S1'
          )
BEGIN
	UPDATE Student SET GradeId=( 
                                 SELECT GradeId FROM  Grade WHERE GradeName='S2'
                               )
	FROM Student INNER JOIN  Grade ON Student.GradeId=Grade.GradeId 
    WHERE GradeName='S1'
--WHERE GradeId = (SELECT GradeId FROM Grade 
--    WHERE GradeName='S1')
END

/*--案例：
   为每个学员制作在校期间每门课程的成绩单，要求查询获得每个学员参加每门课程的最后一次考试成绩
   ，成绩单中包括：学员姓名、课程所属的年级名称、课程名称、考试日期、考试成绩
*/
SELECT  StudentName 姓名,
  ( SELECT GradeName FROM Grade 
    WHERE GradeId=Subject.GradeId  )  课程所属年级,
  SubjectName 课程名称, ExamDate 考试日期, StudentResult 成绩
FROM  Result
  INNER JOIN Student ON Result.StudentNo=Student.StudentNo
  INNER JOIN Subject ON Subject.SubjectNo=Result.SubjectNo
WHERE Result.ExamDate = (
      SELECT Max(ExamDate) FROM Result 
      WHERE SubjectNo=Subject.SubjectNo AND 
                     StudentNo=Student.StudentNo
      GROUP BY Result.SubjectNo
) 
ORDER BY Result.StudentNo ASC,Result.SubjectNo ASC

--或
SELECT StudentName 姓名,GradeName 课程所属年级,SubjectName 年级名称,Convert(varchar(4),DATEPART(YYYY,ExamDate))+'年'+Convert(varchar(2),DATEPART(MM,ExamDate))+'月'+Convert(varchar(2),DATEPART(DD,ExamDate))+'日' 考试日期,StudentResult 成绩 
FROM  Result  INNER JOIN Student ON Result.StudentNo=Student.StudentNo
INNER JOIN Subject ON Subject.SubjectNo=Result.SubjectNo
INNER JOIN Grade ON Subject.GradeID=Grade.GradeId
WHERE Result.ExamDate = (SELECT Max(ExamDate) FROM Result 
WHERE SubjectNo=Subject.SubjectNo and StudentNo=Student.StudentNo
GROUP BY Result.SubjectNo) 
ORDER BY Result.StudentNo ASC,Result.SubjectNo ASC

/*--案例：查询所有课程的考试成绩，并显示第20条至第30条记录--*/
SELECT *,Id=IDENTITY(INT,1,1) INTO #TempResult FROM Result  --创建临时表

SELECT TOP 11 StudentNo,SubjectNo,ExamDate,StudentResult FROM #TempResult 
WHERE Id NOT IN(
                     SELECT TOP 19 Id FROM  #TempResult ORDER BY Id
               )
drop table #TempResult --删除临时表

/*--案例：按学期显示S1学期学生名单中第15名至20名的学生信息--*/
SELECT TOP 6 * FROM Student WHERE StudentNo 
NOT IN(
        SELECT TOP 14 StudentNo FROM Student INNER JOIN Grade
        ON Student.GradeId=Grade.GradeId
        WHERE GradeName='S1' 
        ORDER BY StudentNo ASC 
)
AND GradeId=(
               SELECT GradeId FROM Grade WHERE GradeName='S1' 
             )
ORDER BY StudentNo ASC     

/*--学时4--*/
/*案例：
   统计最近一次“Java Logic”考试的缺考情况，提取学员成绩并保存结果，低于平均分的学员进行循环提分，但提分后最
   高分不能超过97分，提分后统计学员的成绩和通过情况，提分后统计学员的通过率。
*/
DECLARE @subjectName varchar(50)
DECLARE @date datetime  --最近考试时间
DECLARE @subjectNo int  --科目编号
SET  @subjectName='java logic'
SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName= @subjectName
SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName= @subjectName

/*--------------统计考试缺考情况--------------*/

SELECT 应到人数=(
                 SELECT COUNT(*)  FROM Student 
                 INNER JOIN Subject ON Subject.GradeId=Student.GradeId 
                 WHERE SubjectName= @subjectName
                 ) ,
   
      实到人数=( 
                SELECT COUNT(*) FROM Result 
                WHERE ExamDate=@date AND SubjectNo=@subjectNo
               ),
      缺考人数=(
                 SELECT COUNT(*)  FROM Student 
                 INNER JOIN Subject ON Subject.GradeId=Student.GradeId 
                 WHERE SubjectName= @subjectName
              ) -
              (
                 SELECT COUNT(*) FROM Result 
                 WHERE ExamDate=@date AND SubjectNo=@subjectNo
              ) 

/*---------统计考试通过情况，并将统计结果存放在新表TempResult中---------*/
IF EXISTS(SELECT * FROM sysobjects WHERE name='TempResult')
  DROP TABLE TempResult

SELECT  Student.StudentName,Student.StudentNo,StudentResult,
        IsPass=CASE 
                 WHEN StudentResult>=60  THEN 1
                 ELSE 0
               END
 INTO TempResult 
FROM Student LEFT JOIN (
                         SELECT * FROM Result  WHERE ExamDate=@date AND SubjectNo=@subjectNo
                        ) R
ON Student.StudentNo=R.StudentNo
WHERE GradeId=(SELECT GradeId FROM Subject WHERE SubjectName= @subjectName) 
      
--SELECT * FROM TempResult --查看统计结果，可用于调试

/*-------酌情加分-------*/
DECLARE @avg numeric(4,1) --定义变量存放平均分
SELECT @avg=AVG(StudentResult) FROM TempResult WHERE StudentResult IS NOT NULL

IF (@avg<60)  --判断平均分是否低于60分。如果低于60分，设置平均分为60分
 SET @avg=60

WHILE (1=1) --循环加分，最高分不能超过97分
BEGIN  
   IF(NOT Exists(SELECT * FROM TempResult WHERE StudentResult<@avg))
      BREAK
   ELSE
     UPDATE TempResult SET StudentResult=StudentResult+1
     WHERE StudentResult<@avg AND StudentResult<97
END


 --因为提分，所以需要更新IsPass（是否通过）列的数据
UPDATE TempResult 
  SET IsPass=CASE
               WHEN StudentResult>=60  THEN 1
               ELSE  0
            END

--SELECT * FROM newTable--查看更新IsPass列后的成绩和通过情况，可用于调试

/*--------------显示考试最终通过情况--------------*/
SELECT 姓名=StudentName,学号=StudentNo, 
       成绩=CASE 
              WHEN StudentResult IS NULL THEN '缺考'
              ELSE  CONVERT(varchar(5),StudentResult)
            END,
   是否通过=CASE 
              WHEN isPass=1 THEN '是'
              ELSE  '否'
           END
 FROM TempResult  

/*--显示通过率及通过人数--*/ 
SELECT 总人数=COUNT(*) ,通过人数=SUM(IsPass),
       通过率=(CONVERT(varchar(5),AVG(IsPass*100))+'%')  FROM TempResult 
GO

/*--案例：查询参加最近一次“C# OOP”考试成绩最高分的学员名单--*/
SELECT  StudentName From Student
where StudentNo in
(
  SELECT StudentNo FROM Result WHERE SubjectNo=(SELECT SubjectNo From Subject WHERE SubjectName='C# OOP')
  AND StudentResult=
                    (
                       SELECT MAX(StudentResult) FROM Result
                       WHERE SubjectNo=(SELECT SubjectNo From Subject WHERE SubjectName='C# OOP')
                        AND ExamDate=(SELECT MAX(ExamDate) FROM Result INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo WHERE SubjectName='C# OOP')
                    )
  AND ExamDate=(SELECT MAX(ExamDate) FROM Result INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo WHERE SubjectName='C# OOP')
)

select 
	ts.StudentNo,ts.StudentName,ts.SubjectName,
	isnull(CAST(r.StudentResult as VARCHAR(5)),'缺席')
from
(select s.StudentNo,s.StudentName,sc.SubjectNo,sc.SubjectName from student s,Subject sc ) ts
 left outer join 
(select * from result where examdate in (
  select max(examdate) from result where subjectno=result.subjectno --and studentno=result.studentno
  group by subjectno)
) r 
on  r.StudentNo = ts.StudentNo and r.SubjectNo = ts.SubjectNo
order by ts.SubjectNo,ts.StudentNo

--作业
/*--制作学生在校期间所有课程的成绩单*/
select 
	ts.StudentNo,ts.StudentName,ts.SubjectName,
	isnull(CAST(r.StudentResult as VARCHAR(5)),'缺席')
from
(select s.StudentNo,s.StudentName,sc.SubjectNo,sc.SubjectName from student s,Subject sc ) ts
 left outer join Result r on 
 r.StudentNo = ts.StudentNo and r.SubjectNo = ts.SubjectNo

order by 
ts.SubjectNo,ts.StudentNo
