 OUTER JOIN <==> INNER JOIN
 
INNER JOIN : 조인 조건을 만족하는 (조인에 성공하는) 데이터만 조회
OUTER JOIN : 조인 조건을 만족하지 않더라도(조인에 실패하더라도) 기준이 되는 테이블 쪽의 데이터(컬럼)은 조회가 되도록하는 조인 방식.

OUTER JOIN  : 
LEFT OUTER JOIN => 조인 키워드의 왼쪽에 위치하는 테이블을 기준삼아 OUTER JOIN시행

RIGHT OUTER  JOIN => 조인 키워드의 오른쪽에 위치하는 테이블을 기준삼아 OUTER JOIN시행

FULL OUTER JOIN => LEFT OUTER JOIN + RIGHT OUTER  JOIN중복되는 것 제외

ANSI - SQL 
FROM 테이블1 LEFT OUTER JOIN 테이블2 ON(조인조건)

ORACLE - SQL : 테이터가 없는데 나와야하는 테이블의 컬럼 (데이터가 없는 쪽의 테이블. 컬럼에 (+)기호)
FROM 테이블1, 테이블2
WHERE 테이블1.컬럼 = 테이블2.컬럼(+)


ANSI-OUTER JOIN
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON ( e.mgr = m.empno);

ORACLE - OUTER JOIN
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m 
WHERE e.mgr = m.empno(+);


OUTER JOIN 시 조인 조건 (ON 절에 기술)과 일반 조건(WHERE 절에 기술) 적용시 주의 사항
: OUTER JOIN을 사용하는데 WHERE절에 별도의 다른조건을 기술할 경우 원하는 결과가 안나올 수 있음.
==>)OUTER JOIN의 결과가 무시

ex) ANSI
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON ( e.mgr = m.empno AND m.deptno = 10);
==> OUTER 조인이 정상적으로 작동해서 emp e 테이블의 모든 정보가 나오지만, deptno가 10이 아닌 데이터는 모두 NULL로 나옴.
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON ( e.mgr = m.empno)
WHERE m.deptno = 10;
==>FROM후 WHERE절이 실행되므로 OUTER조인 후, WHERE절에서 행 조건을 걸었기때문에 결과가 4건 밖에 안나옴.
   즉, OUTER JOIN을 적용하지 않은 쿼리와 동일한 결과를 나타낸다.
##그래서 ANSI SQL에서  OUTER  JOIN을 사용할 땐 WHERE절을 사용 하지 않고, ON절에 기술


ORACLE - OUTER JOIN
SELECT e.empno, e.ename, m.empno, m.ename, deptno
FROM emp e, emp m 
WHERE e.mgr = m.empno(+)
   AND m.deptno(+)= 10;
##ORACLE에서는 데이터가 없는 쪽의 테이블. 컬럼에 (+)기호를 붙여주는데 이 컬럼이 어디에 있든 다 붙여줘야한다. 안붙여주면 INNER JOIN처럼 작동




RIGHT OUTER JOIN : 기준 테이블이 오른쪽
ANSI-OUTER JOIN
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno);
##이렇게 하면 m 매니저 테이블을 기준으로 한거라서 한 매니저당 관리하는 사원이 많을 시 그것들이 모두다 나오는 거라 데이터가 많아짐.
   또한, 매니저가 아닌 직원들은 관리하는 사원이 없어서 NULL값이 뜸.


SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON ( e.mgr = m.empno);  : 14건

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno); : 21건


FULL OUTER JOIN : LEFT OUTER JOIN + RIGHT OUTER  - 중복제거
(ANSI)
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno); 
##ORACLE SQL에서는 FULL OUTER문법을 제공하지 않음. 에러가 남.
SELECT e.empno, e.ename, m.empno, m.ename, deptno
FROM emp e, emp m
WHERE e.mgr(+) = m.empno(+);


UNION : 합집합
A : {1, 3, 5}
B : {2, 3, 4}
A U B = {1,2,3,4,5}; ##집합에는 중복의 개념은 없다.

A : {1, 3}
B : {1, 3}
C : {1,2,3}
A-B : 공집합
A-C : 공집합
C-A : {2}
MINUS : 빼다

FULL OUTER JOIN 검증

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
UNION
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno)
MINUS
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);


SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
UNION
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno)
INTERSECT
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);
##INTERSECT : 교집합
--------------------------------------------------------------------------------
DOCER
지금까지 배운것의 3가지 키워드
WHERE : 행을 제한
JOIN 
GROUP FUNCTION 


https://www.datastore.or.kr/file/list
시도 : 서울특별시, 충청남도 등
시군구: 강남구, 청주시 등
스토어 구분





