행을 NULL로 만들겠다 -> update
행을 아예 테이블에서 날려버리겠다 -> delete

UPDATE : 상수값으로 업데이트 ==> 서브쿼리 사용 가능

INSERT INTO emp (empno, ename, job) VALUES (9999, 'brown', 'RANGER'); 

SELECT *
FROM emp

방금 입력한 9999번 사번번호를 갖는 사원의 deptno와, job컬럼 값을 SMITH 사원의 deptno와 job값으로 업데이트
## 스칼라 서브쿼리 처럼 1개의 컬럼과 1개의 행만 리턴해야됨.(예시를 들기 위해 만든거고 아래 쿼리는 좋은 쿼리는 아니다. 비효율적임)
UPDATE emp SET deptno = (SELECT deptno FROM emp WHERE ename = 'SMITH'), 
                job = (SELECT job FROM emp WHERE ename = 'SMITH')
WHERE empno = 9999;

===>UPDATE 쿼리1 실행할 때 안쪽 SELECT 쿼리가 2개가 포함됨==>비효율적
    고정된 값을 업데이트 하는게 아니라 다른 테이블에 있는 값을 통해서 업데이트 할때 비효율이 존재
    ==> MERGE 구문을 통해 보다 효율적으로 업데이트가 가능.

-----------------------------------------------------
DELETE : 테이블의 행을 삭제할 때 사용하는 SQL
        특정 컬럼만 삭제하는 거는 UPDATE
        DELETE구문은 행 자체를 삭제
1. 어떤 테이블에서 삭제할지
2. 테이블의 어떤 행을 삭제할지

문법
DELETE [FROM] 테이블명  <- FROM은 생략가능
WHERE 삭제할 행을 선택하는 조건;

9999번 사원 삭제하는 쿼리
DELETE emp
WHERE empno = 9999;


DELETE 쿼리도 SELECT 쿼리 작성시 사용한 WHERE절과 동일 -> 서브쿼리 사용가능
사원중에 mgr가 7698인 사원들만 삭제

DELETE emp
WHERE mgr = 7698;

DELETE emp
WHERE empno IN (SELECT empno
                FROM emp
                WHERE mgr = 7698);
ROLLBACK;

DBMS의 경우 데이터의 복구를 위해서
DML 구문을 실행할 때마다 로그(log)를 생성

대량의 데이터를 지울 때는 로그 기록도 부하가 되기 때문에
개발환경에서는 테이블의 모든 데이터를 지우는 경우에 한해서
TRUNCATE TABLE 테이블명 ; 명령을 통해
로그를 남기지 않고 빠르게 삭제가 가능하다
단, 로그가 없기 때문에 복구가 불가능하다
-DDL
-복구 불가
-주로 개발 데이터베이스에서 사용 

CREATE TABLE emp_copy AS
SELECT *
FROM emp;

SELECT *
FROM emp_copy;

TRUNCATE TABLE emp_copy;

SELECT *
FROM emp_copy;

DELETE 나 TRUNCATE 나 둘다 데이터를 날리는 거기 때문에 조심해서 사용해야한다.



LRU -> 페이지 교체 알고리즘

---------------------------------------------------
Grit 자기개발 서적

트랜잭션
commit

동작은 하난데 두개이상의 테이블에 동시에 입력이 되야할 때 (게시글 같은)

dcl /ddl ->자동 commit, rollback불가

ROLLBACK;

SELECT *
FROM dept;

LEVEL2 : repeatable read;
선행 트랜잭션에서 읽은 데이터를 후행 트랜잭션에서 수정하지 못하게끔 막아,
선행트랜잭션 안에서 항상 동일한 데이터가 조회 되도록 보장하는 레벨

PHANTOM read:
LV2에서는 테이블에 존재하는 데이터에 대해 후앵 트랜잭션에서 작업하지 못하도록 막을수는 있지만
후행 트랜잭션에서 신규로 입력하는 데이터는 막을 수 없다.
즉 선행 트랜잭션에서 처음 읽는 데이터와 후행 트랜잭션에서 신규입력 후 커밋한
이후에 조회한 데이터가 불일치 할 수 있다.

