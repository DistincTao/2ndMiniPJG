use nullish;
select * from rental;
select * from video;
select * from genre;

-- 고객별 장기 미반납 연체 기간 및 연체료 조회
SELECT c.cust_id AS '회원번호', 
	   c.cust_name AS '고객명', 
       r.rent_date AS '대여일',  
       DATEDIFF(SYSDATE(), return_exp) AS "연체기간", 
       DATEDIFF(SYSDATE(), return_exp) / 2 * g.gen_latefee AS '연체료'
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
   AND r.return_date IS NULL
   AND DATEDIFF(SYSDATE(), return_exp) > 0
 ORDER BY c.cust_id;
 
 -- 최다 대여 비디오 목록 조회
SELECT v.vid_tit AS '제목', 
	   COUNT(v.vid_tit) AS '대여횟수', 
       g.gen_name AS '장르'
  FROM video v, rental r, genre g
 WHERE v.vid_id = r.vid_id
   AND g.gen_id = v.gen_id
 GROUP BY v.vid_tit
 ORDER BY 대여횟수 DESC;
 
 -- 장르별 대여 횟수 조회
SELECT g.gen_id AS '장르번호', 
	   g.gen_name AS '장르', 
       COUNT(g.gen_name) AS '대여횟수'
  FROM rental r, genre g
 WHERE g.gen_id = r.gen_id
 GROUP BY g.gen_id
 ORDER BY 대여횟수 DESC;

  -- 대여 건별 대여료 및 연체료 및 매출 현황
select r.rent_id AS '대여번호', 
	   g.gen_fee as '대여료', 
       CASE WHEN DATEDIFF(return_date, return_exp) < 0 THEN 0
			WHEN return_date IS NULL THEN 0    
			ELSE DATEDIFF(return_date, return_exp)
            END AS '연체기간',
	   CASE WHEN DATEDIFF(return_date, return_exp) < 0 THEN 0
			WHEN return_date IS NULL THEN 0
	        ELSE DATEDIFF(return_date, return_exp)
	    END * g.gen_latefee as '연체료',
	   g.gen_fee + 
			CASE WHEN DATEDIFF(return_date, return_exp) < 0 THEN 0
				 WHEN return_date IS NULL THEN 0
				 ELSE DATEDIFF(return_date, return_exp)
			 END * g.gen_latefee AS '매출'
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
 ORDER BY 대여번호;

--  4. 테이블에서 가입날짜가 23년인 회원의 ID, 이름, 가입날짜, 연체횟수(overdue), 생년월일을 조회하는 쿼리문을 작성해주세요.
--     이때 회원 중 비디오 연체 횟수 (overdue)이 NUll인 경우는 출력대상에서 제외시켜 주시고, 결과는 회원번호를 기준으로 오름차순 정렬해주세요. (현성)
SELECT cust_id AS '회원번호',
	   cust_name AS '이름',
       cust_join AS '가입날짜',
       cust_overdue AS '연체횟수',
       cust_birth AS '생년월일'
  FROM customer
 WHERE cust_join BETWEEN '23/01/01' AND '23/12/31'
   AND cust_overdue IS NOT NULL
 ORDER BY 회원번호;

-- 5. 액션 비디오를 대여한 회원의 회원번호, 회원이름, 장르번호, 회원생일을 출력하세요
--  회원번호로 오름차순 정렬하세요. (현성)
SELECT c.cust_id AS '회원번호',
	   c.cust_name AS '회원이름', 
       g.gen_id AS '장르번호', 
       c.cust_birth AS '회원생일'
  FROM customer c, genre g, rental r
 WHERE c.cust_id = r.cust_id
   AND g.gen_id = r.gen_id
   AND g.gen_name = '액션'
 ORDER BY 회원번호;
 
