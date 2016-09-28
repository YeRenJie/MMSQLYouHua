use MySchool
go
/*--ѧʱ1--*/
/*--��������ѯ����ȡ���˹�ġ����ѧԱ����ʾ��ЩѧԱ����Ϣ--*/
--ʹ�þֲ�����ʵ��
DECLARE @Birthday datetime  --��������������˹�ĵĳ�������
SELECT @Birthday=BornDate FROM student
     WHERE studentName='��˹��'      --�����˹�ĵĳ�������
SELECT StudentNo, StudentName,  Sex, BornDate, Address FROM student 
     WHERE BornDate>@Birthday  --ɸѡ�������ڱ���˹�Ĵ��ѧԱ
GO 

--ʹ���Ӳ�ѯʵ��
SELECT StudentNo, StudentName,  Sex, BornDate, Address FROM Student WHERE BornDate >
 (SELECT BornDate FROM Student WHERE StudentName='��˹��')

/*--��������Java Logic���γ�����һ�ο��Ըպõ���60�ֵ�Ψһһ��ѧ����Ϣ--*/
--ʹ�ñ�����ʵ��
SELECT Stu.StudentNo, StudentName FROM Student stu 
  INNER JOIN Result r ON stu.StudentNO = r.StudentNo
  INNER JOIN Subject sub ON r.SubjectNo = sub.SubjectNo 
  WHERE StudentResult = 60 AND SubjectName = 'Java Logic'

--ʹ���Ӳ�ѯʵ��
SELECT StudentNo, StudentName FROM Student WHERE StudentNo =
  (SELECT StudentNo FROM Result
    INNER JOIN Subject ON Result.SubjectNo = Subject.SubjectNo 
	WHERE StudentResult=60 AND SubjectName='Java Logic')

/*--��������Java Logic���γ�����һ�ο��Ըպõ���60�ֵĶ��ѧ����Ϣ--*/
SELECT StudentNo, StudentName FROM Student 
WHERE StudentNo IN (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo = (
     SELECT SubjectNo FROM Subject 
     WHERE SubjectName='Java Logic' )  --�γ�
   AND StudentResult=60                --�ɼ�
)


/*--��������ѯ�μ����һ�Ρ�C# OOP�����Գɼ���߷ֺ���ͷ�--*/
SELECT MAX(StudentResult)  AS ��߷�,MIN(StudentResult) AS ��ͷ� FROM Result
Where SubjectNo=(
                  SELECT SubjectNo FROM Subject WHERE SubjectName='C# OOP'
                ) 

/*������
   ʹ���Ӳ�ѯ������вμ�2009��8��10�ա�Java Logic���γ̿��Ե�����ѧԱ�Ŀ��Գɼ���
   Ҫ�����ѧԱ�������γ����ƺͿ��Գɼ�
*/
SELECT StudentName,'Java logic' AS SubjectName,StudentResult FROM Student 
INNER JOIN  Result  ON Result.StudentNo=Student.StudentNo
WHERE  SubjectNo =(
                    SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic'
                  )
       AND ExamDate='2009-6-10 15:30:00' 

/*--ѧʱ2--*/
--��������ѯ��Java Logic���γ̿��Գɼ��պ���60�ֵ�ѧԱ��Ϣ
INSERT INTO Result VALUES (20011,2,60,'2009-9-18')
INSERT INTO Result VALUES (20015,2,60,'2009-9-18')
SELECT StudentName FROM Student WHERE StudentNo = 
 (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')--��Ŀ
     AND StudentResult=60  --�ɼ�     
 )
--��������ѯ��Java Logic���γ����һ�ο��Գɼ�Ϊ60�ֵ�ѧԱ��Ϣ ̫���ˣ��ݲ���

INSERT INTO Result VALUES (20011,2,60,'2009-9-18')
INSERT INTO Result VALUES (20015,2,60,'2009-9-18')
SELECT StudentName FROM Student WHERE StudentNo IN 
--SELECT StudentName FROM Student WHERE StudentNo -- ����Ӳ�ѯ���ض��ֵ������ѯʹ�ñȽ������ʱ�����
 (
   SELECT StudentNo FROM Result 
   WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')--��Ŀ
     AND StudentResult=60  --�ɼ�
     AND ExamDate =(       --�������ʱ��
					  SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =
						(SELECT SubjectNo FROM Subject 
						  WHERE SubjectName='Java logic')
                   )
 )


