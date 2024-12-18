-- Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the unique values and remove the the original table from the databases and replace the name of the new table with the original name.

SELECT 
    transactionID, COUNT(*)
FROM
    sales_transaction
GROUP BY transactionID
HAVING COUNT(*) > 1;

CREATE TABLE new_tbl AS SELECT DISTINCT * FROM
    sales_transaction;

drop table sales_transaction;

alter table new_tbl
rename to sales_transaction;

SELECT 
    *
FROM
    sales_transaction;
    
-- Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. Also, update those discrepancies to match the price in both the tables.

SELECT 
    TransactionID,
    trans.Price AS TransactionPrice,
    invent.Price AS InventoryPrice
FROM
    Sales_transaction AS trans
        JOIN
    product_inventory AS invent ON trans.ProductID = invent.ProductID
WHERE
    trans.Price != invent.Price;

UPDATE Sales_transaction AS trans
        JOIN
    product_inventory AS invent ON trans.ProductID = invent.ProductID 
SET 
    trans.Price = invent.Price
WHERE
    trans.Price != invent.Price;

SELECT 
    *
FROM
    Sales_transaction;
    
-- Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.

SELECT 
    *
FROM
    customer_profiles
WHERE
    CustomerID IS NULL OR Age IS NULL
        OR Gender IS NULL
        OR Location IS NULL
        OR JoinDate IS NULL;

SELECT 
    COUNT(*)
FROM
    customer_profiles
WHERE
    Location IS NULL;

SELECT 
    CustomerID,
    Age,
    Gender,
    IFNULL(Location, 'unknown') AS Location,
    JoinDate
FROM
    customer_profiles;
    
-- Write a SQL query to summarize the total sales and quantities sold per product by the company.

SELECT 
    ProductID,
    SUM(quantitypurchased) AS TotalUnitsSold,
    SUM(price * quantitypurchased) AS TotalSales
FROM
    Sales_transaction
GROUP BY ProductID
ORDER BY TotalSales DESC;

-- Write a SQL query to count the number of transactions per customer to understand purchase frequency.

SELECT 
    customerID, COUNT(TransactionID) AS NumberOfTransactions
FROM
    sales_transaction
GROUP BY customerID
ORDER BY NumberOfTransactions DESC;

-- Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.

SELECT 
    category,
    SUM(quantitypurchased) AS TotalUnitsSold,
    SUM(sales_transaction.price * quantitypurchased) AS TotalSales
FROM
    sales_transaction
        JOIN
    product_inventory ON sales_transaction.productID = product_inventory.productID
GROUP BY category
ORDER BY TotalSales DESC;

-- Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

SELECT 
    ProductID, SUM(price * quantitypurchased) AS TotalRevenue
FROM
    Sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, provided that at least one unit was sold for those products.

SELECT 
    productID, SUM(quantitypurchased) AS TotalUnitsSold
FROM
    Sales_transaction
GROUP BY productID
HAVING COUNT(quantitypurchased) >= 1
ORDER BY TotalUnitsSold ASC
LIMIT 10;

-- Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

SELECT 
    TransactionDate_updated AS DATETRANS,
    COUNT(TransactionID) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    SUM(price * QuantityPurchased) AS TotalSales
FROM
    Sales_transaction
GROUP BY DATETRANS
ORDER BY DATETRANS DESC;

-- Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.

with cte as
(
select month(transactionDate_updated) as month,
sum(price*quantitypurchased) as total_sales,
lag(sum(price*quantitypurchased)) over (order by month(transactionDate_updated)) as previous_month_sales
from Sales_transaction
group by month
)
select month,total_sales,previous_month_sales,
((total_sales-previous_month_sales)/previous_month_sales*100) as mom_growth_percentage
from cte
order by month;

-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.

SELECT 
    CustomerID,
    COUNT(transactionID) AS NumberOfTransactions,
    SUM(price * QuantityPurchased) AS TotalSpent
FROM
    Sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions > 10
    AND TotalSpent > 1000
ORDER BY TotalSpent DESC;

-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer, which will help us understand the customers who are occasional customers or have low purchase frequency in the company.

SELECT 
    customerID,
    COUNT(transactionID) AS NumberOfTransactions,
    SUM(price * quantitypurchased) AS TotalSpent
FROM
    sales_transaction
GROUP BY customerID
HAVING NumberOfTransactions <= 2
ORDER BY NumberOfTransactions , TotalSpent DESC;

-- Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.

SELECT 
    customerID,
    productID,
    COUNT(quantitypurchased) AS TimesPurchased
FROM
    sales_transaction
GROUP BY customerID , productID
HAVING TimesPurchased > 1
ORDER BY TimesPurchased DESC;

-- Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.

with cte as
(
select customerID,
min(transactiondate_updated) as FirstPurchase,
max(transactiondate_updated) as LastPurchase
from Sales_transaction
group by customerID

)
select customerID,FirstPurchase,LastPurchase,
timestampdiff(day,FirstPurchase,LastPurchase) as DaysBetweenPurchases
from cte 
group by customerID
having DaysBetweenPurchases>0
order by DaysBetweenPurchases desc;

-- Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, count the number of customers in each segment which will help us target a particular segment for marketing.

with cte as
(
    select sales_transaction.customerID,sum(quantitypurchased) as qnt
     from customer_profiles join
     Sales_transaction
     on customer_profiles.customerID=Sales_transaction.customerID  
     group by sales_transaction.customerID
)
select case when qnt
     between 1 and 9 then 'Low'
     when  qnt between 10 and 30 then 'Med' else 'High' end as CustomerSegment
     ,count(*) from cte
     group by CustomerSegment;
     
     



