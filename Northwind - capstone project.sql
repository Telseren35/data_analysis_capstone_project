
--Northwind - capstone project 

--Total orders
select 
 count (order_id) as total_orders
 from orders

select * from order_details

--total orders quantity
SELECT SUM(Quantity) AS Total_orders_quantity
FROM Order_details;



---SALES and ORDERS ANALYSES

-- Total Sales
SELECT
 floor (SUM(od.unit_price * od.quantity)) AS total_sales
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id;
 


--How many units of which product were sold? total revenue per product (77 products available)
SELECT p.product_name,
       SUM(od.quantity) AS total_quantity,
       floor (SUM(od.unit_price * od.quantity) ) AS total_revenue
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue desc

-- Amount of products sold by category
SELECT c.category_name, p.product_name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name
ORDER BY c.category_name, total_quantity DESC

--Best selling category and total quantity
SELECT c.category_name,
        SUM(od.quantity) AS total_quantity,
        FLOOR (SUM(od.quantity * od.unit_price)) AS total_sales
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC;

---Total sales by country
SELECT 
    o.ship_country, 
   floor(SUM(od.quantity * od.unit_price)) AS total_sales
FROM 
    Orders o
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY 
    o.ship_country
ORDER BY 
    total_sales DESC
	
---Total sales amount by month
SELECT EXTRACT(YEAR FROM o.order_date) AS y,
       EXTRACT(MONTH FROM o.order_date) AS m,
       COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
ORDER BY y, m;

---total sales amount by year
SELECT EXTRACT(YEAR FROM o.order_date) AS y,
       COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY EXTRACT(YEAR FROM o.order_date)
ORDER BY y;

--  Products sold and their quantities by country
SELECT
    o.ship_country,
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM
    Orders o
JOIN
    order_details od ON o.order_id = od.order_id
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    o.ship_country, p.product_name
ORDER BY
    o.ship_country, total_quantity DESC;


----------------------------------------------------

---CUSTOMER ANALYSES


--companies that generate the most revenue

SELECT C.company_name, 
floor(SUM(OD.unit_price * OD.quantity * (1 - OD.discount))) AS total_revenue
FROM orders O
JOIN customers C ON O.customer_id = C.customer_id
JOIN order_details OD ON O.order_id = OD.order_id
GROUP BY C.company_name, O.customer_id
ORDER BY total_revenue DESC;

select * from order_details

-- companies with the most orders
SELECT C.company_name,COUNT(distinct O.order_id) AS order_numbers
FROM Orders O
JOIN Customers C ON O.customer_id = C.customer_id
JOIN order_details OD ON O.order_id = OD.order_id
GROUP BY C.company_name, O.customer_id
ORDER BY order_numbers DESC;
	
--Customer's most preferred product
SELECT P.product_name, OD.product_id, SUM(OD.Quantity) AS total_order_quantity
FROM order_details OD
JOIN products P ON OD.product_id = P.product_id
GROUP BY P.product_name, OD.product_id
ORDER BY total_order_quantity DESC
LIMIT 1;

--Which country's customers placed the most orders?
SELECT o.ship_country, COUNT(O.order_ID) AS order_numbers
FROM orders O
JOIN customers C ON O.customer_id = C.customer_id
GROUP BY o.ship_country
ORDER BY order_numbers DESC
;

SELECT C.country, COUNT(C.customer_id) AS customer_number
FROM Customers C
GROUP BY C.country
ORDER BY customer_number DESC
LIMIT 1;

--RFM ANALYSES and SEGMENTATION
with segment_table as(
with tablo3 as(
with tablo2 as( 
with tablo as	 
(SELECT 
    C.customer_id,
    C.company_name,
    MAX(O.order_date) as max_order_date,
    COUNT(O.order_id) AS sipsık,
    floor(SUM(OD.quantity * OD.unit_price)) AS topharcama
  FROM customers C
  JOIN orders O ON C.customer_id = O.customer_id
  JOIN order_details OD ON O.order_id = OD.order_id
  GROUP BY C.customer_id, C.company_name)
  select company_name,  
  '1998-05-06' - max_order_date recency,
  sipsık as frequency,topharcama as monetary
	   from tablo)
select 
company_name,recency as r,
ntile(5) over(order by recency desc)recency_score
frequency as f,
CASE
     WHEN frequency between 1 and 10 THEN 1
     WHEN frequency between 10 and 30 then 2
     WHEN frequency between 30 and 50 then 3
     when frequency between 50 and 60 then 4 
     ELSE 5
     END AS frequency_score,
monetary as m,
ntile(5) over(order by monetary)monetary_score
from tablo2)
select 
company_name,
recency_score || '-' || frequency_score || '-' || monetary_score as score
from tablo3
order by score desc)
select company_id,score,
CASE
            -- most valuable customer (RFM Score: 555)
            WHEN score = '5-5-5' THEN 'most valuable customer'
            -- New customers 
            WHEN recency_score = 5 AND frequency_score <= 3 AND monetary_score <= 3 THEN 'New Customers'
            
            -- Lost Customers 
            WHEN recency_Score <= 2 AND frequency_Score <= 2 AND monetary_score <= 2 THEN 'Lost Customers'
            
            -- Frequent Shoppers 
            WHEN frequency_score >= 4 AND monetary_score >= 4 THEN 'Frequent Shoppers'
            
            ELSE 'other'
        END AS Segment
		from score)
		select company_name,Segment
		from segment_table
		
		
		
