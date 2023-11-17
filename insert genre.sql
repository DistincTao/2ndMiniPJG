use nullish; 
create table gen (
	gen_id int(10),
    gen_name varchar(10),
    gen_fee int(10),
    late_fee int(10)
);

select * from gen;

create table test
( id varchar(6), name varchar (10));

insert into test
values (123, '태호');
select * from gen;

insert into gen
values (28, '액션', 5000, 500);

insert into gen
values (12, '모험', 5000, 500);

insert into gen
values (16, '애니메이션', 4000, 400);

insert into gen
values (35, '코미디', 5000, 500);

insert into gen
values (80, '범죄', 5000, 500);

insert into gen
values (99, '다큐멘터리', 3000, 300);

insert into gen
values (18, '드라마', 4000, 400);

insert into gen
values (10751, '가족', 4000, 400);

insert into gen
values (14, '판타지', 5000, 500);

create table volume
(lent_id int(6), rent_start date, total_lentfee int(10), total_latefee int(10));

select * from rental;
