-- Problem 9: Retrieve the top 3 categories with the highest total sales amount
-- Write an SQL query to retrieve the top 3 categories with the highest total sales amount.
-- The result should include the category ID, category name, and the total sales amount.
-- Hint: You may need to use subqueries, joins, and aggregate functions to solve this problem.

--create a temporary table that joins all the data that you need
--note: to get the total cost, multiply the quantity of the product with the unit cost 
with temp as 
(select oi.order_item_id, oi.order_id, oi.product_id, c.category_id, c.category_name, oi.quantity*oi.unit_price as total_cost
from order_items oi
join Products p on p.product_id = oi.product_id
join Categories c on c.category_id = p.category_id)

  --from the table, sum up the total cost of all the products based on their category, and select the top 3
select top 3 category_id, category_name, sum(total_cost) as total_sales from temp
group by category_id
order by sum(total_cost) desc

-- Problem 10: Retrieve the users who have placed orders for all products in the Toys & Games
-- Write an SQL query to retrieve the users who have placed orders for all products in the Toys & Games
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries, joins, and aggregate functions to solve this problem.
  
  --first create a temporrary table which joins all the information we need 
  --so from order items, we can see which category each item belongs to + the user information of the user who made the order
with temp as 
(select oi.order_item_id, oi.order_id, oi.product_id, u.user_id, u.username, c.category_id, c.category_name
from order_items oi
join Orders o on o.order_id = oi.order_id
join Users u on u.user_id = o.user_id
join Products p on p.product_id = oi.product_id
join Categories c on c.category_id = p.category_id)

--next, we use our table to select only those users who have ordered everything in the Toys category
  --by counting the distinct products each user ordered in the toys category, 
  --and ensuring that it is equal to the total number of products 
select user_id, username, count(distinct category_id)from temp
where category_id = 5
group by user_id, username
having count(distinct product_id) = (select top 1 product_id from Products 
where category_id = 5
order by product_id desc)


-- Problem 11: Retrieve the products that have the highest price within each category
-- Write an SQL query to retrieve the products that have the highest price within each category.
-- The result should include the product ID, product name, category ID, and price.
-- Hint: You may need to use subqueries, joins, and window functions to solve this problem.

select product_id, product_name, max(price), category_id 
from Products
group by category_id

-- Problem 12: Retrieve the users who have placed orders on consecutive days for at least 3 days
-- Write an SQL query to retrieve the users who have placed orders on consecutive days for at least 3 days.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries, joins, and window functions to solve this problem.


--create a temporary table to assign a row number to orders by customers on consecutive days
with temp as (
    select c.user_id, o.order_date, c.username,
        row_number() over(partition by o.user_id order by o.order_date) rn
    from Orders o
    inner join Users c on c.user_id = o.user_id
) 

select user_id, username
, min(order_date) as start, max(order_date) as end, count(*) as cnt, 
  datediff(day, max(order_date), min(order_date) as daysapart
from temp
group by user_id, DATE(order_date, -rn)
having count(*) >= 3 and daysapart between (2,3) 
--the having clause is to ensure that at least 3 orders were made, and that those three orders were between 48 to 72 hours apart (ie, on three consecutive days)
