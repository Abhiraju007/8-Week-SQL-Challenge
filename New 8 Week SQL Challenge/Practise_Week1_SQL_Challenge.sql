select *from sales

select *from menu

SELECT *from members

--# 01. What is the total amount each customer spent at the restaurant?

--select  customer_id, sum(price) As total_amount from sales A  left join menu B on A.product_id = B.product_id
--group by customer_id

--Ques:-#02.How many days has each customer visited the restaurant?

--select A.customer_id, COUNT(distinct(order_date)) as VISITED_DAY from sales A left join members b on A.customer_id = B.customer_id
--group by A.customer_id

--Ques:-03 What was the first item from the menu purchased by each customer?
--with CTE_TABLE AS (
--   select A.customer_id,product_name,DENSE_RANK() OVER(PARTITION BY A.customer_id ORDER BY A.order_date) As rnk from sales A left join menu B on A.product_id = B.product_id
--   )

--select customer_id, product_name as FIRST_NAME
--from CTE_TABLE where rnk = 1
--order by customer_id, product_name

--WITH first_item_cte AS
--(
-- SELECT customer_id, product_name,
--  DENSE_RANK() OVER(PARTITION BY s.customer_id
--  ORDER BY s.order_date) AS rnk
-- FROM sales s, menu m
--where s.product_id = m.product_id
--)
--SELECT customer_id, product_name as First_Item
--FROM first_item_cte
--WHERE rnk = 1
--GROUP BY customer_id,product_name;

--Ques:-04.What is the most purchased item on the menu and how many times was it purchased by all customers?
--Ans:-04
--select top 1 product_name,count(A.product_id) as purchased_item from sales A join menu B on A.product_id=B.product_id
--group by product_name
--order by purchased_item desc

----Ques:-#05.Which item was the most popular for each customer?
----Ans:-05
--WITH  MOST_POPULAR AS
--(
--select  customer_id,product_name,COUNT(a.product_id) AS quantity,DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(A.product_id) DESC ) AS ranks  from sales A join  menu B on A.product_id = B.product_id
--group By customer_id,product_name
--)

--select customer_id,product_name,quantity  from MOST_POPULAR
--where ranks = 1
--group by customer_id,product_name,quantity

--Ques:-#06.Which item was purchased first by the customer after they became a member?
--WITH CTE_TABLE AS (
--select A.customer_id,product_name,count(A.product_id) AS QUANTITY,DENSE_RANK() OVER(PARTITION BY A.customer_id order by order_date) AS RNK, order_date,join_date from sales A join members B  on A.customer_id = B.customer_id join menu C on
--A.product_id = c.product_id
--where join_date <= order_date
--group by A.customer_id,order_date,join_date,product_name
--)

--select customer_id,product_name,order_date,join_date from CTE_TABLE
--where RNK = 1

--Ques:-#07.Which item was purchased just before the customer became a member?

--WITH CTE_TABLE_N AS (
--select A.customer_id,product_name,count(A.product_id) AS QUANTITY,DENSE_RANK() OVER(PARTITION BY A.customer_id order by order_date) AS RNK, order_date,join_date from sales A join members B  on A.customer_id = B.customer_id join menu C on
--A.product_id = c.product_id
--where join_date >= order_date
--group by A.customer_id,order_date,join_date,product_name
--)

--select customer_id,product_name,order_date,join_date from CTE_TABLE_N
--where RNK = 1


----Ques:-8 What is the total items and amount spent for each member before they became a member?
--WITH CTE_TABLE_NE AS
--(
--select A.customer_id,product_name,count(A.product_id) AS QUANTITY,DENSE_RANK() OVER(PARTITION BY A.customer_id order by order_date) AS RNK,price, order_date,join_date from sales A join members B  on A.customer_id = B.customer_id join menu C on
--A.product_id = c.product_id
--where join_date >= order_date
--group by A.customer_id,order_date,join_date,product_name,price
--)
--select customer_id,product_name,price,order_date,join_date from CTE_TABLE_NE
--where RNK = 1

--select A.customer_id,count(A.product_id) AS ITEM,sum(price) AS AMOUNTSPEND from sales A join members B  on A.customer_id = B.customer_id join menu C on
--A.product_id = c.product_id
--where join_date > order_date
--group by A.customer_id
--order by A.customer_id


--Ques:-#09.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

--select A.customer_id,
--SUM(CASE when B.product_name = 'sushi' then 20*price else 10*price END)  AS LOYALITY_BOUNS
--from sales A join menu B on A.product_id = B.product_id
--group by A.customer_id
--order by LOYALITY_BOUNS DESC;

--Select s.customer_id,
--SUM(case when m.product_name='sushi' then 20*m.price
--when (DATEDIFF(DAY,order_date,join_date) between 0 and 6) then 20*m.price
-- else 10*m.price End) as Loyalty_points
--from sales s,menu m, members ms
--where s.product_id=m.product_id
--and s.customer_id =ms.customer_id
--and MONTH(order_date) = 01
--group by s.customer_id
--order by s.customer_id;

--select when DATEDIFF(DAY,order_date,join_date) AS DIFF from sales A join members B on A.customer_id= B.customer_id

--BONUS Questions
--Join All the Things

--SELECT s.customer_id, 
--       s.order_date, 
--       m.product_name,m.price, 
--       CASE WHEN order_date >= join_date THEN 'Y' ELSE 'N' END AS member
--FROM sales s
--LEFT JOIN menu m
--ON s.product_id = m.product_id
--LEFT JOIN members mem
--ON s.customer_id = mem.customer_id;

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
