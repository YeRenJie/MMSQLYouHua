USE MySchool
GO

/*--ѧʱ1--*/
/*--���������ҡ����Ĳš�����������ѧ��ѧԱ--*/
/*--���ҡ����Ĳš�����Ϣ--*/
DECLARE @name nvarchar(50)  --ѧԱ����
SET @name='���Ĳ�'          --ʹ��SET��ֵ
SELECT StudentNo, StudentName, BornDate, Address FROM Student WHERE StudentName = @name

/*--���ҡ����Ĳš�������ѧ��ѧԱ--*/
DECLARE @StudentNo int  --ѧ��
SELECT @StudentNo=StudentNo from Student WHERE StudentName=@name  --ʹ��SELECT��ֵ
SELECT StudentNo, StudentName, BornDate, Address FROM Student WHERE (StudentNo = @StudentNo+1) or (StudentNo = @StudentNo-1)


/*--������������������ơ��汾--*/
PRINT  '������������: ' + @@SERVERNAME    
SELECT  @@SERVERNAME  AS  '����������'

PRINT 'SQL Server�İ汾' + @@VERSION 
SELECT  @@VERSION  AS  'SQL Server�İ汾'

/*--��������ʾ�²����������ݵ�ѧ����¼��@ERRORֵ--*/

INSERT INTO Student(StudentName,StudentNo,LoginPwd,GradeId,Sex,BornDate,IdentityCard)   
     VALUES('����', 10011, '123456', 1, 1, '1980-12-31','11010119791231001x')
--���@@ERROR����0����ʾ��һ�����ִ���д���
print '��ǰ�����' + convert(varchar(5),@@ERROR)

UPDATE Student SET BornDate='1970-7-8' WHERE StudentNo=10011
PRINT '��ǰ�����:'+CONVERT(varchar(5),@@ERROR) 
GO

/*--������ʹ�þֲ�������ʾ���ַ�ƴ�ɵ�������ͼ�Σ�5�У�--*/
DECLARE @tag nvarchar(1)  
SET @tag='��'
PRINT @tag
PRINT @tag+@tag
PRINT @tag+@tag+@tag
PRINT @tag+@tag+@tag+@tag
PRINT @tag+@tag+@tag+@tag+@tag

/*--ѧʱ2--*/
/*--��������ѯѧ����12003ѧ���μ�2009��6��10�վٰ�ġ�Java Logic���γ̿��Եĳɼ���
        ʹ��Print������ѧ�������ͳɼ� --*/
DECLARE @NAME varchar(50)           --����
DECLARE @Result decimal(5,2)        --���Գɼ�
DECLARE @NO int
SET @NO = 10000
SELECT @NAME = StudentName FROM Student WHERE StudentNo=@NO 
SELECT @Result = StudentResult FROM Student 
INNER JOIN Result  ON Student.StudentNo=Result.StudentNo 
INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName='Java Logic' AND Student.StudentNo=@NO  AND ExamDate>='2009-2-15' AND ExamDate<'2009-2-16'  
PRINT '������'+@NAME
--PRINT '�ɼ���'+ @Result
PRINT '�ɼ���'+ Cast(@Result as varchar(10))

/*--��������ѯѧ����20011ѧ�������������䣬�����������1���С1���ѧ����Ϣ--*/

DECLARE @NO int
SET @NO = 20011
-- ���ѧ����20011��ѧ������������
SELECT StudentName ����,FLOOR(DATEDIFF(DY, BornDate, GETDATE())/365) ����
   FROM student  WHERE StudentNo=@NO
-- ��ѯ�����ѧ����20011��ѧ����1���С1���ѧ����Ϣ
DECLARE @date datetime,@year int  --��������
SELECT  @date=BornDate FROM Student WHERE StudentNo=@NO  --ʹ��SELECT��ֵ
print @date
SET @year = DATEPART(YY,@date)
SELECT *  FROM Student WHERE DATEPART(YY,BornDate)=@year+1 or DATEPART(YY,BornDate)=@year-1

/*--�������������ո�ʽ��ʾϵͳ��ǰ���� --*/
PRINT CONVERT(varchar(4),DATEPART(year,GETDATE()))+'��'+CONVERT(varchar(2),DATEPART(month,GETDATE()))+'��'+CONVERT(varchar(2),DATEPART(day,GETDATE()))+'��'

