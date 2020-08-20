숫자 : 4칙연산
날짜 : +, -, 날짜  +-정수 날짜에 정수만 과거나, 미래 날짜 값을 연산의 결과로 리턴
문자 : + ,-
NULL :아직 모르는 값, 아직 정해지지 않은 값
    1. NULL과 숫자타입 0은 다르다.
    2. NULL과 문자타입 ''은 다르다
    3. NULL값을 포함한 연산의 결과는 NULL ; 필요한 경우 NULL값을 다른값으로 치환
ALIAS : 별칭, 컬럼 혹은 ecpression에 다른 이름을 부여
      expression [AS] 벌칭명
       별칭을 작성할 때 주의점
       1. 공백이 들어가면 안됨. -> alias를 더블 쿼테이션으로 묶으면 가능
litral : 값 그 자체
litral표기법 : 언어마다 다르기 때문에 조심해야함.
**test 라는 문자열을 표기하는 방법(추후 시험문제)
java: String s = "test"
SQL : SELECT 'test'

WHERE: 테이블에서 조회할 행의 조건을 기술
        SELECT *
        FROM emp
        WHERE ename = 'SMITH';
WHERE 절에서 사용가능한 연산자 : =,!=,<>,>=,<=,>,<
        BETWEEN AND 값이 특정 범위에 포함 되는지 -> >= , <=
        IN 특정 값이 나열된 리스트에 포함되는 값을 표시


SQL에서는 키워드는 대소문자를 가리진 않지만 데이터는 대소문자를 가린다.
SELECT userid 아이디, usernm 이름, alias 별명
FROM users
WHERE userid in ('brown', 'cony', 'sally');   -> 'BROWN' 으로 하면 조회 안됨

<1교시>
WHERE 절에서 사용 가능한 연산자 : LIKE
사용 용도 :  문자의 일부분으로 검색을 하고 싶을 때 사용
        ex) ename 컬럼의 값이 s로 시작하는 사원들을 조회
사용 방법 : 컬럼 LIKE '패턴 문자열'
마스킹 문자열 : 1. % : 문자가 없거나, 어떤 문자든 여러개의 문자열
                ex) 's%' : s로 시작하는 모든 문자열들, 문자열 길이도 상관 X (s, stes, SMITE
              2. _ : 어떤 문자든 딱 하나의 문자를 의미
                ex) 's_' : s로 시작하고 두번째 문자가 어떤 문자든 하나의 문자가 오는 2자리 문자열
                    's____' : s로 시작하고 문자열의 길이가 5글자인 문자열

emp 테이블에서 ename 컬럼의 값이 s로 시작하는 사원들만 조회
SELECT *
FROM emp
WHERE ename LIKE 'S%';

member 테이블에서 회원의 성이 [신]씨인 사람의 mem_id, mem_name을 조회하는 쿼리를 작성하시오.
SELECT mem_id , mem_name
FROM member
WHERE mem_name LIKE '신%';

b001 : 이쁜이 ==> 쁜이
UPDATE member set mem_name = '쁜이'
WHERE mem_id = 'b001'; 

c001 : 신용환 ==>신이환
UPDATE member set mem_name = '신이환'
WHERE mem_id = 'c001'; 

member 테이블에서 회원의 이름에 글자 [이]가 들어가는 모든 사람의 mem_id , mem_name을 조회하는 쿼리를 작성하시오.
SELECT mem_id , mem_name
FROM member
WHERE mem_name LIKE '%이%';


<2교시>

NULL 비교: = 연산자로 비교 불가, 그래서 IS사용
comm의 값이 NULL인 행을 = 사용하여 조회 (=을 사용하면 데이터 안나옴)
SELECT empno, ename, comm
FROM emp
WHERE comm = NULL;
NULL값에 대한 비교는 =이 아니라 IS 연산자를 사용한다.
SELECT empno, ename, comm
FROM emp
WHERE comm IS NULL;
emp 테이블에서 comm 값이 NULL이 아닌 데이터를 조회(IS NOT 사용)
SELECT empno, ename, comm
FROM emp
WHERE comm IS NOT NULL;

논리 연산자 : AND, OR, NOT
AND : 판단식 1 AND 판단식2 ->식 두개를 동시에 만족하는 행만 참
      일반적으로 AND 조건이 많이 붙으면 조회되는 행의 수가 줄어든다.
OR : 판단식 1 OR 판단식2 ->식 두개 중 하나라도 만족하면 참
NOT: 조건을 반대로 해석하는 부정형 연산
      NOT IN 
      IS NOT NULL 
emp 테이블에서 mgr 컬럼 값이 7698이면서 sal 컬럼의 값이 1000보다 큰 사원 조회(AND)
SELECT *
FROM emp
WHERE mgr = 7698
  AND sal > 1000;
emp 테이블에서 mgr 컬럼 값이 7698이거나 sal 컬럼의 값이 1000보다 큰 사원 조회(OR)  
SELECT *
FROM emp
WHERE mgr = 7698
   OR sal > 1000;
emp 테이블에서 mgr 컬럼 값이 7698, 7839가 아닌 사원들을 조회(NOT)
SELECT *
FROM emp
WHERE mgr NOT IN(7698, 7839); 
## mgr 컬럼에 NULL값이 있을 경우 비교 연산으로 NULL 비교가 불가하기 때문에 
   NULL을 갖는 행은 무시가 된다.