/*--��������ѯ�μӡ�Java Logic���γ����һ�ο��Ե�ѧԱ����--*/
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

/*--��������ѯÿ�ſγ����һ�ο��Գɼ���90�����ϵ�ѧԱ����--?????????????*/
--û��ʹ��IN�ؼ����ݲ���
--����һ��
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

--��������
SELECT D.SubjectName,C.StudentName,A.ExamDate, A.StudentResult
FROM Result A, Student C, Subject D
where StudentResult >= 90 
and Examdate = (SELECT MAX(ExamDate) FROM Result 
where Subjectno=D.subjectno
GROUP BY SubjectNo) 
and C.StudentNo=A.StudentNo AND D.SubjectNo=A.SubjectNo
ORDER BY A.SubjectNo,a.StudentNo
								
/*--��������ѯS1ѧ�ڿ���Ŀγ�--*/
SELECT SubjectName FROM Subject WHERE GradeId IN(
                                                  SELECT GradeId FROM Grade WHERE GradeName='S1'
                                                 )

/*--��������ѯδ�μӡ�Java Logic���γ����һ�ο��Ե�ѧԱ����*/
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


--��ѯͬ�꼶δ�μӡ�Java Logic���γ����һ�ο��Ե�ѧԱ����
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

/*--��������ѯδ�μӡ�SQL Base���γ����һ�ο��Ե�ѧԱ����*/
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

/*--ѧʱ3--*/
/*������
  ��顰Java Logic���γ����һ�ο��ԣ�����������˿��Գɼ��ﵽ80�����ϣ���ÿ����2�֣�
  ����ÿ��������5�֡����յ�ѧ���ɼ����ô���100�� 
*/
PRINT '����Java Logic�γ̿���ѧ��ԭʼ�ɼ��ǣ�'
SELECT ExamDate AS ��������, StudentNo AS ѧ��, StudentResult AS �ɼ�
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
    PRINT '����Java Logic�γ̿��Բ���ѧ���ɼ�����80�֣�ÿ��ֻ��2�֣��ӷֺ�ĳɼ��ǣ�'
  END
ELSE
  BEGIN
    UPDATE Result SET StudentResult=StudentResult+5 
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic') )	
    AND StudentResult<=95	 
    PRINT '����Java Logic�γ̿���û��ѧ���ɼ�����80�֣�ÿ�˿��Լ�5�֣��ӷֺ�ĳɼ��ǣ�'
  END
SELECT ExamDate AS ��������, StudentNo AS ѧ��, StudentResult AS �ɼ�
FROM Result
WHERE SubjectNo = (
  SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
)
AND ExamDate =(
  SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(
     SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'
  ) 
)

/*--������
��顰Java Logic���γ����һ�ο��ԣ��������ȫ��û��ͨ�����ԣ�������ƫ�ѣ�ÿ�˼�3�֣�����ÿ��ֻ��1��  
ʹ�� EXISTS
*/
IF EXISTS(SELECT * FROM Result 
               WHERE SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
               AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
               AND StudentResult>=60
          )
BEGIN
--������ڿ��Գɼ�����60�ֵ�ѧ������ôÿ���μӱ��ο��Ե�ѧ��ÿ�˼�1��
--�ӷֺ����߳ɼ����ø���99��
    PRINT '����Java Logic�γ̿����в���ѧ���ɼ�����60�֣�ÿ�˼�1�֣��ӷֺ�ĳɼ��ǣ�'
    UPDATE Result SET StudentResult=StudentResult+1
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
    AND StudentResult<=99
END                
ELSE
BEGIN
--������Գɼ�������60�֣���ôÿ���μӱ��ο��Ե�ѧ��ÿ�˼�3��
--�ӷֺ����߳ɼ����ø���97��
    PRINT '����Java Logic�γ̿���ѧ���ɼ�������60�֣�ÿ�˼�3�֣��ӷֺ�ĳɼ��ǣ�'
	UPDATE Result SET StudentResult=StudentResult+3
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))  
    AND StudentResult<=97
