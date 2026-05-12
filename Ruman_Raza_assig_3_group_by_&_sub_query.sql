-- ============================================================
--   ASSIGNMENT 03 — GROUP BY, HAVING & SUBQUERIES
--   Database  : BikeStores
--   Topics    : GROUP BY · Aggregate Functions · HAVING
--               Subqueries · JOINs with GROUP BY
-- ============================================================


-- ============================================================
--  SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- Q1.
-- Count the total number of orders placed by each customer.
-- Show customer_id and order_count.
-- Sort by order_count descending.

select count(order_id) as order_count, customer_id
from sales.orders
group by customer_id
order by order_count DESC

-- Q2.
-- For each store, find the total number of orders placed.
-- Show store_id and total_orders.

select store_id, count(order_id) as total_orders
from sales.orders 
group by store_id

-- Q3.
-- Calculate the net revenue per order.
-- Net revenue formula: SUM( quantity * list_price * (1 - discount) )
-- Show order_id and net_revenue, sorted by net_revenue descending.
-- (Hint: use sales.order_items)

select order_id, sum(quantity * list_price * (1 - discount)) as net_revenue
from sales.order_items
group by order_id
order by net_revenue DESC

-- Q4.
-- Find the average list price of products in each category.
-- Show category_id and avg_price (rounded to 2 decimal places).
-- (Hint: use ROUND())

select category_id, round(avg(list_price),2) as avg_price
from production.products
group by category_id

-- Q5.
-- Find the total number of orders placed in each year.
-- Show order_year and total_orders, sorted by order_year.
-- (Hint: use YEAR(order_date))

select year(order_date) as order_year, count(order_id) as total_order
from sales.orders
group by order_id, order_date
order by order_year ASC

-- ============================================================
--  SECTION B — HAVING CLAUSE
-- ============================================================

-- Q6.
-- Find customers who have placed MORE than 5 orders in total.
-- Show customer_id and order_count.

select customer_id, count(order_id) as order_count
from sales.orders
group by customer_id
having count(order_id) > 5

-- Q7.
-- Find categories where the AVERAGE list price is greater than $1,500.
-- Show category_id and avg_price.

select category_id, avg(list_price) as avg_price
from production.products
group by category_id
having avg(list_price) > 1500

-- Q8.
-- Find customers who placed at least 2 orders in the year 2017.
-- Show customer_id, order_year, and order_count.

select customer_id, year(order_date) as order_year, count(order_id) as order_count
from sales.orders
group by customer_id, year(order_date)
having count(order_id) >=2 and year(order_date) = '2017'

-- ============================================================
--  SECTION C — SUBQUERIES
-- ============================================================

-- Q9.
-- Find all orders placed by customers who live in 'Houston'.
-- Use a subquery to get the customer_ids first.
-- Show all columns from sales.orders.

select *
from sales.orders
where customer_id in (
	select customer_id from sales.customers
	where city = 'Houston'
)

-- Q10.
-- Find all products whose list_price is greater than the
-- AVERAGE list_price of ALL products.
-- Show product_name and list_price.

select product_name, list_price
from production.products
where list_price > (
	select avg(list_price) from production.products
)

-- Q11.
-- Find all products that belong to the category 'Mountain Bikes'
-- or 'Road Bikes'. Use a subquery on production.categories.
-- Show product_name and list_price.

select product_name, list_price
from production.products
where category_id in (
	select category_id from production.categories
	where category_name in ('Mountain Bikes','Road Bikes')
)

-- Q12.
-- Find all customers who have NEVER placed an order.
-- Show customer_id, first_name, and last_name.
-- (Hint: use NOT IN with a subquery on sales.orders)

select customer_id, first_name, last_name
from sales.customers
where customer_id not in (
	select customer_id from sales.orders
)

-- ============================================================
--  SECTION D — JOINs WITH GROUP BY
-- ============================================================

-- Q13.
-- Find the total number of orders per city (customer's city).
-- Join sales.orders with sales.customers.
-- Show city and total_orders, sorted by total_orders descending.

select count(order_id) as total_orders, city
from sales.orders o
join sales.customers c
	on o.customer_id = c.customer_id
group by c.city
order by total_orders DESC

-- Q14.
-- For each staff member, count how many orders they handled.
-- Join sales.orders with sales.staffs.
-- Show staff full name (first_name + ' ' + last_name) as staff_name
-- and order_count, sorted by order_count descending.

select first_name + ' ' + last_name as staff_name, count(o.order_id) as order_count
from sales.orders o
join sales.staffs s
	on o.staff_id = s.staff_id
group by first_name, last_name
order by order_count DESC

-- Q15. (BONUS — Multi-concept)
-- Find customers who have spent more than $10,000 in total.
-- Join sales.customers → sales.orders → sales.order_items.
-- Show customer full name as customer_name and total_spent.
-- Sort by total_spent descending.
-- (Hint: JOIN + GROUP BY + HAVING)

select c.first_name + ' ' + c.last_name as customer_name,
		sum(oi.quantity * oi.list_price) as total_spent
from sales.customers c
join sales.orders o
	on o.customer_id = c.customer_id
join sales.order_items oi
	on oi.order_id = o.order_id
group by c.first_name, c.last_name
having sum(oi.quantity * oi.list_price) > 10000
order by total_spent DESC

-- ============================================================
--  END OF ASSIGNMENT 03
-- ============================================================
