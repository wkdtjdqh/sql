GROUPING(column) : 0,1
0 : 컬럼이 소계 계산에 사용되지 않았다.(GROUP BY 컬럼으로 사용됨)
1 : 컬럼이 소계 계산에 사용되었다.

SELECT NVL(job,'총계') job, deptno,  SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);
#job컬럼이 소계계산으로 사용되어 null값이 나온 것인지, 정말 컬럼의 값이 null인 행들이 group by 된 것인지 알려면
GROUPING 함수를 사용해야 정확한 값을 알 수 있다.

##Grouping 함수를 사용하여 나타냄
SELECT DECODE(GROUPING(job), 0, job, 1, '총계') job, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);
##컬럼명이랑 동일한 Alias를 사용해도 가능

###NVL함수를 사용하지 않고 GROUPING함수를 사용해야 하는 이유
SELECT job, mgr, SUM(sal)
FROM emp
GROUP BY ROLLUP(job,mgr);
##king은 원래도 mgr값이 null이라 GROUP BY job, GROUP BY job,mgr 둘다 null이 나와서 구별이 불가능하다. 그래서 안쓰는게 맞음


--------------------------
실습2
SELECT DECODE(GROUPING(job),1,'총계',0,job) job, DECODE(GROUPING(deptno)+GROUPING(job),2,'계',1,'소계', 0, deptno) deptno, SUM(sal)
FROM emp
GROUP BY ROLLUP(job, deptno);
##이렇게 DECODE조건에 사칙연산을 이용하여 값을 직접 만들수도있다.
SELECT DECODE(GROUPING(job),1,'총계',0,job) job, DECODE(GROUPING(deptno)+GROUPING(job), 0, TO_CHAR(deptno), 1,'소계', 2, '계') deptno, SUM(sal)
  FROM emp
  GROUP BY ROLLUP(job, deptno);
실습3
SELECT deptno, job, SUM(sal+NVL(comm,0))
FROM emp
GROUP BY ROLLUP(deptno, job);

