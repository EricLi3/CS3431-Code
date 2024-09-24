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

SELECT P.PATIENTSSN, P.PATIENTFNAME, P.PATIENTTELNUM, count(ADMISSIONNUM)
FROM Patient P, Admission A
Where P.PATIENTSSN = A.PatientSSN
GROUP BY P.PATIENTSSN, P.PATIENTFNAME, P.PATIENTTELNUM;

------- Q5 ---------
--Report the room number that has an equipment unit with serial number ‘A01-02X’.
SELECT E.ROOMNUMBER
FROM EQUIPMENT E
WHERE E.SERIALNUM = 'A01-02X';


------- Q6 ---------
-- Report the employee who has access to the largest number of rooms.
-- We need the employee ID, and the number of rooms they can access.
-- Note: If there are several employees with the same maximum number, then report all of these employees.
SELECT RoomAccess.EmployeeID, COUNT(RoomAccess.RoomNum) AS RoomCount
FROM RoomAccess
GROUP BY RoomAccess.EmployeeID
HAVING COUNT(RoomAccess.RoomNum) = (
    SELECT MAX(RoomCount)
    FROM (SELECT COUNT(RoomNum) AS RoomCount
          FROM RoomAccess
          GROUP BY EmployeeID)
);

------- Q7 ---------
-- Report the number of regular employees, division managers, and general managers in
-- the hospital.
SELECT
    CASE  -- For Type Column
        WHEN empRank = 0 THEN 'Regular Employees'
        WHEN empRank = 1 THEN 'Division Managers'
        WHEN empRank = 2 THEN 'General Managers'
        END AS Type,

    COUNT(*) AS Count -- For Count Column
FROM Employee
GROUP BY empRank
ORDER BY empRank;

------- Q8 ---------
--For patients who have a scheduled future visit (which is part of their most recent visit),
--report that patient's SSN, first name, and last name, and the visit date.
--Do not report patients who do not have a scheduled visit.
SELECT P.PATIENTSSN, P.PATIENTFNAME, P.PATIENTLNAME,A.ADMISSIONDATE
FROM Admission A, Patient P
WHERE P.PatientSSN = A.PatientSSN
  AND A.FutureVisitDate IS NOT NULL;

------- Q9 ---------
--Report all equipment types that have less than two technicians that can maintain them.
SELECT EQUIPMENTTYPE
FROM CANREPAIREQUIPMENT
GROUP BY EQUIPMENTTYPE
HAVING Count(EMPLOYEEID) < 2;

------- Q10 ---------

------- Q11 ---------

------- Q12 ---------
SELECT TYPEID
FROM EQUIPMENT
WHERE purchaseyear = 2010
INTERSECT
SELECT TYPEID
FROM EQUIPMENT
WHERE purchaseyear = 2011;
