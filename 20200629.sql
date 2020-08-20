<1교시> SQL에서 어려운 부분

가상 컬럼 (ROWNUM)
ROWNUM :  SELECT 순서대로 행 번호를 부여해주는 가상컬럼(컬럼이 없는)
특징 : WHERE 절에서 사용 하는게 가능
   ## 사용할 수 있는 형태가 정해져 있음
   WHERE ROWNUM = 1; ROWNUM이 1일 때
   WHERE ROWNUM <= (<) N;  ROWNUM 이 N보다 작거나 같은 경우, 작은 경우
   WHERE ROWNUM BETWEEN 1 AND N; ROWNUM이 1보다 크거나 같고 N보다 작거나 같은경우
   --> ROWNUM은 1부터 순차적으로 읽는 환경에서만 사용이 가능
   ##안되는 경우
   SELECT *
   WHERE ROWNUM = 2
   FROM emp;
   WHERE ROWNUM >= 2;
ROWNUM 사용 용도 : 페이징 처리
페이징 처리란? 네이버 카페이서 게시글 리스트를 한화면에 제한적인 갯수로 조회(100개) ex)1페이지에 10건 2페이지에 10건 이런식으로
            카페에 전체 게시글 수는 굉장히 많음
            --> 한 화면에 못보여줌(1. 웹브라저가 버벅임, 2.사용자의 사용성이 굉장히 불편)
            --> 한 페이지당 건수를 정해놓고 해당 건수만큼만 조회해서 화면에 보여준다.
사용 가능한 형태 예시
SELECT  ROWNUM ,empno, ename
FROM emp
WHERE ROWNUM <= 10;
사용 불가능한 형태 예시 (에러가 나는건 아니지만 값이 안나옴)
SELECT  ROWNUM ,empno, ename
FROM emp
WHERE ROWNUM >= 10;

ROWNUM과 ORDER BY
SELECR SQL의 실행순서 : FROM -> WHERE -> SELECT -> ORDER BY

SELECT ROWNUM ,empno, ename
FROM emp
ORDER BY ename;
## 이렇게 하면 ORDER BY 보다 SELECT 절이 먼저 시행되기 때문에 이상하게 정렬됨

그래서!
ROWNUM의 결과를 정렬 이후에 반영 하고 싶은 경우 --> IN-LINE VIEW 를 사용
VIEW :  SQL -> DBMS에 저장되어있는 SQL 
IN-LINE : 직접 기술 했다, 어딘가에 저장을 한게 아니라 그 자리에 직접 기술


SELECT 절에 *만 단독으로 사용하지 않고 콤마를 통해 다른 임의 컬럼이나 expression을 표기한경우  
        * 앞에 어떤 테이블(뷰)에서 온것인지 한정자 (테이블 이름, view 이름)를 붙여줘야한다.
        
table, view 별칭 : table, view 에도 SELECT절의 컬럼처럼 별칭을 부여할 수 있다
                    단, SELECT절 처럼 AS 키워드는 사용하지 않는다.
                  ex)  FROM emp e
                       FROM (SELECT empno, ename 
                             FROM emp
                             ORDER BY ename) v_emp;
        
SELECT ROWNUM, empno, ename

SELECT a. *
FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename) a;

요구사항 : 1페이당 10건의 사원 리스트가 보여야된다.
페이지 번호, 페이지당 사이즈
1 page : 1~10
2 page : 11~20
3 page : 21~30
*
*
n page : BETWEEN (n-1) *pagesize + 1  AND n*pagesize
페이징처리 쿼리 1page : 1~10
SELECT a. *
FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename) a
WHERE ROWNUM BETWEEN 1 AND 10;

페이징처리 쿼리 2page : 11~20
SELECT a. *
FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename) a
WHERE ROWNUM BETWEEN 11 AND 20;
## ROWNUM의 특성으로 1번부터 읽지 않는 형태이기 때문에 정상적으로 동작하지 않는다.

