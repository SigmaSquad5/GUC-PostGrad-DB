USE PostGradDB

-- 1

-- 2

-- 3

-- a) List all supervisors in the system.
GO
CREATE PROC AdminListSup
AS
	SELECT *
	FROM Supervisor
RETURN

-- b) view the profile of any supervisor that contains all his/her information.
GO
CREATE PROC AdminViewSupervisorProfile
@supId INT
AS
	SELECT *
	FROM Supervisor
	WHERE Supervisor.id = @supId
RETURN

-- c) List all Theses in the system.
GO
CREATE PROC AdminViewAllTheses
AS
	SELECT *
	FROM Thesis
RETURN

-- d) List the number of on going theses.
GO
CREATE PROC AdminViewOnGoingTheses
@thesesCount INT
AS
	SELECT @thesesCount = COUNT(*)
	FROM Thesis
	WHERE Thesis.endDate IS NULL
RETURN

-- e) List all supervisorsí names currently supervising students, theses title, student name.
-- what should the output be exactly
GO
CREATE PROC AdminViewStudentThesisBySupervisor
AS
	SELECT Supervisor.first_name, Thesis.title, allStudents.firstname
	FROM 
		(
		SELECT * 
		FROM 
			GUCianStudentRegisterThesis 
			INNER JOIN GucianStudent ON GUCianStudentRegisterThesis.sid = GucianStudent.id
		UNION 
		SELECT * 
		FROM 
			NonGUCianStudentRegisterThesis
			INNER JOIN NonGucianStudent ON NonGUCianStudentRegisterThesis.sid = NonGucianStudent.id
		)
		AS allStudents
		INNER JOIN Supervisor ON allStudents.supid = Supervisor.id
		INNER JOIN Thesis ON allStudents.serial_no = Thesis.serialNumber
	WHERE
		endDate IS NULL
RETURN

-- f) List nonGucians names, course code, and respective grade.
-- what do I do with this input ?
GO
CREATE PROC AdminListNonGucianCourse
@courseID INT
AS
	SELECT NonGucianStudent.firstname, NonGucianStudent.lastname, Course.courseCode, NonGucianStudentTakeCourse.grade
	FROM 
		NonGucianStudentTakeCourse
		INNER JOIN NonGucianStudent ON NonGucianStudentTakeCourse.sid = NonGucianStudent.id
		INNER JOIN Course ON NonGucianStudentTakeCourse.cid = Course.id
	WHERE 
		@courseID = Course.id
RETURN

-- g) Update the number of thesis extension by 1.
GO
CREATE PROC AdminUpdateExtension
@ThesisSerialNo INT
AS
	UPDATE Thesis
	SET Thesis.noExtension = Thesis.noExtension + 1
	WHERE Thesis.serialNumber = @ThesisSerialNo
RETURN

-- h) Issue a thesis payment.
-- CHECK SCOPE IDENTITY & SUCCESS BIT
GO
CREATE PROC AdminIssueThesisPayment
@ThesisSerialNo INT, @amount DECIMAL, @noOfInstallments INT, @fundPercentage DECIMAL,
@Success BIT OUTPUT
AS
	INSERT INTO Payment
	VALUES (@amount, @noOfInstallments, @fundPercentage);
	UPDATE Thesis
	SET Thesis.payment_id = SCOPE_IDENTITY()
	WHERE Thesis.serialNumber = @ThesisSerialNo;
	SET @Success = 1;
RETURN

-- i) view the profile of any student that contains all his/her information.
GO
CREATE PROC AdminViewStudentProfile
@sid INT
AS
	SELECT *
	FROM(
		SELECT * 
		FROM 
			GUCianStudentRegisterThesis 
			INNER JOIN GucianStudent ON GUCianStudentRegisterThesis.sid = GucianStudent.id
		UNION 
		SELECT * 
		FROM 
			NonGUCianStudentRegisterThesis
			INNER JOIN NonGucianStudent ON NonGUCianStudentRegisterThesis.sid = NonGucianStudent.id
		)
		AS allStudents
	WHERE
		allStudents.sid = @sid
RETURN

-- j) Issue installments as per the number of installments for a certain payment every six months starting from the entered date.
--  amount, done FROM WHERE ????
GO
CREATE PROC AdminIssueInstallPayment
@paymentID INT, @InstallStartDate DATE
AS
	DECLARE @i INT = 0;
	DECLARE @InstallmentDate DATE = @InstallStartDate;
	DECLARE @no_installments INT = 
		(SELECT Payment.no_installments
		FROM Payment
		WHERE Payment.id = @paymentID)

	WHILE @i < @no_installments
		INSERT INTO Installment(date, paymentId)
		VALUES (@InstallmentDate, @paymentID);
		SET @InstallmentDate = DATEADD(month, 6, @InstallmentDate);
		SET @i = @i + 1;
RETURN

-- k) List the title(s) of accepted publication(s) per thesis.
-- CHECK THE GROUP BY AND BIT CHECK
GO
CREATE PROC AdminListAcceptPublication
AS
	SELECT Thesis.title, Publication.title
	FROM
		ThesisHasPublication
		INNER JOIN Thesis ON ThesisHasPublication.serialNo = Thesis.serialNumber
		INNER JOIN Publication ON Publication.id = ThesisHasPublication.pubid
	WHERE
		Publication.accepted = 1
	GROUP BY Thesis.title, Publication.title
