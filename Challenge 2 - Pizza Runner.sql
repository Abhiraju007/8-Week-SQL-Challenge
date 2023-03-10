#Database Creation & Data Insertion
	#Creating Schema
CREATE SCHEMA if not exists pizza_runner;
	#Creating Runners Table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

	#Creating Customer Orders Table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

	#Creating Runner Orders Table
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

	#Creating Pizza Names Table
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

	#Creating Pizza Recipe Table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

	#Creating Pizza Toppings Table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
 
 #Cleaning Data
	#Customer Orders Table
drop table if exists cust_ord_cl;
Create table cust_ord_cl
SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions like '' or extras LIKE 'null' THEN null
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras like '' or extras LIKE 'null' THEN null
	ELSE extras
	END AS extras,
	order_time
FROM customer_orders;

	#Runner Orders Table
drop table if exists run_ord_cl;
create table run_ord_cl 
SELECT order_id, runner_id,  
CASE
	WHEN pickup_time LIKE 'null' THEN null
	ELSE pickup_time
	END AS pickup_time,
CASE
	WHEN distance LIKE 'null' THEN null
	WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	ELSE distance
	END AS distance,
CASE
	WHEN duration LIKE 'null' THEN null
	WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	ELSE duration
	END AS duration,
CASE
	WHEN cancellation like '' or cancellation LIKE 'null' or cancellation LIKE 'NaN'THEN null
	ELSE cancellation
	END AS cancellation
FROM runner_orders;

ALTER TABLE run_ord_cl
modify pickup_time DATETIME,
modify COLUMN distance FLOAT,
modify COLUMN duration INTEGER;
  
  
  #Case Study Questions
		#A.Pizza Metrics

#01.How many pizzas were ordered?
select count(pizza_id) as pizza_count
from customer_orders;

#02.How many unique customer orders were made?
select count(distinct(customer_id)) as customer_count
from customer_orders;

#03.How many successful orders were delivered by each runner?
select runner_id,count(order_id) as order_count
from runner_orders
where 
group by runner_id
order by runner_id;

#04.How many of each type of pizza was delivered?
#05How many Vegetarian and Meatlovers were ordered by each customer?
#06What was the maximum number of pizzas delivered in a single order?
#07For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
#08How many pizzas were delivered that had both exclusions and extras?
#09What was the total volume of pizzas ordered for each hour of the day?
#10What was the volume of orders for each day of the week?