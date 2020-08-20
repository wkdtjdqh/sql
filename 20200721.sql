전날 정리
확장된 
GROUP BY 
==> 서브그룹을 자동으로 생성
    만약 이런구문이 없다면 개발자가 직접 SELECT 쿼리를 여러개 작성해서 UNION ALL을 실행 ==> 동일한 테이블을 여러번 조회 ==> 성능저하

1. ROLLUP
    1-1. ROLLUP절에 기술한 컬럼을 오른쪽에서 부터 지워나가며 서브그룹을 생성
    1-2. 생성되는 서브 그룹 : ROLLUP절에 기술한 컬럼 개수 +1
    1-3. ROLLUP절에 기술한 컬럼의 순서가 결과에 영향을 미친다
2. GROUPING SET
    2-1. 사용자가 원하는 서브그룹을 직접 지정하는 형태
    2-2. 컬럼 기술의 순서는 결과 집합에 영향을 미치지 않음(집합)
3. CUBE
    3-1. CUBE절에 기술한 컬럼의 가능한 모든 조합으로 서브그룹을 생성
    3-2. 잘 안쓴다. 서브그룹이 너무 많이 생성됨(2^CUBE절에 기술한 컬럼개수)

    
================================================================================
상호연관쿼리를 이용하여 삭제
sub 실습2]

SELECT *
FROM dept_test;

1. dept_test테이블의 empcnt컬럼삭제
ALTER TABLE dept_test DROP COLUMN empcnt; 


2. 2개의 신규 데이터 입력
INSERT INTO dept_test VALUES(99,'ddit1','deajeon');
INSERT INTO dept_test VALUES(98,'ddit2','deajeon');

3.부서(dept_test) 중에 직원이 속하지 않은 부서를 삭제
서브쿼리를 사용하여 
1.비상호 연관
2.상호 연관
삭제 대상 : 40, 98, 99

1-1비상호 연관
DELETE dept_test
WHERE deptno NOT IN (SELECT deptno
                     FROM emp
                     GROUP BY deptno);


1-2상호연관   
EXISTS 사용
DELETE dept_test
WHERE NOT EXISTS (SELECT 'X'
                  FROM emp
                  WHERE deptno = dept_test.deptno);

NOT IN 사용
DELETE dept_test
WHERE deptno NOT IN (SELECT deptno
                    FROM emp
                    WHERE deptno = dept_test.deptno);

중복제거
##GROUP BY와 같은 결과를 내지만, 중복이 있다는 것 자체가 쿼리를 잘못 작성했을 가능성이 높아 잘 사용하지 않는다.
DELETE dept_test
WHERE deptno NOT IN (SELECT DISTINCT deptno
                     FROM emp);

===========================================================
sub 실습3]
SELECT *
FROM emp_test

DROP TABLE emp_test;

1.emp테이블을 이용하여 emp_test테이블 생성
CREATE TABLE emp_test AS
SELECT *
FROM emp
WHERE 1=1;

2.subquery를 이용하여 emp_test테이블에서 본인이 속한 부서의 (sal)평균 급여보다
 급여가 작은 직원의 급여를 현 급여에서 200을 추가해서 업데이트 하는 쿼리
  2-1 업데이트 할 대상 먼저 조회
  2-2 하드코딩
  2-3 효율성 있게 수정
 
 UPDATE emp_test a
 SET sal = sal + 200
 WHERE sal < (SELECT AVG(sal)
              FROM emp_test b
              WHERE a.deptno = b.deptno);

====================================================
서브쿼리 WITH : 
쿼리 블럭을 생성하고 같이 실행되는 SQL에서 해당 쿼리 블럭을 반복적으로 사용할 때 성능 향상 효과를 기대할수 있다.
WITH절에서 기술된 쿼리 블럭은 메모리에 한번만 올리기 때문에 쿼리에서 반복적으로 사용 하더라도 실제 데이터를 가져오는 작업은 한번만 발생

하지만 하나의 쿼리에서 동일한 서브쿼리가 반복적으로 사용된다는 것은 쿼리를 잘못 작성할 가능성이 높다는 뜻이므로, WITH절로 해결하기 보다는
쿼리를 다른 방식으로 작성할 수 없는지 먼저 고려 해볼 것을 추천

회사의 DB를 다른 외부인에게 오픈할 수 없기 때문에, 외부인에게 도움을 구하고자 할 때 테이블을 대신할 목적으로 많이 사용

사용방법 : 쿼리 블럭은 콤마(,)를 통해 여러개를 동시에 선언하는 것도 가능
WITH 쿼리블럭이름 AS {
        SELECT 쿼리
)
SELECT *
FROM 쿼리블럭이름;

===================================================
계층쿼리(이걸알면 편하게 작성할 수 있다)

달력만들기 
- 데이터의 행을 열로 바꾸는 방법
- 레포트 쿼리에서 활용할 수 있는 예제 연습


