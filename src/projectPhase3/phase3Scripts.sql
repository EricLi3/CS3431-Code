DROP TRIGGER NewEquipmentCheck;
DROP TRIGGER EmployeeHierarchyCeiling;
DROP TRIGGER EmployeeHierarchy;
DROP TRIGGER SetInsurance;
DROP TRIGGER requireComment;
DROP VIEW CriticalCases;
DROP VIEW DoctorsLoad;

--Part 1 Views--
----1. Create a view named CriticalCases that selects the patients who have been admitted to
-- Intensive Care Unit (ICU) at least 2 times.
-- The view columns should be: Patient_SSN, firstName, lastName, numberOfAdmissionsToICU

CREATE OR REPLACE VIEW CriticalCases AS
    SELECT PATIENTSSN AS Patient_SSN,
       PATIENTFNAME AS firstName,
       PATIENTLNAME AS LastName,
       count(PATIENTSSN) AS numberOfAdmissionsToICU

    FROM PATIENT NATURAL JOIN ADMISSION

    WHERE ADMISSIONNUM IN (SELECT ADMISSIONNUM FROM STAYIN
                             WHERE ROOMNUM IN (
                                SELECT ROOMNUM FROM ROOMSERVICE WHERE SERVICE = 'ICU'
                             )
                          )

    GROUP BY PATIENTSSN, PATIENTFNAME, PATIENTLNAME
    HAVING count(PATIENTSSN) >= 2;

--2.
/*Create a view named DoctorsLoad that reports for each doctor whether this doctor has an overload or not.
  A doctor has an overload if they have more than 10 distinct admission cases; otherwise, the doctor has an underload.
  Notice that if a doctor examined a patient multiple times in the same admission, that still counts as one admission case.
  The view columns should be: DoctorID, graduatedFrom, load.*/

CREATE OR REPLACE VIEW DoctorsLoad AS
SELECT
    Doctor.EmployeeID AS DoctorID,
    Doctor.GraduatedFrom,
    CASE
        WHEN (SELECT COUNT(DISTINCT Examine.AdmissionNUM) -- If the admission_num dup, then only count once
              FROM Examine
              WHERE Examine.DoctorID = Doctor.EmployeeID) > 10 -- If more than 10 distinct admissions, the doctor is overloaded

            THEN 'Overloaded'
            ELSE 'Underloaded'
        END
        AS load
FROM Doctor;

--3.
/*Use the views created above (you may need the original tables as well) to report the critical-case patients
  with number of admissions to ICU greater than 4.*/
SELECT Patient_SSN, firstName, LastName
FROM CriticalCases
WHERE numberOfAdmissionsToICU > 4;

--4.
/*Use the views created above (you may need the original tables as well) to report the overloaded doctors that graduated from WPI.
  You should report the doctor ID, firstName, and lastName*/
SELECT
    Doctor.EmployeeID AS DoctorID,
    Employee.FName AS firstName,
    Employee.LName AS lastName
FROM
    Doctor, Employee
WHERE
    Doctor.EmployeeID IN (
        SELECT DoctorID
        FROM DoctorsLoad
        WHERE load = 'Overloaded'
    )
  AND Doctor.EmployeeID = Employee.ID
  AND Doctor.GraduatedFrom = 'WPI';

--5.
/*Use the views created above (you may need the original tables as well) to report the comments inserted by underloaded doctors when
  examining critical-case patients. You should report the doctor ID, patient SSN, and the comment.*/
SELECT DISTINCT
    Doctor.EmployeeID AS DoctorID,
    Patient.PatientSSN AS PatientSSN,
    DBMS_LOB.SUBSTR(Examine.EXAMCOMMENT, 4000, 1) AS ExamComment
FROM
    Examine, Doctor, Admission, Patient, CriticalCases, DoctorsLoad