-- 6. 아직 반납하지 않은 회원 정보(회원id, 이름, 전화번호, 회원 연체횟수)와 해당 비디오 제목, 장르코드, 대여일 출력 전체 출력(수혁)
SELECT c.cust_id AS '회원 id',
	   c.cust_name AS '이름', 
       c.cust_phone AS '전화번호', 
       c.cust_overdue AS '연체횟수', 
       v.vid_tit AS '제목', 
       g.gen_id AS '장르코드', 
       r.rent_date AS '대여일'
  FROM customer c, video v, rental r, genre g
 WHERE c.cust_id = r.cust_id
   AND v.vid_id = r.vid_id
   AND g.gen_id = r.gen_id
   and r.return_date IS NULL;

-- 7. 23년 8월부터 대여료와 연체체료 10%인상하여 금액 산출 (상용)
SELECT r.rent_date AS '대여일', 
	   g.gen_fee * 1.1 AS '인상대여료',
       g.gen_latefee * 1.1 AS '인상된 연체료'
  FROM rental r, genre g
 WHERE r.gen_id = g.gen_id
   AND r.rent_date > '23/08/01'
 ORDER BY 대여일;

-- 8. 8. 연령대별(10대 ~ 60대) 인기비디오top10 전체 데이터 조회 연령대별로 오름차순 조회 (수혁)(쿼리문 6개 → 1개로 해봐야함.) (수혁)
SELECT r.rent_id AS '대여번호',
	   v.vid_tit AS '제목',
	   count(r.vid_id) AS '대여횟수',
	   CASE WHEN DATEDIFF(SYSDATE(), c.cust_birth) / 365 < 20 THEN '10대 미만'
			WHEN DATEDIFF(SYSDATE(), c.cust_birth) / 365 >= 20 and DATEDIFF(SYSDATE(), c.cust_birth) / 365 < 30 THEN '20대'
            WHEN DATEDIFF(SYSDATE(), c.cust_birth) / 365 >= 30 and DATEDIFF(SYSDATE(), c.cust_birth) / 365 < 40 THEN '30대'
            WHEN DATEDIFF(SYSDATE(), c.cust_birth) / 365 >= 40 and DATEDIFF(SYSDATE(), c.cust_birth) / 365 < 50 THEN '40대'
            WHEN DATEDIFF(SYSDATE(), c.cust_birth) / 365 >= 50 and DATEDIFF(SYSDATE(), c.cust_birth) / 365 < 60  THEN '50대'
            WHEN DATEDIFF(SYSDATE(), c.cust_birth) / 365 >= 60  THEN '60대 이상'
            else DATEDIFF(SYSDATE(), c.cust_birth) / 365
		END AS '연령대'
  FROM customer c, video v, rental r
 WHERE v.vid_id = r.vid_id
   AND c.cust_id = r. cust_id
 group by 제목
 order by 대여횟수 desc;
            