/*--������ͳ��ѧ����Java Logic�������һ�ο��Ե�ƽ���ֲ���ʾ��3��ѧ���ɼ�--*/
DECLARE @date datetime  --�������ʱ��
SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName='Java Logic'

DECLARE @myavg decimal(5,2)    --ƽ����
SELECT  @myavg=AVG(StudentResult) FROM Student 
INNER JOIN Result  ON Student.StudentNo=Result.StudentNo 
INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
WHERE SubjectName='Java Logic' AND ExamDate=@date

PRINT 'ƽ���֣�'+CONVERT(varchar(5),@myavg)
IF (@myavg>70)
  BEGIN
    PRINT '���Գɼ����㣬ǰ�����ĳɼ�Ϊ'
    SELECT TOP 3 StudentNo, StudentResult FROM Result 
    INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo 
    WHERE SubjectName='Java Logic' AND ExamDate=@date  
    ORDER BY StudentResult DESC
  END
ELSE
  BEGIN
    PRINT '���Գɼ��ϲ�������ĳɼ�Ϊ'
    SELECT TOP 3 StudentNo, StudentResult FROM Result 
    INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo 
    WHERE SubjectName='Java Logic' AND ExamDate=@date
    ORDER BY StudentResult 
  END

/*--��������ѯѧ����20012ѧ��Java�γ����һ�ο��Գɼ������ѧ�������Ϳ��Եȼ���
          ����ɼ�����85�֣���ʾ�����㡱�������������70�֣���ʾ�����á���
          �������60�֣���ʾ���еȡ���������ʾ���-- 
*/
DECLARE @name nvarchar(50) --����
DECLARE @score decimal(5,2)       --����
SELECT TOP 1  @score=StudentResult,@name=stu.StudentName 
   FROM Result r	
   INNER JOIN Student stu ON r.StudentNo=stu.StudentNo
   INNER JOIN Subject sub ON r.SubjectNo=sub.SubjectNo
   WHERE r.StudentNo='20012' AND sub.SubjectName='Java Logic'
ORDER BY ExamDate DESC

PRINT 'ѧ������:'+ @name
IF(@score>85)
begin
  PRINT '���Եȼ�:'+'����'
end
ELSE IF(@score>70)
begin
  PRINT '���Եȼ�:'+'����'
end 
ELSE IF(@score>60)
begin
  PRINT '���Եȼ�:'+'�е�'
end
ELSE
begin
  PRINT '���Եȼ�:'+'��'
end

/*--ѧʱ3--*/
/*--���������ѧ����Winforms�������һ�ο����Ƿ��в������ѧ����
���У�ÿ�˼�2�֣�����95�ֵ�ѧ�����ڼӷ�  WHILE����﷨
*/
DECLARE @date datetime  --����ʱ��
DECLARE @subNO int      --�γ̱��
SELECT  @subNo=SubjectNo FROM Subject
WHERE SubjectName='Winforms'

SELECT  @date=max(ExamDate) FROM Result 
WHERE SubjectNo=@subNO

DECLARE @n int
WHILE(1=1) --������Զ����
  BEGIN
    SELECT @n=COUNT(*) FROM Result 
    WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<60 --ͳ�Ʋ���������
    IF (@n>0) --ÿ�˼�2��
       UPDATE Result SET StudentResult=StudentResult+2 FROM Result 
       WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<95
    ELSE
       BREAK  --�˳�ѭ��
  END
PRINT '�ӷֺ�ĳɼ����£�'
SELECT StudentName,StudentResult FROM Result
 INNER JOIN Student ON Result.StudentNo=Student.StudentNo
 WHERE SubjectNo=@subNO AND ExamDate=@date 

/*--����������������ABCDE�弶�������ʾѧ����java�������һ�ο��Գɼ� CASE����﷨--*/
DECLARE @date datetime  --����ʱ��
SELECT  @date=max(ExamDate) FROM Result INNER JOIN  Subject
  ON Result.SubjectNo=Subject.SubjectNo
  WHERE SubjectName='Java Logic'
