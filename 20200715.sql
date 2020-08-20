오라클 객체(object)
table - 데이터 저장 공간
    -ddl 생성, 수정, 삭제
view - sql(쿼리다) 논리적인 데이터 정의, 실체가 없다
        view 구성하는 테이블의 데이터가 변경되면 view결과도 달라진다
sequence - 중복되지 않는 장수값을 반환해주는 객체
            유일한 값이 필요할 때 사용할 수 있는 객체
            nextval, currval
index - 테이블의 일부 컬럼을 기준으로 미리 정렬해 놓은 데이터
    ==> 테이블 없이 단독적으로 생성 불가, 특정 테이블에 종속
        table 삭제를 하면 index도 같이 삭제됨

DATE - 7 byte
'YYYYMMDD'문자열로 나타내면 - 8byte

oracle db data structure -> pt보고정리

DB 구조에서 중요한 전제 조건
1. DB에서 I/O의 기준은 행단위가 아니라 block단위
    한건의 데이터를 조회하더라도, 해당 행이 존재하는 block전체를 읽는다.
    
    데이터 접근 방식
    1.table full access (항상 나쁜 방식은 아님)
    multi block io ==> 읽어야 할 블럭 여러개를 한번에 읽어 들이는 방식
                        (일반적으로 8~16 block)
    사용자가 원하는 데이터의 결과가 table의 모든 데이터를 다 읽어야 처리가 가능한경우
    ==>인덱스보다 여러 블럭을 한번에 많이 조회하는 table full access방식이 유리 할 수 있다.
    ex :
    전제조건은 mgr, sal, comm컬럼으로 인덱스가 없을 때
    mgr, sal, comm정보를 table에서만 획득이 가능할 때
    SELECT COuNT(mgr), SUM(sal), SUM(comm), AVG(sal)
    FROM emp;
    
    
    2. index접근, index 접근후 table access
    single block io => 읽어야 할 행이 있는 데이터 block만 읽어서 처리하는 방식
    소수의 몇건 데이터를 사용자가 조회할 경우, 그리고 조건에 맞는 인덱스가 존재할 경우
    빠르게 응답을 받을 수 있다.
    하지만 single block io가 빈번하게 일어나면 multi block io보다 느리다.

2. extent,공간할당 기준


====================================================================================

현재상태
인덱스 : IDK_NU_emp_01 (empno)

emp 테이블의 job컬럼을 기준으로 2번째 NON-UNIQUE 인덱스 생성
CREATE INDEX idx_nu_emp_02 ON emp (job);

현재상태
인덱스 : IDK_NU_emp_01 (empno), idx_nu_emp_02 ON emp (job);
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT job, rowid
FROM emp
ORDER BY job; -> 현재 job컬럼에 null값이 있는데 null값이 있으면 인덱스에 저장을 안함. (index에 null관리를 안해줌)
                    인덱스 구성 컬럼 전체가 null일때는 인덱스에 저장을 안함.
                    만약 인덱스는 job을 기준으로 만들고 

SELECT * 
FROM emp

SELECT *
FROM TABLE(dbms_xplan.display);

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_02 |     3 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" LIKE 'C%')
   2 - access("JOB"='MANAGER')
------------------------------------------------
실행 순서 2 - 1 - 0
MANAGER 의 인덱스 값을 빠르게 찾아서 MANAGER가 끝나는 부분 까지 총 4건의 데이터를 찾은 후 테이블에 접근을 해서 MANAGER에 해당하는 총 3건중 'C%'가 있나 찾는 형태 
===========================================================

인덱스 추가 생성
emp 테이블의 job, ename 컬럼으로 복합 non-unique index생성
idx_nu_emp_03
CREATE INDEX idx_nu_emp_03 ON emp (job, ename);
현재상태
인덱스 : IDK_NU_emp_01 (empno), idx_nu_emp_02 ON emp (job),idx_nu_emp_03(job,ename)
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job ='MANAGER'
AND ename LIKE 'C%'

SELECT job, ename, ROWID
FROM emp
ORDER BY job, ename

SELECT *
FROM TABLE(dbms_xplan.display);

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       filter("ENAME" LIKE 'C%')
---------------------------------------------------
실행순서 2-1-0
INDEX정렬이 manager, ename으로 되어 있으니까 바로 manager이고 이름이 c로 시작하는 데이터를 찾은 후 1건의 데이터를 가지고 테이블로 접근

위에 쿼리와 변경된 부분은 LIKE 패턴이 변경
LIKE 'C%' -> LIKE '%C'

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job ='MANAGER'
AND ename LIKE '%C'

SELECT *
FROM TABLE(dbms_xplan.display);

| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER')
       filter("ENAME" LIKE '%C' AND "ENAME" IS NOT NULL)

## 이건 위에 쿼리와 다르게 C로 시작이 아니라 C로 끝나는 거라 일단 인덱스에선 job이 manager인거를 찾고 그다음 ename이 c로 끝나는걸 찾았는데
    해당하는게 없어서 테이블로 접근 안하고 거기서 끝
    
=====================================
인덱스 추가
emp테이블에 ename, job 컬럼을 기준으로 non-unique 인덱스 생성(idx_nu_emp_04)
CREATE INDEX idx_nu_emp_04 ON emp (ename, job)
현재상태
인덱스 : IDK_NU_emp_01 (empno), idx_nu_emp_02 ON emp (job),
        idx_nu_emp_03(job,ename),idx_nu_emp_04(ename, job)


