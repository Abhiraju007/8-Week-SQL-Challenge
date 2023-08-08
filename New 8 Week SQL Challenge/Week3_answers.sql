--Ques1; How many customers has Foodie-Fi ever had?

select top 10 *from [dbo].[subscriptions]
select top 10 *from [dbo].[plans]

select COUNT(DISTINCT(customer_id)) as number_of_Customer from [dbo].[subscriptions] A  join
[dbo].[plans] B on A.plan_id = B.plan_id

--Ques2:-
--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
--Ans:-2
  SELECT MONTH(start_date) As MON_DATE,DATENAME(MONTH,start_date) AS MON_NAME,count(plan_id) as num_of_trial
    FROM subscriptions
   WHERE plan_id = 0
GROUP BY MONTH(start_date),DATENAME(MONTH,start_date)
ORDER BY MONTH(start_date);

--Ques:-3
--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
--Ans:-3
select plan_name, count(start_date) as count_date from [dbo].[plans] A join 
[dbo].[subscriptions] b on A.plan_id = B.plan_id
where year(start_date) > '2020'
group by plan_name
order by count_date desc


--Ques:-4
--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
--Ans:-4

WITH CTE AS (
select CONVERT(float,count(distinct(customer_id))) As No_of_churn,
SUM(CASE when A.plan_id = 4 then 1 else 0 end) as churned_customer_count
from [dbo].[subscriptions] A join [dbo].[plans] B on A.[plan_id] = B.[plan_id]
)

select *, churned_customer_count/ No_of_churn*100 AS Churn_Percentage from CTE


--Ques:-5. How many customers have churned straight after their initial free trial -what percentage is this rounded to the nearest whole number?

--Ans:-5
WITH FREE_TRIAL AS 
(
select plan_name,A.plan_id,customer_id, DENSE_RANK() OVER(PARTITION BY customer_id order by A.plan_id) as RNK
from [dbo].[subscriptions] A join [dbo].[plans] B on A.plan_id = B.plan_id

)
select COUNT(*) as churn_count,ROUND(100*COUNT(*)/(select COUNT(DISTINCT customer_id) from [dbo].[subscriptions]),0) as Churn_percentage
from FREE_TRIAL
where plan_id = 4
and RNK = 2


--Ques:-6
--6. What is the number and percentage of customer plans after their initial free trial?

--Ans:-6

WITH next_plan_cte AS (
SELECT 
  customer_id, 
  A.plan_id, 
  LEAD(A.plan_id, 1) OVER( -- Offset by 1 to retrieve the immediate row's value below 
    PARTITION BY customer_id 
    ORDER BY A.plan_id) as next_plan,plan_name
FROM [dbo].[subscriptions] A join [dbo].[plans] B on A.[plan_id] = B.[plan_id])

SELECT 
  next_plan,
  COUNT(*) AS conversions,
  100 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) 
    FROM [dbo].[subscriptions]) AS conversion_percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0 
GROUP BY next_plan
ORDER BY next_plan;


--Ques:-7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
--Ans:-7

with latest_plan AS
( select *,row_number() OVER(PARTITION by customer_id ORDER by start_date DESC) as latest_
from [dbo].[subscriptions]  
where [start_date] <= '2020-12-31')

select A.plan_id,plan_name,count(customer_id) AS customer_count,
(100*CONVERT(float,count(customer_id))/(select COUNT(DISTINCT customer_id) from [dbo].[subscriptions])) as percentage_breakdown
from latest_plan A join [dbo].[plans] B on A.plan_id = B.plan_id
where latest_ = 1
group by A.plan_id,plan_name
order by A.plan_id

--Ques:-08 How many customers have upgraded to an annual plan in 2020?
--Ans:-08
SELECT COUNT(customer_id) as annual_plan_count
FROM [dbo].[subscriptions]
WHERE plan_id = 3 and start_date <= '2020-12-31';


--Ques:-09 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

	--Ans:-09
	SELECT avg(datediff(DAY,s1.start_date,s2.start_date)) as average_days
	  FROM [dbo].[subscriptions] s1
	  JOIN [dbo].[subscriptions] s2
		ON s1.customer_id = s2.customer_id
	 WHERE s1.plan_id = 0 and s2.plan_id = 3;


--Ques10:- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH upgrade_days as (SELECT
     (CASE
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 30 THEN '0-30 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 60 THEN '31-60 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 90 THEN '61-90 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 120 THEN '91-120 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 150 THEN '121-150 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 180 THEN '151-180 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 210 THEN '181-210 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 240 THEN '211-240 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 270 THEN '241-270 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 300 THEN '271-300 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 330 THEN '301-330 days'
          WHEN (datediff(DAY,s2.start_date,s1.start_date)) <= 360 THEN '331-360 days'END ) days_to_upgrade,
       avg(datediff(DAY,s2.start_date,s1.start_date)) as average_upgrade_days,
       count(datediff(DAY,s2.start_date,s1.start_date)) as num_of_customers
     FROM [dbo].[subscriptions] s1
     JOIN [dbo].[subscriptions] s2
       ON s1.customer_id = s2.customer_id
    WHERE s1.plan_id = 0 and s2.plan_id = 3
 GROUP BY s1.start_date,s2.start_date
 )

  SELECT days_to_upgrade
    FROM upgrade_days
   WHERE days_to_upgrade is not null 
GROUP BY average_upgrade_days
ORDER BY 3;





