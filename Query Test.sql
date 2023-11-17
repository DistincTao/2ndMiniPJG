use nullish;
select * from rental;
select * from video;
select * from genre;

-- 고객별 장기 미반납 연체 기간 및 연체료 조회
select c.cust_id, c.cust_name as '고객명', r.rent_date as '대여일',  DATEDIFF(sysdate(), return_exp) as "연체기간", DATEDIFF(sysdate(), return_exp) / 2 * g.gen_latefee as '연체료'
  from rental r, customer c, genre g
 where c.cust_id = r.cust_id
   and r.gen_id = g.gen_id
   and r.return_date is null
   and DATEDIFF(sysdate(), return_exp) > 0
 order by c.cust_id;
 
 -- 최다 대여 비디오 목록 조회
select v.vid_tit as '제목', count(v.vid_tit) as '대여횟수', g.gen_name as '장르'
  from video v, rental r, genre g
 where v.vid_id = r.vid_id
   and g.gen_id = v.gen_id
 group by v.vid_tit
 order by 대여횟수 desc;
 
 -- 장르별 대여 횟수 조회
select g.gen_id, g.gen_name as '장르', count(g.gen_name) as '대여횟수'
  from rental r, genre g
 where g.gen_id = r.gen_id
 group by g.gen_id
 order by 대여횟수 desc;

  -- 대여 건별 대여료 및 연체료 및 매출 현황
select r.rent_id as '대여번호', 
	   g.gen_fee as '대여료', 
       case when DATEDIFF(return_date, return_exp) < 0 then 0
			when return_date is null then 0    
			else DATEDIFF(return_date, return_exp)
            end as '연체기간',
	   case when DATEDIFF(return_date, return_exp) < 0 then 0
			when return_date is null then 0
	        else DATEDIFF(return_date, return_exp)
	    end  * g.gen_latefee as '연체료',
	   g.gen_fee + 
			case when DATEDIFF(return_date, return_exp) < 0 then 0
				 when return_date is null then 0
				 else DATEDIFF(return_date, return_exp)
			 end * g.gen_latefee as '매출'
  from rental r, customer c, genre g
 where c.cust_id = r.cust_id
   and r.gen_id = g.gen_id
 order by r.rent_id;

--  4. 테이블에서 가입날짜가 23년인 회원의 ID, 이름, 가입날짜, 연체횟수(overdue), 생년월일을 조회하는 쿼리문을 작성해주세요.
--     이때 회원 중 비디오 연체 횟수 (overdue)이 NUll인 경우는 출력대상에서 제외시켜 주시고, 결과는 회원번호를 기준으로 오름차순 정렬해주세요. (현성)
select cust_id as '회원 ID',
	   cust_name as '이름',
       cust_join as '가입날짜',
       cust_overdue as '연체횟수',
       cust_birth as '생년월일'
  from customer
 where cust_join between '23/01/01' and '23/12/31'
   and cust_overdue is not null
 order by cust_id;

-- 5. 액션 비디오를 대여한 회원의 회원번호, 회원이름, 장르번호, 회원생일을 출력하세요
--  회원번호로 오름차순 정렬하세요. (현성)
select c.cust_id as '회원번호', c.cust_name as '회원이름', g.gen_id as '장르번호', c.cust_birth as '회원생일'
  from customer c, genre g, rental r
 where c.cust_id = r.cust_id
   and g.gen_id = r.gen_id
   and g.gen_name = '액션'
 order by c.cust_id;
 
-- 6. 아직 반납하지 않은 회원 정보(회원id, 이름, 전화번호, 회원 연체횟수)와 해당 비디오 제목, 장르코드, 대여일 출력 전체 출력(수혁)
select c.cust_id as '회원 id', c.cust_name as '이름', c.cust_phone as '전화번호', c.cust_overdue as '연체횟수', v.vid_tit as '제목', g.gen_id as '장르코드', r.rent_date as '대여일'
  from customer c, video v, rental r, genre g
 where c.cust_id = r.cust_id
   and v.vid_id = r.vid_id
   and g.gen_id = r.gen_id
   and r.return_date is null;

-- 7. 23년 8월부터 대여료 10%인상하여 금액 산출 (상용)

-- 8. 연령대별(10대 ~ 60대) 인기비디오top10 전체 데이터 조회 연령대별로 오름차순 조회 (수혁)

-- 9. 연체횟수가 3회이상인 회원 연체료10% 인상 및 대출일(3일로) 제한 (해당 회원이 비디오를 대여한 경우 대여일을 3일로 제한 3일이 지났을 경우 연체료가 하루 10%인상된 가격으로 측정)(수혁)

-- 10. 매출이 50만원 이상인 월의 회원 목록 및 총 대여료 및 총 연체료 및 총 수입(수혁)

-- 11. 고객에 렌탈 기록을 보고 연체일 업데이트 (상용)
-- 12. 6월달 범죄영화 총대여료 (건우)
-- 13. 가장 인기있는 장르 총 대여료(건우)
-- 14. 대여 시 해당 영화 비디오 갯수(vid_num) 업데이트 (상용)
-- 15. 출시일 2000년 전 중 인기없는 비디오 제거, 대여정보가 없는! (상용)
-- 17. 비디오를 기한보다 일찍 반납한 렌트아이디(오름차순), 손님아이디 ,이름을 출력하고 그 반납한 비디오의 이름과 장르번호를 출력하세요. (동진)
-- 18. ‘서울특별시’에 거주하는 사람들이 빌린 비디오를 장르별수로 분류하시오. (동진)
-- 19. 2023년 가장 많은 배급을 한 배급사를 출력하고 그 회사의 영화중 전체기간 동안 가장 많은 대여기록이 있는 영화의 정보를 출력하세요. (동진)

























 
  -- 기간 별 대여료 및 연체료
select date_format(r.rent_date, '%y-%m') as '월',
	   sum(g.gen_fee) as '대여료', 
       sum(case when DATEDIFF(return_date, return_exp) - 2 < 1 then 0
			    when return_date is null then 0
				else DATEDIFF(return_date, return_exp) - 2
			end / 2 * g.gen_latefee) as '연체료',
        sum(g.gen_fee + DATEDIFF(return_date, return_exp) / 2 * g.gen_latefee) as '매출'
  from rental r, customer c, genre g
 where c.cust_id = r.cust_id
   and r.gen_id = g.gen_id
group by date_format(r.rent_date, '%y-%m');