실습4
SELECT dname ,job, SUM(sal+NVL(comm,0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, job)
ORDER BY dname, job DESC;

인라인뷰로
SELECT d.dname, a.job, a.sal_sum
FROM(SELECT deptno, job, SUM(sal + NVL(comm,0)) sal_sum
     FROM emp
     GROUP BY ROLLUP(deptno, job))a,dept d
WHERE a.deptno = d.deptno(+);


실습5
SELECT DECODE(GROUPING(dname),1,'총합',0,dname) dname, job, SUM(sal+ NVL(comm,0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, job)
ORDER BY dname, job DESC

소계까지 나타내면
SELECT DECODE(GROUPING(dname),1,'총',0,dname) dname, DECODE(GROUPING(dname) + GROUPING(job), 2, '합', 1, '소계', 0, job) job, SUM(sal+ NVL(comm,0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, job)
ORDER BY dname, job DESC

확장된 GROUP BY
1. ROLLUP (2) - 컬럼 기술에 방향성이 존재
    GROUP BY ROLLUP(job, deptno) != GROUP BY ROLLUP(deptno, job)
    GROUP BY job, deptno             GROUP BY deptno, job
    GROUP BY job                     GROUP BY deptno
    GROUP BY ''                     GROUP BY ''
    단점: 개발자가 필요없는 서브 그룹을 임의로 제거할 수 없다.
    
2. GROUPING SETS (실무에서 많이 씀 1) - 필요한 서브그룹을 임의로 지정하는 형태
   ==> 복수의 GROUP BY를 하나로 합쳐서 결과를 돌려주는 형태, ROLLUP과는 다르게 컬럼 나열 순서가 데이터자체에 영향을 미치지 않음
    GROUP BY GROUPING SETS(col1,col2)
    GROUP BY col1
    UNION ALL
    GROUP BY col2
    
    GROUP BY col1, col2
    UNION ALL
    GROUP BY col1
    ==> GROUPING SETS((col1, col2), col1)

GROUPING SETS 실습
SELECT job, deptno, SUM(sal+NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS(job, deptno);

위쿼리를 UNION ALL로 풀어 쓰기

SELECT job, null deptno, SUM(sal+NVL(comm,0)) sal_sum
FROM emp
GROUP BY job
UNION ALL
SELECT null job,deptno, SUM(sal+NVL(comm,0)) sal_sum
FROM emp
GROUP BY deptno
-------------------------------------------------
SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS((job, deptno), mgr);

SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS(job, deptno, mgr);
##위에 쿼리와 아래쿼리는 다르다
    
-------------------------------------------------------------------    
3. CUBE (3 잘 안쓰긴하지만 시험에 잘나옴)
- CUBE절에 나열한 모든 가능한 조합으로 서브그룹을 생성
- 가능한 서브그룹은 2^기술한 컬럼 개수
- 기술한 컬럼이 3개만 넘어도 생성되는 서브그룹의 개수가 8개가 넘기 때문에
실제 필요하지 않은 서브 그룹이 포함될 가능성이 높아 ==>ROLLUP, GROUPING SETS보다 활용성이 떨어진다.

GROUP BY CUBE (job, deptno);

풀어서 쓰면(4가지)
GROUP BY job,deptno
GROUP BY job
GROUP BY deptno
GROUP BY 

SELECT job, deptno, SUM(sal + NVL(comm,0)) sum_sal
FROM emp
GROUP BY CUBE(job, deptno)


GROUP BY job, ROLLUP(deptno), CUBE(mgr)
==> 내가 필요로하는 서브그룹을 GROUPING SETS을 통해 정의하면 간단하게 작성 가능.
ROLLUP (deptno) : GROUP BY deptno
                  GROUP BY ''
CUBE(mgr) : GROUP BY mgr
            GROUP BY ''

GROUP BY job, deptno, mgr
GROUP BY job, deptno
GROUP BY job, mgr
GROUP BY job


SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY job, ROLLUP(deptno), CUBE(mgr);


SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY job, ROLLUP(job, deptno), CUBE(mgr);


1. 서브그룹 나누기
job, job, deptno  mgr
job, job, deptno
job, job, mgr
job, job
job, mgr
job


GROUP BY job, deptno, mgr
GROUP BY job, deptno
GROUP BY job, mgr (중복)
GROUP BY job (중복)



2.엑셀로 나누기


========================================================================
<실습1>
1. emp_test 테이블 삭제
 DROP TABLE emp_test;
 
2. emp테이블을 이용하여 emp_test테이블 생성 (모든행, 모든컬럼)
 CREATE TABLE emp_test AS
    SELECT *
    FROM emp
    WHERE 1 = 1;
    
3. emp_test테이블에 dname(VARCHAR2(14))컬럼을 추가
 ALTER TABLE emp_test ADD(dname VARCHAR2(14));
 
4. emp_test테이블에 dname 컬럼을 dept테이블에서 dname을 이용하여 UPDATE
UPDATE emp_test
SET dname = (SELECT dname
             FROM dept
             WHERE dept.deptno = emp_test.deptno);


<실습2>
1. dept_test 테이블 삭제
DROP TABLE dept_test

2. dept 테이블을 이용하여 dept_test 생성(모든행, 모든컬럼)
CREATE TABLE dept_test AS
SELECT *
FROM dept
WHERE 1 = 1;

3. dept_test 테이블에 empcnt(NUMBER) 컬럼을 추가
ALTER TABLE dept_test ADD(empcnt NUMBER);

4. subquery를 이용하여 dept_test 테이블의 empcnt 컬럼을 해당 부서원수를 emp테이블을 이용하여 update실행
UPDATE dept_test 
SET empcnt = (SELECT COUNT(*)
              FROM emp
              WHERE emp.deptno = dept_test.deptno);
              
COMMIT;

SELECT *
FROM dept_test




