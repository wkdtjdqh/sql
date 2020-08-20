GROUP 함수의 특징
1. null은 그룹함수 연산에서 제외가 된다.
부서번호별 사원의 sal, comm컬럼의 총 합을 구하기
SELECT deptno, SUM(sal + comm),SUM(sal + NVL(comm,0)),SUM(sal) + SUM(comm), SUM(sal) + NVL(SUM(comm),0)
FROM emp
GROUP BY deptno;
##SUM(sal + comm) 컬럼과 컬럼의 합을 구하면, 먼저 안쪽에서 더하는거기 때문에 null값도 계산됨. ex) 1000 + null = null이 나옴
##

NULL처리의 효율
SELECT deptno, SUM(sal) + NVL(SUM(comm),0),SUM(sal)+SUM(NVL(comm,0))
FROM emp
GROUP BY deptno;
NVL(SUM(comm),0) //이게 더 효율적이다, SUM결과에 NVL처리를 한번만 하면되지만
SUM(NVL(comm,0)) //이건 행들마다 다 NVL처리를 해야한다. 이게 행이 억단위로 넘어가면 함수를 불러오는데 차이가 커짐.

<실습>
emp테이블을 이용하여 다음을 구하시오.
1.직원중 가장 높은 급여
2.직원중 가장 낮은 급여
3.전체 직원 급여 평균
4.전체 직원 급여 합계
5.급여가 있는 직원의 수
6.상급자가 있는 직원의 수
7.전체 직원의 수

DECODE나 CASE를 사용시에 새끼를 증손자 이상 낳지마라. (3중첩하지마라)어처피 3충첩이되면 해석도 힘듬.


SELECT MAX(sal) max_sal,MIN(sal) Min_sal, ROUND(AVG(sal),2)avg_sal,SUM(sal)sum_sal,
       COUNT(sal)count_sal,COUNT(MGR)count_mgr,COUNT(*)count
FROM emp;

SELECT deptno, MAX(sal) max_sal,MIN(sal) Min_sal, ROUND(AVG(sal),2)avg_sal,SUM(sal)sum_sal,
       COUNT(sal)count_sal,COUNT(MGR)count_mgr,COUNT(*)count
FROM emp
GROUP BY deptno;

-------------------------------------------------------
위에서 작성한 쿼리를 활용하여 deptno대신 부서명이 나올수 있도록 수정(이게 제일 낫다)
SELECT DECODE(deptno,10,'ACCOUNTING',20,'RESEARCH',30,'SALES') dname,
       MAX(sal) max_sal,MIN(sal) Min_sal, ROUND(AVG(sal),2)avg_sal,SUM(sal)sum_sal,
       COUNT(sal)count_sal,COUNT(MGR)count_mgr,COUNT(*)count
FROM emp
GROUP BY deptno;


컬럼 자체를 생성하여 그룹에 사용하는 쿼리
SELECT DECODE(deptno,10,'ACCOUNTING',20,'RESEARCH',30,'SALES') dname,
       MAX(sal) max_sal,MIN(sal) Min_sal, ROUND(AVG(sal),2)avg_sal,SUM(sal)sum_sal,
       COUNT(sal)count_sal,COUNT(MGR)count_mgr,COUNT(*)count
FROM emp
GROUP BY DECODE(deptno,10,'ACCOUNTING',20,'RESEARCH',30,'SALES');


IN-LINE VIEW (이렇게 하는건 안좋다 쿼리도 길어지고 가독성도 안좋음/ 칠거지악 5번 꼭 필요한 인라인뷰인지 생각해라)
SELECT DECODE(deptno,10,'ACCOUNTING',20,'RESEARCH',30,'SALES') dname, a.*
FROM
      (SELECT deptno, MAX(sal) max_sal,MIN(sal) Min_sal, ROUND(AVG(sal),2)avg_sal,SUM(sal)sum_sal,
              COUNT(sal)count_sal,COUNT(MGR)count_mgr,COUNT(*)count
       FROM emp
       GROUP BY deptno)a;
-------------------------------------------
입사 년월로 입사한 사람의 수를 나타내는 쿼리
SELECT TO_CHAR(hiredate,'YYYYMM')hire_yyyymm, COUNT(*)
FROM emp
GROUP BY TO_CHAR(hiredate,'YYYYMM');

입사 년으로 입사한 사람의 수를 나타내는 쿼리
SELECT TO_CHAR(hiredate,'YYYY')hire_yyyymm, COUNT(*)
FROM emp
GROUP BY TO_CHAR(hiredate,'YYYY');
-------------------------------------------
회사에 존재하는 부서의 개수는 몇개인지 조회하는 쿼리
SELECT COUNT(*)cnt
FROM dept;

직원이 속한 부서의 개수를 조회하는 쿼리
SELECT COUNT(*) cnt
FROM
    (SELECT deptno
     FROM emp
     GROUP BY deptno);
##기본적인 방법

SELECT COUNT(COUNT(deptno)) cnt 
FROM emp
GROUP BY deptno;
##이렇게 중첩도 가능하다.

------------------------------------------
JOIN : 컬럼을 확장하는 방법(데이터를 연결한다)
        다른 테이블의 컬럼을 가져온다.