1.2020년 7월의 일수 구하기 (하드코딩 X)
SELECT TO_DATE(:YYYYMM,'YYYYMM') + (level - 1)
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM,'YYYYMM')),'DD');
## level : 여기서는 행의 번호 (정수)
##TO_DATE(:YYYYMM,'YYYYMM') : 이렇게해도 날짜는 00이 없어서 01인 첫날이 들어간다.

2. 요일 구하기

SELECT DECODE(d, 1 ,iw+1,iw),MAX(DECODE(d,1,dt)) sun, MAX(DECODE(d,2,dt)) mon, MAX(DECODE(d,3,dt)) tue, MAX(DECODE(d,4,dt)) wed, MAX(DECODE(d,5,dt)) thu, MAX(DECODE(d,6,dt))fri, MAX(DECODE(d,7,dt))sat
FROM
    (SELECT  TO_DATE(:YYYYMM,'YYYYMM') + (level - 1) dt, TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM') + (level - 1),'D') d,
        TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM') + (level - 1),'IW') iw
     FROM dual
     CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM,'YYYYMM')),'DD'))
GROUP BY DECODE(d, 1 ,iw+1,iw)
ORDER BY DECODE(d, 1 ,iw+1,iw);

## level : 여기서는 행의 번호 (정수)
##TO_DATE(:YYYYMM,'YYYYMM') : 이렇게해도 날짜는 00이 없어서 01인 첫날이 들어간다.



<과제 2019년 12월 달 제대로 나오게 하기>
SELECT iw, MAX(DECODE(d,1,dt)) sun, MAX(DECODE(d,2,dt)) mon, MAX(DECODE(d,3,dt)) tue, MAX(DECODE(d,4,dt)) wed, MAX(DECODE(d,5,dt)) thu, MAX(DECODE(d,6,dt))fri, MAX(DECODE(d,7,dt))sat
FROM
(SELECT TO_DATE(:yyyymm,'YYYYMM') + (level -1) dt, TO_CHAR(TO_DATE(:yyyymm,'YYYYMM') + (level - 1),'D') d,
       DECODE(TO_CHAR(TO_DATE(:yyyymm,'YYYYMM') + (level - 1),'D'), 1, TO_CHAR(TO_DATE(:yyyymm,'YYYYMM') + level,'IW'), TO_CHAR(TO_DATE(:yyyymm,'YYYYMM') + (level-1),'IW'))iw
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm,'YYYYMM')),'DD'))
GROUP BY iw
ORDER BY sat;




<전달의 날짜도 나오게 하는 쿼리>

SELECT MAX(DECODE(d,1,dt)) sun, MAX(DECODE(d,2,dt)) mon, MAX(DECODE(d,3,dt)) tue, MAX(DECODE(d,4,dt)) wed, MAX(DECODE(d,5,dt)) thu, MAX(DECODE(d,6,dt))fri, MAX(DECODE(d,7,dt))sat
FROM
(SELECT TO_DATE(:YYYYMM,'YYYYMM') + (level - TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM'),'D')) dt, TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM') + (level - TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM'),'D')),'D') d,
        DECODE(TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM') + (level - TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM'),'D')),'D'),1, 
        TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM') + (level - TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM'),'D'))+1,'IW'), --일요일 일땐 월요일로 만들어 주차를 같게 해줌. 즉, 안쪽에 날짜에서 +1
        TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM') + (level - TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM'),'D')),'IW'))iw
        
FROM dual
CONNECT BY LEVEL <= (LAST_DAY(TO_DATE(:YYYYMM,'YYYYMM')) + (7 - TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM,'YYYYMM')),'D'))) - (TO_DATE(:YYYYMM,'YYYYMM') - (TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM'),'D') - 1)) + 1)
GROUP BY iw
ORDER BY sat;






============================================
복습
SELECT *
FROM sales


SELECT MAX(DECODE(a,1,sales,0)) jan,
       MAX(DECODE(a,2,sales,0)) feb,
       MAX(DECODE(a,3,sales,0)) mar,
       MAX(DECODE(a,4,sales,0)) apr,
       MAX(DECODE(a,5,sales,0)) may,
       MAX(DECODE(a,6,sales,0)) jun

FROM      
    (SELECT TO_NUMBER(TO_CHAR(dt,'MM')) a, SUM(sales) sales
    FROM sales
    GROUP BY TO_NUMBER(TO_CHAR(dt,'MM')));
    
##알고리즘을 구하는 성능 : MAX, MIN, SUM -> MIN

==========================================================
JAVA에서 SQL을 사용하는 방법

기본포트
ORACLE : 1521
TOMCAT : 8080
MYSQL : 3306

미리 정의된 포트(보통은 1000번 미만)
http : 80
https : 443
ftp : 21

데이터베이스에 접속하기 위해선 접속정보가 필요하다.
ORN



