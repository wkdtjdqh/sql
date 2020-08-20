DROP TABLE  dept_test;

제약조건 생성 방법 중 2번째 : 테이블 생성시, 모든 컬럼을 기술이후 제약조건만 별도로 기술
dept_test 테이블의 deptno컬럼을 대상으로 PRIMARY KEY  제약 조건생성

CREATE TABLE dept_test(
    DEPTNO    NUMBER(2),    
    DNAME     VARCHAR2(14), 
    LOC       VARCHAR2(13),
    
    CONSTRAINT pk_dapt_test PRIMARY KEY (DEPTNO)
);

dept_test 테이블에 deptno가 동일한 값을 갖는 INSERT쿼리를 2개 생성하여
2개의 쿼리가 정상적으로 동작하는지 테스트
INSERT INTO dept_test VALUES('99','ddit','deajeon');

INSERT INTO dept_test VALUES('99','대덕','대전');
오류 보고 -
ORA-00001: unique constraint (JW.PK_DAPT_TEST) violated : unique 제약조건에 위반, 중복된 값이 들어갔다.


NOT NULL 제약조건: 컬럼 레벨에 기술, 테이블 기술 없음, 테이블 수정시 변경 가능)
SELECT *
FROM dept_test;

INSERT INTO dept_test VALUES('98',NULL,'대전'); 
아직 NOT NULL제약조건을 걸지 않아서 NULL값 가능


DROP TABLE  dept_test;

CREATE TABLE dept_test(
    DEPTNO    NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY,    
    DNAME     VARCHAR2(14) NOT NULL, 
    LOC       VARCHAR2(13) 
);

INSERT INTO dept_test VALUES('98',NULL,'대전');
오류 보고 -
ORA-01400: cannot insert NULL into ("JW"."DEPT_TEST"."DNAME") : NULL 값이 있으면 안된다.

------------------------------------------------------------------------------------
UNIQUE 제약조건 : 해당 컬럼의 값이 다른 행에 나오지 않도록(중복되지 않도록) 데이터 무결성을 지켜주는 조건(ex 사번, 학번)
수업시간 UNIQUE 제약조건 명명 규칙 : UK_테이블명_해당컬럼명

DROP TABLE  dept_test;

CREATE TABLE dept_test(
    DEPTNO    NUMBER(2),    
    DNAME     VARCHAR2(14), 
    LOC       VARCHAR2(13),
    CONSTRAINT uk_dept_test_dname UNIQUE(dname, loc)
);
:unique제약조건에 복합컬럼을 걸었다. 

dname, loc를 결합해서 중복되는 데이터가 없으면 됨
ddit, 'daejeon'
ddit, '대전' (O)
부서명은 동일하지만 loc정보가 다르기 때문에 dname, loc조합은 서로 다른 데이터 

ddit, 'daejeon'
ddit, 'daejeon' (X)
둘다 동일해서 제약조건 위반

ex)
dname, loc 컬럼조합의 값이 동일한 데이터인 경우 ==> 에러 
INSERT INTO dept_test VALUES(90,'ddit','daejeon');
INSERT INTO dept_test VALUES(90,'ddit','daejeon');
오류 보고 -
ORA-00001: unique constraint (JW.UK_DEPT_TEST_DNAME) violated : unique 제약조건 위반
ROLLBACK;

dname, loc 컬럼조합의 값이 다른 데이터인 겨우 ==> 성공
INSERT INTO dept_test VALUES(90,'ddit','daejeon');
INSERT INTO dept_test VALUES(90,'ddit','대전');

---------------------------------------------------------
FOREIGN KEY : 참조키 
한 테이블의 컬럼의 값이 참조하는 테이블의 컬럼 값중에 존재하는 값만 입력되도록 제어하는 제약조건
즉, FOREIGN KEY 경우 두개의 테이블간의 제약조건(두개의 테이블이 필요)
*참조되는 테이블의 컬럼에는(dept_test.deptno) 인덱스가 생성되어 있어야한다. 자세한 내용은 INDEX편에서 다시 배우도록

DROP TABLE  dept_test;

CREATE TABLE dept_test(
    DEPTNO    NUMBER(2),    
    DNAME     VARCHAR2(14), 
    LOC       VARCHAR2(13),
    CONSTRAINT pk_dept_test PRIMARY KEY (deptno) 
);
테스트 데이터 준비
INSERT INTO dept_test VALUES ( 1, 'ddit','daejeon');