그래서 ROWNUM의 값을 별칭을 통해 새로운 컬럼으로 만들고 해당 SELECT SQL 을 in-line viewfh
만들어 외부에서 ROWNUM에 부여한 별칭을 통해 페이징 처리를 한다.

페이징처리 쿼리 2page : 11~20
SELECT *
FROM (SELECT ROWNUM rn, a. *
      FROM (SELECT empno, ename 
             FROM emp
             ORDER BY ename) a)
WHERE rn BETWEEN 11 AND 20;



SQL 바인딩 변수 : java의 변수랑 똑같은 개념
페이지 번호 : page
페이지 사이즈 : pagesize
SQL 바인딩 변수 표기 ->    :변수명 --> :page, :pagesize

바인딩 변수 적용한 쿼리 (BETWEEN (:page -1) * :pagesize + 1  AND :page *:pagesize)

페이징처리 쿼리 1page : 1~10
SELECT *
FROM (SELECT ROWNUM rn, a. *
      FROM (SELECT empno, ename 
             FROM emp
             ORDER BY ename) a)
WHERE rn BETWEEN (:page -1) * :pagesize + 1 AND :page *:pagesize;

<2교시> -------------------------------------------------------------
함수
FUNCTION : 입력을 받아들여 특정 로직을 수행후 결과 값을 반환하는 객체
오라클에서 함수 구분 : 입력되는 행의 수에 따라
1. Single row function 
 하나의 행이 입력되서 결과로 하나의 행이 나온다.
2. Multi row function
 여러개의 행이 입력되서 결과로 하나의 행이 나온다.
 
dual 테이블 : oracle의 sys계정에 존재하는 하나의 행, 하나의 컬럼(dummy)을 갖는 테이블
            누구나 사용할 수 있도록 권한이 개방됨
dual 테이블 용도
1. 함수 실행(테스트)
2. 시퀀스 실행
3. merge 구문
4. **데이터 복제(중요)

*LENGTH 함수 테스트
SELECT LENGTH('TEST') 
FROM dual;

문자열 관련 함수 : 설명은 PT 참고, 억지로 외우지는 말자
SELECT CONCAT ('Hello', CONCAT(', ' , 'World')) concat,
       SUBSTR ('Hello, World', 1, 5) substr,     
       LENGTH ('Hello, World') length,
       INSTR ('Hello, World', 'o') instr,
       INSTR ('Hello, World', 'o',INSTR('Hello, World', 'o')+1) instr,
       LPAD('Hello, World',15, ' ')lpad,
       RPAD('Hello, World',15, ' ')rpad,
       REPLACE('Hello, World', 'o', 'p')replace,
       TRIM(' Hello, World ') trim,
       TRIM('d' FROM 'Hello, World') trim,
       UPPER('Hello, World ') upper,
       LOWER('Hello, World ') lower,
       INITCAP('hello, World ') initcap
FROM dual;

함수는 WHERE 절에서도 사용 가능
사원 이름이 smith인 사람
SELECT *
FROM emp
WHERE ename = UPPER('smith');

SELECT *
FROM emp
WHERE LOWER(ename) = 'smith';

위 두개의 쿼리중에서 하지 말아야 할 형태
좌변을 가공하는 형태 (좌변 : 테이블 컬럼을 의미)/ 테이블 컬럼을 가공하지말라
SELECT *
FROM emp
WHERE LOWER(ename) = 'smith';
왜냐하면 이걸 실행하기 위해서는 오라클에서는 emp테이블이 갖고있는 14행을 다 실행해야한다. 
만약 테이블이 갖고있는 건수가 1000건이 넘어간다면


<3교시>------------------------------
오라클 숫자 관련 함수
ROUND(숫자, 반올림 기준자리) : 반올림 함수
TRUNC(숫자, 내림 기준자리) :  내림 함수
MOD(피제수, 제수) : 나머지 값을 구하는 함수/ 피제수: 나눔을 당하는 수

SELECT ROUND(105.54,1) round,
       ROUND(105.55,1) round2,
       ROUND(105.55) round3,
       ROUND(105.55,-1) round4
