SELECT PATIENTSSN, PATIENTFNAME, PATIENTLNAME, PATIENTADDRESS
FROM PATIENT
WHERE PATIENTSSN = '124-12-4545';

SELECT DOCTOR.EMPLOYEEID, GENDER, SPECIALTY, GRADUATEDFROM, FName, LNAME
FROM DOCTOR, EMPLOYEE
WHERE EMPLOYEEID = 1 AND ID = 1 AND JOBTITLE = 'Doctor';

--When the user enters a number, the program should query the admission table and print
-- on the screen the following information, and then terminate:

SELECT ADMISSIONNUM, PATIENTSSN, ADMISSIONDATE, TOTALPAYMENT
FROM ADMISSION
WHERE ADMISSIONNUM = 1;

SELECT ROOMNUM, STARTDATE, ENDDATE FROM STAYIN WHERE ADMISSIONNUM = 1;

SELECT DOCTORID FROM EXAMINE WHERE ADMISSIONNUM = 1;


/*Updating Admission Payment” mode. The program should
print out the following line:
Enter Admission Number: <and wait for user’s input>
Enter the new total payment: <and wait for user’s input>
Then your program should update the total payment value for the specified admission
number in the database.
//Now if you execute option 3 again, you should get the new payment value
*/

UPDATE ADMISSION SET TOTALPAYMENT = 10000.00 WHERE ADMISSIONNUM = 1;