-- 9. 연체횟수가 3회이상인 회원 연체료10% 인상한 금액을 출력 
--      및 반납일은 빌린 날로부터 3일로 제한 (해당 회원이 비디오를 대여한 경우 대여일을 3일로 제한 3일이 지났을 경우 연체료가 하루 10%인상된 가격으로 측정.(수혁)

-- 10. 매출이 30만원 이상인 월의 총 대여료 및 총 연체료 및 총 수입(수혁) -> 회원 목록 x
SELECT DATE_FORMAT(r.rent_date, '%y-%m') AS '월',
	   SUM(g.gen_fee) AS '대여료',
       SUM(CASE WHEN DATEDIFF(return_date, return_exp) < 1 THEN 0
			    WHEN return_date IS NULL THEN 0
				ELSE DATEDIFF(return_date, return_exp)
			END * g.gen_latefee) AS '연체료',
        SUM(g.gen_fee + DATEDIFF(return_date, return_exp) * g.gen_latefee) AS '매출'
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
GROUP BY 월;

-- 11. 고객에 렌탈 기록을 보고 연체일 업데이트 (상용)


-- 12. 6월달 범죄영화 총대여료 (건우)
SELECT g.gen_name AS '장르명',
	   SUM(gen_fee) AS '총대여료'
  FROM genre g, rental r
 WHERE g.gen_id = r.gen_id
   AND r.rent_date BETWEEN '23/06/01' AND '23/06/30'
   AND g.gen_name = '범죄';

-- 13. 생일이 6월인 사람들 , 6월 대여료 20%할인(건우)
Select cust_name
  from customer
 where Month(cust_birth) = 6;

SELECT g.gen_name AS '장르명',
	   g.gen_fee * 0.8 AS '6월 할인 대여료'
  FROM genre g;

-- 14. 대여 시 해당 영화 비디오 갯수(vid_num) 업데이트 (상용)


-- 15. 출시일 2000년 전 중 인기없는 비디오 제거, 대여정보가 없는! (상용)
SELECT v.vid_tit AS '제목', 
	   COUNT(r.rent_id) AS '대여횟수'
  FROM video v, rental r
 WHERE v.vid_id = r.vid_id
   AND v.vid_rel_date <= '00/12/31'
 GROUP BY v.vid_tit
 ORDER BY 대여횟수;
-- 비디오 제거




-- 17. 비디오를 기한보다 일찍 반납한 렌트아이디(오름차순), 손님아이디 ,이름을 출력하고 그 반납한 비디오의 이름과 장르번호를 출력하세요. (동진)
SELECT r.rent_id AS '대여번호', 
	   c.cust_id AS '회원번호', 
       c.cust_name AS '회원명', 
       v.vid_tit AS '비디오제목', 
       v.gen_id AS '장르번호'
  FROM customer c, video v, rental r
 WHERE c.cust_id = r.cust_id
   AND v.vid_id = r.vid_id
   AND DATEDIFF(return_exp, return_date) > 0
ORDER BY 대여번호;

-- 18. ‘서울특별시’에 거주하는 사람들이 빌린 비디오를 장르별로 분류하시오. (동진)
SELECT g.gen_name '장르', COUNT(r.gen_id) AS '대여횟수' 
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
   AND c.cust_addr LIKE '서울특별시%'
 GROUP BY r.gen_id
 order by 대여횟수 desc;

-- 19. 2023년 가장 많은 배급을 한 배급사를 출력하고 그 회사의 영화중 전체기간 동안 가장 많은 대여기록이 있는 영화의 정보를 출력하세요. (동진) => 배급사 출력 불가
SELECT v.vid_tit AS '제목',
	   COUNT(r.vid_id) AS '총 대여수'
  FROM rental r, video v
 WHERE v.vid_id = r.vid_id
   AND v.vid_com = (                 
			SELECT v.vid_com
			  FROM video v, rental r
			 WHERE v.vid_id = r.vid_id
			   AND v.vid_rel_date BETWEEN '23/01/01' AND '23/12/31'
			 GROUP BY v.vid_com
			 ORDER BY COUNT(r.vid_id) DESC
             LIMIT 1
			 )
 GROUP BY v.vid_tit
 ORDER BY COUNT(r.vid_id) DESC;















   -- 기간 별 대여료 및 연체료
SELECT DATE_FORMAT(r.rent_date, '%y-%m') AS '월',
	   SUM(g.gen_fee) AS '대여료', 
       SUM(CASE WHEN DATEDIFF(return_date, return_exp) < 1 THEN 0
			    WHEN return_date IS NULL THEN 0
				ELSE DATEDIFF(return_date, return_exp)
			END * g.gen_latefee) AS '연체료',
        SUM(g.gen_fee) + SUM(CASE WHEN DATEDIFF(return_date, return_exp) < 1 THEN 0
			    WHEN return_date IS NULL THEN 0
				ELSE DATEDIFF(return_date, return_exp)
			END * g.gen_latefee) AS '매출'
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
GROUP BY DATE_FORMAT(r.rent_date, '%y-%m');