LEVEL3 : Serializable read
후행 트랜잭션이 데이터를 입력, 수정, 삭제 하여더라도 선행트랜잭션에서는
트랜잭션 시작 시점의 데이터가 보이도록 보장

##DBMS의 특성을 생각하지 않고 일관성 레벨을 임의로 수정하는 것은 위험

SNAPSHOT TOO OLD 오류=> 내가 읽어야될 데이터를 찾지 못했다.

--------------------------------------------------------------------
지금까지 배운거
DML(Data Manipulation[조작] Language): 데이터를 다루는 SQL
SELECT, INSERT, UPDATE, DELETE

앞으로 배울거
DDL(Data Definition[정의] Language)  : 데이터를 정의 하는 SQL
데이터가 들어갈 공간(table)생성, 삭제
컬럼 추가
각종 객체생성, 수정, 삭제
DDL은 자동 커밋, ROLLBACK불가
ex: 테이블 생성 DDL 생성 => 롤백불가
   ==> 테이블 삭제 DDL실행

테이블과 컬럼명 규칙 (pt보고 정리하기)

-------------------------------


테이블삭제
문법
DROP 객체종류 객체이름;
##삭제한 테이블과 관련된 데이터는 삭제
##[나중에 배울 내용 제약조건] 이런 것들도 다같이 삭제
테이블과 관련된 내용은 삭제
DROP TABLE emp_copy;

삭제한 테이블이라 에러
SELECT *
FROM emp_copy;


DML문과 DDL문을 혼합해서 사용 할 경우 발생할 수 있는 문제점
==>의도와는 다르게 DML문에 대해서 COMMIT 될 수 있다.

INSERT INTO emp (empno, ename) VALUES(9999, 'brown');

SELECT COUNT (*)
FROM emp; 15건


DROP TABLE batch;
[COMMIT]; //여기서 이미 커밋 되어버림 그래서 롤백해도 안됨.

ROLLBACK;

SELECT COUNT (*)
FROM emp;
-----------------------

테이블 생성
문법
CREATE TABLE 테이블명 (
    컬럼명1 컬럼1타입,
    컬럼명2 컬럼2타입,
    컬럼명3 컬럼3타입 DEFAUlT 기본값
)

<실습>
ranger라는 이름의 테이블 생성

CREATE TABLE ranger (
    ranger_no NUMBER,
    ranger_nm VARCHAR2 (50),
    reg_dt DATE DEFAULT SYSDATE 
)
##DEFAULT SYSDATE : 데이터를 따로 안넣어 줬을 땐 현재 날짜를 넣어라.

SELECT *
FROM ranger;

INSERT INTO ranger (ranger_no, ranger_nm) VALUES(100,'brown');

SELECT *
FROM ranger;

데이터 무결성 : 잘못된 데이터가 들어가는 것을 방지하는 성격
ex)1.사원 테이블에 중복된 사원번호가 등록되는 것을 방지
   2. 반드시 입력이 되어야 되는 컬럼의 값을 확인
==> 파일시스템이 갖을 수 없는 성격

오라클에서 제공하는 데이터 무결성을 지키기 위해 제공하는
제약조건 5가지(4가지)
1. NOT NULL (CHECK 제약 조건에 들어감)
    해당컬럼에 값이 NULL 들어오는 것을 제약, 방지
    (ex. emp테이블의 empno 컬럼)
2. UNIQUE
    전체 행중에 해당 컬럼의 값이 중복이 되면 안된다.
    (ex. emp테이블에서 empno컬럼이 중복되면 안된다)
    단, NULL에 대한 중복은 허용한다.
3. PRIMARY KEY = UNIQUE + NOT NULL
    값이 반드시 존재하면서 중복이 되면 안된다.
