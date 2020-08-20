 DECODE : 조건에 따라 반환 값이 달라지는 함수 (CASE 보다는 코드가 좀 짧아져서 가독성이 좋음)
        ==> 비교, JAVA (if), SQL - case와 비슷
        단 비교연산이 (=)만 가능, 다른건 다 불가능(>,<,>=,<= 등)
        CASE의 WHEN절에 기술할 수 있는 코드는 참 거짓 판단할 수 있는 코드면 가능
        ex) sal > 1000
        이것과 다르게 DECODE 함수 에서는 SAL = 1000, SAL=2000 
        
DECODE는 가변인자(인자의 갯수가 정해지지 않음. 상황에 따라 늘어날 수 도 있다)를 갖는 함수
문법 : DECODE(기준값[col| expression], 비교값1, 반환값1
                                      비교값2, 반환값2
                                      비교값3, 반환값3
                                      옵션[기준값이 비교값중에 일치하는 값이 없을 때 기본적으로 반환할 값](있을 수도, 없을 수도)
==>java
if( 기준값 == 비교값1)
    반환값1을 반환해준다
else if(기준값 == 비교값2)
    반환값2를 반환해준다
else 
    마지막 인자가 있을 경우 마지막 인자를 반환하고
    마지막 인자가 없을 경우 null을 반환

ex)
(CASE)
SELECT empno, ename,
    CASE 
        WHEN deptno = 10 THEN 'ACCOUNTING'
        WHEN deptno = 20 THEN 'RESEARCH'
        WHEN deptno = 30 THEN 'SALES'
        WHEN deptno = 40 THEN 'OPERATIONS'
        ELSE 'DDIT'
    END dname
FROM emp;
(DECODE)
SELECT empno, ename, deptno,
    DECODE(deptno,10,'ACCOUNTING',
                  20,'RESEARCH',
                  30,'SALES',
                  40,'OPERATIONS',
                  'DDIT') dname
FROM emp;

(CASE)
SELECT ename, job, sal, 
     CASE
        WHEN job = 'SALESMAN' THEN sal*1.05
        WHEN job = 'MANAGER' THEN sal * 1.10
        WHEN job = 'PRESIDENT' THEN sal * 1.20
        ELSE sal
     END int_sal
FROM emp;
(DECODE)
SELECT ename, job, sal,
        DECODE(job, 'SALESMAN', sal*1.05,
                    'MANAGER', sal*1.10,
                    'PRESIDENT', sal*1.20,
                    sal)int_sal
                    
FROM emp;


ex)
위의 문제 처럼 job에 따라 sal을 인상을 한다. 단 추가조건으로 manager이면서 소속부서가 30(SALES)이면 sal *1.5
(CASE) 논리연산자도 사용 가능하다. 중첩도 가능하다
SELECT ename, job, deptno, sal,
        case
            WHEN job = 'MANAGER' AND deptno = 30 THEN sal * 1.5
            WHEN job = 'SALESMAN' THEN sal * 1.05
            WHEN job = 'MANAGER' THEN sal * 1.10
            WHEN job = 'PRESIDENT' THEN sal * 1.20
            ELSE sal
        END int_sal
FROM emp;

SELECT ename, job, deptno, sal,
        case
            WHEN job = 'MANAGER' THEN 
                                        CASE WHEN  deptno = 30 THEN sal * 1.50
                                             ELSE sal * 1.1
                                        END
            WHEN job = 'SALESMAN' THEN sal * 1.05
            WHEN job = 'PRESIDENT' THEN sal * 1.20
            ELSE sal
        END int_sal
FROM emp;



(DECODE) 중첩이 가능하다.(안에 CASE 넣어도됨)
SELECT ename, job, deptno, sal,
        DECODE(job,'MANAGER',DECODE(deptno, 30, sal * 1.5, sal * 1.1),
                   'SALESMAN',  sal * 1.05,
                   'PRESIDENT', sal * 1.20,
                   sal)int_sal
FROM emp;
----------------------------
<실습> 
1.올해 년도에 따라 건강검진 대상자인지 비대상자인지 구분하는 쿼리작성
  단, 년도가 바뀔 때마다 결과값도 바뀌어야함.
(CASE)
SELECT empno, ename, hiredate, 
        CASE 
            WHEN MOD(TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - TO_NUMBER(TO_CHAR(hiredate,'YYYY')), 2) = 0 THEN '건강검진 대상자'
            ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR
FROM emp;
##묵시적 형변환이 일어나서 TO_NUMBER는 써도되고 안써도되고.

(DECODE)
SELECT empno, ename, hiredate, 
                    DECODE(MOD(TO_CHAR(SYSDATE,'YYYY') - TO_CHAR(hiredate,'YYYY'), 2) , 0 , '건강검진 대상자',
                          '건강검진 비대상자')CONTACT_TO_DOCTOR
FROM emp;

2. users테이블을 이용하여 reg_dt에 따라 올해 건강보험 검진대상자인지 조회하는 쿼리를 작성하세요.
(생년을 기준으로 하나 여기서는 reg_dt를 기준으로 한다)
SELECT userid, usernm, alias, reg_dt,
                           DECODE(MOD(TO_CHAR(SYSDATE,'YYYY'), 2) , MOD(TO_CHAR(reg_dt,'YYYY'),2) , '건강검진 대상자',
                                  '건강검진 비대상자')CONTACT_TO_DOCTOR
