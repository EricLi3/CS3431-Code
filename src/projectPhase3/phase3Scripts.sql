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
  examining critical-case patients. You should report the doctor Id, patient SSN, and the comment.*/
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
