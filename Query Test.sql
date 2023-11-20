use nullish;
select * from rental;
select * from video;
select * from genre;

 -- 1. 장르별 총 대여 횟수 조회 (횟수 기준 기준 내림차순 정렬)
SELECT g.gen_id AS '장르번호', 
	   g.gen_name AS '장르', 
       COUNT(g.gen_name) AS '대여횟수'
  FROM rental r, genre g
 WHERE g.gen_id = r.gen_id
 GROUP BY g.gen_id
 ORDER BY 대여횟수 DESC;
 
-- 2. 고객별 현재 미반납 비디오 연체 기간 및 연체료 조회
SELECT c.cust_id AS '회원번호', 
	   c.cust_name AS '고객명', 
       r.rent_date AS '대여일',  
       DATEDIFF(SYSDATE(), return_exp) AS "연체기간", 
       DATEDIFF(SYSDATE(), return_exp) * g.gen_latefee AS '연체료'
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
   AND r.return_date IS NULL
   AND DATEDIFF(SYSDATE(), return_exp) > 0
 ORDER BY c.cust_id;
 
 -- 3. 제목별 비디오 대여 횟수 조회 (대여 횟수 기준 내림차순 정렬)
SELECT v.vid_tit AS '제목', 
	   COUNT(v.vid_tit) AS '대여횟수', 
       g.gen_name AS '장르'
  FROM video v, rental r, genre g
 WHERE v.vid_id = r.vid_id
   AND g.gen_id = v.gen_id
 GROUP BY v.vid_tit
 ORDER BY 대여횟수 DESC;

--  4. 23년에 가입한 회원의 ID, 이름, 가입날짜,  연체횟수(overdue) , 생년월일 을 조회하는 쿼리문을 작성 
-- (회원 중 비디오 연체횟수(overdue)가 NUll인 경우는 출력대상에서 제외, 결과는 회원번호를 기준으로 오름차순 정렬.)
SELECT cust_id AS '회원번호',
	   cust_name AS '이름',
       cust_join AS '가입날짜',
       cust_overdue AS '연체횟수',
       cust_birth AS '생년월일'
  FROM customer
 WHERE cust_join BETWEEN '23/01/01' AND '23/12/31'
   AND cust_overdue IS NOT NULL
 ORDER BY 회원번호;

-- 5. 액션 비디오를 대여한 회원의 회원번호, 회원이름, 장르번호, 회원생일을 출력 (회원번호로 오름차순 정렬)
SELECT c.cust_id AS '회원번호',
	   c.cust_name AS '회원이름', 
       g.gen_id AS '장르번호', 
       c.cust_birth AS '회원생일'
  FROM customer c, genre g, rental r
 WHERE c.cust_id = r.cust_id
   AND g.gen_id = r.gen_id
   AND g.gen_name = '액션'
 ORDER BY 회원번호;
 
-- 6. 아직 비디오를 반납하지 않은 회원의 회원id, 이름, 전화번호, 회원 연체횟수 및 해당 비디오의 제목, 장르코드, 대여일 출력 (회원 연체횟수(cust_overdue)가 null일 경우 0 으로 출력하십시오.)
SELECT c.cust_id AS '회원 id',
	   c.cust_name AS '이름', 
       c.cust_phone AS '전화번호', 
       CASE WHEN c.cust_overdue IS NULL THEN 0
			WHEN c.cust_overdue > 0 THEN c.cust_overdue 
		END AS '연체횟수', 
       v.vid_tit AS '제목', 
       g.gen_id AS '장르코드', 
       r.rent_date AS '대여일'
  FROM customer c, video v, rental r, genre g
 WHERE c.cust_id = r.cust_id
   AND v.vid_id = r.vid_id
   AND g.gen_id = r.gen_id
   AND r.return_date IS NULL;

-- 7. 23년 8월부터 대여료와 연체료 10%인상하여 금액 산출
SELECT r.rent_date AS '대여일', 
	   g.gen_fee * 1.1 AS '10% 인상 대여료',
       g.gen_latefee * 1.1 AS '10% 인상 연체료'
  FROM rental r, genre g
 WHERE r.gen_id = g.gen_id
   AND r.rent_date >= '23/08/01'
 ORDER BY 대여일;

-- 8. 연령대별(10대 ~ 60대) 대여한 비디오의 제목, 대여 횟수, 연령대 출력 (대여 횟수에 따른 오름차순 정렬)
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
 GROUP BY 제목
 ORDER BY 대여횟수 DESC;
            
-- 9. 연체횟수가 3회이상인 회원 연체료10% 인상한 금액을 출력, 반납일은 빌린 날로부터 3일로 제한된 날짜로 출력 
-- (해당 회원이 비디오를 대여한 경우 반납일을 대여일로부터 3일 후로 출력. 3일이 지났을 경우 연체료가 하루 10%인상된 가격으로 측정. )
SELECT r.rent_id as '대여번호',
	   c.cust_name as '회원명',
	   r.rent_date as '대여일',
	   Date_format(r.rent_date + 3, '%Y-%m-%d') as '반납 예정일',
