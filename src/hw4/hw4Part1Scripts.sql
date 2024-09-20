-- Eric Li - CS3431 HW4

-- PROBLEM 1
-- 1. find the name and ages of each employee work in both Hardware and software
-- We can essentially do a giant theta join and project the name and age from that
-- SELECT e.ENAME, e.AGE, d1.DNAME, d2.DNAME
SELECT e.ENAME, e.AGE
FROM "Emp" e, "Works" w1, "Works" w2, "Dept" d1, "Dept" d2
WHERE e.EID = w1.EID AND w1.DID = d1.DID AND d1.DNAME ='Software'
AND  e.EID = w2.EID AND w2.DID = d2.DID AND d2.DNAME ='Hardware';

--
-- 2. For each department with more than 10 full-time-equivalent employees (i.e., where the
-- part-time and full-time employees add up to at least that many full-time employees – see
-- below for details) and print the department ID (did) together with the number of
-- employees that work in that department.

SELECT W.DID, count(W.EID)
FROM "Works" W
GROUP BY W.DID -- this is fine becuause we grouped by it
HAVING 1000 <= (SELECT SUM(W1.PCT_TIME)
        FROM "Works" W1
        WHERE W1.DID = W.DID);

--3. Retrieve the name of each employee whose salary exceeds the budget for each of the
-- departments that they work in. For example, if employee A has salary 5 and employee B
-- has salary 2 and both work in departments X (budget=1) and Y (budget=4), then this
-- query would return only employee A.
SELECT E.ename
FROM "Emp" E, "Dept" D,"Works" W
WHERE E.EID = W.EID AND W.DID = D.DID AND E.SALARY > D.BUDGET;

-- 4.
SELECT DISTINCT D.MANAGERID
FROM "Dept" D
WHERE D.budget > 1000000;

-- 5.5. Find the enames of manager(s) who manage the department(s) with the largest budget(s).
-- For example, if employee A manages a department with a budget of 2,
-- employee B manages a department with a budget of 2,
-- and employee C manages a department with a budget of 1,
-- this should display A and B.

SELECT E.ename
FROM "Emp" E
WHERE E.EID IN (SELECT D.MANAGERID
                FROM "Dept" D
                WHERE D.BUDGET = (SELECT MAX(D2.BUDGET)
                FROM "Dept" D2));