4.FOREIGN KEY
    연관된 테이블에 해당 데이터가 존재해야만 입력이 가능
    emp테이블과 dept테이블은 deptno 컬럼으로 연결되어 있음
    emp 테이블에 데이터를 입력할 때 dept테이블에 존재하지 않는
    deptno 값을 입력하는 것을 방지
    ex)
5. CHECK 제약 조건
    컬럼에 들어오는 값을 정해진 로직에 따라 제어
    ex) 어떤 테이블에 성별 컬럼이 존재하면
    남성 = M, 여성 = F
    M,F 두가지 값만 저장될 수 있도록 제어
    C 성별을 입력하면?? 시스템 요구사항을 정의할 때
    정의하지 않은 값이기 때문에 추후 문제가 될 수 도있다.
    
    
제약조건 생성하는 방법
1. 테이블 생성시, 컬럼 옆에 기술하는 경우
    #상대적으로 세세하게 제어하는건 불가능
2. 테이블 생성시, 모든 컬럼을 기술하고 나서 제약조건만 별도로 기술
    #1번 방법보다 세세하게 제어하는게 가능    
3. 테이블 생성이후, 객체 수정명령을 통해 제약조건을 추가

---------------------------------
1번방법으로 PRIMARY KEY 생성
dept 테이블과 동일한 컬럼명, 타입으로 dept_test라는 테이블 이름으로 생성
1. dept 테이블 컬럼의 구성 정보확인
DESC dept;

CREATE TABLE dept_test(
    DEPTNO    NUMBER(2) PRIMARY KEY,    
    DNAME     VARCHAR2(14), 
    LOC       VARCHAR2(13) 
);

SELECT *
FROM dept_test

PRIMARY KEY 제약조건 확인
UNIQUE + NOT NULL

1. NULL값 입력 테스트
INSERT INTO dept_test VALUES (null, 'ddit', 'daejeon');
PRIMARY KEY 제약조건에 의해 deptno 컬럼에는 null값이 들어갈 수 없다.
오류 보고 -
ORA-01400: cannot insert NULL into ("JW"."DEPT_TEST"."DEPTNO") : deptno컬럼에는 null값을 입력할 수 없다는 뜻

2. 값 중복 테스트
INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon'); 
첫번째 INSERT 구문에 의해 99번 부서는 dept_test 테이블에 존재 

INSERT INTO dept_test VALUES (99, 'ddit2', '대전');
deptno 컬럼의 값이 99번인 데이터가 이미 존재하기 때문에 중복 데잍로 입력이 불가능.
오류 보고 -
ORA-00001: unique constraint (JW.SYS_C007092) violated 
: unique 제약조건에 위배되었다./ SYS_C007092는 PRIMARY KEY 이름을 정해주지 않아서 ORACLE에서 자동으로 정해준것


현 시점에서 dept테이블에는 deptno컬럼에 PRIMARY KEY 제약이 걸려 있지 않은 상황
SELECT *
FROM dept;

이미 존재하는 10번 부서 추가로 등록

INSERT INTO dept VALUES (10,'ddit','daejeon');
제약조건이 안걸려있어서 똑같은 이름의 10번 부서 삽입 가능.

테이블 생성시 제약조건 명을 설정한 경우
DROP TABLE dept_test;
컬럼명 컬럼 타입 CONSTRAINT 제약조건 이름 제약조건타입(PRIMARY KEY)

PRIMARY KEY 제약조건 명명 규칙: PK_테이블명

CREATE TABLE dept_test(
    DEPTNO    NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY,    
    DNAME     VARCHAR2(14), 
    LOC       VARCHAR2(13) 
);

INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
SELECT *
FROM dept_test;
INSERT INTO dept_test VALUES (99, 'ddit2', '대전');
오류 보고 -
ORA-00001: unique constraint (JW.PK_DEPT_TEST) violated
##이름을 바꿔줘서 JW.PK_DEPT_TEST 이렇게 알아보기 쉬워짐

