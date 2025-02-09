-- Problem 1: Retrieve all products in the Sports category
-- Write an SQL query to retrieve all products in a specific category.

--select all rows from the product table where the category ID matches the category ID for the 'Sports' category
select * from Products 
where category_id = (select category_id from Categories  where category_name = 'Sports & Outdoors');

-- Problem 2: Retrieve the total number of orders for each user
-- Write an SQL query to retrieve the total number of orders for each user.
-- The result should include the user ID, username, and the total number of orders.

--select user information from the user table 
--join it with order information from the order table 
--count the number of times each user id appears in the order table 
select o.user_id, u.username, count(o.order_id) as TotalOrders 
  from Orders o
  join Users u on u.user_id = o.user_id
  group by u.user_id, u.username

-- Problem 3: Retrieve the average rating for each product
-- Write an SQL query to retrieve the average rating for each product.
-- The result should include the product ID, product name, and the average rating.

 --get the product information from the products table and the review information from the review table 
  --join both on the product ID 
select r.product_id, p.product_name, avg(rating) from Reviews r
join Products p on p.product_id = r.product_id 
group by r.product_id, p.product_name

-- Problem 4: Retrieve the top 5 users with the highest total amount spent on orders
-- Write an SQL query to retrieve the top 5 users with the highest total amount spent on orders.
-- The result should include the user ID, username, and the total amount spent.

  --find the sum of total orders for each user 
  --find user information in the users table 
  -- use the top 5 command with the order by command to get the 5 highest users 
select top 5 o.user_id, u.username, sum(o.total_amount) 
from Orders o
join Users u on u.user_id = o.user_id
group by  o.user_id, u.username
order by sum(o.total_amount) desc
