SELECT 'TEST1' alias1, 'TEST2' AS alias2, 'TEST3' AS 'alias3'
FROM dual;

SELECT *
FROM dual;




SELECT *
FROM (SELECT ROWNUM rn, a. *
              FROM (SELECT *
                    FROM emp
                    ORDER BY ename) a)
WHERE rn BETWEEN (:page -1) * :pagesize + 1 AND :page *:pagesize;


---------------------------------------------------
1.GROUP BY (여러개의 행을 하나의 행으로 묶는행위)
2.JOIN
3.서브쿼리
 1. 사용위치
 2. 반환하는 행, 컬럼의 개수
 3. 상호연관 / 비상호연관
   ->메인쿼리의 컬럼을 서브쿼리에서 사용하느지(참조하는지) 유무에 따른 분류
   : 비상호연관 서브쿼리의 경우 단독으로 실행 가능
   : 상호연관 서브쿼리의 경우 메인쿼리의 컬럼을 사용하기 때문에 단독으로 실행 불가능
---------------------------------------------------
sub2 : 사원들의 급여평균보다 높은 급여를 받는 직원(비상호 연관 서브쿼리)
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp);
    

1. 전체 사원의 정보를 조회, 조인 없이 해당 사원의 속한 부서의 부서이름 가져오기 (상호연관서브쿼리)
SELECT empno, ename, deptno, (SELECT dname FROM dept WHERE deptno = emp.deptno)
FROM emp;


2.사원이 속한 부서의 급여 평균보다 높은 급여를 받는 사원 정보 조회(상호연관서브쿼리)
 ## 그사원이 속한 부서 -> deptno = emp.deptno
 
SELECT *
FROM emp 
WHERE sal > (SELECT ROUND(AVG(sal),2) 
             FROM emp
             WHERE deptno = emp.deptno);
##이렇게 하면 deptno = emp.deptno이 테이블이 같아서 어디에 있는 테이블을 가져올지 몰라 가까운 곳에 있는 테이블을 가져오는데
  결과가 서브쿼리emp.deptno = 서브쿼리emp.deptno 이 되어버려서 1 = 1이 된다. 그래서 전체행의 평균 값보다 높은 행만 추출됨.
SELECT *
FROM emp e
WHERE sal > (SELECT ROUND(AVG(sal),2) 
             FROM emp
             WHERE deptno = e.deptno);
##그래서 테이블에 별칭을 붙여줘서 두개 테이블은 다르다는걸 알려주면 정확한 값이 추출됨.


3.'SMITH'와 'WARD'사원이 속한 부서의 모든 사원 정보를 조회하는 쿼리를 작성.
'SMITH' : 20, 'WARD' : 30

SELECT *
FROM emp 
WHERE deptno IN (SELECT deptno
                 FROM emp
                 WHERE ename IN('SMITH','WARD'));
##단일 값비교는 '='
복수행(단일컬럼) 비교는 'IN'


서브쿼리 Multi-row연산자(잘안씀. 이런게 있다 정도)
비교 연산자 any
비교 연산자 all

---------------------------------------------
*IN, NOT IN 이용시 NULL값의 존재 유무에 따라 원하지 않는 결과가 나올 수도 있다.
NULL 과 IN, NULL 과 NOT IN

mgr IN (7902, NULL);

==> mgr = 7902 OR mgr = NULL
==> mgr값이 7902이거나 mgr값이 null인 데이터
==> NULL은 = 로 비교 못함 그래서 무시가 되어 KING데이터는 안나옴).

SELECT *
FROM emp
WHERE mgr NOT IN (7902, NULL);

mgr NOT IN (7902, NULL);
==> mgr != 7902 AND mgr != NULL
==> mgr != NULL NULL =로 비교가 불가능 하다 그래서 이부분이 항상 false여서 에러가 나는건 아니지만 값이 안나온다.

pairwise, non-pairwise (가끔 씀)
한행의 컬럼 값을 하나씩 비교하는 것 : non pairwise
한행의 복수 컬럼을 비교하는 것 : pairwise
SELECT *
FROM emp
WHERE job IN('MANAGER', 'CLERK');


SELECT *
FROM emp
WHERE (job, deptno) IN (('MANAGER', 20), ('CLERK',20));


SELECT *
FROM emp
WHERE (mgr, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE empno IN(7499, 7782));
pairwise
7698 30
7839 10
                        
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
             FROM emp
             WHERE empno IN(7499, 7782))
 AND deptno IN (SELECT deptno
                FROM emp
                WHERE empno IN (7499, 7782));
                
SELECT *
FROM emp
WHERE mgr IN(7698, 7839)
 AND deptno IN(30, 10);
 
non-pairwize
7698 30
7839 30
7698 10
7839 10

------------------------------------------------
상호연관 서브쿼리는 단독으로 서브쿼리가 안되서 ORACLE에서 무조건 main쿼리 먼저 실행후 서브쿼리 실행
main -> sub

비상호연관 서브쿼리는 단독으로 서브쿼리 사용가능해서 어떤거를 먼저 사용할지는 ORACLE 이 정함


INSERT INTO dept VALUES (99, 'ddit', 'daejeon');

SELECT *
FROM dept;

<실습>
4.dept 테이블에서 직원이 속하지 않은 부서만 나오도록 제한하는 쿼리.
SELECT *
FROM dept
WHERE deptno 10이 아니고, 20이 아니고, 30이 아닌

SELECT *
FROM dept
WHERE deptno NOT IN (SELECT deptno
                     FROM emp);

5.cycle, product 테이블을 이용하여 cid = 1고객이 애용하지 않는 제품 조회하는 쿼리

SELECT *
FROM product
WHERE pid NOT IN (SELECT pid
                  FROM cycle
                  WHERE cid = 1)
                  
6.cycle 테이블을 이용하여 cid = 1인 고객이 애음하는 제품 중 cid = 2인 고객도 애음하는 제품의 정보를 조회하는 쿼리

SELECT *
FROM cycle c
WHERE pid IN ( SELECT pid
               FROM cycle
               WHERE cid = 2 )
  AND cid = 1;

7.customer, product, cycle 테이블을 이용하여 cid = 1 인 고객이 애음 하는 제품 중 cid = 2인 고객도 애음하는 제품을 조회하고 
  고객명, 제품명까지 포함하는 쿼리
(ORACLE) 
SELECT cnm, c.pid, pnm, day, cnt
FROM cycle c, product p, customer cm
WHERE c.pid IN (SELECT pid
              FROM cycle
              WHERE cid = 2)
  AND c.cid = 1
  AND c.pid = p.pid
  AND c.cid = cm.cid;

(ANSI)
SELECT cnm, c.pid, pnm, day, cnt
FROM cycle c JOIN product p ON(c.pid = p.pid) JOIN customer cm ON(c.cid = cm.cid)
WHERE c.pid IN (SELECT pid
              FROM cycle
              WHERE cid = 2)
  AND c.cid = 1