복합컬럼의 인덱스 순서가 미치는 영향
EXPLAIN PLAN FOR
SELECT ename, job, rowid
FROM emp
WHERE job = 'MANAGER'
 AND ename LIKE 'C%';
 
SELECT *
FROM TABLE(dbms_xplan.display);

| Id  | Operation        | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |               |     1 |    26 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_NU_EMP_03 |     1 |    26 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       filter("ENAME" LIKE 'C%')
=====================================================================
       
3번쨰 인덱스를 지우고 테스트 (4번 인덱스 사용) 
DROP INDEX idx_nu_emp_03;

| Id  | Operation        | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |               |     1 |    26 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_NU_EMP_04 |     1 |    26 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("ENAME" LIKE 'C%' AND "JOB"='MANAGER')
       filter("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       
==========================================================================
JOIN에서의 인덱스

ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY(empno);
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept(deptno);

접근방식 : emp 1.table full access, 2.인덱스 * 4방법 : 방법5가지 존재
        dept 1.table full access, 2.인덱스 * 1방법 : 방법2가지 존재
        가능한 경우의 수가 10가지
        방향성 emp, dept를 먼저 처리할지 ==> 20가지
EXPLAIN PLAN FOR
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno
    AND emp.empno = 7788;
    
SELECT *
FROM TABLE(dbms_xplan.display);

-----------------------------------------------------------------------------------------------
| Id  | Operation                     | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |               |     1 |    55 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |               |       |       |            |          |
|   2 |   NESTED LOOPS                |               |     1 |    55 |     2   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     1   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_NU_EMP_01 |     1 |       |     0   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN          | PK_DETP       |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT          |     5 |    95 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter("EMP"."DEPTNO" IS NOT NULL)
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
-----------------------------------------------------
실행순서 4 - 3 - 5 - 2 - 6 - 1 - 0
## NESTED LOOPS -> 내가 했던 행동을 반복하겠다.
## 실행 계획에서는 

EXPLAIN PLAN FOR
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno
    
SELECT *
FROM TABLE(dbms_xplan.display);
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |    13 |   715 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |         |    13 |   715 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     5 |    95 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | PK_DETP |     5 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |         |    14 |   504 |     4  (25)| 00:00:01 |
|*  5 |    TABLE ACCESS FULL         | EMP     |    14 |   504 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
       filter("EMP"."DEPTNO"="DEPT"."DEPTNO")
   5 - filter("EMP"."DEPTNO" IS NOT NULL)
---------------------------------------------------
실행순서 3 - 2 - 5 - 4 - 1 - 0;

테이블에 인덱스가 있다면 - pt보고 정리
b*트리 -> 벨런스 트리


<실습>
구문으로 DEPT_TEST2 테이블 생성후 다음 조건에 맞는 인덱스를 생성
CREATE TABLE dept_test2 AS
SELECT *
FROM dept
WHERE 1=1

1. deptno컬럼을 기준으로 unique 인덱스 생성
idx_nu_emp_04
ALTER TABLE dept_test2 ADD CONSTRAINT u_dept_test2 UNIQUE (deptno)
CREATE UNIQUE INDEX idx_u_dept_test2_01 ON dept_test2 (deptno);
CREATE INDEX idx_nu_dept_test2_02 ON dept_test2 (dname);
CREATE INDEX idx_nu_dept_test2_03 ON dept_test2 (deptno, dname);

DROP INDEX idx_u_dept_test2_01;
DROP INDEX idx_u_dept_test2_02;
DROP INDEX idx_u_dept_test2_03;



<실습2>
CREATE TABLE emp_test3 AS
SELECT *
FROM emp
WHERE 1=1

CREATE INDEX idx_nu_emp_test3_01 ON emp_test3(empno, deptno, mgr);
CREATE INDEX idx_nu_emp_test3_02 ON emp_test3(ename);
CREATE INDEX idx_nu_emp_test3_03 ON emp_test3(deptno, sal);

DROP INDEX idx_nu_emp_test3_02;

SELECT *
FROM emp



1. empno(=)
2. ename(=)
3. deptno(=), empno (LIKE)
4. deptno(=), sal
5. deptno(=)
   empno(=)
6. deptno, hiredate 컬럼으로 구성된 인덱스가 있을 경우 table 접근이 필요 없음.

empno
ename
deptno, empno, sal, hiredate

emp테이블에 데이터가 5천만건
10, 20, 30 데이터는 각각 50건씩만 존재 ==> 인덱스가 유리
40번데이터 4850만건 ==> table full access




===========================================================================
DDL(Synonym)

GRANT CREATE SYNONYM TO hr; ==> hr계정에 synonym 생성권한줌.

hr 계정 테스트
SELECT *
FROM JW.v_emp;

JW.v_emp 을 v_emp 시노님을 생성

CREATE SYNONYM v_emp FOR JW.v_emp;

SELECT *
FROM v_emp;

SYNONYM : 오라클 객체체 별칭을 생성
JW.v_emp ==> v_emp

생성방법
CREATE SYNONYM 시노님이름 FOR 원본객체이름;
CREATE [PUBLIC] SYNONYM 시노님이름 FOR 원본객체이름;
        PUBLIC => 모든 사용자가 사용할 수 있는 시노님. 권한이 있어야 생성가능
        PRIVATE [DEFAULT] => 해당 사용자만 사용할 수 있는 시노님

삭제방법
DROP SYNONYM 시노님이름;



   