dept_test 테이블의 deptno 컬럼을 참조하는 emp_test 테이블생성
DESC emp;

CREATE TABLE emp_test (
empno NUMBER(4),
ename VARCHAR(10),
deptno NUMBER(2) REFERENCES dept_test (deptno)
);

1.dept_test테이블에는 부서번호가 1번인 부서가 존재
2.emp_test 테이블의 deptno 컬럼으로 depto_test.deptno컬럼을 참조
==>emp_test 테이블의 deptno컬럼에는 depto_test.deptno컬럼에 존재하는 값만 입력하는 것이 가능

dept_test 테이블에 존재하는 부서번호로 emp_test테이블에 입력하는 경우우
INSERT INTO emp_test VALUES (9999, 'brown', 1);
dept_test 테이블에 존재하지 않는 부서번호로 emp_test테이블에 입력하는 경우 - 에러
INSERT INTO emp_test VALUES (9999, 'brown', 2);
오류 보고 -
ORA-02291: integrity constraint (JW.SYS_C007105) violated - parent key not found



FK 제약조건을 테이블 컬럼 기술이후에 별도로 기술하는 경우
CONSTRAINT 제약조건명 제약조건 타입 (대상컬럼) REFERENCES 참조테이블(참조테이블의 컬럼명)
수업시간 명명규칙 : FK_타겟테이블명_참조테이블명[INDEX]
DROP TABLE  emp_test;

CREATE TABLE emp_test (
empno NUMBER(4),
ename VARChAR(10),
deptno NUMBER(2),
CONSTRAINT FK_emp_test_dept_test FOREIGN KEY (deptno) REFERENCES dept_test (deptno)

);

dept_test 테이블에 존재하는 부서번호로 emp_test테이블에 입력하는 경우
INSERT INTO emp_test VALUES (9999, 'brown', 1);
dept_test 테이블에 존재하지 않는 부서번호로 emp_test테이블에 입력하는 경우 - 에러
INSERT INTO emp_test VALUES (9999, 'brown', 2);
오류 보고 -
ORA-02291: integrity constraint (JW.SYS_C007105) violated - parent key not found

참조키 주의사항(pt보고 정리)


참조되고 있는 부모쪽 데이터를 삭제하는 경우
dept_test테이블에 1번 부서가 존재하고 emp_test테이블의 brown사원이 1번 부서에 속한 상태에서 1번 부서를 삭제하는 경우
FK의 기본 설정에서는 참조하는 데이터가 없어 질수 없기 때문에 에러발생
SELECT *
FROM emp_test

DELETE dept_test
WHERE deptno = 1;
오류 보고 -
ORA-02292: integrity constraint (JW.FK_EMP_TEST_DEPT_TEST) violated - child record found : 자식인 데이터가 있어서 삭제할 수 없음.

FK 생성시 옵션
0. DEFAULT : 무결성이 위배되는 경우 에러
1.ON DELETE CASCADE : 부모 데이터를 삭제할경우 참조하는 자식 데이터를 같이 삭제
 (ex dept_test 테이블의 1번부를 삭제하면 1번부서에 소속된 brown사원도 삭제)
2.ON DELETE SET NULL : 부모데이터를 삭제할 경우 참조하는 자식 데이터의 컬럼을 NULL로수정

-----------------------------------
1번 ON DELETE CASCADE  테스트
DROP TABLE  emp_test;

CREATE TABLE emp_test (
empno NUMBER(4),
ename VARChAR(10),
deptno NUMBER(2),

CONSTRAINT fk_emp_test_dept_test FOREIGN KEY(deptno) REFERENCES dept_test(deptno) ON DELETE CASCADE
);

INSERT INTO emp_test VALUES(9999, 'brown', 1);
부모데이터 삭제
DELETE dept_test
WHERE deptno = 1;

SELECT *
FROM emp_test
##부모데이터를 삭제하니 자식데이터도 자동삭제됨.


----------------------------------------------------
2번 ON DELETE SET  NULL 테스트
DROP TABLE  emp_test;