RDBMS가 중복을 최소화하는 구조이기 떄문에 하나의 테이블에 데이터를 전부 담지 않고, 목적에 맞게 설계한 테이블에
데이터가 분산된다. 하지만 데이터를 조회 할때  다른 테이블의 데이터를 연결하여 컬럼을 가져올수 있다.

ANSI-SQL : American National Standard Institute ...SQl
ORALCE-SQL 문법

JOIN : ANSI-SQL
       ORALCE-SQL 의 차이가 다소 발생 (나중에 회사에 입사하면 그 회사에서 쓰는 룰에 맞춰서 사용을 해야한다)

ANSI-SQL
NATURAL JOIN : 조인하고자 하는 테이블간 컬럼명이 동일할 경우 해당 컬럼으로
                행을 연결
                컬럼 이름 뿐만아니라 데이터 타입도 동일해야함.
사용방법:
SELECT 컬럼...
FROM 테이블1 NATURAL JOIN 테이블2

emp, dept 두 테이블의 공통된 이름을 갖는 컬럼 : deptno
ex)
SELECT empno , ename, deptno, dname
FROM emp NATURAL JOIN dept;
##NATURAL JOIN을 하면 조인된 컬럼은 하나만 나옴
##만약 emp 테이블과 dept테이블에  dname, deptno 컬럼명이 겹친다면 두개 다 =(EQUAL)일때만 결과가 나옴
##만약 두 테이블의 컬러명이 겹칠땐 테이블 한정자 사용해서 어느쪽 테이블에서 가져올지 정할 수 있다.
만약 empno가 겹친다면, emp.empno 이런식으로
그러나, 조인 조건으로 사용된 컬럼은 테이블 한정자를 붙이면 에러(ANSI-SQL)
emp.deptno (X)

위의 쿼리를 ORACLE 버전으로 수정
오라클에서는 조인 조건을 WHERE절에 기술
행을 제한하는 조건, 조인 조건 ==> WHERE절에 기술

SELECT * 
FROM emp, dept
WHERE deptno = deptno;
##이렇게하면 "column ambiguously defined" 에러가 뜨는데 이건 컬럼명이 모호하다 즉, deptno를 어디서 가져왔는지 모르겠다 이런 의미.

SELECT emp.*, emp.deptno, dname 
FROM emp, dept
WHERE emp.deptno = dept.deptno;



SELECT emp.*, emp.deptno, dname 
FROM emp, dept
WHERE emp.deptno != dept.deptno;
##이런식으로 되면 deptno가 emp테이블과 dept테이블에서 다를때 조인해라라는 뜻
즉 emp테이블에서 deptno가 10이면 dept테이블의 deptno가 10이 아닌 것을 조인하라는 뜻 그래서 
10이아닌 20,30,40과 조인하여 결과가 42개가 됨.

ANSI-SQL : JOIN WITH USING
조인 테이블간 동일한 이름의 컬럼이 복수개 인데
이름이 같은 컬럼중 일부로만 조인 하고 싶을 때 사용

SELECT *
FROM emp JOIN dept USING (deptno);

위의 쿼리를 ORACLE 조인으로 변경하면?

SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;


위에서 배운 NATURAL JOIN, JOIN with USING의 경우 조인 테이블의 조인컬럼이
이름이 같아야 한다는 제약 조건이 있음
그래서 
ANSI -SQL : JOIN with ON
설계상 두 테이블의 컬럼 이름 다를수도 있음. 컬럼 이름다를경우
개발자가 직접 조인 조건을 기술할 수 있도록 제공 해주는 문법
SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

ORACLE-SQL
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELF-JOIN : 동일한 테이블끼리 조인 할 때 지칭하는 명칭
            (별도의 키워드가 아니다)
사원번호, 사원이름, 사원의 상사 사원번호, 사원 상사 이름
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON ( e.mgr = m.empno );
## KING은 조인에서 실패해서 결과에 안뜸.
 총 행의 수는 13건 조회된다.
 
사원중 사원의 번호가 7369~7698인 사원만 대상으로 해당 사원의
사원번호, 사원이름, 사원의 상사 사원번호, 사원 상사 이름

SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON ( e.mgr = m.empno )
WHERE e.empno BETWEEN 7369 AND 7698;


NON-EQUI-JOIN = 조인 조건이 =이 아닌 조인
                (!=) 값이 다를 때 연결


급여 등급 정보 테이블
SELECT *
FROM salgrade;
## 빠지는 값이 없는 것을 상분이력?

empno, ename, sal, grade급여등급을 알고 싶다?
SELECT empno, ename, sal, grade
FROM emp, salgrade
WHERE sal BETWEEN losal AND hisal;

<실습>
1.
(ANSI)
SELECT empno, ename, emp.deptno, dname
FROM emp JOIN dept ON(emp.deptno = dept.deptno);


(oracel)
SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno;


2.
(ANSI)
SELECT empno, ename, deptno, dname
FROM emp JOIN dept USING(deptno)
WHERE deptno != 20;

(ORACEL)
SELECT empno, ename, e.deptno, dname 
FROM emp e, dept d 
WHERE e.deptno = d.deptno
      AND e.deptno IN(10,20);







