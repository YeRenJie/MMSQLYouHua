/*--ѧʱ2--*/
/*--������Ϊʲô��Ҫ����--*/
--ͬһ���У��綼��ũ�е��ʺţ�����ֱ��ת��
/*��--------------����-----------------*/
USE MySchool
GO

--����ũ���ʻ���bank
IF EXISTS(SELECT * FROM sysobjects WHERE name='bank')
   DROP TABLE bank
GO
 
CREATE TABLE bank
(
    customerName CHAR(10), --�˿�����
    currentMoney MONEY     --��ǰ���
)
GO

/*---���Լ�����������й涨���ʻ���������1Ԫ����������----*/
ALTER TABLE bank
  ADD CONSTRAINT CK_currentMoney CHECK(currentMoney>=1)
GO

/*--����������ݣ������������������Ϊ800 �����Ŀ������������1 ---*/
INSERT INTO bank(customerName,currentMoney) VALUES('����',1000)
INSERT INTO bank(customerName,currentMoney) VALUES('����',1)
GO
--�鿴���
SELECT * FROM bank
GO

/*--ת�ʲ��ԣ�����ϣ��ͨ��ת�ˣ�ֱ�ӻ�Ǯ������1000Ԫ--*/
--���ǿ��ܻ���������д����
--�������ʻ���1000Ԫ�����ĵ��ʻ���1000Ԫ
UPDATE bank SET currentMoney=currentMoney-1000 
     WHERE customerName='����'
UPDATE bank SET currentMoney=currentMoney+1000 
     WHERE customerName='����'
GO
--�ٴβ鿴��������������ʲô���صĴ���?��ν���أ�
SELECT * FROM bank
GO

/*--ѧʱ3--*/
/*--������
������Result���в������μ�Java���Ե�10��ѧԱ�ĳɼ���
����һ��ѧԱ�ĳɼ�����100�֣�Υ���˳ɼ�С�ڵ���100�ֵ�Լ��
 */
--delete from Result where examdate=GETDATE()
BEGIN TRANSACTION;
DECLARE @errorSum INT
SET @errorSum=0
/*--��������--*/
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
            VALUES(10012,1,GETDATE(),102)--����Υ��Լ��
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

/*--�����Ƿ��д���ȷ���������ύ���ǳ���--*/
IF(@errorSum<>0) --����д���
  BEGIN
    PRINT '����ʧ�ܣ��ع�����'
    ROLLBACK TRANSACTION 
  END  
ELSE
  BEGIN
    PRINT '����ɹ����ύ����'
    COMMIT TRANSACTION   
  END
GO

/*--������Ϊ��ҵѧԱ������У����--*/
BEGIN TRANSACTION
DECLARE @errorSum INT
SET @errorSum=0
/*--��ѯResult��������Y2ѧԱ�Ŀ��Գɼ������浽�±�HistoreResult*/
SELECT Result.* INTO HistoreResult 
FROM Result INNER JOIN Student ON Result.StudentNo=Student.StudentNo
INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--ɾ��Result��������Y2ѧԱ�Ŀ��Գɼ�*/
DELETE  Result FROM  Result JOIN Student ON Result.StudentNo=Student.StudentNo
INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--��Student��������Y2��ѧԱ��¼�����浽�±�HistoryStudent*/
SELECT Student.* INTO HistoryStudent
FROM Student INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--ɾ��Studet��������Y2ѧԱ��¼*/
DELETE Student FROM Student 
INNER JOIN Grade ON Grade.GradeId=Student.GradeId 
WHERE GradeName='Y2'
SET @errorSum=@errorSum+@@error

/*--�����Ƿ��д���ȷ���������ύ���ǳ���--*/
IF (@errorSum<>0) --����д���
  BEGIN
    PRINT '����ʧ�ܣ��ع�����'
    ROLLBACK TRANSACTION 
  END  
ELSE
  BEGIN
    PRINT '����ɹ����ύ����'
    COMMIT TRANSACTION   
  END
GO

/*--ѧʱ4--*/
/*--������������ͼ���鿴ѧԱ�ĳɼ�--*/
--������,�ݲ���
--������ͼ
CREATE VIEW vw_student_result
  AS
    SELECT ����=StudentName,ѧ��=Student.StudentNo,�ɼ�=StudentResult,
           ��Ŀ=SubjectName,��������=ExamDate
    FROM Student INNER JOIN Result ON Student.StudentNo=Result.StudentNo
                 INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
GO
--ִ����ͼ
SELECT * FROM vw_student_result


--�Ӹ��������Java Logic�γ����һ�ο��Ե�ѧ���ɼ� 
--��ʦ��ע����ͼ
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_subject_result')
   DROP VIEW vw_student_subject_result
GO

CREATE VIEW vw_student_subject_result
AS
  SELECT ����=StudentName,ѧ��=Student.StudentNo,�ɼ�=StudentResult,
           �γ�����=SubjectName,��������=ExamDate
    FROM Student INNER JOIN Result ON Student.StudentNo=Result.StudentNo
                 INNER JOIN Subject ON Result.SubjectNo=Subject.SubjectNo
  WHERE Subject.SubjectNo = (
          SELECT SubjectNo FROM Subject WHERE SubjectName='Java logic')--��Ŀ
    AND ExamDate =(       --�������ʱ��
	      SELECT MAX(ExamDate) FROM Result,Subject WHERE Result.SubjectNo = Subject.SubjectNo
          AND SubjectName='Java logic' )
  --ORDER BY StudentResult DESC  --ORDER BY�Ӿ�����ͼ���Ӳ�ѯ����Ч
GO

--ִ����ͼ
SELECT * FROM vw_student_subject_result

--���ѧ�����ſγ̵��ܳɼ�
--�����ι�ע����ͼ����
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_result_info')
BEGIN
  DROP VIEW vw_student_result_info
END
GO
CREATE VIEW vw_student_result_info
AS
  --��ѧ����Ϣ���ܳɼ�
  SELECT ����=StudentName,ѧ��=Student.StudentNo,��ϵ�绰=Phone,ѧ��=GradeName,�ɼ�=Total
  FROM Student
  LEFT OUTER JOIN (
      --��ÿ��ѧ����ѧ�ڵ����пγ��ܳɼ�
	  SELECT r.StudentNo,GradeName,SUM(StudentResult) Total 
	  FROM Result r 
	  INNER JOIN (
        --��ÿ��ѧ���μ�ÿ�ſγ̿��Ե��������
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
/*--ʹ����ͼ����ͼ��һ������������������һ����--*/
SELECT * FROM vw_student_result

/*--������ɾ���鿴ѧԱ�ɼ�����ͼ--*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_result')
   DROP VIEW vw_student_result
GO

/*--������������ͼ���鿴��ѧ��ѧԱ����--*/
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'vw_student_grade')
   DROP VIEW vw_student_grade
GO
CREATE VIEW vw_student_grade
  AS
    SELECT ѧ��=GradeName,����=StudentName,ѧ��=StudentNo
    FROM Grade INNER JOIN Student ON Student.GradeId=Grade.GradeId
GO

/*--ʹ����ͼ����ͼ��һ������������������һ����--*/
SELECT * FROM vw_student_grade
SELECT ѧ��,����,ѧ�� FROM vw_student_grade