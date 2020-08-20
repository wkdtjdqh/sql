mybatis
SELECT: 결과가 1건이냐, 복수건이냐
    1건 : sqlSession.selectOne("네임스페이스.sqlid", [인자]) ==> overloading
            리턴타입 : resultType
    복수 : sqlSession.selectList("네임스페이스.sqlid", [인자]) ==> overloading
            리턴타입 : List<resultType>

EmpDao 운영코드 작성
==>테스트 할 수 있는 테스트 코드
src/test/java

운영코드+Test
EmpDaoTest

1. 운영코드작성 ==> 실행 ==> 눈으로 확인 ==> 에러발생 
            ==>코드수정 ==> 실행 ==> 눈으로 확인 ==> 에러발생 
            ==>코드수정 ==> 실행 ==> 눈으로 확인 ==> 에러발생 


2. 운영코드작성 ==> 테스트코드 작성 ==> 테스트코드실행 ==> junit view
            ==> 코드 수정 ==> 테스트코드실행 ==> junit view
            ==> 코드 수정 ==> 테스트코드실행 ==> junit view


3. 테스트코드 작성 ==> 운영코드작성
TDD(test Driven Development)    
BDD(Behavior Driven Development)



===================================================================
오라클 계층 쿼리 : 하나의 테이블(혹은 인라인 뷰)에서 특정 행을 기준으로 다른 행을 찾아가는 문법

조인 : 테이블 - 테이블
계층 쿼리 : 행 - 행

1.시작점(행)을 설정
2.시작점(행)과 다른행을 연결시킬 조건을 기술

ex)
1. 시작점 : mgr 정보가 없는 KING
2. 연결 : KING을 mgr컬럼으로 하는 사원

LPAD('기준문자열',15,'*') : 15자가 안되면 왼쪽에 *를 붙여라, 세번째 인자를 안주면 공백처리

LEVEL = 1 : 0;
LEVEL = 2 : 4;
LEVEL = 3 : 8;

==============하향식
왼쪽에 LEVEL별로 공백을 삽입해서 계층구조로 나타내기 (실무에서 많이씀) 
SELECT LPAD(' ', (LEVEL-1)*4)||ename, LEVEL
FROM emp
START WITH mgr IS NULL --ename = 'KING', empno = 7839 도 가능
CONNECT BY PRIOR empno = mgr; -- PRIOR 먼저 읽은 값의. 라는뜻  즉 매니저가 널인 값


## BLAKE 밑의 직원들 조회
SELECT LPAD(' ', (LEVEL-1)*4)||ename, LEVEL
FROM emp
START WITH ename = 'BLAKE'
CONNECT BY PRIOR empno = mgr; -- PRIOR 먼저 읽은 값의. 라는뜻  즉 매니저가 널인 값


==============상향식(최하단 노드에서 상위노드로 연결하는 상향식 연결방법)
시작점 : 'SMITH'

SELECT LPAD(' ', (LEVEL-1)*4)||ename, LEVEL
FROM emp
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno; --현재 읽고있는 매니저와 부서번호가 일치하는 사람

** PRIOR 키워드는 CONNECT BY 키워드와 떨어져서 사용해도 무관
** PRIOR 키워드는 현재 읽고있는 행을 지칭하는 키워드
CONNECT BY empno = PRIOR mgr; 

**PRIOR 키워드는 한번이상 사용해도 무관
SELECT LPAD(' ', (LEVEL-1)*4)||ename, LEVEL
FROM emp
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno AND PRIOR hiredate < hiredate --현재 읽고있는 매니저와 부서번호가 일치하면서 현재 읽고있는 입사일자가 읽을 행의 입사일자보다 빠를떄 


=============================실습1

SELECT *
FROM dept_h

XX회사 부서부터 시작하는 하향식 계층쿼리 작성, 부서이름과 LEVEL 컬럼을 이용하여 들여쓰기 표현

SELECT LEVEL lv, deptcd, LPAD(' ',(LEVEL -1) * 4)||deptnm, p_deptcd
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd; --지금 읽고있는 부서코드가 상위부서코드랑 일치할 떄

==============================실습2
정보시스템부 하위의 부서계층 구조를 조회하는 쿼리 작성

SELECT LEVEL lv, deptcd, LPAD(' ',(LEVEL -1) * 4)||deptnm, p_deptcd
FROM dept_h
START WITH deptnm = '정보시스템부'
CONNECT BY PRIOR deptcd = p_deptcd;

============================실습3
디자인팀에서 시작하는 상향식 계층쿼리
SELECT LEVEL lv, deptcd, LPAD(' ',(LEVEL -1) * 4)||deptnm, p_deptcd
FROM dept_h
START WITH deptnm = '디자인팀'
CONNECT BY PRIOR p_deptcd = deptcd;





=============================실습4
SELECT *
FROM h_sum;

SELECT LPAD(' ', (LEVEL-1)*4)||s_id s_id, value
FROM h_sum
START WITH s_id = 0
CONNECT BY PRIOR s_id = ps_id;









