

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
  );
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11' , '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

DROP TABLE IF EXISTS menu;
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER 
  );
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

DROP TABLE IF EXISTS members;
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


--  # Case Study Questions
--# Ques:-01. What is the total amount each customer spent at the restaurant?

--Ans:-01
select  customer_id, sum(price) As total_amount from sales A  left join menu B on A.product_id = B.product_id
group by customer_id


--Ques:-#02.How many days has each customer visited the restaurant?

--Ans:-02
select A.customer_id, COUNT(distinct(order_date)) as VISITED_DAY from sales A left join members b on A.customer_id = B.customer_id
group by A.customer_id

--Ques:-03 What was the first item from the menu purchased by each customer?

--Ans:-03
with CTE_TABLE AS (
   select A.customer_id,product_name,DENSE_RANK() OVER(PARTITION BY A.customer_id ORDER BY A.order_date) As rnk from sales A left join menu B on A.product_id = B.product_id
   )

select customer_id, product_name as FIRST_NAME
from CTE_TABLE where rnk = 1
order by customer_id, product_name


--Ques:-04.What is the most purchased item on the menu and how many times was it purchased by all customers?
--Ans:-04
select top 1 product_name,count(A.product_id) as purchased_item from sales A join menu B on A.product_id=B.product_id
group by product_name
order by purchased_item desc

--Ques:-#05.Which item was the most popular for each customer?
--Ans:-05
WITH  MOST_POPULAR AS
(
select  customer_id,product_name,COUNT(a.product_id) AS quantity,DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(A.product_id) DESC ) AS ranks  from sales A join  menu B on A.product_id = B.product_id
group By customer_id,product_name
)

select customer_id,product_name,quantity  from MOST_POPULAR
where ranks = 1
group by customer_id,product_name,quantity

--Ques:-#06.Which item was purchased first by the customer after they became a member?

--Ans:-06

WITH CTE_TABLE AS (
select A.customer_id,product_name,count(A.product_id) AS QUANTITY,DENSE_RANK() OVER(PARTITION BY A.customer_id order by order_date) AS RNK, order_date,join_date from sales A join members B  on A.customer_id = B.customer_id join menu C on
A.product_id = c.product_id
where join_date <= order_date
group by A.customer_id,order_date,join_date,product_name
)

select customer_id,product_name,order_date,join_date from CTE_TABLE
where RNK = 1

--Ques:-#07.Which item was purchased just before the customer became a member?

--Ans:-07
WITH CTE_TABLE_N AS (
select A.customer_id,product_name,count(A.product_id) AS QUANTITY,DENSE_RANK() OVER(PARTITION BY A.customer_id order by order_date) AS RNK, order_date,join_date from sales A join members B  on A.customer_id = B.customer_id join menu C on
A.product_id = c.product_id
where join_date >= order_date
group by A.customer_id,order_date,join_date,product_name
)

select customer_id,product_name,order_date,join_date from CTE_TABLE_N
where RNK = 1
--Ques:-8 What is the total items and amount spent for each member before they became a member?
--ANS:-08
 
select A.customer_id,count(A.product_id) AS ITEM,sum(price) AS AMOUNTSPEND from sales A join members B  on A.customer_id = B.customer_id join menu C on
A.product_id = c.product_id
where join_date > order_date
group by A.customer_id
order by A.customer_id


--Ques:-09 .If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--Ans:-09
select A.customer_id,
SUM(CASE when B.product_name = 'sushi' then 20*price else 10*price END)  AS LOYALITY_BOUNS
from sales A join menu B on A.product_id = B.product_id
group by A.customer_id
order by LOYALITY_BOUNS DESC;

--Ques:-#10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
--Ans:-10
Select s.customer_id,
SUM(case when m.product_name='sushi' then 20*m.price
when (DATEDIFF(DAY,order_date,join_date) between 0 and 6) then 20*m.price
 else 10*m.price End) as Loyalty_points
from sales s,menu m, members ms
where s.product_id=m.product_id
and s.customer_id =ms.customer_id
and MONTH(order_date) = 01
group by s.customer_id
order by s.customer_id;

--BONUS Questions
--Join All the Things

select A.customer_id, A.order_date, B.product_name, B.price,
CASE when order_date >= join_date then 'Y' ELSE 'N' END AS member
from sales A left join menu B
on  A.product_id = B.product_id
left join members c
on A.customer_id = c.customer_id



--RANK ALL THINGS

WITH CTE AS (
select A.customer_id, A.order_date, B.product_name, B.price,
CASE when order_date >= join_date then 'Y' ELSE 'N' END AS member
from sales A left join menu B
on  A.product_id = B.product_id
left join members c
on A.customer_id = c.customer_id
)

select customer_id, order_date, product_name, price,
CASE when member = 'Y' then RANK() OVER  (PARTITION BY customer_id,member order by order_date) else NULL end AS RNK
from CTE