FROM users;


-----------------------------------------------

JAVA : 배열, 객체(class), 쓰레드
SQL : GROUP 함수


DELETE emp
WHERE empno = 9999;

COMMIT;


GROUP 함수
-여러개의 행을 입력으로 받아서 하나의 행으로 결과를 리턴하는 함수
SUM :합계
COUNT : 행의 수
AVG : 평균
MAX : 그룹에서 가장 큰 값
MIN : 그룹에서 가장 작은 값

사용방법
SELECT 행들을 묶을 기준1, 행들을 묶을 기준2, 그룹함수
FROM 테이블
[WHERE]
GROUP BY 행들을 묶을 기준1, 행들을 묶을 기준2

ex) 부서별 급여(sal)합
1. 부서번호가 같은 행들을 하나의 행으로 만든다.
SELECT deptno, SUM(sal) 
FROM emp
GROUP BY deptno;

2. 부서번호별 가장 큰 급여를 받는 사람 급여 액수
SELECT deptno, SUM(sal), MAX(sal)
FROM emp
GROUP BY deptno;

3. 부서번호별 가장 작은 급여를 받는 사람 급여 액수
SELECT deptno, SUM(sal), MAX(sal), MIN(sal)
FROM emp
GROUP BY deptno;

4. 부서번호별 급여 평균
SELECT deptno, SUM(sal), MAX(sal), MIN(sal), ROUND(AVG(sal),2)
FROM emp
GROUP BY deptno;

5. 부서 번호별로 급여가 존재하는 사람의 수 (sal컬럼이 null이 아닌 행의 수)
SELECT deptno, SUM(sal), MAX(sal), MIN(sal), ROUND(AVG(sal),2), COUNT(sal) ,COUNT(comm), COUNT(*)
FROM emp
GROUP BY deptno;
 ##COUNT(*) / 그 그룹의 행 수를 의미 그래서 null값도 같이 나옴 (COUNT는 행의 수를 세는 경우가 많아서 보통 * 사용)
 ##COUNT(컬럼)/ null이 아닌 행의 수
 
 그룹함수의 특징 : 
 1. null값을 무시
 30번 부서의 사원 6명중 2명은 comm값이 null
 SELECT deptno, SUM(comm)
 FROM emp
 GROUP BY deptno;
 
2. GROUP BY를 적용하여 여러행을 하나의 행으로 묶게 되면 SELECT 절에 기술할 수 있는 컬럼이 제한됨.
   ==> SELECT절에 기술되는 일반 컬럼들은(그룹 함수를 적용하지 않은) 반드시 GROUP BY절에 기술 되어야 한다.
       * 단, 그룹핑에 영향을 주지 않는 고정된 상수, 함수는 기술하는 것이 가능하다. ex) 10, SYSDATE
SELECT deptno, SUM(sal), ename
FROM emp
GROUP BY deptno;
##이런식으로 하게 되면 ename중 어떤걸 표기해야될지 몰라 에러가 난다.
 그래서 MAX(ename)으로 쓰거나, GROUP BY 절에 기술해줘야한다.
 
 그룹함수 이해하기 힘들다 ==> 엑셀에 데이터를 그려보자
 
3.일반 함수를 WHERE절에서 사용하는게 가능
 (WHERE UPPER('smith') = 'SMITH';)
 그룹함수의 경우 WHERE 절에서 사용하는게 불가능
 하지만 HAVING절에 기술하여 동일한 결과를 나타낼 수 있다
 SUM(sal) 값이 9000보다 큰 행들만 조회하고 싶은 경우
SELECT deptno, SUM(sal)
FROM emp
WHERE SUM(sal)>9000
GROUP BY deptno;
##이렇게 하면 에러남 그래서 having사용

SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno
HAVING SUM(sal) > 9000;

//HAVING 안쓰고 하는 방법 IN-LINE VIEW
SELECT *
FROM(SELECT deptno, SUM(sal) sum_sal
     FROM emp
     GROUP BY deptno)
WHERE sum_sal > 9000;

--------------------------------------
SELECT 쿼리 문법 총정리
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY

GROUP BY절에 행을 그룹핑할 기준을 작성
ex) 부서번호별로 그룹을 만들경우
    GROUP BY deptno
전체행을 기준으로 그루핑을 하려면 GROUP BY절에 어떤 컬럼을 기술해야 할까?
ex) emp테이블에 등록된 14명의 사원 전체의 급여 합계를 구하려면??
    =>GROUP BY 절을 기술하지 않는다.
SELECT deptno, SUM(sal)
FROM emp; 
##이렇게하면 에러가 난다. 

SELECT SUM(sal)
FROM emp;

GROUP BY절에 기술한 컬럼을 SELECT 절에 기술하지 않은 경우??
==>정상적으로 값이 나온다.
SELECT SUM(sal)
FROM emp
GROUP BY deptno;

 
그룹함수의 제한사항
==> 부서번호별 가장 높은 급여를 받는 사람의 급여액
    근데 그 사람이 누군데?(서브쿼리, 분석함수)
SELECT deptno, MAX(sal)
FROM emp
GROUP BY deptno;

 
 
