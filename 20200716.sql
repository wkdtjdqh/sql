개발자가 sql을 dbms에 요청을 하더라도
1. 오라클 서버가 항상 최적의 실행계획을 선택할 수는 없음 
    (응답성이 중요하기 때문 : OLTP - 온라인 트랜잭션 프로세싱 화면출력같은)
    (전체 처리 시간이 중요 : OLAP - Online Analtical Processing 은행이자같은 ==> 실행 계획을 세우는데 30분이상이 소요되기도함)
2. 항상 실행계획을 세우지 않음
    만약 동일한 SQL이 이미 실행된적이 있으면 해당 SQL의 실행계획을 세우지 않고 Shared pool(메모리)에 존재하는 실행게획을 재사용
   ##동일한 SQL : 문자가 완벽하게 동일한 SQL
                SQL의 실행결과가 같다고 해서 동일한 SQL이 아님
                대소문자를 가리고, 공백도 문자로 취급
                ex) SELECT * FROM emp;
                    select * FROM emp; 두개의 sql이 서로 다른 SQL로 인식
SELECT /* plan_test */ *
FROM emp
WHERE empno = 7698;
    
select /* plan_test */ *
FROM emp
WHERE empno = 7698;

select /* plan_test */ *
FROM emp
WHERE empno = 7369;

select /* plan_test */ *
FROM emp
WHERE empno = :empno;
##그래서 SQL 을 공유할 목적으로 바인딩변수를 사용한다.


SELECT *
FROM v$sql
WHERE sql_text LIKE '%plan_test%';

===========================================================
JOIN : 두개 이상의 테이블을 하나의 집한으로 만드는 연산

논리적 조인 : 지금까지 배운것
물리적 조인 
NESTED LOOP

HASH JOIN
 - =일때만 사용 가능 왜? 조인 컬럼의 값을 사용하지 않고 난수로 치환하기 때문에(난수를 사용하기 때문에)
 - 조인 테이블의 건수가 한쪽은 많고 한쪽은 작은경우 (작은쪽이 선행, 큰쪽이 후행 / 작은쪽으로 HASH TABLE을 먼저 만듬) 
HASH 함수의 특징? 암호에 사용함. (비밀번호 같은/ 복구 불가능 그래서 재설정하는것)

응답이 빠른 순서  : NESTED -> HASH -> SORF MARGE

Rows, Bytes, Cost -> 오라클이 예상한 값, 실제는 아님



SELECT /*+ 주석문자열에 힌트*/ *
FROM emp
WHERE 
===========
벨런스 트리
=========
인덱스의 특징 pt보고 정리
인덱스를 활용하지 못하는 경우 pt정리
컬럼을 가공하면 -> 해당 컬럼을 인식을 못함
ex )WHERE LOWER(job) = 'salesman' 이래서 좌변을 가공하면 안됨

WHERE job != 'SALESMAN' , job <> 'SALESMAN' 등등 부정형 둘다 안됨.

NOT NULL제약의 중요성 (오라클이 인덱스를 사용할지 말지 결정하는 기준이 될 수 있음)


===================================
DCL (보통 데이터베이스 관리자가 활용, 개발자는 보통 못쓰게함)
DCL : DATA CONTROL Language : 시스템 권한 또는 객체 권한을 부여 / 회수
부여
GRANT 권한명 | 롤명 TO 사용자;
회수
REVOKE 권한명 | 롤명 FROM 사용자;


===================================
SELECT *
FROM dictionary;

SELECT *
FROM user_tables;

SELECT *
FROM all_tables;

SELECT *
FROM dba_tables;

==================================
DATA DICTIONARY
오라클 서버가 사용자 정보를 관리하기 위해 저장한 데이터를 볼 수 있는 view

CATEGORY(접두어)
USER_ : 해당 사용자가 소유한 객체 조회
ALL_ : 해당 사용자가 소유한 객체 조회 + 권한을 부여받은 객체 조회
DBA_ : 데이터베이스에 설치된 모든 객체(DBA권한이 있는 사용자만 가능 -SYSTEM)
v$ : 성능, 모니터와 관련된 특수 view

DCL : DATA CONTROL Language : 시스템 권한 또는 객체 권한을 부여 / 회수
부여
GRANT 권한명 | 롤명 TO 사용자;
회수
REVOKE 권한명 | 롤명 FROM 사용자;
