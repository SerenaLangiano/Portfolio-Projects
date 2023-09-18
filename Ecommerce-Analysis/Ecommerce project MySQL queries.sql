USE ecommerce;
SELECT category, SUM(shipping.oi.quantity*shipping.oi.price) AS 'Total revenue per category'
FROM shipping.order_items oi
JOIN products p
	ON oi.product_id=p.product_id
GROUP BY category;

 
SELECT CONCAT(c.first_name, ' ', c.last_name) AS 'Client Name', COUNT(*) AS Total_orders
FROM customers c
JOIN shipping.orders o
	ON c.customer_id=o.customer_id
GROUP BY c.customer_id
ORDER BY Total_orders DESC
LIMIT 1;


USE ecommerce;
SELECT CONCAT(c.first_name, ' ', c.last_name) AS 'Client Name', AVG(shipping.oi.quantity*shipping.oi.price) AS 'Average Order Value'
FROM shipping.orders o 
JOIN customers c
	ON o.customer_id=c.customer_id
JOIN shipping.order_items oi
	ON o.order_id=oi.order_id
GROUP BY c.customer_id;


USE shipping;
SELECT MONTH(o.order_date) AS Month, SUM(oi.quantity*oi.price) AS 'Total Revenue'
FROM order_items oi
JOIN orders o
	ON oi.order_id=o.order_id
GROUP BY Month
ORDER BY Month;


SELECT p.name AS 'Product Name', COUNT(*) AS Times_ordered
FROM order_items oi
JOIN ecommerce.products p
	ON oi.product_id=p.product_id
GROUP BY oi.product_id
ORDER BY Times_ordered DESC;


USE ecommerce;
SELECT CONCAT(c.first_name,' ',c.last_name) AS Client_name, p.name AS Product_name, COUNT(oi.quantity) AS Quantity
FROM products p
JOIN shipping.order_items oi
	ON p.product_id=oi.product_id
JOIN shipping.orders o
	ON oi.order_id=o.order_id
JOIN customers c
	ON o.customer_id=c.customer_id
GROUP BY Client_name, Product_name;


USE shipping;
SELECT MONTH(o.order_date) AS Month, AVG(oi.quantity*oi.price) AS 'Average Order Value'
FROM orders o
JOIN order_items oi
	ON o.order_id=oi.order_id
GROUP BY Month;


USE ecommerce;
SELECT p.name AS Product, AVG(oi.quantity) AS 'Average Quantity Ordered'
FROM products p
JOIN shipping.order_items oi
	ON p.product_id=oi.product_id
GROUP BY Product;


SELECT category,SUM(oi.quantity*oi.price)/COUNT(DISTINCT(c.customer_id)) AS 'Average Revenue per Customer'
FROM products p
JOIN shipping.order_items oi
	ON p.product_id=oi.product_id
JOIN shipping.orders o
	ON oi.order_id=o.order_id
JOIN customers c
	ON o.customer_id=c.customer_id
WHERE o.status='Delivered'
GROUP BY category;


USE shipping;
SELECT MONTH(order_date) AS Month, o.status, SUM(quantity*price) AS 'Total Revenue'
FROM orders o
JOIN order_items oi
	ON o.order_id=oi.order_id
GROUP BY Month, status;
