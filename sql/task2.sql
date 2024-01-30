-- Problem 5: Retrieve the products with the highest average rating
-- Write an SQL query to retrieve the products with the highest average rating.
-- The result should include the product ID, product name, and the average rating.
-- Hint: You may need to use subqueries or common table expressions (CTEs) to solve this problem.

-- this script will retrieve the top 100 products based on the average rating.
select top 100 r.product_id, p.product_name, avg(rating) from Reviews r
  -- join the reviews table with the products table to get the rating as well as product name 
join Products p on p.product_id = r.product_id 
  -- group by the product ID and name to get the average rating for each product 
group by r.product_id, p.product_name 
  -- order by the average rating to retrieve only the top ones 
order by avg(rating) desc

-- Problem 6: Retrieve the users who have made at least one order in each category
-- Write an SQL query to retrieve the users who have made at least one order in each category.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries or joins to solve this problem.

  --first create a temporrary table which joins all the information we need 
  --so from order items, we can see which category each item belongs to + the user information of the user who made the order
with temp as 
(select oi.order_item_id, oi.order_id, oi.product_id, u.user_id, u.username, c.category_id 
from order_items oi
join Orders o on o.order_id = oi.order_id
join Users u on u.user_id = o.user_id
join Products p on p.product_id = oi.product_id
join Categories c on c.category_id = p.category_id)

--next, we use our table to select only those users who have made an order in each category
  --by counting the distinct categories each user made orders in, 
  --and ensuring that it is equal to the total number of cateogries 
select user_id, username, count(distinct category_id)from temp
group by user_id, username
having count(distinct category_id) = (select top 1 category_id from Categories order by category_id desc)

-- Problem 7: Retrieve the products that have not received any reviews
-- Write an SQL query to retrieve the products that have not received any reviews.
-- The result should include the product ID and product name.
-- Hint: You may need to use subqueries or left joins to solve this problem.

-- this script will retrieve the products without reviews
select p.product_id, p.product_name
from Products p
  -- join the reviews table with the products table 
left join Reviews r on p.product_id = r.product_id 
  -- group by the product ID and name to get the average rating for each product 
where r.product_id is null

-- Problem 8: Retrieve the users who have made consecutive orders on consecutive days
-- Write an SQL query to retrieve the users who have made consecutive orders on consecutive days.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries or window functions to solve this problem.


  --create a temporary table to hold the rows from Orders + the lag columns (previous values of the date and the order id)
  --this is paritioned by user_id so we are comparing same user id with order date and number 
with cte
as
(
select *
,lag(Order_date) over(partition by user_id order by Order_date) as previous_date 
,lag(Order_id) over(partition by user_id order by Order_id) as previous_order 
from Orders

)

  --from that table, select all entries where the difference between the prev date and current date is 1 day (ie, consecutive)
  --and the difference between prev order number and current number is 1 (ie, consectutive orders)
select distinct c1.user_id, u.username 
from cte c1 
inner join cte c2 on c1.user_id=c2.user_id 
join Users u on u.user_id = c1.user_id
where DATEDIFF(day,c2.previous_date,c1.Order_Date)=1 
and abs(c1.order_id - c2.previous_order) = 1