RETURN

-- l) Add courses and link courses to students.

-- DECIMAL PARAMETERS ????
GO
CREATE PROC AddCourse
@courseCode VARCHAR(10), @creditHrs INT, @fees DECIMAL
AS
	INSERT INTO Course VALUES (@fees, @creditHrs, @courseCode)
RETURN


-- NonGucianStudentPayForCourse ??????
GO
CREATE PROC linkCourseStudent
@courseID INT, @studentID INT
AS
	INSERT INTO NonGucianStudentTakeCourse VALUES (@studentID, @courseID)
RETURN

-- GRADE DECIMAL ????
GO
CREATE PROC addStudentCourseGrade
@courseID INT, @studentID INT, @grade DECIMAL
AS
	UPDATE NonGucianStudentTakeCourse
	SET grade = @grade
	WHERE cid = @courseID AND sid = @studentID
RETURN

-- m) View examiners and supervisor(s) names attending a thesis defense taking place on a certain date.

-- HOW TO GET SUPEVISOR ???
GO
CREATE PROC ViewExamSupDefense
@defenseDate datetime
AS
	
RETURN

-- 4

-- a) Evaluate a studentís progress report, and give evaluation value 0 to 3. DONE
GO
	CREATE PROC EvaluateProgressReport
	@supervisorid INT,
	@thesisserialno INT,
	@progressreportno INT,
	@evaluation INT
	AS
		UPDATE GucianProgressReport
		SET GUCianProgressReport.eval = @evaluation
		WHERE @supervisorid = GUCianProgressReport.supid AND @thesisserialno = GUCianProgressReport.thesisserialnumber and @progressreportno = GUCianProgressReport.no;
		UPDATE NonGUCianProgressReport
		SET NonGUCianProgressReport.eval = @evaluation
		WHERE  NonGUCianProgressReport.supid = @supervisorid AND @thesisserialno = NonGUCianProgressReport.thesisserialnumber and @progressreportno = NonGUCianProgressReport.no

RETURN

-- b) View all my studentsís names and years spent in the thesis. TWO SOLUTIONS, THIS ONE BETTER THAN COMMENTED
--GO
--	CREATE PROC ViewSupStudentsYears
--	@supervisorID INT
--	AS
--		SELECT allStudents.firstname, allStudents.lastname, Thesis.years
--		FROM 
--			(
--			SELECT * 
--			FROM 
--				GUCianStudentRegisterThesis 
--				INNER JOIN GucianStudent ON GUCianStudentRegisterThesis.sid = GucianStudent.id
--			UNION 
--			SELECT * 
--			FROM 
--				NonGUCianStudentRegisterThesis
--				INNER JOIN NonGucianStudent ON NonGUCianStudentRegisterThesis.sid = NonGucianStudent.id
--			)
--			AS allStudents
--			INNER JOIN Supervisor ON allStudents.supid = Supervisor.id
--			INNER JOIN Thesis ON allStudents.serial_no = Thesis.serialNumber
--			WHERE @supervisorID = NonGUCianStudentRegisterThesis.supid
	
--RETURN

GO 
CREATE PROC ViewSupStudentsYears
@supervisorID INT
AS
	SELECT AllStudents.firstname, AllStudents.lastname, AllStudents.years
	FROM
	(
	SELECT GucianStudent.firstname, GucianStudent.lastname, Thesis.years
	FROM GUCianStudentRegisterThesis
		INNER JOIN GucianStudent ON GUCianStudentRegisterThesis.sid = GucianStudent.id
		INNER JOIN Thesis ON GUCianStudentRegisterThesis.serial_no = Thesis.serialNumber
	WHERE GUCianStudentRegisterThesis.supid = @supervisorID
	UNION
	SELECT NonGucianStudent.firstname, NonGucianStudent.lastname, Thesis.years
	FROM NonGUCianStudentRegisterThesis
		INNER JOIN NonGucianStudent ON NonGUCianStudentRegisterThesis.sid = NonGucianStudent.id
		INNER JOIN Thesis ON NonGUCianStudentRegisterThesis.serial_no = Thesis.serialNumber
	WHERE NonGUCianStudentRegisterThesis.supid = @supervisorID
	)
	AS AllStudents
RETURN

-- c) View my profile
GO 
	CREATE PROC SupViewProfile
	@supervisorID INT
	AS
	SELECT * 
	FROM Supervisor
	WHERE Supervisor.id = @supervisorID
RETURN

-- Update my personal information. DONE QUESTION: SHOULD WE ASSUME ALL VALUES WILL BE AVAIABLE AS INPUTS?
GO
	CREATE PROC UpdateSupProfile
	@supervisorID INT,
	@first_name VARCHAR(20),
	@last_name VARCHAR(20),
	@email VARCHAR(50),
	@faculty VARCHAR(20)
	AS
	UPDATE Supervisor
	SET Supervisor.first_name = @first_name, Supervisor.last_name = @last_name, Supervisor.email = @email, Supervisor.faculty = @faculty
	WHERE Supervisor.id = @supervisorID
