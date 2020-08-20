SELECT *
FROM emp;


expression : 컬럼값을 가공하거나, 존재하지 않는 새로운 상수값(정해진 값)을 표현
             연산을 통해 새로운 컬럼을 조회할 수 있다. (+,-,*,/,())가능
             연산을 하더라도 해당 SQL 조회 결과에만 나올 뿐이고 실제 테이블의 데이터에는 영향을 주지 않음.
             SELECT 구문은 테이블의 데이터에 영향을 주지 않음.
날짜에 사칙연산 :  수학적으로 정의가 되어 있지 않음.
                SQL에서는 날짜 데이터 +- 정수 --> 정수를 일수 취급
                 '2020년 6월 25일' +5 : 2020년 6월 25일로부터 5일 이후 날짜
                 '2020년 6월 25일' -5 : 2020년 6월 25일로부터 5일 이전 날짜    
                 
SELECT sal, sal + 500, sal-500, sal/500, 500
FROM emp;

SELECT hiredate, hiredate +5, hiredate -5
FROM emp;


데이터 베이스에서 주로 사용하는 데이터 타입 : 문자, 숫자, 날짜
empno : 숫자
ename : 문자
job : 문자
mgr : 숫자
hiredate : 숫자
sal : 숫자
comm : 숫자
deptno : 숫자

테이블의 컬럼구성 정보 확인 : 
DESC 테이블명 (DESCRIBE 테이블명)
DESC emp;


* users 테이블의 컬럼 타입을 확인하고
reg_dt 컬럼 값에 5일 뒤 날짜를 새로운 컬럼으로 표현
조회 컬럼 : userid, reg_dt, reg_dt의 5일뒤날짜

DESC users;

SELECT userid, reg_dt, reg_dt +5
FROM users;


<2교시>

NULL :아직 모르는 값, 할당되지 않은 값
NULL과 숫자타입의 0은 다르다.
NULL과 문자타입의 공백은 다르다.

NULL의 중요한 특징
**NULL을 피연산자로 하는 결과는 항상 NULL**
ex) NULL + 500(피연산자) = NULL

ex) emp테이블에서 sal 컬럼과 comm컬럼의 합을 새로운 컬럼으로 표현
조회 컬럼은 : empno, ename, sal, comm, sal 컬럼과 comm컬럼의 합
ALIAS :컬럼이나, EXPRESSION 에 새로운 이름을 부여
##적용방법 : 컬럼, EXPRESSION [AS] 별칭명 (AS를 쓰는 회사도 있고 안쓰는 회사도 있다. 생략해도 무방 그 회사의 룰에 따를 것)
## sal + comm AS sal_puls_comm  -> AS는 alias 의 약자 
## 별칭을 소문자로 적용 하고 싶은 경우 : 별칭명을 더블 쿼테이션으로 묶는다. (별칭에는 공백 사용 가능 그냥 샤용 불가능)
## sal + comm AS sal puls comm (X)   sal + comm AS "sal puls comm" (O)
SELECT empno, ename, sal s, comm AS "commition", sal + comm AS sal_puls_comm
FROM emp;

<실습>
1.
SELECT prod_id id, prod_name name
FROM prod;
2.
SELECT lprod_gu gu, lprod_nm nm
FROM lprod;
3.
SELECT buyer_id 바이어아이디, buyer_name 이름
FROM buyer;

<3교시>

literal :값 자체
literal 표기법 :값을 표현하는 방법
#문자열#
값 :test
java :System.out.println("test"), java에서는 더블 쿼테이션으로 문자열 표기(싱글로 하면 에러남)
sql : 'test', sql에서는 싱글 쿼테이션으로 문자열 표기
#번외#
int samll = 10;
java 대입연산자: =
pl/sql 대입연산자 : :=
즉, 언어마다 연산자 표기, literal표기법이 다르기 때문에 해당 언어에서 지정하는 방식을 잘 따라야한다.

문자열 연산 : 결합
일상생활에서 문자열 결합 연산자가 존재? 
java에서 문자열 결합 : +
sql에서 문자열 결합 연산자 : ||
sql에서 문자열 결합 함수 : CONCAT(문자열1, 문자열2) --> 문자열 1||문자열2
                        두개의 문자열을 인자로 받아서 결합 결과를 리턴
