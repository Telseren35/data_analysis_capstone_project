
--Northwind - capstone project 

--Toplam Sipariş Sayısı
select 
 count (order_id) as toplam_siparis
 from orders

select * from order_details

--Toplam Sipariş Miktarı
SELECT SUM(Quantity) AS ToplamSiparisMiktari
FROM Order_details;



---SATIŞ ve SİPARİŞ ANALİZİ

-- Toplam Satış
SELECT
 floor (SUM(od.unit_price * od.quantity)) AS toplam_satis
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id;
 


--Hangi üründen kaç adet satılmış ürün başına toplam gelir (77 adet ürün mevcut)
SELECT p.product_name,
       SUM(od.quantity) AS toplam_miktar,
       floor (SUM(od.unit_price * od.quantity) ) AS toplam_gelir
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY toplam_gelir desc

-- kategori bazında satılan ürünün miktarı
SELECT c.category_name, p.product_name, SUM(od.quantity) AS toplam_miktar
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name
ORDER BY c.category_name, toplam_miktar DESC

--En Çok hangi kategori satmış ve toplam miktarı
SELECT c.category_name,
        SUM(od.quantity) AS toplam_miktar,
        FLOOR (SUM(od.quantity * od.unit_price)) AS toplam_satis
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY toplam_satis DESC;

---Ülkelere göre Toplam satışlar
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
	
---Aylara göre toplam sipariş miktarları
SELECT EXTRACT(YEAR FROM o.order_date) AS yil,
       EXTRACT(MONTH FROM o.order_date) AS ay,
       COUNT(o.order_id) AS toplam_siparis
FROM orders o
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
ORDER BY yil, ay;

---Yıllara göre toplam sipariş miktarı
SELECT EXTRACT(YEAR FROM o.order_date) AS yil,
       COUNT(o.order_id) AS toplam_siparis
FROM orders o
GROUP BY EXTRACT(YEAR FROM o.order_date)
ORDER BY yil;

-- Ülkelere göre satılan ürünler ve miktarları
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

---MÜŞTERİ ANALİZİ


--en çok gelir sağlayanlar

SELECT C.company_name, 
floor(SUM(OD.unit_price * OD.quantity * (1 - OD.discount))) AS ToplamGelir
FROM orders O
JOIN customers C ON O.customer_id = C.customer_id
JOIN order_details OD ON O.order_id = OD.order_id
GROUP BY C.company_name, O.customer_id
ORDER BY ToplamGelir DESC;

select * from order_details

-- En çok sipariş veren müşteriler
SELECT C.company_name,COUNT(distinct O.order_id) AS SiparisSayisi
FROM Orders O
JOIN Customers C ON O.customer_id = C.customer_id
JOIN order_details OD ON O.order_id = OD.order_id
GROUP BY C.company_name, O.customer_id
ORDER BY SiparisSayisi DESC;
	
--Müşterinin en çok tercih ettiği ürün
SELECT P.product_name, OD.product_id, SUM(OD.Quantity) AS ToplamSiparisMiktari
FROM order_details OD
JOIN products P ON OD.product_id = P.product_id
GROUP BY P.product_name, OD.product_id
ORDER BY ToplamSiparisMiktari DESC
LIMIT 1;

--Hangi ülkenin müşterisi en fazla siparişi vermiş
SELECT o.ship_country, COUNT(O.order_ID) AS SiparisSayisi
FROM orders O
JOIN customers C ON O.customer_id = C.customer_id
GROUP BY o.ship_country
ORDER BY SiparisSayisi DESC
;

SELECT C.country, COUNT(C.customer_id) AS MusteriSayisi
FROM Customers C
GROUP BY C.country
ORDER BY MusteriSayisi DESC
LIMIT 1;

--RFM ANALİZİ ve SEGMENTASYON
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
            -- En değerli müşteriler (RFM Skoru: 555)
            WHEN score = '5-5-5' THEN 'En Değerli Müşteriler'
            -- Yeni müşteriler (Recency puanı en yüksek, Frequency ve Monetary düşük)
            WHEN recency_score = 5 AND frequency_score <= 3 AND monetary_score <= 3 THEN 'Yeni Müşteriler'
            
            -- Kaybedilen müşteriler (Recency puanı düşük, Frequency ve Monetary düşük)
            WHEN recency_Score <= 2 AND frequency_Score <= 2 AND monetary_score <= 2 THEN 'Kaybedilen Müşteriler'
            
            -- Sık alışveriş yapan müşteriler (Frequency ve Monetary yüksek)
            WHEN frequency_score >= 4 AND monetary_score >= 4 THEN 'Sık Alışveriş Yapanlar'
            
            ELSE 'Diğer'
        END AS Segment
		from score)
		select company_name,Segment
		from segment_table
		
		
		
---------------------------------------------




---ÇALIŞAN ANALİZİ


--Her çalışan ne kadar satmış
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
	
---Her çalışan kaç adet satmış

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
	
----Her çalışan hangi müşterilere satmış

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

---- Çalışanların ay bazında gelir durumu
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    EXTRACT(YEAR FROM o.order_date) as yil,
    EXTRACT(MONTH FROM o.order_date) as ay,
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
    e.employee_id, yil,ay;
--------------------------------------------------


---LOJİSTİK ANALİZİ

--Siparişlerin zamanında teslim edilme oranı

SELECT
   floor(floor(( COUNT(CASE WHEN o.shipped_date <= o.required_date THEN 1 END))) * 100.0 / (COUNT(*)))/100 AS OnTimeDeliveryRate
FROM
    Orders o;
	
	
--- Hangi firmanın ortalama süresi iyi
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
	
	
---Hangi ülkeye yollanmış ne kadar sürede yollanmış
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
	
	
-- Nakliyecilere göre ortalama sipariş süreleri	
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


---Sipariş başına ortalama nakliye maliyeti

SELECT
    AVG(o.Freight) AS AvgFreightCostPerOrder
FROM
    Orders o
select * from orders

------Ortalama nakliye fiyatı şirkete göre
SELECT
    s.company_name,
    AVG(o.Freight) AS AvgFreightCostPerOrder
FROM
    Orders o
JOIN
    shippers s ON o.ship_via = s.shipper_id	
group by s.company_name

-----Ülkelere göre ortalama nakliye Fiyatı

SELECT 
    ship_country,
    SUM(freight) AS total_freight
FROM orders
GROUP BY ship_country
ORDER BY total_freight DESC

