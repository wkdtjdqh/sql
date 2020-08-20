SQL-응용 : DML(SELECT, UPDATE, INSERT, MERGE)

1. Multiple Insert ==> 많이 사용하는 편은 아님 왜냐? 중복이 되기 때문에
한번의 INSERT 구문을 통해 여러 테이블에 데이터를 입력, 
RDBMS :데이터의 중복을 최소화
실 사용 ex) 1. 실제 사용할 테이블과 별개로 보조 테이블에도 동일한 데이터 쌓기
           2. 데이터의 수평분할(*)
                주문 테이블
                2020년 데이터 ==>TB_ORDER_2020
                2021년 데이터 ==>TB_ORDER_2021
                ==> 오라클 PARTITION 을 통해 더 효과적으로 관리 가능 (정식버전)
                    하나의 테이블안에 데이터 값에 따라 저장하는 물리공간
                    :개발자 입장에서는 데이터를 입력하면 데이터 값에 따라 물리적인 공간을 오라클이 알아서 나눠서 저장
MULTIPLE INSERT 종류
1. unconditional insert : 조건과 관계없이 하나의 데이터를 여러 테이블 입력
2. conditional all insert : 조건을 만족하는 모든 테이블에 입력
3. conditional first insert : 조건을 만족하는 첫번째 테이블에 입력

ex)
emp_test, emp_test2 drop
emp테이블의 empno컬럼이랑 ename컬럼만 갖고 emp_test, emp_test2를 생성 단 데이터를 복사하지 않음

DROP TABLE emp_test

CREATE TABLE emp_test2 AS
SELECT empno, ename
FROM emp
WHERE 1 != 1;

unconditional insert

아래 두개의 행을 emp_test, emp_test2에 동시 입력, 하나의 insert구문 사용
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual;

INSERT ALL
    INTO emp_test VALUES(empno, ename)
    INTO emp_test2 (empno) VALUES (empno)
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual;
##emp_test는 empno와 ename, emp_test2에는 empno만 들어감.


2. condition insert
ROLLBACK;
조건 분기 문법 : CASE WHEN THEN END
조건 분기 함수 : DECODE

##부서번호가 9999와 같거나 크면 emp_test테이블에 , 작으면 emp_test2테이블에 삽입
ROLLBACK;

INSERT ALL
    WHEN empno >= 9999 THEN
      INTO emp_test VALUES(empno, ename)
    ELSE
      INTO emp_test2 (empno) VALUES (empno)
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual;


##부서번호가 9999와 같거나 크면 emp_test테이블에 ,9998보다 같거나 크면 emp_test2테이블에 삽입
 결과  : emp_test -> 9999번 행 하나
        emp_test2 -> 9999번, 9998번 2행
ROLLBACK;

INSERT ALL
    WHEN empno >= 9999 THEN
      INTO emp_test VALUES(empno, ename)
    WHEN empno >= 9998 THEN
      INTO emp_test2 VALUES(empno, ename)
    ELSE
      INTO emp_test2 (empno) VALUES (empno)
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual;



3.conditional first insert
ROLLBACK;

INSERT FIRST
    WHEN empno >= 9999 THEN
      INTO emp_test VALUES(empno, ename)
    WHEN empno >= 9998 THEN
      INTO emp_test2 VALUES(empno, ename)
    ELSE
      INTO emp_test2 (empno) VALUES (empno)
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual;

 
=============================================================================
merge 
1.사용자로부터 받은 값을 갖고
테이블 저장 or 수정
입력받은 값이 테이블에 존재하면 수정을 하고 싶고
입력받은 값이 테이블에 존재하지 않으면 신규 입력 하고 싶을 때
ex : empno 9999, ename 'brown'
emp테이블에 동일한 empno가 있으면 ename을 업데이트
emp테이블에 동일한 empno가 없으면 신규 입력

merge구문을 사용하지 않는다면
1. 해당 데이터가 존재하는지 확인하는 SELECT 구문을 실행
2. 1번 쿼리의 조회 결과 있으면 
    2.1 UPDATE
3. 1번 쿼리의 조회 결과 없으면
    3.1 INSERT

SELECT *
FROM emp
WHERE empno = 9999;

2. UPDATE emp SET ename = 'brown'
    WHERE empno = 9999;

3. INSERT INTO emp (empno, ename) VALUES ( 9999, 'brown');


2. 테이블의 데이터를 이용하여 다른 테이블의 데이터를 업데이트 OR INSERT 하고 싶을 때 
   ALLEN의 job과 smith사원과 동일하게 업데이트하시오
UPDATE emp SET job = (SELECT job FROM emp WHERE ename = 'SMITH'),
                deptno = (SELECT job FROM emp WHERE ename = 'SMITH')
WHERE ename = 'ALLEN';
## 일반 업데이트 구문에서는 서브쿼리가 두번들어가기도 해서 비효율 적임.


문법
MERGE INTO 테이블명(덮어 쓰거나, 신규로 입력할 테이블) AS(테이블 별칭)
USING ( 테이블명 | view | inline-view ) AS(별칭)
  ON ( 두 테이블간 데이터 존재여부를 확인할 조건)
WHEN MATCHED THEN 
    UPDATE SET 컬럼1 = 값1,
               컬럼2 = 값2,
WHEN NOT MATCHED THEN
    INSERT(컬럼1, 컬럼2....) VALUES( 값1, 값2...)

ROLLBACK;


1. 7369사원의 데이터를 emp_test로 복사(empno, ename)
INSERT INTO emp_test
SELECT empno, ename
FROM emp
WHERE empno = 7369;