CREATE TABLE emp_test (
empno NUMBER(4),
ename VARChAR(10),
deptno NUMBER(2),

CONSTRAINT fk_emp_test_dept_test FOREIGN KEY(deptno) REFERENCES dept_test(deptno) ON DELETE SET  NULL
);
INSERT INTO dept_test VALUES(1,'ddit','daejeon');
INSERT INTO emp_test VALUES(9999, 'brown', 1);
부모데이터 삭제
DELETE dept_test
WHERE deptno = 1;

SELECT *
FROM emp_test;

---------------------------------------------------
CHECK 제약조건(생각보다 많이 쓰진 않음)
: 컬럼에 입력되는 값을 검증하는 제약조건
(ex : salary 컬럼(급여)이 음수가 입력되는 것은 부자연스러움, 성별에 남, 여가 아닌 값이 들어오는 것은 데이터가 잘못된 것
        직원 구분이 정직원, 임시직 2개가 존재할때 다른 값이 들어오면 논리적으로 어긋남)

DROP TABLE  emp_test;
CREATE TABLE emp_test (
empno NUMBER(4),
ename VARChAR(10),
--sal NUMBER(7,2) CHECK (sal > 0)
sal NUMBER(7,2) CONSTRAINT sal_no_zero CHECK (sal > 0)
);##IS NOT NULL, IN 이런것도 가능


sal 값이 음수인 데이터 입력
INSERT INTO emp_test VAlUES(9999, 'brown',-500);
오류 보고 -
ORA-02290: check constraint (JW.SAL_NO_ZERO) violated : CHECK제약조건 위반
-----------------------------------------------

테이블 생성 + [제약조건 포함] CTAS라고 줄여서 읽음
CREATE TABLE 테이블명 AS
SELECT....

CTAS 명령을 이용하여 emp테이블의 모든 데이터를 바탕으로 emp_test 테이블 생성
DROP TABLE emp_test;

CREATE TABLE emp_test AS
SELECT *
FROM emp;

CREATE TABLE emp_test2 AS
SELECT *
FROM emp
WHERE 1 != 1;
##테이블 컬럼 구조만 복사하고 싶을 때 WHERE절에 항상 FALSE가 되는 조건을 기술하여 생성 가능


생성된 테이블 변경
컬럼 작업
1.존재하지 않았던 새로운 컬럼 추가
** 테이블의 컬럼 기술순서를 제어하는건 불가. 신규로 추가하는 컬럼의 경우 컬럼순서가 항상 테이블의 마지막 
** 설계를 할 때 컬럼순서에 충분히 고려, 누락된 컬럼이 없는지도 고려

2.존재하는 컬럼 삭제
**제약조건(FK) 주의

3. 존재하는 컬럼 변경
* 컬럼명 변경 ==> FK와 관계 없이 알아서 적용해줌
* 그 외적인 부분에서는 사실상 불가능하다고 생각하면 편함
        (데이터가 이미 들어가 있는 테이블의 경우)
        1. 컬럼 사이즈변경
        2. 컬럼 타입변경
        ==>설계시 충분히 고려

4. 제약조건 작업
    1. 제약조건 추가
    2. 제약조건 삭제
    3.제약조건 비활성화, 활성화

------------ex)
DROP TABLE  emp_test;

CREATE TABLE emp_test (
empno NUMBER(4),
ename VARChAR(10),
deptno NUMBER(2) 
);

테이블 수정
ALTER TABLE 테이블명 ...

1.신규컬럼 추가(맨 마지막에 추가됨, 순서는 변경 불가능)(ADD)
ALTER TABLE emp_test ADD (hp VARCHAR2(11));

SELECT *
FROM emp_test;
## hp 컬럼 추가 됨

2.컬럼 수정(MODIFY)
** 데이터가 존재하지 않을 때는 비교적 자유롭게 수정가능
ALTER TABLE emp_test MODIFY (hp VARCHAR2(5));
ALTER TABLE emp_test MODIFY (hp NUMBER);

    컬럼 기본값 설정
    ALTER TABLE emp_test MODIFY (hp DEFAULT 123);
    
    INSERT INTO emp_test(empno, ename, deptno) VALUES( 9999, 'brown', NULL);
    
    SELECT *
    FROM emp_test;

    컬럼명칭변경(RENAME COLUMN 현재컬럼명 TO 변경할 컬럼명)
    ALTER TABLE emp_test RENAME COLUMN hp TO cell;
    SELECT *
    FROM emp_test;
    
    컬럼삭제(DROP, DROP COLUMN)
    ALTER TABLE emp_test DROP (cell);
    ALTER TABlE emp_tset DROP COLUMN cell;
    
    DESC emp_test;

