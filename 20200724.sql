계층쿼리
1. CONNECT BY LEVEL <, <= 정수
    : 시작행, 연결될 다음 행과의 조건이 없음
    ==> CROSS JOIN과 유사
    ==>일반테이블과 사용하면 행이 기하급수적으로 늘어서 사용하지 않고 dual테이블과만 사용
2. START WITH, CONNECT BY : 일반적인 계층 쿼리
                            시작 행 지칭, 연결될 다음 행과의 조건을 기술
                            
ex)
CREATE TABLE imis(
t VARCHAR2(2)
);


INSERT INTO imis VALUES ('a');
INSERT INTO imis VALUES ('b');
COMMIT;

SELECT t, LEVEL, LTRIM(SYS_CONNECT_BY_PATH(t,'-'),'-')
FROM imis
CONNECT BY LEVEL <= 3;  ==> 결과 14건

SELECT DUMMY, LEVEL
FROM dual
CONNECT BY LEVEL <= 10;

==============================================================================
WINDOW 함수
LAG(col) : 파티션별 이전 행의 특정 컬럼 값을 가져오는 함수 (맨 위의 값이 null)
LEAD(col) : 파티션별 이후 행의 특정 컬럼 값을 가져오는 함수 (맨 마지막 값이 null)

ex)
전체 사원의 급여 순위가 자신보다 1단계 낮은 사람의 급여값을 5번째 컬럼으로 생성 ( 단 급여가 같을 경우 입사일자가 빠른 사람이 우선순위가 높음)
SELECT empno, ename, hiredate, sal
FROM emp
ORDER BY sal DESC, hiredate;

SELECT empno, ename, hiredate, sal, LEAD(sal) OVER (ORDER BY sal DESC, hiredate) lead_sal
FROM emp;

SELECT empno, ename, hiredate, sal, LAG(sal) OVER (ORDER BY sal DESC, hiredate) lead_sal
FROM emp;


<실습>
SELECT empno, ename, hiredate, job, sal, LAG(sal) OVER(PARTITION BY job ORDER BY sal DESC, hiredate) lag_sal
FROM emp;
##파티션으로 그룹을 나누고 정렬

SELECT  empno, ename, hiredate, sal, a.cnt
FROM
(SELECT empno, ename, hiredate, sal, COUNT(*) cnt
FROM emp
ORDER BY sal DESC) a,
(SELECT LEVEL lv
FROM dual
CONNECT BY LEVEL <= (SELECT COUNT(*) FROM emp))b
WHERE a.cnt = b.lv

윈도우 함수를 안쓰고
SELECT a.empno, a.ename, a.hiredate, a.sal, b.sal
FROM 
    (SELECT ROWNUM rn, a.* 
    FROM
        (SELECT empno, ename, hiredate, sal
        FROM emp
        ORDER BY sal DESC, hiredate)a)a,
    (SELECT ROWNUM rn, a.* 
     FROM
        (SELECT empno, ename, hiredate, sal
        FROM emp
        ORDER BY sal DESC, hiredate)a)b
WHERE a.rn-1 = b.rn(+)
ORDER BY a.sal DESC, a.hiredate




=====================================================
WINDOWING : 파티션 내의 행들을 세부적으로 선별하는 범위를 기술
1. UNBOUNDED PRECEDING : 현재 행을 기준으로 선행(이전)하는 모든 행들
2. CURRENT ROW : 현재 행
3. UNBOUNDED FOLLOWING : 현재행을 기준으로 이후 모든 행들

WINDOWING 기본 설정값이 존재 : RANGE UNBOUNDED PRECEDING AND CURRENT ROW (값이 같으면 같은 행으로 생각)

SELECT empno, ename, sal
FROM emp
ORDER BY sal;

//sal의 누적합 구하기
SELECT empno, ename, sal, SUM(sal) OVER( ORDER BY sal ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) c_sum
FROM emp

SELECT empno, ename, sal, SUM(sal) OVER(ORDER BY sal) c_sum
FROM emp

//현재 행을 기준으로 앞뒤의 행의 누적
SELECT empno, ename, sal, SUM(sal) OVER(ORDER BY sal ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) c_sum
FROM emp

//부서별 급여와 사번으로 정렬을 한후 현재 행과 선행하는 행들의 누적합
SELECT empno, ename, deptno, sal, SUM(sal) OVER (PARTITION BY deptno ORDER BY sal, empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum
FROM emp


## ROWS 와 RANGE
SELECT empno, ename, deptno, sal, SUM(sal) OVER(ORDER BY sal ROWS UNBOUNDED PRECEDING)rows_sum,
                                  SUM(sal) OVER(ORDER BY sal RANGE UNBOUNDED PRECEDING)range_sum,
                                  SUM(sal) OVER(ORDER BY sal)c_sum
FROM emp

=====================================================================
모델링 과정(요구사항 파악 이후)
[개념모델] -      ( 논리모델 - 물리모델 )**
논리 모델의 요약판

논리 모델 : 시스템에서 필요로 하는 엔터티(테이블), 엔터티의 속성, 엔터티간의 관계를 기술
            데이터가 어떻게 저장되지는 관심사항이 아니다 ==> 물리 모델에서 고려할 사항
            논리 모델에서는 데이터의 전반적인 큰 틀은 설계
물리 모델 : 논리 모델을 갖고 해당 시스템이 사용할 데이터베이스를 고려하여 최적화된 테이블, 컬럼, 제약조건을 설계하는 단계

논리 모델         :     물리 모델
엔터티 type      :       테이블
속성             :       컬럼
식별자(속성)      :      KEY ==> 행들을 구분할 수 있는 유일한 값
관계(relation)   :  제약조건
관계차수 : 1-N, 1-1, n-n ==> 1:n으로 변경할 대상
        수직바, 까마귀발
관계 옵션 : mandatory(필수),optional(옵션) O표기

요구사항(요구사항 기술서, 장표, 인터뷰)에서 명사 ==> 엔터티 or 속성일 확률이 높음

명명규칙
엔터티 : 단수 명사 (서술식 표현은 잘못된 표현, 복수 명사도 X)
