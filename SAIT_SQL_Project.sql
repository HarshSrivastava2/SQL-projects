-- Team 3
-- Alireza Alamatsaz, Arezo Aziz, Hamideh Eskandari, Harsh Srivastava

-- 3 questions:
-- Q1) Which SupportRep got the highest sales (round to two decimal places)? Whos is their Supervisor? Who is their supervisor's supervisor?

-- Q2) Sales questions:
-- 2 a) What quarter of what year did the company have least sales?
-- 2 b) FINDING SEASONALITY: What quarter in general does the company have least sales?
-- 2 c) Give sales by countries, sort by descending order. Which countries have the two highest and the two lowest sales?
-- 2 d) Give Customer Name, Customer Email, CustomerId and total $ spend by each customer. Sort in descending order; who is the highest spending customer?

-- Q3) "Hot" Market for sales and popularity of genres
-- 3 a) Which country has the highest number of distinct invoices?
-- 3 b) What genre is the most popular in the country that had the highest number of disctinct invoices?


--------------------------------------------------------------------------------
-- 1) Which SupportRep got the highest sales (round to two decimal places)?
-- Whos is their Supervisor? Who is their supervisor's supervisor?

-- Ans: SupportRep #3 had highest sales of $833.04. Their reporting manager is Nancy Edwards, and her manager is Andrew Adams
--------------------------------------------------------------------------------

SELECT Customer.SupportRepId, ROUND(SUM(Invoice.Total),2) as Sales_per_SupportRep,
		CONCAT(e1.FirstName,' ',e1.LastName) as Emp_Name, CONCAT(e2.FirstName,' ',e2.LastName) as Supervizor_Name,
		CONCAT(e3.FirstName,' ',e3.LastName) as General_Mngr_name
FROM Customer
		JOIN Invoice ON Customer.CustomerID = Invoice.CustomerId
		JOIN Employee as e1 ON e1.EmployeeID = Customer.SupportRepId
		JOIN Employee as e2 ON e2.EmployeeID = e1.ReportsTo
		JOIN Employee as e3 ON e3.EmployeeID = e2.ReportsTo
	
GROUP BY Customer.SupportRepId, e1.FirstName, e1.LastName, e2.FirstName, e2.LastName, e3.FirstName, e3.LastName
ORDER BY Sales_per_SupportRep desc;

--------------------------------------------------------------------------------
-- Q2: Sales questions
-- 2 a) What quarter of what year did the company have least sales?

-- Ans: The 4th quarter of 2011 overall has to lowest total sales at $99.
--------------------------------------------------------------------------------

SELECT DATEPART(YEAR, Invoice.InvoiceDate) as YEAR, DATEPART(QUARTER, Invoice.InvoiceDate) as QTR, 
       SUM(Invoice.Total) as Total_sales
FROM Invoice
GROUP BY DATEPART(YEAR, Invoice.InvoiceDate),DATEPART(QUARTER, Invoice.InvoiceDate)
ORDER BY YEAR;

--------------------------------------------------------------------------------
-- 2 b) FINDING SEASONALITY: What quarter in general does the company have least sales?

-- Ans: The 4th quarter overall has lowest total sales at $568.44.
--------------------------------------------------------------------------------

SELECT DATEPART(QUARTER, Invoice.InvoiceDate) as QTR, 
       ROUND(SUM(Invoice.Total),2) as Total_sales
FROM Invoice
GROUP BY DATEPART(QUARTER, Invoice.InvoiceDate)
ORDER BY QTR;

--------------------------------------------------------------------------------
-- 2 c) Give sales by countries, sort by descending order.
-- Which countries have the two highest and the two lowest sales?

-- Ans: Highest 2 sales: USA & Canada
-- Lowest 2 sales: Argentina, Australia, Belgium, Denmark, Poland, Italy, Spain are all the lowest sales at $37.62
--------------------------------------------------------------------------------

SELECT Invoice.BillingCountry,
		SUM(Invoice.Total) as Country_Sales 
FROM Invoice
GROUP BY Invoice.BillingCountry
ORDER BY Country_Sales desc;

-- Top 2 sales
SELECT Top 2 Invoice.BillingCountry,
		SUM(Invoice.Total) as Country_Sales 
FROM Invoice
GROUP BY Invoice.BillingCountry
ORDER BY Country_Sales desc;

-- Bottom 2 sales
SELECT Top 2 Invoice.BillingCountry,
		SUM(Invoice.Total) as Country_Sales 
FROM Invoice
GROUP BY Invoice.BillingCountry
ORDER BY Country_Sales asc;

--------------------------------------------------------------------------------
-- 2 d) Give Customer Name, Customer Email, CustomerId and total $ spend by each customer.
-- Sort in descending order; who is the highest spending customer?

-- Ans: Helena Holy (CustomerID #6) is the highest spending customer with a total spend of $49.62
--------------------------------------------------------------------------------

SELECT Invoice.CustomerId, SUM(Invoice.Total) as Sales_per_Customer,
		CONCAT(Customer.FirstName,' ',Customer.LastName) as Customer_Name, Customer.Email

FROM Invoice JOIN Customer ON Invoice.CustomerId = Customer.CustomerId

GROUP BY Invoice.CustomerId, Customer.FirstName, Customer.LastName, Customer.Email
ORDER BY Sales_per_Customer desc;



--------------------------------------------------------------------------------
-- Q 3 a) Which country has the highest number of distinct invoices?

-- Ans: USA has 91 invoices, the highest of any country in our dataset
--------------------------------------------------------------------------------

SELECT Invoice.BillingCountry, COUNT(Invoice.InvoiceId) as Number_of_invoices
FROM Invoice	
GROUP BY Invoice.BillingCountry
ORDER BY Number_of_invoices desc;

--------------------------------------------------------------------------------
-- 3b) What genre is the most popular in the country that had the highest number of disctinct invoices?

-- Ans: Rock is the most popular Genre in the USA as 39 invoices have "Rock" genre present and
-- 157 Rock songs are present on 91 distinct invoices

-- Genre_on_distinct_invoices: On how many distinct invoices is that Genre present,
-- i.e. 39 invoices out of total 91 invoices (from "3.a" above) have Rock as genre

-- Songs_on_distinct_invoices: How many distinct songs from that Genre are present on invoices,
-- i.e. 157 Rock songs are present on 91 invoices (from "3.a" above) in the USA
--------------------------------------------------------------------------------

SELECT Invoice.BillingCountry, Genre.name as genre_name,
	COUNT(DISTINCT Invoice.InvoiceId) as Genres_on_distinct_invoices,
	COUNT(Invoice.InvoiceId) as Songs_on_distinct_invoices

FROM Invoice	
	JOIN InvoiceLine ON Invoice.InvoiceId = InvoiceLine.InvoiceId
	JOIN Track ON InvoiceLine.TrackId = Track.TrackId
	JOIN Genre ON Track.GenreId = Genre.GenreId

WHERE Invoice.BillingCountry = 'USA'
GROUP BY Invoice.BillingCountry, Genre.name
ORDER BY Genres_on_distinct_invoices desc;