3. 제약조건 추가(ADD), 삭제(DROP)
            +
    테이블 레벨의 제약조건 생성

ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명 제약조건타입 대상컬럼

    별도의 제약조건없이 emp_test 테이블 생성
    DROP TABLE  emp_test;
    
    CREATE TABLE emp_test (
    empno NUMBER(4),
    ename VARChAR(10),
    deptno NUMBER(2)
    );
    
    테이블 수정을 통해서 emp_test 테이블의 empno컬럼에 PRIMARY KEY 제약조건 추가
    ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);
    
    제약조건 삭제 (DROP)
    ALTER TABLE emp_test DROP CONSTRAINT pk_emp_test;

4. 제약조건 활성 / 비활성
제약조건 DROP은 제약조건 자체를 삭제하는 행위
제약조건 비활성화는 제약조건 자체는 남겨두지만, 사용하지는 않는 형태
때가되면 다시 활성화 하여 데이터 무결성에 대한 부분을 강제할 수 있음.

DROP TABLE  emp_test;
CREATE TABLE emp_test (
empno NUMBER(4),
ename VARChAR(10),
deptno NUMBER(2)
);

테이블 수정명령을 통해 emp_test 테이블의 empno컬럼으로 PRIMARY KEY 제약 생성
ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);

제약조건을 활성화 비활성화 (ENABLE /DISABLE)
ALTER TABLE emp_test DISABLE CONSTRAINT pk_emp_test;
##pk_emp_test가 비활성화 되어 있기 때문에 empno컬럼에 중복되는 값 입력가능
INSERT INTO emp_test VALUES (9999, 'brown' , NULL);
INSERT INTO emp_test VALUES (9999, 'sally' , NULL);

pk_emp_test 제약조건을 활성화
ALTER TABLE emp_test ENABLE CONSTRAINT pk_emp_test;
오류 보고 -
ORA-02437: cannot validate (JW.PK_EMP_TEST) - primary key violated - 제약조건 위배
##중복되는 데이터를 삭제하던가, 아니면 그대로 비활성화 하던가 해야한다.
---------------------------------------------
DICTIONARY : 사전 같은 의미 
(테이블) - 전체 테이블 검색가능
SELECT *
FROM user_tables;

(제약조건) - 제약조건 검색가능
SELECT *
FROM user_constraints
WHERE constraint_type = 'P';
--WHERE table name = 'EMP_TEST'


제약조건별 컬럼정보
SELECT *
FROM user_cons_columns
WHERE table_name = 'CYCLE'

테이블에 대한 코멘트(주석같은것 해당테이블이 뭔지)
SELECT *
FROM user_tab_comments;

컬럼에 대한 코멘트
SELECT *
FROM user_col_comments;

테이블, 컬럼 주석달기
COMMENT ON TABLE 테이블명 IS '주석';
COMMENT ON COLUMN 테이블명.컬럼명 IS '주석';

emp_test 테이블, 컬럼에 주석
COMMENT ON TABLE emp_test IS '사원_복제';
COMMENT ON COLUMN emp_test.empno IS '사번';
COMMENT ON COLUMN emp_test.ename IS '사원이름';
COMMENT ON COLUMN emp_test.deptno IS '소속부서번호';

SELECT  *
FROM user_tab_comments;

SELECT *
FROM user_col_comments
WHERE table_name = 'EMP_TEST';
## 우리가 따로 설정하지 않으면 다 대문자로 들어간다.


ex)
user_tab_comments, user_col_comments view를 이용하여
customer, product, cycle, daily 테이블과 컬럼의 주석정보를 조회하는 쿼리를 작성하여라.

SELECT tab.*, col.column_name, col.comments col_comments
FROM user_tab_comments tab, user_col_comments col
WHERE tab.table_name = col.table_name
 AND tab.table_name IN('CYCLE','PRODUCT','DAILY');

------------------------------------------------------    
ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY(empno);
ALTER TABLE dept ADD CONSTRAINT pk_detp PRIMARY KEY(deptno);
ALTER TABLE emp ADD CONSTRAINT FK_emp FOREIGN KEY (deptno) REFERENCES dept (deptno);

DELETE dept
WHERE dname = 'ddit'


SELECT *
FROM dept



