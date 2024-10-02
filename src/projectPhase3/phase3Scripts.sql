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