---------------------------------------------




---EMPLOYEE ANALYSES


--sales amounts of employees
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    floor(SUM(od.unit_price * od.quantity)) AS TotalSales
FROM 
    orders o
JOIN 
    employees e ON o.employee_id = e.employee_id
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    e.employee_id, e.first_name, e.last_name
ORDER BY 
    TotalSales DESC;
	
---Sales numbers of employees

SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(od.quantity) AS TotalQuantitySold
FROM 
    orders o
JOIN 
    employees e ON o.employee_id = e.employee_id
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    e.employee_id, e.first_name, e.last_name
ORDER BY 
    TotalQuantitySold DESC;
	
----Which customers did each employee sell to

SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(DISTINCT c.customer_id) AS TotalCustomers
FROM 
    orders o
JOIN 
    employees e ON o.employee_id = e.employee_id
JOIN 
    customers c ON o.customer_id = c.customer_id
GROUP BY 
    e.employee_id, e.first_name, e.last_name
ORDER BY 
    TotalCustomers DESC;

---- monthly income status of employees
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    EXTRACT(YEAR FROM o.order_date) as y,
    EXTRACT(MONTH FROM o.order_date) as m,
    floor (SUM(od.unit_price * od.quantity * (1 - od.discount))) MonthlyRevenue
FROM
    orders o
JOIN
    employees e ON o.employee_id = e.employee_id
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    e.employee_id, e.first_name, e.last_name, EXTRACT(YEAR FROM o.order_date),
       EXTRACT(MONTH FROM o.order_date) 
ORDER BY
    e.employee_id, y,m;
--------------------------------------------------


---LOGISTICS ANALYSES

--On-time delivery rate of orders

SELECT
   floor(floor(( COUNT(CASE WHEN o.shipped_date <= o.required_date THEN 1 END))) * 100.0 / (COUNT(*)))/100 AS OnTimeDeliveryRate
FROM
    Orders o;
	
	
--- average shipping times of companies
SELECT
    o.ship_via,s.company_name,
    COUNT(CASE WHEN o.shipped_date <= o.required_date THEN 1 END) * 100.0 / COUNT(*) AS OnTimeDeliveryRate
FROM
    Orders o
JOIN
    shippers s ON o.ship_via = s.shipper_id
GROUP BY
    o.ship_via,s.company_name
ORDER BY
    OnTimeDeliveryRate DESC;
	
	
---Delivery times of orders by country
WITH tablo AS (
    SELECT
        o.ship_country,
        s.company_name AS shippers,
        AVG(AGE(o.shipped_date, o.order_date)) AS AvgDeliveryTime
    FROM
        Orders o
    JOIN
        shippers s ON o.ship_via = s.shipper_id
    WHERE
        o.shipped_date IS NOT NULL
    GROUP BY 
        o.ship_country, s.company_name
    ORDER BY 
        o.ship_country
)
SELECT 
    ship_country,
    CAST(EXTRACT(EPOCH FROM AVG(AvgDeliveryTime)) / 86400 AS INTEGER) AS adt
FROM 
    tablo
GROUP BY 
    ship_country
ORDER BY 
    ship_country;
	
	
-- Average order days by shippers
SELECT
    s.shipper_id,
    s.company_name,
    AVG(AGE(o.shipped_date, o.order_date)) AS AvgDeliveryTime
FROM
    orders o
JOIN
    shippers s ON o.ship_via = s.shipper_id
WHERE
    o.shipped_date IS NOT NULL
GROUP BY
    s.shipper_id, s.company_name
ORDER BY
    AvgDeliveryTime;

SELECT 
    s.company_name,
    s.shipper_id,
   floor (AVG(shipped_date - order_date)) AS avg_delivery_time
FROM orders o 
JOIN
    shippers s ON o.ship_via = s.shipper_id
WHERE
    o.shipped_date IS NOT NULL
GROUP BY shipper_id;


---Average shipping cost per order
SELECT
    AVG(o.Freight) AS AvgFreightCostPerOrder
FROM
    Orders o
select * from orders

------Average shipping price by company
SELECT
    s.company_name,
    AVG(o.Freight) AS AvgFreightCostPerOrder
FROM
    Orders o
JOIN
    shippers s ON o.ship_via = s.shipper_id	
group by s.company_name

-----Average shipping Price by country

SELECT 
    ship_country,
    SUM(freight) AS total_freight
FROM orders
GROUP BY ship_country
ORDER BY total_freight DESC

