
발전지수 =  (KFC + 버거킹 + 맥도날드) / 롯데리아
순위, 시도, 시군구, 버거 도시발전지수(소수점 2자리)
정렬은 순위가 높은 행이 가장 먼저 나오도록
1, 서울특별시, 강남구, 5.32
2, 서울특별시, 서초구, 5.13
....

1. 시도, 시군구, 프렌차이즈별 kfc, 맥도날드, 버거킹, 롯데리아 건수 세기
   1-1. 프렌차이즈별로 SELECT 쿼리 분리 한 경우
        ==> OUTER
        ==> 기준 테이블을 무엇으로??
   1-2. kfc, 맥도날드, 버거킹 1개의 SQL로, 롯데리아 1개     
   1-3. 모든 프렌차이즈를 SELECT 쿼리 하나에서 카운팅 한 경우
   
SELECT kfc.sido, kfc.sigungu, ROUND((kfc.kfc + bk.bk + mac.mac) / lot.lot, 2) score
FROM 
(SELECT sido, sigungu, COUNT(*) kfc
 FROM fastfood
 WHERE gb = 'KFC'
 GROUP BY sido, sigungu) kfc,
(SELECT sido, sigungu, COUNT(*) bk
 FROM fastfood
 WHERE gb = '버거킹'
 GROUP BY sido, sigungu) bk,
 (SELECT sido, sigungu, COUNT(*) mac
 FROM fastfood
 WHERE gb = '맥도날드'
 GROUP BY sido, sigungu) mac,
 (SELECT sido, sigungu, COUNT(*) lot
 FROM fastfood
 WHERE gb = '롯데리아'
 GROUP BY sido, sigungu) lot
WHERE kfc.sido = bk.sido
  AND kfc.sigungu = bk.sigungu
  AND kfc.sido = mac.sido
  AND kfc.sigungu = mac.sigungu
  AND kfc.sido = lot.sido
  AND kfc.sigungu = lot.sigungu
ORDER BY ROUND((kfc.kfc + bk.bk + mac.mac) / lot.lot, 2) DESC  ;


1.2
SELECT m.sido, m.sigungu, ROUND(m.m / d.d, 2) score
FROM 
(SELECT sido, sigungu, COUNT(*) m
 FROM fastfood
 WHERE gb IN ('KFC', '버거킹', '맥도날드')
 GROUP BY sido, sigungu) m,
(SELECT sido, sigungu, COUNT(*) d
 FROM fastfood
 WHERE gb = '롯데리아'
 GROUP BY sido, sigungu) d 
WHERE m.sido =  d.sido
  AND m.sigungu = d.sigungu
ORDER BY score DESC; 


1.3
SELECT sido, sigungu, 
       ROUND((NVL(SUM(DECODE(gb, 'KFC', 1)), 0) + 
           NVL(SUM(DECODE(gb, '맥도날드', 1)), 0) +
           NVL(SUM(DECODE(gb, '버거킹', 1)), 0)) /
           NVL(SUM(DECODE(gb, '롯데리아', 1)), 1), 2) SCORE
FROM fastfood
WHERE gb IN ('KFC', '맥도날드', '버거킹', '롯데리아')
GROUP BY sido, sigungu
ORDER BY SCORE DESC;