FROM dual;
** 두번째 인자가 정수면 그 다음 자리에서 반올림
   두번째 인자가 - 이면 그 자리에서 반올림
SELECT ROUND(105.54,1) round    결과값 : 105.5
SELECT ROUND(105.55,-1) round4  결과값 : 110


TRUNC 함수(내림)
SELECT TRUNC(105.54,1) round,
       TRUNC(105.55,1) round2,
       TRUNC(105.55) round3,
       TRUNC(105.55,-1) round4
FROM dual;


MOD함수
sal를 1000으로 나눴을 때의 나머지 --> mod함수, 별도의 연산자는 없다.
몫 :  quotient
나머지  : remider
SELECT ename, sal, MOD(sal, 1000) remider 구할때
FROM emp;

SELECT ename, sal, TRUNC(sal/ 1000) quotient 구할때
FROM emp;

날짜 관련 함수
SYSDATE : 오라클에서 제공해주는 특수함수
        1. 인자가 없다
        2. 오라클이 설치된 서버의 현재 년, 월, 일, 시, 분, 초 정보를 반환 해주는 함수
           (환경설정에 따라 년, 월, 일 만 나올 수도 있다)
        
SELECT SYSDATE
FROM dual;

날짜 타입 +- 정수 : 정수를 일자 취급, 정수만큼 미래, 혹은 과거 날짜의 DATE 값을 반환
ex : 오늘 날짜에서 하루 더한 미래 날짜 값은?
SELECT SYSDATE +1
FROM dual;

ex : 현재 날짜에서 3시간 뒤 DATE를 구하려면?
데이트  + 정수 (하루)
1시간 1/24
3시간 (1/24) *3 = 3/24
1분 1/24/60
30분 (1/24/60) *30
SELECT SYSDATE + (1/24)*3
FROM dual;
SELECT SYSDATE  + (1/24/60) *30
FROM dual;

DATE 표현하는 방법
1. DATE 리터럴 : NSL_SESSION_PARATER 설정에 따르기 떄문에 DBMS 환경 마다 다르게 인식될 수 있음
2. TO_DATE  문자열을 날짜로 변경해주는 함수 (결과를 날짜로 인식)
3. SYSDATE  시스템상의 현재 날짜 나오게 하는 함수
4. TO_CHAR  날짜를 내가 원하는 형태로 표시하고 싶을 때(결과를 문자로 인식)

<실습>
SELECT TO_DATE('20191231','YYYYMMDD') LASTDAY, 
       TO_DATE('20191231','YYYYMMDD') - 5 LASTDAY_BEFORE5,
       SYSDATE NOW,
       SYSDATE -3 NOW_BEFORE3
FROM dual;

문자열 ==> 데이트
TO_DATE(날짜 문자열, 날짜 문자열의 패턴);
데이트 ==> 문자열(보여주고 싶은 형식을 지정할때)
TO_CHAR(데이트 값, 표현하고 싶은 문자열 패턴);

SYSDATE 현재 날짜를 년도 4자리-월 2자리-일2자리

SELECT SYSDATE, TO_CHAR(SYSDATE,'YYYYMMDD'),
       TO_CHAR (SYSDATE,'d'),TO_CHAR(SYSDATE,'IW')
FROM dual;
##내가 원하는 형태로 바꿀 수 있다.


날짜 포맷 : PT참고
YYYY
MM
DD
HH24
MI
SS

특수한경우 D, IW

SELECT ename, hiredate, TO_CHAR(hiredate,'YYYY/MM/DD HH24:MI:SS') h1,
        TO_CHAR(hiredate +1 ,'YYYY/MM/DD HH24:MI:SS') h2,
        TO_CHAR(hiredate + 1/24,'YYYY/MM/DD HH24:MI:SS') h3
FROM emp;

<실습>
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD') dt_dash,
       TO_CHAR(SYSDATE,'YYYY-MM-DD HH24-MI-SS') dt_dash_with_time,
       TO_CHAR(SYSDATE,'DD-MM-YYYY') dt_dd_mm_yyyy
FROM dual;