--        count(CASE WHEN DATEDIFF(r.return_date, r.return_exp) < 0 THEN 0
--    				WHEN r.return_date IS NULL THEN 1 
--  				WHEN DATEDIFF(r.return_date, r.return_exp) > 0 THEN 1
--  			END) AS '연체횟수',
	   g.gen_latefee * 1.1 as '10% 인상 연체료'
  FROM rental r, customer c, video v, genre g
 WHERE r.cust_id = c.cust_id
   AND r.gen_id = g.gen_id
 group by c.cust_id
 having count(CASE WHEN DATEDIFF(r.return_date, r.return_exp) < 0 THEN 0
				   WHEN r.return_date IS NULL THEN 1 
 				   WHEN DATEDIFF(r.return_date, r.return_exp) > 0 THEN 1
 			   END) >= 3;

-- 10. 월 별 총 대여료, 총 연체료 및 총 매출 산출
SELECT DATE_FORMAT(r.rent_date, '%y-%m') AS '월',
	   SUM(g.gen_fee) AS '총 대여료', 
       SUM(CASE WHEN DATEDIFF(return_date, return_exp) < 1 THEN 0
			    WHEN return_date IS NULL THEN 0
				ELSE DATEDIFF(return_date, return_exp)
			END * g.gen_latefee) AS '총 연체료',
        SUM(g.gen_fee) + 
			SUM(CASE WHEN DATEDIFF(return_date, return_exp) < 1 THEN 0
					 WHEN return_date IS NULL THEN 0
					 ELSE DATEDIFF(return_date, return_exp)
				 END * g.gen_latefee) AS '총 매출'
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
 GROUP BY DATE_FORMAT(r.rent_date, '%y-%m');

-- 11. 고객의 렌탈 기록 및 연체 횟수 조회 후 고객 테이블에 연체 횟수 업데이트 - 업데이트는 쿼리문만
SELECT c.cust_name as '회원명',
	   count(CASE WHEN DATEDIFF(r.return_date, r.return_exp) < 0 THEN 0
				   WHEN r.return_date IS NULL THEN 1 
 				   WHEN DATEDIFF(r.return_date, r.return_exp) > 0 THEN 1
 			   END) as '연체횟수'
  FROM customer c, rental r
 WHERE r.cust_id = c.cust_id
 GROUP BY c.cust_name
HAVING count(CASE WHEN DATEDIFF(r.return_date, r.return_exp) < 0 THEN 0
				   WHEN r.return_date IS NULL THEN 1 
 				   WHEN DATEDIFF(r.return_date, r.return_exp) > 0 THEN 1
 			   END) > 0
 ORDER BY 연체횟수 DESC;
-- 업데이트
UPDATE customer
   SET cust_overdue = 8
 WHERE cust_name = '이정후';

-- 12. 6월달 범죄영화 총대여료 산출
SELECT g.gen_name AS '장르명',
	   SUM(gen_fee) AS '총대여료'
  FROM genre g, rental r
 WHERE g.gen_id = r.gen_id
   AND r.rent_date BETWEEN '23/06/01' AND '23/06/30'
   AND g.gen_name = '범죄';

-- 13. 대여 시 해당 영화 비디오 갯수(vid_num) 조회  후 업데이트 → 업데이트는 쿼리문만
SELECT v.vid_num, r.rent_date
  FROM video v, rental r
 WHERE v.vid_id = r.vid_id
   and r.rent_date = SYSDATE();
-- 업데이트
UPDATE video v, rental r
   SET v.vid_num = v.vid_num - 1
 WHERE r.rent_date = SYSDATE();


-- 14. 출시일 2000년 전 중 인기없는 비디오 조회 및 (대여정보가 없는) 비디오 제거  ⇒  대여 정보 없는 비디오 없어 삭제 불가
SELECT v.vid_tit AS '제목', 
	   COUNT(r.rent_id) AS '대여횟수'
  FROM video v, rental r
 WHERE v.vid_id = r.vid_id
   AND v.vid_rel_date <= '00/12/31'
 GROUP BY v.vid_tit
 ORDER BY 대여횟수;
-- 비디오 제거


-- 15. 대여 건별 대여료, 연체기간, 연체료 및 매출 현황 (미반납 건에 대한 것은 연체료 0으로 반영)
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

-- 16. 비디오를 기한보다 일찍 반납한 렌트아이디(오름차순), 회원 ID, 회원이름, 비디오 제목 및  장르번호를 출력하세요.
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

-- 17. ‘서울특별시’에 거주하는 사람들이 빌린 비디오를 장르별로 분류하시오.
SELECT g.gen_name '장르', COUNT(r.gen_id) AS '대여횟수' 
  FROM rental r, customer c, genre g
 WHERE c.cust_id = r.cust_id
   AND r.gen_id = g.gen_id
   AND c.cust_addr LIKE '서울특별시%'
 GROUP BY r.gen_id
 ORDER BY 대여횟수 DESC;

-- 18. 2023년 가장 많은 배급을 한 배급사의 영화중 전체기간 동안의 대여기록(top5) 영화의 제목 및 총 대여수를 출력하세요.
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