SELECT ѧ��=StudentNo,�ɼ�=CASE  WHEN StudentResult<60 THEN 'E'
							 WHEN StudentResult BETWEEN 60 AND 69 THEN 'D'
							 WHEN StudentResult BETWEEN 70 AND 79 THEN 'C'
							 WHEN StudentResult BETWEEN 80 AND 89 THEN 'B'
							 ELSE 'A'
  END  
  FROM Result INNER JOIN  Subject ON Result.SubjectNo=Subject.SubjectNo
  WHERE SubjectName='Java Logic' AND ExamDate=@date 

/*������
ʹ��While��Case-End����ѯѧ���������ڣ������ÿ��ѧ�������䡣
���ѧ��������ڵ���18�꣬���"��ϲ�����Ѿ��ǳ������ˡ�"��������ʾ"ϣ�������ճ���"��
*/
SELECT ����=StudentName, CASE  WHEN FLOOR(DATEDIFF(DY,BornDate,GETDATE())/365.25)>=18 THEN '��ϲ�����Ѿ��ǳ������ˡ�'
						 ElSE 'ϣ�������ճ���'
                         END  FROM Student

/*������
ʹ��Case-End���������ʾѧ���ɼ��ȼ���
ʹ��While��IF������Ƿ���������ѧ����
����У���ÿ�˼�2��ֱ��ȫ��ѧ��������
���ѧ���ɼ�����100����100�ּ��㡣
*/
DECLARE @date datetime  --����ʱ��
DECLARE @subNO int      --�γ̱��
SELECT @subNO=SubjectNo FROM Subject
WHERE SubjectName='C# OOP'
SELECT  @date=max(ExamDate) FROM Result 
WHERE SubjectNo=@subNO

PRINT '�ӷ�ǰѧ���Ŀ��Գɼ����£�'
SELECT ѧ��=StudentNo,�ɼ��ȼ�=CASE  
								 WHEN StudentResult BETWEEN 0 AND 59 THEN '��ҪŬ���ˣ�����'
								 WHEN StudentResult BETWEEN 60 AND 69 THEN '��'
								 WHEN StudentResult BETWEEN 70 AND 79 THEN '���'
								 WHEN StudentResult BETWEEN 80 AND 89 THEN '����'
								 ElSE '�����'
                                END  
       FROM Result 
       WHERE SubjectNo=@subNO AND ExamDate=@date 

DECLARE @n int
WHILE(1=1) --������Զ����
   BEGIN
    SELECT @n=COUNT(*) FROM Result 
    WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<60 --ͳ�Ʋ���������
    IF (@n>0)
       UPDATE Result SET StudentResult=StudentResult+2 FROM Result
       WHERE SubjectNo=@subNO AND ExamDate=@date AND StudentResult<=98
  --ÿ�˼�2��
    ELSE
       BREAK  --�˳�ѭ��
  END


/*--ѧʱ4--*/
/*--��������ѯ���в�����ļ�¼������������±�punish��--*/
USE MyMySchool  
GO
IF  EXISTS(SELECT * FROM  sysobjects  WHERE  name ='punish')
	DROP TABLE punish
GO

CREATE TABLE punish(  --������
ѧ�� int,
��������� int,
������� varchar(50)
)
GO

INSERT INTO punish --��������
SELECT  StudentNo ѧ��,COUNT(0) ���������,'' ������� from Result where StudentResult<60 GROUP BY StudentNo
GO
UPDATE punish SET �������='����' WHERE ���������=1 --����
UPDATE punish SET �������='��ҵ' WHERE ��������� BETWEEN 2 AND 3 --����
UPDATE punish SET �������='����' WHERE ���������>3 --����
SELECT * FROM punish --��ѯ
GO



/*--��������������Ա��Admin������2������Ա��¼�������һ������Ա������ go --*/
USE MySchool  
GO
IF  EXISTS(SELECT * FROM  sysobjects  WHERE  name ='Admin')
	DROP TABLE Admin
GO
CREATE TABLE Admin(  --������
	[LoginId]  [nvarchar](50) NOT NULL,
	[LoginPwd] [nvarchar](50) NOT NULL
)

ALTER TABLE Admin    --�������Լ��
ADD CONSTRAINT PK_Admin PRIMARY KEY (LoginId)
GO
INSERT INTO Admin([LoginId],[LoginPwd]) VALUES('TEST1','123')    --��������
INSERT INTO Admin([LoginId],[LoginPwd]) VALUES('TEST2','123456') --��������
GO
UPDATE Admin SET [LoginPwd]='1234567' WHERE [LoginId]='TEST2' --��������
GO
