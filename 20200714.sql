DDL 
 오라클 객체
 1. table : 데이터를 저장할 수 있는 공간
    - 제약조건
    NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK
 2. VIEW : SQL ==> 실제 데이터가 존재하는 것이 아님
            논리적인 데이터 집합의 정의
    * VIEW TABLE 잘못된 표현
     IN-LINE VIEW

VIEW 생성 문법
CREATE              TABLE
CREATE              INDEX
CREATE [OR REPLACE] VIEW 뷰이름 [column1, column2...] AS
OR REPLACE -> 같은 이름의 뷰가 있으면 이걸로 업데이트 해라


emp테이블에서 급여 정보인 sal, comm컬럼을 제외하고 나머지 6개 컬럼만 조회할 수 있는 SELECT 쿼리를 v_emp 이름의 view로 생성

CREATE OR REPLACE VIEW v_emp AS
SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp;
오류 보고 -
ORA-01031: insufficient privileges ==> 불충분한 권한 이다.

JW계정에게 VIEW를 생성할 수 있는 권한 부여 : system계정에서 JW계정으로 VIEW만드는 권한 주기.
GRANT CREATE VIEW TO JW; 

오라클 view객체를 생성하여 조회
SELECT *
FROM v_emp;

inline view를 이용하여 조회
SELECT *
FROM (SELECT empno, ename, job, mgr, hiredate, deptno
        FROM emp)


view 객체를 통해 얻을 수 있는 이점
1. 코드를 재사용 할 수 있다
2. SQL 코드가 짧아진다.

hr계정에게 emp 테이블이 아니라 v_emp에 대한 접근권한 부여 -> hr계정에서는 emp테이블의 sal, comm컬럼을 볼 수가 없다.
==> 급여정보에 대한 부분을 비관련자로 부터 차단을 할 수가있다.


GRANT SELECT ON v_emp TO hr;

hr계정으로 접속하여 테스트
v_emp view는 JW계정이 hr계정에게 SELECT 권한을 주었기 때문에 정상적으로 조회가능
SELECT *
FROM JW.v_emp;
emp는 hr계정에게 SELECT 권한을 준적이 없어서 에러
SELECT *
FROM JW.emp;

1. emp테이블에서 신규 사원을 입력 (기존 15건, 추가되어 16건)
2. SELECT *
   FROM v_emp;결과가 몇 건일까? 16건 ==> view는 실체가 없는 데이터 집합을 정의하는 SQL이기 때문에 해당 SQL에서 사용하는 
                                        테이블의 데이터가 변경되면 view 에도 영향을 미친다.
                                        

view는 SQL이기 때문에 조인된 결과나, 그룹함수를 적용하여 행의 건수가 달라지는 SQL도 view로 생성하는 것이 가능.
emp, dept 테이블의 경우 업무상 자주 같이 쓰일수 밖에 없는 테이블
부서명, 사원번호, 사원이름, 담당업무, 입사일자
다섯개의 컬럼을 갖는 view를 v_emp_dept로 생성

CREATE OR REPLACE VIEW v_emp_dept AS
SELECT dname, emp.empno, ename, job, hiredate
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELECT *
FROM v_emp_dept

=====================================================================================
SEQUENCE : 중복되지 않는 정수값을 반환해주는 오라클 객체
    시작값( default 1, 혹은 개발자가 설정가능) 부터 1씩 순차적으로 증가한 값을 반환한다.

문법
CREATE SEQUENCE 시퀀스 명;
[옵션...]

seq_emp 이름으로 SEQUENCE 생성
CREATE SEQUENCE seq_emp;

시퀀스 객체를 통해 중복되지 않는 값을 조회
시퀀스 객체에서 제공하는 함수
1.nextval (next value)
    시퀀스 객체의 다음 값을 요청하는 함수
    함수를 호출하면 시퀀스 객체의 값이 하나 증가하여 다음번 호출시 증가된 값을 반환하게 된다.
2.currval (current value)
    nextval함수를 사용하고 나서 사용할수 있는 함수
    nextval함수를 통해 얻은 값을 다시 확인 할 때 사용
    시퀀스 객체가 다음에 리턴할 값에 대해 영향을 미치지 않음


nextval 사용하기전에 currval 사용한 경우 ==> 에러

SELECT seq_emp.currval
FROM dual