##emp 테이블에서 mgr 컬럼 값이 7698, 7839가 아니고, NULL이 아닌 사원들을 조회(NOT)
SELECT *
FROM emp
WHERE mgr NOT IN(7698, 7839, NULL); 
 mgr IN(7698, 7839, NULL) ->  mgr = 7698 OR  mgr = 7839 OR  mgr = NULL
 mgr NOT IN(7698, 7839, NULL) ->  mgr != 7698 AND  mgr != 7839 AND  mgr != NULL  
###AND 는 하나라도 false면 안되기 때문에 NULL 때문에 오류가 생김
    
SELECT *
FROM emp
WHERE mgr NOT IN(7698, 7839)
   OR mgr IS NOT NULL;



   
<실습>
1. emp 테이블에서 job이 SALESMAN 이면서 입사 일자가 1981년 06월 01일 이후 인 사원을 조회하는 쿼리를 작성해라.
SELECT *
FROM emp
WHERE job = 'SALESMAN'
  AND hiredate >= TO_DATE('19810601', 'yyyymmdd');
2. emp 테이블에서 job이 SALESMAN 이거나 입사 일자가 1981년 06월 01일 이후 인 사원을 조회하는 쿼리를 작성해라. (OR)
SELECT *
FROM emp
WHERE job = 'SALESMAN'
  OR  hiredate >= TO_DATE('19810601', 'yyyymmdd');

3. emp 테이블에서 부서번호가  10이 아니면서 입사 일자가 1981년 06월 01일 이후 인 사원을 조회하는 쿼리를 작성해라. 
SELECT *
FROM emp
WHERE deptno != 10
  AND hiredate >= TO_DATE('19810601', 'yyyymmdd');
4. emp 테이블에서 부서번호가  10이 아니면서 입사 일자가 1981년 06월 01일 이후 인 사원을 조회하는 쿼리를 작성해라.(NOT IN)
SELECT *
FROM emp
WHERE deptno NOT IN (10)
  AND hiredate >= TO_DATE('19810601', 'yyyymmdd');
5. emp 테이블에서 부서번호가  10이 아니면서 입사 일자가 1981년 06월 01일 이후 인 사원을 조회하는 쿼리를 작성해라.(IN)
SELECT *
FROM emp
WHERE deptno IN (20, 30)
  AND hiredate >= TO_DATE('19810601', 'yyyymmdd');
6. emp 테이블에서 job이 SALESMAN 이거나 사원번호가 78로 시작하는 직원의 정보 조회
SELECT *
FROM emp
WHERE job = 'SALESMAN'
   OR empno LIKE '78%';  형변환 : 명시적, 묵시적
7.emp 테이블에서 job이 SALESMAN 이거나 사원번호가 78로 시작하는 직원의 정보 조회 (LIKE 안쓰고)
SELECT *
FROM emp
WHERE job = 'SALESMAM'
   OR empno BETWEEN 7800 AND 7899
   OR empno BETWEEN 780 AND 789
   OR empno = 78;
7.emp 테이블에서 job이 SALESMAN 이거나 사원번호가 78로 시작하면서 입사날짜가 1981.06.01 이후인 직원의 정보 조회 (LIKE 안쓰고)   
SELECT *
FROM emp
WHERE job = 'SALESMAN'
   OR (empno LIKE '78%' AND hiredate >= TO_DATE('19810601','yyyymmdd')); 
   
SQL 작성 순서      오라클
1           SELECT   3
2           FROM     1
3           WHERE    2
4          ORDER BY  4
## 그래서 나중에 쿼리가 길어지면 오라클 순서대로 하는게 좋다.



정렬
RDBMS 집합적인 사상을 따른다
 집합에는 순서가 없다. (1, 3, 5) == (3, 5, 1)
 집합에는 중복이 없다. (1,3,5,1) ==(3,5,1)
##그래서 데이터 정렬 (ORDER BY)
##첫번째 기술한 조건에서 중복이 있으면 두번째 조건 거기서 중복이면 세번째 조건 .....
정렬 방법 : ORDER BY 절을 통해 정렬 기준 컬럼을 명시
            컬럼 뒤어 [ASc(생략가능)  | DESC]을 기술하여 오름차순, 내림차순을 지정할 수 있다.
1.    ORDER BY 컬럼        
2.    ORDER BY 별칭
3.    ORDER BY  
ex) ORDER BY ename DESC,
오름차순(기본)
SELECT *
FROM emp
ORDER BY ename ;
내림차순
SELECT *
FROM emp
ORDER BY ename DESC;


별칭으로 ORDER BY
SELECT empno, ename, sal, sal*12 salary
FROM emp
ORDER BY salary;

SELECT 절에 기술된 컬럼순서(인덱스)로 정렬 (잘 안씀)
SELECT empno, ename, sal, sal*12 salary
FROM emp
ORDER BY 4;  (4번째 sal*12 salary로 오름차순 정렬을 하겠다)

<실습>
1. dept 테이블의 모든 정보를 부서이름으로 오름차순 정렬
SELECT *
FROM dept
ORDER BY dname;
2. dept 테이블의 모든정보를 회사위치로 내림차순으로 정렬
SELECT *
FROM dept
ORDER BY loc DESC;
3. 상여가 있는 사람만 조회 단, 상여가 많이 받는 순으로 정렬하고, 그다음 조건으론 부서번호를 내림차순으로 정렬해라. (상여가 0인 사람 안나오도록) 
SELECT *
FROM emp 
WHERE comm > 0
ORDER BY comm DESC,empno DESC;

  
