USE PostGradDB;
-- 1
-- a)

-- i) student
EXEC StudentRegister 'Abd El Ghafour', 'El Boray', '123456','MET',1,'barbora@gmail.com','Wekalet El Balah, St 2, Apt 5';
EXEC StudentRegister 'Fatma', 'Koshary', 'as@45asfg%!gAGAs','Pharmacy',0,'zawgatabdelghafourelboray@yahoo.com','Wekalet El Balah, St 2, Apt 5';

SELECT * FROM GucianStudent;
SELECT * FROM NonGucianStudent;
-- ii) supervisor
EXEC SupervisorRegister 'Tenen', 'Elkemya', 'loveChemistry33&','Pharmacy', 'ahmedabdelwaged@hotmail.com';

SELECT * FROM Supervisor;
-- 2

-- a)
DECLARE @Success BIT;
EXEC userLogin '17','as@45asfg%!gAGAs', @Success OUTPUT;
PRINT (@Success);

-- b) 
EXEC addMobile '16', '01020304050';
EXEC addMobile '17', '01020304055';

SELECT * FROM GUCStudentPhoneNumber
SELECT * FROM NonGUCStudentPhoneNumber
-- 3

-- a)
EXEC AdminListSup;

-- b)
EXEC AdminViewSupervisorProfile @supId = 3;

-- c)
EXEC AdminViewAllTheses;

-- d)
DECLARE @thesesCountOut INT;
EXEC AdminViewOnGoingTheses @thesesCount = @thesesCountOut OUTPUT;
PRINT (@thesesCountOut);

-- e)
EXEC AdminViewStudentThesisBySupervisor;

-- f)
EXEC AdminListNonGucianCourse 2;
-- g)
EXEC AdminUpdateExtension 1;
-- h)
DECLARE @Success BIT;
EXEC AdminIssueThesisPayment 2, 200000, 6, 0, @Success OUTPUT;
-- i)
EXEC AdminViewStudentProfile 1;

-- j)
EXEC AdminIssueInstallPayment 2, '2020-12-01';

DECLARE @no_installments INT = 
		(SELECT Payment.no_installments
		FROM Payment
		WHERE Payment.id = 1)
print(@no_installments)

delete from Installment;

-- k)
EXEC AdminListAcceptPublication;
-- l)
	-- DONE
-- m)
select Thesis.defenseDate
from Thesis
EXEC ViewExamSupDefense '2021-10-07 00:00:00.000';

-- 4
-- a)
GO
INSERT INTO Thesis (field, type, title, startDate, endDate) VALUES ('Chemistry','MSC','Chemistry wow', '10/7/2001','12/15/2021');
EXEC StudentRegister 'Harry', 'Potter', 'HarryPotterPass', 'Gryffindor', 1, 'HarryPotterPassEmail ', '4 Privet Drive';
EXEC SupervisorRegister 'Remus', 'Lupin', 'RemusLupinPass', 'Gryffindor', 'RemusLupinEmail';
INSERT INTO GUCianStudentRegisterThesis VALUES (1,2,1);
INSERT INTO GUCianProgressReport (sid, date, state, thesisSerialNumber, supid) VALUES (1,'10/10/2012',0,1,2);
EXEC EvaluateProgressReport 2, 1, 1, 0;

GO
INSERT INTO Thesis (field, type, title, startDate, endDate) VALUES ('Computer Science','PHD','Hacker', '1/3/2011','4/12/2018');
EXEC StudentRegister 'Draco', 'Malfoy', 'DracoMalfoyPass', 'Slytherin', 0, 'DracoMalfoyEmail', ' The Malfoy Mansion';
EXEC SupervisorRegister 'Severus', 'Snape', 'SeverusSnapePass', 'Slytherin', 'SeverusSnapeEmail';
INSERT INTO NonGUCianStudentRegisterThesis VALUES (3,2,2);
INSERT INTO NonGUCianProgressReport (sid, date, state, thesisSerialNumber, supid) VALUES (3,'11/7/2012',0,2,2);
EXEC EvaluateProgressReport 5, 2, 1, 0;

-- b)
EXEC ViewSupStudentsYears 1;

-- c)
EXEC SupervisorRegister 'Remus', 'Lupin', 'RemusLupinPass', 'Gryffindor', 'RemusLupinEmail';
EXEC SupViewProfile 2;

EXEC UpdateSupProfile 2, StillRemus, Lupin, ALWAYSGRYF;

-- d)
INSERT INTO Publication (title, date, place, accepted, host) VALUES ('1ST PUBLICATION', '10/1/2013', 'CAIRO', 1, 'YOUSEF');
INSERT INTO ThesisHasPublication VALUES (1,1);
INSERT INTO Publication (title, date, place, accepted, host) VALUES ('2ND PUBLICATION', '12/4/2013', 'ALEX', 1, 'YOUSEF2');
INSERT INTO ThesisHasPublication VALUES (1,2);
EXEC ViewAStudentPublications 2;

-- e)

EXEC AddDefenseGucian 1, '10/7/2021', 'cairo';

EXEC AddCourse 'CSEN 1', 8, 1000;
EXEC linkCourseStudent 1,3;
EXEC addStudentCourseGrade 1,3,100;

EXEC AddCourse 'MATH 1', 6, 2000;
EXEC linkCourseStudent 2,3;
EXEC addStudentCourseGrade 2,3,55;

EXEC AddDefenseNonGucian 2, '12/17/2021', 'BERLIN';

-- f)
EXEC AddExaminer 1,'10/7/2021', 'ALBUS', 1, 'MANG';

-- g)
-- h)
-- i)
-- j)
-- k)

-- 5) 

-- a)

SELECT * FROM Thesis;
INSERT INTO Defense (serialNumber,date,location) values (1,'2020/12/9 12:12:12','Elmeshmesh');
SELECT * FROM Defense;
EXEC AddDefenseGrade 1, '2020/12/9 12:12:12', 5.2;

-- b)
INSERT Into ExaminerEvaluateDefense (date,serialNo,examinerId) values ('2020/12/9 12:12:12',1,19)
EXEC AddCommentsGrade 1,'2020/12/9 12:12:12',19, 'very very very very bad'
select* from ExaminerEvaluateDefense



--6)
--a)
EXEC viewMyProfile 9
EXEC viewMyProfile 12
--b)
EXEC editMyProfile 9, 'lord', 'seventh', 'finallyHokage', 'rasenganAndDhadowGotMeHere@gmail.com', ' The uzumaki residence', 'Phd'
--c)
EXEC addUndergradID 9, '4923423'
--d)
EXEC ViewCoursesGrades 12
--e
	--i)
	EXEC ViewCoursePaymentsInstall 12
	--ii)
	EXEC ViewThesisPaymentsInstall 9
	--iii)
	EXEC ViewUpcomingInstallments 12
	--iv)
	EXEC ViewMissedInstallments 9
--f
	--i)
	EXEC AddProgressReport 5, '2022-11-09'
	--ii)
	EXEC FillProgressReport 5, 10, 75, 'i am gonna pass out cause this uses more chakra than what i get from the ramen'
--g)
EXEC ViewEvalProgressReport 6, 2
--h)
EXEC addPublication 'i think i did it too well,they wanna make me hokage now' ,'2024-07-07' ,'konoha news' ,'konoha' ,1
--i)
EXEC linkPubThesis 10, 5
