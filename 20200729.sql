정규화는 몇단계?
[1-2-3]-BCNF-4-5

정규화 순서 : 순서대로 하는게 맞음
1-2-3

정규화 : 데이터 상태 이상을 방지

정규화 끝나고 나서 물리적인 고려 : 반정규화
nomalization                    de-nomalization
성능을 위해서 인위적인 컬럼을 추가할 순 있는데 값이 틀어질 가능성이 있다.

==========================================================

수직분할도 반정규화

수평분할은 파티션으로 만들수 있는것
====================================
pl/SQL record type
java에서 클래스를 인스턴스로 생성을 하려면
1. class : (붕어빵 틀)
2. 1번에서 생성한 class를 활용하여 row연산자를 통해 instance를 생성(붕어빵)

dept테이블의 10번 부서의 부서번호랑. 부서 이름을 pl/sql record type으로 생선된 변수에
값을 담아서 출력 (dept모든컬럼을 조회하는 것이 아니라 , 일부만 조회)

TYPE 선언방법 :
TYPE 타입이름(class이름 짓기) IS RECORD(
    컬렁명1 타입명 1
    컬럼명2 타입명 2
    );
    
    변수명 변수타입;
    변수명 타입이름;
    
SET SERVEROUTPUT ON;    
    
DECLARE
    TYPE dept_rec_type IS RECORD(
   dname dept.dname%TYPE,
   deptno dept.deptno%TYPE
   );
   
   dept_rec dept_rec_type;
BEGIN
 SELECT dname, deptno INTO dept_rec
 FROM dept
 WHERE deptno = 10;
 
 DBMS_OUTPUT.PUT_LINE('deptno : ' || dept_rec.deptno || ' / dname : ' || dept_rec.dname);
END;
/


================================================
TABLE TYPE : 여러건의 행을 저장할 수 있는 타입
dept 테이블의 모든 행을 담아보는 실습

TABLE TYPE 선언
TYPE 테이블 타입 이름 IS TABLE OF 행의 타입 INDEX BY BINARY_INTEGER;

테이블 타입의 인덱스는 java와 다르게 1부터 시작한다.

DECLARE
    TYPE dept_tab_type IS TABLE OF dept%ROWTYPE INDEX BY BINARY_INTEGER;
    dept_tab dept_tab_type;
BEGIN
    SELECT * BULK COLLECT INTO dept_tab
    FROM dept;
    
    FOR i IN  1..dept_tab.count LOOP
     DBMS_OUTPUT.PUT_LINE('deptno : ' || dept_tab(i).deptno );
    END LOOP;
    
END;
/
=================================================
조건제어 - 분기 (if)
구문
IF condition THEN 
    실행할 문장
ELSIF condition THEN
    실행할 문장
ELSE
    실행할 문장
END IF;


DECLARE
    p NUMBER := 2;
BEGIN
    IF p = 1 THEN
    DBMS_OUTPUT.PUT_LINE('p = 1');
    ELSIF p = 2 THEN
     DBMS_OUTPUT.PUT_LINE('p = 2');
    ELSE
    DBMS_OUTPUT.PUT_LINE('ELSE');
    END IF;
END;
/
==============================================
FOR LOOP 

문법
FOR 인덱스변수 IN [REVERSE] 시작값..종료값 LOOP
    반복실행할 문장;
END LOOP;

1~5까지 출력
DECLARE
BEGIN
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/

구구단 출력
DECLARE --선언할 변수가 없어서 생략가능
BEGIN
    FOR i IN 2..9 LOOP
        DBMS_OUTPUT.PUT_LINE(' ');
        FOR j IN 1..9 LOOP
            DBMS_OUTPUT.PUT_LINE(i || ' * ' ||j ||' = '|| i*j);
        END LOOP;
    END LOOP;
END;
/
=============================================
while
문법
    WHILE 조건 LOOP
        반복할 문장;
    END LOOP;

DECLARE
 i NUMBER := 0;