emp : 14, emp_test : 1 (7369 - emp 테이블에도 존재)
emp테이블을 이용하여 emp_test에 동일한 empno 값이 있이면 emp_test.ename 업데이트
 동일한 empno값이 없으면 emp테이블의 데이터를 신규입력
 
 MERGE INTO emp_test a
 USING emp b 
  ON (a.empno = b.empno)
WHEN MATCHED THEN
    UPDATE SET a.ename = b.ename || '_m'
WHEN NOT MATCHED THEN
    INSERT (empno, ename) VALUES (b.empno, b.ename);

SELECT *
FROM emp_test;

결과 : emp_test 테이블에는 7369사원의 이름이 'm'으로 업데이트, 7369를 제외한 13명의 사원이 insert

##merge에서 많이 사용하는 형태
사용자로부터 받은 데이터를 emp _test테이블에 동일한 데이터 존재 유무에 따른 merge
시나리오 : 사용자 입력 empno = 9999, ename = brown

MERGE INTO emp_test
USING dual
   ON (emp_test.empno = :empno)
WHEN MATCHED THEN
    UPDATE SET ename = :ename
WHEN NOT MATCHED THEN
    INSERT VALUES(:empno, :ename);

SELECT *
FROM emp_test

SELECT *
FROM dept_test2

실습 : dept_test3 테이블을 dept 테이블과 동일하게 생성, 단 10, 20번 부서 데이터만 복제

dept 테이블을 이용하여 dept_test3 테이블에 데이터를  merge
*머지 조건 : 부서번호가 같은 데이터
 동일한 부서가 있을 때 : 기존 loc컬럼의 값 + '_m'로 업데이트
 동일한 부서가 없을 때 : 신규 데이터 입력
 
 DROP TABLE dept_test3;
 
 CREATE TABLE dept_test3 AS
 SELECT *
 FROM dept
 WHERE deptno IN (10, 20);
 
 SELECT *
 FROM dept_test3
 
MERGE INTO dept_test3 dt
USING dept d
   ON (dt.deptno = d.deptno)
WHEN MATCHED THEN 
   UPDATE SET dt.loc = d.loc || '_m'
WHEN NOT MATCHED THEN
    INSERT VALUES (d.deptno, d.dname, d.loc);
--------------------------------------------------------------------------------------

실습2 : 사용자 입력받은 값을 이용한 meerge
 사용자 입력 : deptno  : 9999, dname : 'ddit', loc:'daejeon'
 detp_test3 테이블에 사용자가 입력한 deptno 값과
 동일한 데이터가 있을 경우  : 사용자가 입력한 dname, loc값으로 두개 컬럼 업데이트
 동일한 데이터가 없을 경우 : 사용자가 입력한 deptno, dname, loc값으로 인설트
 
MERGE INTO dept_test3 dt
USING dual d
   ON (dt.deptno = :deptno)
WHEN MATCHED THEN 
  UPDATE SET dt.dname = :dname, dt.loc = :loc
WHEN NOT MATCHED THEN
 INSERT VALUES (:deptno, :dname, :loc);
 
-=====================================================================================
GROUP FUNCTION 응용, 확장


SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno
UNION ALL
SELECT null, SUM(sal)
FROM emp
ORDER BY deptno;
##이렇게 하면 emp 테이블을 두번이나 읽어야 되서 불합리적임

##emp 테이블을 한번만 사용하면서 구하기 
SELECT DECODE(rn, 1, deptno, 2, null) deptno, SUM(sum_sal)
FROM      
    (SELECT deptno, SUM(sal) sum_sal
    FROM emp
    GROUP BY deptno) a,
    (SELECT ROWNUM rn
    FROM dept
    WHERE ROWNUM <=2) b
GROUP BY DECODE(rn, 1, deptno, 2, null)
ORDER BY deptno;
##그래서 행 2개 이상인 테이블을 이용하여 행 갯수만 가져오도록 
SELECT deptno, SUM(sal)

FROM emp
GROUP BY ROLLUP(deptno);
##GROUP BY ROLLUP 기능을 사용하면 쉽게 구할 수 있으나 모든 프로그램에서 지원하는건 아님 

================================================================
ROLLUP : 1.GROUP BY의 확장 구문
         2. 정해진 규칙으로 서브 그룹을 생성하고 생성된 서브 그룹을 하나의 집합으로 반환
         3. GROUP BY ROLLUP (col1, col2 ....)
         4. ROLLUP 절에 기술된 컬럼을 오른쪽에서 부터 하나씩 제거해가며 서브 그룹을 생성
           GROUP BY ROLLUP (job, deptno)
           GROUP BY ROLLUP (deptno, job)
           ROLLUP의 경우 방향성이 있기 때문에 컬럼 기술 순서가 다르면 다른결과가 나온다.
           
예시 : GROUP BY ROLLUP (deptno)
1. GROUP BY deptno ==> 부서번호별 총계
2. GROUP BY ''==> 전체 총계

예시 : GROUP BY ROLLUP (job, deptno)
1. GROUP BY job, detpno ==> 담당업무, 부서번호별 총계
2. GROUP BY job ==> 담당업무별 총계
3 .GROUP BY ''==> 전체 총계

* ROLLUP을 사용했을 때 SUBGROUP의 개수는 : n+1 개의 서브 그룹이 생성

SELECT job, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);


SELECT job, deptno, GROUPING(job), GROUPING(deptno), SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);

SELECT DECODE(GROUPING(job), 0, job, 1, '총계') job, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);

SELECT DECODE(job, null, '총계', job) job, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);


SELECT job, null, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY job;




    