ex) users 테이블의 userid 컬럼과 usernm 컬럼을 결합
SELECT   userid, usernm, userid || usernm id_name, CONCAT(userid,usernm) concat_id_name
FROM users;

임의 문자열 결합 (sal+500, '아이디:'||userid)
ex) SELECT '아이디 :' ||  userid, 500, 'test'
    FROM users;
    
 <실습>
 ##연산자만 이용해서(가독성을 위해서 함수보다 많이 쓰긴함)
 SELECT 'SELECT * FROM '||table_name ||';' QUERY
 FROM user_tables;
 ##CONCAT 함수만 사용해서
 SELECT CONCAT('SELECT * FROM ',CONCAT(table_name,';')) QUERY
 FROM user_tables; 

<4교시>
  WHERE 절 (필터같은것)
# WHERE : 테이블에서 조회할 행의 조건을 기술
        WHERE 절에서 기술한 조건이 참일 대 해당 행을 조회한다. (거짓일 땐 아무것도 안나옴)
        SQL에서 가장어려운 부분, 많은 응용이 발생하는 부분
 SELECT *
 FROM users
 WHERE userid = 'brown';
 
 emp 테이블에서 deptno 컬럼의 값이 30보다 크거나 같은 행을 조회, 컬럼은 모든 컬럼
 SELECT *
 FROM emp
 WHERE deptno >= 30;
 
 emp 테이블 총 행수 : 14
 SELECT *
 FROM emp
 WHERE 1 = 1;
 
 DATE 타입에 대한 WHERE절 조건 기술   
 ##SQL에서 DATE 리터럴 표기법 : 'RR/mm/dd';
 단 서버 설정마다 표기법이 다르다
 한국 : yy/mm/dd
 미국 : mm/dd/yy
 '12/11/01' -->국가별로 다르게 해석이 가능하기 때문에 DATE 리터럴보다는
                문자열을 DATE타입으로 변경해주는 함수를 주로 사용
                TO_DATE('날짜','첫번째 인자의 형식')
 emp 테이블에서 hiredate 값이 1982년 1월 1일 이후인 사원들만 조회
 SELECT *
 FROM emp
 WHERE hiredate >='1982/01/01'
 
 TO_DATE 함수를 사용하여 날짜 표기
 SELECT *
 FROM emp
 WHERE hiredate >=TO_DATE('1982/01/01', 'YYYY/MM/DD')


BETWEEN AND :두 값 사이에 위치한 값을 참으로 인식
사용방법: 비교값 BETWEEN 시작값 AND 종료값
비교값이 시작값과 종료값을 포함하여 사이에 있으면 참으로 인식
ex) emp 테이블에서 sal 값이 1000보다 크거나 같고 2000보다 작거나 같은 사원들만 조회
SELECT *
FROM emp
WHERE sal BETWEEN 1000 AND 2000;
 sal BETWEEN 1000 AND 2000 조건을 부등호로 나타내면?
SELECT *
FROM emp
WHERE sal >= 1000 
  AND sal >= 2000;
 
 <실습> 
 ##BETWEEN 함수 사용
 SELECT ename, hiredate 
 FROM emp
 WHERE hiredate BETWEEN TO_DATE('1982/1/1','yyyy/mm/dd') AND TO_DATE('1983/1/1','yyyy/mm/dd');
 ##비교 연산자 사용
 SELECT ename, hiredate 
 FROM emp
 WHERE hiredate >= TO_DATE('1982/1/1','yyyy/mm/dd') AND hiredate <= TO_DATE('1983/1/1','yyyy/mm/dd');
 
 SELECT *
 FROM emp
 WHERE doptno = 10
   AND doptno = 20;
   
IN 연산자 : 비교값이 나열된 값에 포함될 때 참으로 인식
사용방법 : 비교값 IN (비교대상 값1,비교대상 값2,비교대상 값3) (비교 1000개정도 가능)
 ex) 사원의 소속 부서가 10번 혹은 20번인 사람을 조히하는 SQL
 SELECT *
 FROM emp
 WHERE deptno IN(10,20);
 ##연산자 사용 했을 때 
 SELECT *
 FROM emp
 WHERE deptno = 10 or deptno = 20;
 
 SELECT *
 FROM emp
 WHERE 10 IN(10,20);    이것도 참이라 값이 나옴

 