END 

/*--������
��顰Java Logic���γ����һ�ο��ԣ��������ȫ��û��ͨ�����ԣ�������ƫ�ѣ�ÿ�˼�3�֣�����ÿ��ֻ��1��  
ʹ�� NOT EXISTS
*/
IF NOT EXISTS(SELECT * FROM Result 
               WHERE SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
               AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
               AND StudentResult>=60
          )
BEGIN
    PRINT '����Java Logic�γ̿���ѧ���ɼ�������60�֣�ÿ�˼�3�֣��ӷֺ�ĳɼ��ǣ�'
    UPDATE Result SET StudentResult=StudentResult+3
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))
    AND StudentResult<=97
END                
ELSE
BEGIN
    PRINT '����Java Logic�γ̿����в���ѧ���ɼ�����60�֣�ÿ�˼�1�֣��ӷֺ�ĳɼ��ǣ�'
	UPDATE Result SET StudentResult=StudentResult+1
	WHERE  SubjectNo = (SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic')
	AND ExamDate =(SELECT MAX(ExamDate) FROM Result WHERE SubjectNo =(SELECT SubjectNo FROM Subject WHERE SubjectName='Java Logic'))  
    AND StudentResult<=99
END

/*--����������Ƿ���S1��ѧԱ������У������ڶ��꼶����ΪS2--*/
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

/*--������
   Ϊÿ��ѧԱ������У�ڼ�ÿ�ſγ̵ĳɼ�����Ҫ���ѯ���ÿ��ѧԱ�μ�ÿ�ſγ̵����һ�ο��Գɼ�
   ���ɼ����а�����ѧԱ�������γ��������꼶���ơ��γ����ơ��������ڡ����Գɼ�
*/
SELECT  StudentName ����,
  ( SELECT GradeName FROM Grade 
    WHERE GradeId=Subject.GradeId  )  �γ������꼶,
  SubjectName �γ�����, ExamDate ��������, StudentResult �ɼ�
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

--��
SELECT StudentName ����,GradeName �γ������꼶,SubjectName �꼶����,Convert(varchar(4),DATEPART(YYYY,ExamDate))+'��'+Convert(varchar(2),DATEPART(MM,ExamDate))+'��'+Convert(varchar(2),DATEPART(DD,ExamDate))+'��' ��������,StudentResult �ɼ� 
FROM  Result  INNER JOIN Student ON Result.StudentNo=Student.StudentNo
INNER JOIN Subject ON Subject.SubjectNo=Result.SubjectNo
INNER JOIN Grade ON Subject.GradeID=Grade.GradeId
WHERE Result.ExamDate = (SELECT Max(ExamDate) FROM Result 
WHERE SubjectNo=Subject.SubjectNo and StudentNo=Student.StudentNo
GROUP BY Result.SubjectNo) 
ORDER BY Result.StudentNo ASC,Result.SubjectNo ASC

/*--��������ѯ���пγ̵Ŀ��Գɼ�������ʾ��20������30����¼--*/
SELECT *,Id=IDENTITY(INT,1,1) INTO #TempResult FROM Result  --������ʱ��

SELECT TOP 11 StudentNo,SubjectNo,ExamDate,StudentResult FROM #TempResult 
WHERE Id NOT IN(
                     SELECT TOP 19 Id FROM  #TempResult ORDER BY Id
               )
drop table #TempResult --ɾ����ʱ��

/*--��������ѧ����ʾS1ѧ��ѧ�������е�15����20����ѧ����Ϣ--*/
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

/*--ѧʱ4--*/
/*������
   ͳ�����һ�Ρ�Java Logic�����Ե�ȱ���������ȡѧԱ�ɼ���������������ƽ���ֵ�ѧԱ����ѭ����֣�����ֺ���
   �߷ֲ��ܳ���97�֣���ֺ�ͳ��ѧԱ�ĳɼ���ͨ���������ֺ�ͳ��ѧԱ��ͨ���ʡ�
*/
DECLARE @subjectName varchar(50)
DECLARE @date datetime  --�������ʱ��
DECLARE @subjectNo int  --��Ŀ���
SET  @subjectName='java logic'
SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName= @subjectName
SELECT @subjectNo=subjectNo FROM Subject WHERE SubjectName= @subjectName

/*--------------ͳ�ƿ���ȱ�����--------------*/

SELECT Ӧ������=(
                 SELECT COUNT(*)  FROM Student 
                 INNER JOIN Subject ON Subject.GradeId=Student.GradeId 
                 WHERE SubjectName= @subjectName
                 ) ,
   
      ʵ������=( 
                SELECT COUNT(*) FROM Result 
                WHERE ExamDate=@date AND SubjectNo=@subjectNo
               ),
      ȱ������=(
                 SELECT COUNT(*)  FROM Student 
                 INNER JOIN Subject ON Subject.GradeId=Student.GradeId 
                 WHERE SubjectName= @subjectName
              ) -
              (
                 SELECT COUNT(*) FROM Result 
                 WHERE ExamDate=@date AND SubjectNo=@subjectNo
              ) 

/*---------ͳ�ƿ���ͨ�����������ͳ�ƽ��������±�TempResult��---------*/
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
      
--SELECT * FROM TempResult --�鿴ͳ�ƽ���������ڵ���

/*-------����ӷ�-------*/
DECLARE @avg numeric(4,1) --����������ƽ����
SELECT @avg=AVG(StudentResult) FROM TempResult WHERE StudentResult IS NOT NULL

IF (@avg<60)  --�ж�ƽ�����Ƿ����60�֡��������60�֣�����ƽ����Ϊ60��
 SET @avg=60

WHILE (1=1) --ѭ���ӷ֣���߷ֲ��ܳ���97��
BEGIN  
   IF(NOT Exists(SELECT * FROM TempResult WHERE StudentResult<@avg))
      BREAK
   ELSE
     UPDATE TempResult SET StudentResult=StudentResult+1
     WHERE StudentResult<@avg AND StudentResult<97
END


 --��Ϊ��֣�������Ҫ����IsPass���Ƿ�ͨ�����е�����
UPDATE TempResult 
  SET IsPass=CASE
               WHEN StudentResult>=60  THEN 1
               ELSE  0
            END

--SELECT * FROM newTable--�鿴����IsPass�к�ĳɼ���ͨ������������ڵ���

/*--------------��ʾ��������ͨ�����--------------*/
SELECT ����=StudentName,ѧ��=StudentNo, 
       �ɼ�=CASE 
              WHEN StudentResult IS NULL THEN 'ȱ��'
              ELSE  CONVERT(varchar(5),StudentResult)
            END,
   �Ƿ�ͨ��=CASE 
              WHEN isPass=1 THEN '��'
              ELSE  '��'
           END
 FROM TempResult  

/*--��ʾͨ���ʼ�ͨ������--*/ 
SELECT ������=COUNT(*) ,ͨ������=SUM(IsPass),
       ͨ����=(CONVERT(varchar(5),AVG(IsPass*100))+'%')  FROM TempResult 
GO

/*--��������ѯ�μ����һ�Ρ�C# OOP�����Գɼ���߷ֵ�ѧԱ����--*/
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
	isnull(CAST(r.StudentResult as VARCHAR(5)),'ȱϯ')
from
(select s.StudentNo,s.StudentName,sc.SubjectNo,sc.SubjectName from student s,Subject sc ) ts
 left outer join 
(select * from result where examdate in (
  select max(examdate) from result where subjectno=result.subjectno --and studentno=result.studentno
  group by subjectno)
) r 
on  r.StudentNo = ts.StudentNo and r.SubjectNo = ts.SubjectNo
order by ts.SubjectNo,ts.StudentNo

--��ҵ
/*--����ѧ����У�ڼ����пγ̵ĳɼ���*/
select 
	ts.StudentNo,ts.StudentName,ts.SubjectName,
	isnull(CAST(r.StudentResult as VARCHAR(5)),'ȱϯ')
from
(select s.StudentNo,s.StudentName,sc.SubjectNo,sc.SubjectName from student s,Subject sc ) ts
 left outer join Result r on 
 r.StudentNo = ts.StudentNo and r.SubjectNo = ts.SubjectNo

order by 
ts.SubjectNo,ts.StudentNo