BEGIN
    WHILE i <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
        i := i + 1;
    END LOOP;
END;
/


==============================================
LOOP    
    
문법
LOOP
    반복 실행할 문장;
    EXIT 탈출조건
    반복 실행할 문장;
END LOOP;

DECLARE
    i NUMBER := 0;
BEGIN
    LOOP
        EXIT WHEN i > 5;
        DBMS_OUTPUT.put_LINE(i);
        i := i + 1;
    END LOOP;
END;
/


============================================
SQL - DBMS
실행계획 -> 바인드 -> 실행 ->Fetch(인출)

운반단위(buffer) JDBC : 15건
                SQl : 50건

CURSOR : SELECT문이 실행되는 메모리 상의 공간
        다량의 데이터를 변수에 담게되면 메모리 낭비가 심해져 프로그램이 정상적으로 동작 못할 수도 있음.
        
        그래서 한번에 모든 데이터를 인출하지 않고, 개발자가 직접 인출 단계를 제어 함으로써
        변수에 모든 데이터를 담지 않고도 개발하는 것이 가능.
        
CURSOR의 종류
묵시적 커서 : 커서이름을 변도로 지정하지 않을 경우 ==> ORACLE이 알아서 처리해줌
명시적 커서 : 커서를 명시적이름과 함계 선언하고, 개발자가 해당 커서를 직접 제어가능

명시적 CURSOR 사용방법 (잘 안씀)
1. 커서 선언 (DECLARE)
    CURSOR 커서이름 IS
        SELECT 쿼리;
2. 커서 열기
    OPEN 커서이름;
3. FETCH (인출)
    FETCH 커서이름 INTO 변수
4. 커서 닫기
    CLOSE 커서이름;


dept테이블의 모든 행에 대해 부서번호, 부서이름을 cursor를 통해 데이터를 다루는 실습

DECLARE
    CURSOR dept_cur IS
        SELECT deptno, dname
        FROM dept;
    v_deptno dept.deptno%TYPE;
    v_dname dept.dname%TYPE;
BEGIN
    OPEN dept_cur;
    LOOP 
        FETCH dept_cur INTO v_deptno, v_dname;
        EXIT WHEN dept_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_deptno || ', ' || v_dname);
    END LOOP;
    CLOSE dept_cur;
END;
/

CURSOR의 경우 반복문과 사용되는 일이 많기 때문에
PL/SQL 에서는 FOR LOOP문과 함께 사용하는 문법을 지원한다.(많이 씀)

문법
    FOR 레코드명 IN 커서명 LOOP
        반복실행할 문장;
    END LOOP;

OPEN, FETCH, CLOSE : 2~4단계를 FOR LOOP가 알아서 해줌

DECLARE
    CURSOR dept_cur IS
        SELECT deptno, dname
        FROM dept;
BEGIN
    FOR dept_row IN dept_cur LOOP
        DBMS_OUTPUT.PUT_LINE(dept_row.deptno || ', ' || dept_row.dname);
    END LOOP;
END;
/

emp 테이블에서 특정 부서에 속하는 사원의 사번과, 이름을 출력하는 로직을 파라미터가 있는 커서를 활용하여 작성하는 실습
DECLARE
    CURSOR emp_cur (p_deptno dept.deptno%TYPE) IS -- 파라미터를 만들어서 사용함
        SELECT empno, ename
        FROM emp
        WHERE deptno = p_deptno; 
BEGIN
    FOR emp_row IN emp_cur(30) LOOP
        DBMS_OUTPUT.PUT_LINE(emp_row.empno || ', ' || emp_row.ename);
    END LOOP;
    
END;
/

================================================
인라인 커서
FOR LOOP 기술시 커서를 직접 기술

BEGIN
    FOR dept_row IN (SELECT deptno, dname FROM dept) LOOP
        DBMS_OUTPUT.PUT_LINE(dept_row.deptno || ', ' || dept_row.dname);
    END LOOP;
END;
/







 
