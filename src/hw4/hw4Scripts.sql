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

