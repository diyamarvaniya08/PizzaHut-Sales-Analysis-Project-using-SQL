create database pizzahut;

SELECT * FROM orders;
 describe orders;

-- change column type text to date  
update orders
set order_date = str_to_date(order_date, '%d %M %Y');

alter table orders
modify column order_date date;

-- change column type  text to time
alter table orders
modify column order_time time;

SHOW DATABASES;
USE pizzahut;


-- QUERIES: Basic(5), Intermediate(5), Advance(3)

-- B1.  Retrieve the total number of order placed
 select count(order_id)Total_orders from orders;
 
-- B2. calculate the total revenue generated from pizza sales(ctrl + B to beautify the query)
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- B3. identify the highest-prized pizza 
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

select max(price) from pizzas;

-- B4. identify the most common pizza size ordered
SELECT 
    pizzas.size, COUNT(order_details.order_details_id) order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- B5. list the top 5 most ordered pizza types along with their quantity
  SELECT 
    pizza_types.name,
    SUM(order_details.quantity) most_ordered_pizzas_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY most_ordered_pizzas_quantity DESC
LIMIT 5;

-- I1. join all the necessary tables to find the total quantity of each pizza category ordered.
			SELECT 
				pizza_types.category,
				SUM(order_details.quantity) AS quantity
			FROM
				pizza_types
					JOIN
				pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
					JOIN
				order_details ON order_details.pizza_id = pizzas.pizza_id
			GROUP BY pizza_types.category
			ORDER BY quantity DESC;  

-- I2.determine the distribution of orders by hours of the day 
			SELECT 
				HOUR(order_time) AS hour, COUNT(order_id) AS order_count
			FROM
				orders
			GROUP BY HOUR(order_time);

-- I3. join relevant tables to find the category wise distribution of pizzas
			SELECT 
				category, COUNT(name)
			FROM
				pizza_types
			GROUP BY category;
            
-- I4. group the orders by date and calculate the average number of pizzas order per day
			SELECT 
				ROUND(AVG(total_orders), 0) Average_pizzas_order_per_day
			FROM
				(SELECT 
					orders.order_date, SUM(order_details.quantity) total_orders
				FROM
					orders
				JOIN order_details ON orders.order_id = order_details.order_id
				GROUP BY orders.order_date) AS data;            
 
 -- I5. determine the top 3 most ordered pizza types based on revenue
			SELECT 
				pizza_types.name,
				SUM(order_details.quantity * pizzas.price) revenue
			FROM
				pizza_types
					JOIN
				pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
					JOIN
				order_details ON order_details.pizza_id = pizzas.pizza_id
			GROUP BY pizza_types.name
			ORDER BY revenue DESC
			LIMIT 3;
            
-- A1. calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category, 
round(sum(order_details.quantity*pizzas.price) / (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue

from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;

-- A2. analyze the cumulative revenue generated over time
select order_date, round(sum(revenue) over (order by order_date),2) as cum_revenue from
(select orders.order_date, round(sum(order_details.quantity * pizzas.price),2) as revenue 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id

join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- A3. determine the top 3 most ordered pizza types based on revenue for each pizza category
select category, name, revenue, rnk from
 (select category, name, revenue, rank() over(partition by category order by revenue desc) as rnk
 from
(select pizza_types.category, pizza_types.name,  round(sum(order_details.quantity * pizzas.price),2) as revenue
from order_details join pizzas
     on order_details.pizza_id = pizzas.pizza_id
     join pizza_types
     on pizza_types.pizza_type_id = pizzas.pizza_type_id
     group by pizza_types.category, pizza_types.name) as data) as b where rnk <=2;
     
