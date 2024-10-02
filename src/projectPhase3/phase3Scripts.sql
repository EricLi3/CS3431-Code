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