WHERE
        Examine.DoctorID = Doctor.EmployeeID  -- Match Doctor ID
  AND Examine.AdmissionNUM = Admission.AdmissionNum  -- Match Admission number
  AND Admission.PatientSSN = Patient.PatientSSN  -- Match Patient SSN
  AND Doctor.EmployeeID IN (
    SELECT DoctorID
    FROM DoctorsLoad
    WHERE load = 'Underloaded'  -- Filter for underloaded doctors
)
  AND Patient.PatientSSN IN (
    SELECT Patient_SSN
    FROM CriticalCases  -- Filter for critical case patients
);

--Part 2 Triggers--
-- //: You are allowed to combine several requirements into one trigger

/*If a doctor visits a patient who has been in the ICU during their current admission, they
must leave a comment. An example of this could be a patient whose admission involved a
1-day stay in a room designated as an Emergency Room, a 2-hour stay in an operating
room, and a 1-day stay in a room designated as an ICU. If a doctor was to visit the patient
during this admission, then they must leave a comment*/
CREATE TRIGGER requireComment
    BEFORE INSERT ON EXAMINE
    FOR EACH ROW
    DECLARE numICUVisits int;
    BEGIN
         SELECT COUNT(SERVICE)
         INTO numICUVisits
         FROM ROOMSERVICE, (SELECT ROOMNUM
                            FROM STAYIN
                            WHERE ADMISSIONNUM = :new.ADMISSIONNUM)
         WHERE SERVICE = 'ICU';
    IF(:new.EXAMCOMMENT = '') AND (numICUVisits > 0) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Doctor comment required');
    END IF;
END;
/* The insurance payment should be calculated automatically as 65% of the total payment.
   If the total payment changes, then the insurance amount should also change.*/
CREATE TRIGGER SetInsurance
    AFTER INSERT OR UPDATE ON ADMISSION
    BEGIN
        INSURANCEPAYMENT = 0.65 * TOTALPAYMENT;
    END;
/* Ensure that regular employees (with rank 0) must have their supervisors as division managers (with rank 1).
   Also, each regular employee must have a supervisor at all times.
   Similarly, division managers (with rank 1) must have their supervisors as general managers (with rank 2).
   Division managers must have supervisors at all times. General Managers must not have any supervisors.*/
CREATE TRIGGER EmployeeHierarchy
    BEFORE INSERT OR UPDATE ON EMPLOYEE
    FOR EACH ROW
    WHEN (new.EMPRANK = 0 OR new.EMPRANK = 1)
DECLARE SupervisorRank int;
BEGIN
    SELECT E.EMPRANK INTO SupervisorRank FROM EMPLOYEE E WHERE :new.SUPERVISORID = E.ID;
    IF (SupervisorRank != :new.EMPRANK + 1) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Incorrect supervisor rank. Supervisor ranks must be one higher than the employees ' ||
                                        'own rank for regular employees and division managers.');
    END IF;
END;

CREATE TRIGGER EmployeeHierarchyCeiling
       BEFORE INSERT OR UPDATE ON EMPLOYEE
    FOR EACH ROW
    WHEN (new.EMPRANK = 2)
    BEGIN
        IF (:new.SUPERVISORID IS NOT NULL) THEN
            RAISE_APPLICATION_ERROR(-20004, 'General managers can not have supervisors');
        END IF;
    END;
/* When a patient is admitted to an Emergency Room (a room with an Emergency service) on date D,
   the futureVisitDate should be automatically set to 2 months after that date, i.e., D + 2 months.
   The futureVisitDate may be manually changed later. */


/* When a new piece of equipment is purchased, and it has not been inspected for over a month,
   check if there is an equipment technician who can service it. If there is, update the inspection date. */
CREATE TRIGGER NewEquipmentCheck
    BEFORE INSERT ON EQUIPMENT
    FOR EACH ROW
DECLARE technicianAmount int;
BEGIN
    SELECT COUNT(C.EMPLOYEEID)
    INTO technicianAmount
    FROM CANREPAIREQUIPMENT C
    WHERE :new.TYPEID = C.EQUIPMENTTYPE;

    IF (SYSDATE - :new.LASTINSPECTION > 31) AND (technicianAmount > 0) THEN
        SELECT SYSDATE
        INTO :new.LASTINSPECTION
        FROM dual;
    END IF;
END;