RETURN

-- d) View all publications of a student. DONE

GO
	CREATE PROC ViewAStudentPublications
	@StudentID INT
	AS
		SELECT * 
		FROM GUCianStudentRegisterThesis
			INNER JOIN ThesisHasPublication ON ThesisHasPublication.serialNo = GUCianStudentRegisterThesis.serial_no
			INNER JOIN Publication ON Publication.id = ThesisHasPublication.pubid
		WHERE GUCianStudentRegisterThesis.sid = @StudentID
		UNION
		SELECT * 
		FROM NonGUCianStudentRegisterThesis
			INNER JOIN ThesisHasPublication ON ThesisHasPublication.serialNo = NonGUCianStudentRegisterThesis.serial_no
			INNER JOIN Publication ON Publication.id = ThesisHasPublication.pubid
		WHERE NonGUCianStudentRegisterThesis.sid = @StudentID
RETURN

-- e) Add defense for a thesis GUCIAN
GO
	CREATE PROC AddDefenseGucian
	@ThesisSerialNo INT,
	@DefenseDate Datetime, 
	@DefenseLocation varchar(15)
	AS
	INSERT INTO DEFENSE (serialNumber ,date , location) VALUES (@ThesisSerialNo, @DefenseDate, @DefenseLocation)
RETURN

-- Add defense for a thesis NONGUCIAN. DONE

GO
	CREATE PROC AddDefenseNonGucian
	@ThesisSerialNo INT,
	@DefenseDate Datetime,
	@DefenseLocation varchar(15)
	AS
	IF (SELECT MIN(grade)
	FROM NonGUCianStudentRegisterThesis
		INNER JOIN NonGucianStudentTakeCourse ON NonGUCianStudentRegisterThesis.sid = NonGucianStudentTakeCourse.sid
	) > 50
	INSERT INTO DEFENSE (serialNumber ,date , location) VALUES (@ThesisSerialNo, @DefenseDate, @DefenseLocation)
RETURN

-- g) Cancel a Thesis if the evaluation of the last progress report is zero. QUESTION : HOW WOULD I DELETE FROM A TABLE WHICH IN JOINED WITH ANOTHER?
GO 
	CREATE PROC CancelThesis
	@ThesisSerialNo INT
	AS
	SELECT Top 1 *
	FROM Thesis
		INNER JOIN GUCianProgressReport ON GUCianProgressReport.thesisSerialNumber = Thesis.serialNumber
		WHERE @ThesisSerialNo = Thesis.serialNumber
	ORDER BY date DESC
RETURN


-- A PROCEDURE WHICH RETURNS THE ID OF THE NEW EXAMINER TO BE USED IN THE FOLLOWING PROCEDURE
GO
CREATE PROC NewExaminer(
@ExaminerName varchar(20),
@National bit, 
@fieldOfWork varchar(20)
)

AS
	Insert INTO Examiner (name, isNational, fieldOfWork) VALUES (@ExaminerName, @National, @fieldOfWork);
	SELECT id
	FROM Examiner
	WHERE name = @ExaminerName AND fieldOfWork = @National AND isNational = @fieldOfWork
	
RETURN

-- h,f) Add examiner(s) for a defense. QUESTION : ARE H AND F REPEATED OR ARE THEY DIFFERENT SOMEHOW? DONE
-- PROCEDURE WHICH TAKES INPUTS FOR THE ABOVE FUNCTION TO RETURN THE ID FOR THE NEW EXAMINER NEEDED TO INSERT THE NEWEXAMINER TO THE DEFENSE.
GO
CREATE PROC AddExaminer
@ThesisSerialNo INT,
@DefenseDate Datetime,
@ExaminerName varchar(20),
@National BIT, 
@fieldOfWork varchar(20)
AS
	DECLARE @NewExaminerId INT;
	EXEC NewExaminer @ExaminerName, @National, @fieldOfWork, @NewExaminerId ;	
	Insert INTO ExaminerEvaluateDefense (date, serialNo, examinerId) VALUES (@DefenseDate, @ThesisSerialNo, @NewExaminerId)
RETURN



-- i) QUESTION: WHERE IS THE GRADE INPUT, SHOULDNT THE NAME BE ADDGRADE.
GO 
	CREATE PROC AddGrade
	@ThesisSerialNo INT,
	@ThesisGrade DECIMAL(4,2)
	AS
	UPDATE THESIS
	SET grade = @ThesisGrade
	WHERE @ThesisSerialNo = Thesis.serialNumber
RETURN

-- 5

-- 6

-- b) Edit my profile (change any of my personal information).


--c) As a Gucian graduate, add my undergarduate ID.




--d) As a nonGucian student, view my coursesí grades



--e) View all my payments and installments.
--e-i)
--e-ii)
--e-iii)
--e-iv)


--f) Add and fill my progress report(s).
--f-i)
--f-ii)



--g) View my progress report(s) evaluations.




--h) Add publication.



--i) Link publication to my thesis.

-- 6

