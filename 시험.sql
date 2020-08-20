1.
SELECT ename, hiredate
FROM emp
WHERE hiredate >= TO_DATE('19820101','YYYYMMDD') AND hiredate <= TO_DATE('19830101','YYYYMMDD');

2.
SELECT *
FROM emp
WHERE job = 'SALESMAN'
  AND hiredate >= TO_DATE('19810601','YYYYMMDD');
  
3.
SELECT *
FROM emp
WHERE deptno NOT IN(10)
  AND hiredate >= TO_DATE('19810601','YYYYMMDD');

4.
SELECT ROWNUM, a.*
FROM
(SELECT empno, ename
FROM emp
ORDER BY empno)a;

5.
SELECT *
FROM emp
WHERE deptno IN (10,30) AND sal > 1500
ORDER BY ename DESC;

6.
SELECT deptno, MAX(sal) max_sal, MIN(sal) min_sal, ROUND(AVG(sal), 2) avg_sal
FROM emp
GROUP BY deptno;

7.
SELECT empno, ename, sal, emp.deptno, dname
FROM emp, dept
WHERE sal > 2500 
  AND empno > 7600
  AND dname = 'RESEARCH'
  AND emp.deptno = dept.deptno;

8. 
SELECT empno, ename, e.deptno, dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
  AND e.deptno IN (10,30);

9.
SELECT b.ename, (SELECT ename FROM emp WHERE b.mgr = empno) mgr
FROM emp a, emp b
WHERE a.empno(+) = b.mgr
ORDER BY a.empno


10.
SELECT TO_CHAR(hiredate,'YYYYMM') hire_yyyymm, COUNT(*)
FROM emp
GROUP BY TO_CHAR(hiredate,'YYYYMM');

11.
SELECT *
FROM emp 
WHERE deptno IN (SELECT deptno
                 FROM emp
                 WHERE ename = 'SMITH'
                   OR ename = 'WARD');

12.
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp)
             
13.
INSERT INTO dept VALUES(99,'ddit','대전');

14.
UPDATE dept SET dname = 'ddit_modi', loc = '대전_modi'
WHERE deptno = 99;

15.
DELETE dept
WHERE deptno = 99;

16.
CREATE TABLE emp(
 empno NUMBER(4) PRIMARY KEY,
 ename VARCHAR2(10),
 job VARCHAR2(9),
 mgr NUMBER(4),
 hiredate DATE,
 sal NUMBER(7,2),
 comm NUMBER(7,2),
 deptno NUMBER(2) REFERENCES dept(deptno)
 );

CREATE TABLE dept(
 deptno NUMBER(2) PRIMARY KEY,
 dname VARCHAR2(14),
 loc VARCHAR2(13)
 ); 


17.
SELECT deptno, SUM(sal)
FROM emp
GROUP BY ROLLUP(deptno)

18.
SELECT empno, ename, hiredate, sal, RANK() OVER(PARTITION BY deptno ORDER BY sal DESC, hiredate)
FROM emp


19.
SELECT empno, ename, hiredate, sal, LEAD(sal) OVER(ORDER BY sal DESC, hiredate) lead_sal
FROM emp

20.
SELECT empno, ename, sal, SUM(sal) OVER( ORDER BY sal ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) c_sum
FROM emp