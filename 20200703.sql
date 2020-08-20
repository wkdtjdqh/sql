JOIN실습
perspective : 사용자들이 많이 사용하는 뷰들을 모아놓은것 
ctrl + f8 -> perspective왔다 갔다 하는 단축키 
ctrl + f7 뷰 간 서로 왔다 갔다 할 수 있는 단축키

ctrl + m  뷰 제일 크게 했다가 다시 ctrl + m 누르면 원래 상태로 돌아옴. 보통은 코딩할 때 뷰 제일 크게 해놓고 씀

ctrl + shift + r ->  open resource가 열리는데 패키지명이나 어디에 들어있는지 모르고 파일명만 알때 검색창에 치면 파일이 뜸.

ctrl + pageup or ctrl + page down ->열려있는 에디터(메인작업창)창 왔다갔다 할 수 있는 단축키

논리모드 : 그 테이블의 진짜 영문명
물리모드 : 각 나라의 언어로 번역


<실습>
1. erd다이어그램을 참고하여 prod 테이블과 lprod테이블을 조인하여 다음과 같은 결과가 나오는 쿼리를 작성.
<oracle>
SELECT lprod_gu, lprod_nm, prod_id, prod_name
FROM prod, lprod
WHERE prod.prod_lgu = lprod.lprod_gu;
##실제 데이터 건은 74행인데 오라클 자체에 페이징 처리가 50건으로 되어있어서 처음에는 50으로 뜨고, 그후에 스크롤 하면 74행 된다 

<ansi> 
SELECT lprod_gu, lprod_nm, prod_id, prod_name
FROM prod JOIN lprod ON(prod.prod_lgu = lprod.lprod_gu);
##조인하는 컬럼명이 달라서 JOIN with ON사용

2.erd다이어그램을 참고하여 prod 테이블과 buyer테이블을 조인하여 buyer별 담당하는 제품 나오도록 쿼리 작성.
<oracle>
SELECT buyer_id, buyer_name, prod_id, prod_name
FROM prod p, buyer b
WHERE p.prod_buyer = b.buyer_id; 
##집합적인 개념이라 FROM에 기술하는 테이블 순서는 상관 없다.
<ansi>
SELECT buyer_id, buyer_name, prod_id, prod_name
FROM prod p JOIN buyer b ON(p.prod_buyer = b.buyer_id);


#
SELECT buyer_id, COUNT(buyer_id)
FROM prod p JOIN buyer b ON(p.prod_buyer = b.buyer_id)
GROUP BY buyer_id;

3. erd다이어그램을 참고하여 member, cart, prod를 연결하여 회원별 장바구니에 담은 정보를 출력할 수있는 쿼리
(oracle)
SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM
     (SELECT *
     FROM member m, cart c
     WHERE m.mem_id = c.cart_member)a, prod p
WHERE a.cart_prod = p.prod_id;


(oracle)
SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM member m, cart c, prod p
WHERE m.mem_id = c.cart_member AND c.cart_prod = p.prod_id;  

(ansi)
SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM member m JOIN cart c ON(m.mem_id = c.cart_member)  
              JOIN prod p ON(c.cart_prod = p.prod_id);
              ##첫번째 조인한걸 테이블 처럼 생각 
              

customer : 고객
product : 제품
DAILY : 일실적
cycle(주기) : 고객 제품 애음 주기 
SELECT *
FROM cycle;

<실습>

SELECT cm.cid, cnm, pid, day, cnt
FROM customer cm, cycle cy
WHERE cm.cid = cy.cid 
  AND cm.cid IN(1,2); 
 --------------------- 
SELECT cm.cid, cnm, cy.pid, pnm, day, cnt
FROM customer cm, cycle cy, product pr
WHERE cm.cid = cy.cid
  AND cy.pid = pr.pid
  AND cm.cid IN(1,2);
-----------------

SELECT pnm, COUNT(cnt)
FROM cycle cy, product pr
WHERE cy.pid = pr.pid
GROUP BY pr.pnm;

-------------------------------------
SELECT cm.cid, cnm, cy.pid, pnm, SUM(cnt)
FROM customer cm, cycle cy, product pr
WHERE cm.cid = cy.cid
  AND cy.pid = pr.pid
GROUP BY  cm.cid, cnm, cy.pid, pnm;
15 조인  ==> 6 group

(인라인으로 만드는 거)

SELECT cm.cid, cm.cnm, cy.pid, pr.pnm, cy.cnt
FROM(SELECT cid, pid, SUM(cnt) cnt
     FROM cycle
     GROUP BY cid, pid) cy, customer cm, product pr
WHERE cm.cid = cy.cid
  AND cy.pid = pr.pid;
  

-------------------------

SELECT cy.pid, pnm, SUM(cnt)
FROM cycle cy, product pr
WHERE cy.pid = pr.pid
GROUP BY cy.pid, pnm;
 
 
 ---------------------------------------
 조인 성공 여부로 데이터 조회를 결정하는 구분방법
 INNER JOIN : 조인에 성공하는 데이터만 조회하는 조인 방법
 OUTER JOIN : 조인에 실패하더라도, 개발자가 지정한 기준이 되는 테이블의 데이터는 나오도록하는 조인
 ##일상적으로 쓰진 않지만 필요한 경우가 꽤 있다.
 OUTER <==> INNER JOIN
 
 복습 -  사원의 관리자 이름을 알고 싶은 상황
 조회 컬럼: 사원의 사번, 사원의 이름, 사원의 관리자의 사번, 사원의 관리자의이름
 SELECT e.empno, e.ename, e.mgr, m.ename
 FROM emp e, emp m 
 WHERE e.mgr = m.empno;
 동일한 테이블끼리 조인 되었기 때문에 : SELF-JOIN
 조인 조건을 만족하는 데이터만 조회 되었기 때문에 : INNER-JOIN
 
 king의 경우 president이기 때문에 mgr 컬럼의 값이 null -> 조인에 실패
 -> king의 데이터는 조회되지 않음( 총 14 데이터중 13거느이 데이터만 조인 성공)
 
 OUTER조인을 이용하여 조인 테이블중 기준이 되는 테이블을 선택하면
 조인에 실패하더라도 기준 테이블의 데이터는 조회 되도록 할 수 있다.
 ANSI-SQL
 테이블1 JOIN 테이블2 ON(.....)
 테이블1 LEFT OUTER JOIN 테이블2 ON(......)
 위 쿼리는 아래와 동일
 테이블2 RIGHT OUTER JOIN 테이블1 ON(....)
 
 SELECT e.empno, e.ename, e.mgr, m.ename
 FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = e.empno);
 



