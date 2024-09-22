------- Q1 ---------
-- Report all tuples for doctors graduated from WPI
SELECT *
FROM DOCTOR
WHERE DOCTOR.GRADUATEDFROM = 'WPI';

------- Q2 ---------
-- For a given division manager (say, ID = 10), report all regular employees that are
-- supervised by this manager. Display the employees ID, names, and salary.
SELECT E.ID, E.FNAME, E.LNAME, e.SALARY
FROM EMPLOYEE E
WHERE E.SUPERVISORID = 10 AND E.EMPRANK = 0;

------- Q3 ---------
-- For each patient, report the sum of amounts paid by the insurance company for that
-- patient, i.e., report the patients SSN, and the sum of insurance payments over all visits
SELECT P.PATIENTSSN, sum(INSURANCEPAYMENT) AS TotalInsurancePayout
FROM PATIENT P, ADMISSION A
WHERE P.PATIENTSSN = A.PATIENTSSN
GROUP BY P.PATIENTSSN;

------- Q4 ---------
--Report the number of visits done for each patient, i.e., for each patient, report the
--patient SSN, first and last names, and the count of visits done by this patient.
SELECT PatientSSN, PatientFName, PatientLName,
(SELECT COUNT(*) FROM Admission A WHERE A.PatientSSN = P.PatientSSN) AS NumberofVisits
FROM Patient P; WHERE

------- Q5 ---------

------- Q6 ---------

------- Q7 ---------

------- Q8 ---------

------- Q9 ---------

------- Q10 ---------

------- Q11 ---------

------- Q12 ---------