nextval 사용한 후 currval 사용한 경우
SELECT seq_emp.nextval
FROM dual

SELECT seq_emp.currval
FROM dual

##이진탐색(정렬을 해놓은 상태에서만 사용가능)
##다이너리 트리
======================================================

테이블 :정령이 안되어있음 (집합) ==> ORDER BY

emp테이블에서 emobo =7698인 데이터를 조회
EXPLAIN PLAN FOR
SELECT*
FROM emp
WHERE empno = 7698;


SELECT *
FROM TABLE (dbms_xplan.display);


ROWID 특수컬럼 : 행의 주소
( c언어 : 포인터
java : TV tv = new TV();) 참조형처럼 주소를 저장

SELECT ROWID, emp.*
FROM emp
WHERE empno = 7698;

ROWID값을 알고 있으면 테이블에 빠르게 접근 하는 것이 가능
SELECT *
FROM emp
WHERE ROWID = 'AAAE5gAAFAAAACNAAF';

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE ROWID = 'AAAE5gAAFAAAACNAAF';
-----------------------------------------------------------------------------------
| Id  | Operation                  | Name | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |      |     1 |    36 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY USER ROWID| EMP  |     1 |    36 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------
##TABLE ACCESS BY USER ROWID : 한건의 데이터를 조회하기 위해서 전체를 다 본것이아니라 사용자가 지정해준 ROWID로 한건을 읽음.

===================================================================

INDEX : 눈으로 보이는 것이 아님

ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY(empno);
ALTER TABLE dept ADD CONSTRAINT pk_detp PRIMARY KEY(deptno);
ALTER TABLE emp ADD CONSTRAINT FK_emp FOREIGN KEY (deptno) REFERENCES dept (deptno);

emp 테이블에 pk_emp PRIMARY KEY 제약조건을 통해 EMPNO 컬럼으로 인덱스 생성이 되어 있는 상태
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7698;
​

SELECT *
FROM TABLE (dbms_xplan.display);

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    36 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    36 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7698)  ## 바로 접근했다
----------------------------------------------------
실행계획을 읽는 순서 2 - 1 - 0

emp 테이블에 primary key 제약조건을 생성하고 나서 변경된 점
 * 오라클 입장에서는 데이터를 조회할 때 사용할 수 있는 전략이 하나 더 생김
 1. table full scan - 테이블의 정보를 다 읽음
 2. pk_emp 인덱스를 이용하여 사용자가 원하는 행을 빠르게 찾아가서
    필요한 컬럼들은 인덱스에 저장된 rowid를 이용하여 테이블의 행으로 바로접근 (인덱스를 사용했을때와 안했을때의 가장 큰차이점)



EXPLAIN PLAN FOR
SELECT empno
FROM emp
WHERE empno = 7698;
​

SELECT *
FROM TABLE (dbms_xplan.display);


 
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |     1 |     4 |     0   (0)| 00:00:01 |
|*  1 |  INDEX UNIQUE SCAN| PK_EMP |     1 |     4 |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("EMPNO"=7698)
---------------------------------------------------

##사용자가 찾는게 empno 라서 테이블까지 접근안하고 그대로 한번만 인덱스에서 찾아버림



empno컬럼의 인덱스를 unique 인덱스가 아닌 일반 인덱스(중복이 가능한)로 생성한 경우
1.fk_emp_dept 제약 조건삭제
2.pk_emp 제약조건 삭제
ALTER TABLE emp DROP CONSTRAINT FK_emp;
ALTER TABLE emp DROP CONSTRAINT pk_emp;

1. NON-UNIQUE 인덱스 생성 (중복 가능)
  UNIQUE 인덱스 명명 규칙 : IDX_U_테이블명_01;
  NON UNIQUE 인덱스 명명 규칙 : IDX_NU_테이블명_01;
  
CREATE [UNIQUE] INDEX 인덱스명 ON 테이블(인덱스로 구성할 컬럼);

CREATE INDEX idx_nu_emp_01 ON emp(empno);

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7698;
​

SELECT *
FROM TABLE (dbms_xplan.display);

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_01 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7698)
---------------------------------------------------
##NON-UNIQUE 인덱스 이므로 계속해서 인덱스를 스캔한다.
*empno = 7788인 값을 만나고 나서야

                                        

                                        
