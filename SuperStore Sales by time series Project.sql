/*
SuperStore Time Series sales data exploration

Skills used:  creating temp table, cte, aggregation, Windows funstion(RANK LEAD LAG SUM()over ...), moving average, rolling avg, time/date/month convert format

*/



Use SuperStore

Select * From superstore;

-- Analyze by Time Series: day, month, year

-- Find out Sales, Quantity, Profit & avg Discount by day
Select [Order Date], sum(Sales) as total_sales, sum(Quantity) as total_qty, avg(Discount) as avg_discount, sum(Profit) as total_profit
From superstore
Group by [Order Date]
Order by [Order Date]

-- Create a temp table to store the daily sales: 
CREATE TABLE #Order_by_Day ( 
                            [Order Date] datetime primary key, 
							total_sales float, 
							total_qty int, 
							avg_discount float, 
							total_profit float
							);

INSERT INTO #Order_by_Day ([Order Date] , total_sales , total_qty , avg_discount , total_profit )
Select [Order Date], sum(Sales) as total_sales, sum(Quantity) as total_qty, avg(Discount) as avg_discount, sum(Profit) as total_profit
From superstore
Group by [Order Date]
Order by [Order Date];

Select * From #Order_by_Day;

--Use the LEAD window function to create a new column sales_next that displays the sales of the next row in the dataset. 
--This function will help quickly compare a given row’s values and values in the next row

--current day sales, profit VS next day
Select [Order Date], total_sales, LEAD(total_sales,1,0) OVER (ORDER BY [Order Date]) as Next_sales,
total_profit, LEAD(total_profit,1,0) OVER (ORDER BY [Order Date]) as Next_profit
From #Order_by_Day
							
--Create a new column sales_previous to display the values of the row above a given row.

--current day sales, profit VS previous day
Select [Order Date], total_sales, LAG(total_sales,1,0) OVER (ORDER BY [Order Date]) as sales_prev,
total_profit, LAG(total_profit,1,0) OVER (ORDER BY [Order Date]) as profit_prev
From #Order_by_Day

--Rank the data based on sales then profit in descending order using the RANK function.

Select *, RANK () OVER (ORDER BY total_sales DESC) as sales_rank From #Order_by_Day;

Select *, RANK () OVER (ORDER BY total_profit DESC) as profit_rank From #Order_by_Day;

--Let's see the daily, month sales averages

Select YEAR([Order Date]) as year, MONTH([Order Date]) as month, FORMAT([Order Date], 'yyyy-MM') as year_month
From superstore

--Sales by each month:
Select FORMAT([Order Date], 'yyyy-MM') as year_month, sum(Sales) as m_sales
From superstore
Group by FORMAT([Order Date], 'yyyy-MM')
Order by FORMAT([Order Date], 'yyyy-MM')

--The avg monthly sales:
Select AVG(m_sales) as avg_monthly_sales
FROM (Select FORMAT([Order Date], 'yyyy-MM') as year_month, sum(Sales) as m_sales
From superstore
Group by FORMAT([Order Date], 'yyyy-MM')
) t

--Sales by each day:
Select [Order Date], sum(Sales) as d_sales
From superstore
Group by [Order Date]
Order by [Order Date]

--The avg sales by day:
Select AVG(d_sales) as avg_daily_sales
From (
Select [Order Date], sum(Sales) as d_sales
From superstore
Group by [Order Date]
) t


--Let's analysize the avg discount by day:
SELECT [Order Date], AVG(Discount) FROM superstore
GROUP BY [Order Date]
ORDER BY [Order Date]

SELECT [Order Date], Discount FROM superstore
ORDER BY [Order Date]


--Evaluate the moving averages:

--total sales, profit, quantity by yr_month:
Select FORMAT([Order Date], 'yyyy-MM') as year_month, sum(Sales) as m_sales, SUM(profit) as s_profit, SUM(quantity) as s_qty
From superstore
Group by FORMAT([Order Date], 'yyyy-MM')
Order by FORMAT([Order Date], 'yyyy-MM')

--Let's see the moving avg by month: 
With cte as (
Select FORMAT([Order Date], 'yyyy-MM') as year_month, sum(Sales) as m_sales, SUM(profit) as s_profit, SUM(quantity) as s_qty
From superstore
Group by FORMAT([Order Date], 'yyyy-MM')
)
Select year_month, m_sales, 
       avg(m_sales) OVER (ORDER BY year_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) as moving_avg_3months
From cte

--Rolling total sales by month:
With cte as (
Select YEAR([Order Date]) as yr, 
       FORMAT([Order Date], 'yyyy-MM') as year_month, 
       sum(Sales) as m_sales
From superstore
Group by YEAR([Order Date]), FORMAT([Order Date], 'yyyy-MM')
)
Select *,
       SUM(m_sales) over (partition by yr order by year_month ROWS UNBOUNDED PRECEDING) as month_rolling_byYear
From cte;

--Let's see the growth% by month:
With ct as(
Select FORMAT([Order Date], 'yyyy-MM') as year_month, sum(Sales) as m_sales, 
       LAG(sum(Sales),1,0) over (ORDER BY FORMAT([Order Date], 'yyyy-MM')) as prev_sales
From superstore
Group by FORMAT([Order Date], 'yyyy-MM')
)
SELECT *, round ((m_sales - prev_sales)/prev_sales *100 , 2) as growth_pct
FROM ct
WHERE prev_sales != 0

--Let's see the sales by year
SELECT YEAR([Order Date]) as yr, round(sum(sales),1) as t_sales, SUM(quantity) as t_qty,round(SUM(profit),1) as t_profit
FROM superstore
GROUP BY YEAR([Order Date])
ORDER BY YEAR([Order Date])

--Sales Growth by yr:
SELECT *, round((t_sales - pre_yr)/pre_yr * 100, 2) as yr_growth_pct
FROM (
SELECT YEAR([Order Date]) as yr, round(sum(sales),1) as t_sales, LAG(SUM(sales),1,0) OVER (ORDER BY YEAR([Order Date])) as pre_yr
FROM superstore
GROUP BY YEAR([Order Date])
 ) t
WHERE pre_yr != 0 


--Let's analyse the customers:

--TOP 10 customers for sales: 
SELECT TOP 10 Segment, [Customer ID], sum(Sales) AS t_sales
FROM superstore
GROUP BY Segment, [Customer ID]
ORDER BY sum(Sales) DESC;

--Sales by segment customer, ship mode
SELECT Segment, [Customer ID], [Ship Mode], sum(Quantity) AS qty
FROM superstore
GROUP BY Segment, [Customer ID],  [Ship Mode]
ORDER BY Segment, [Customer ID], [Ship Mode], qty

--Sales by segment, ship mode by qty
SELECT Segment, [Ship Mode], sum(Quantity) AS qty
FROM superstore
GROUP BY Segment,  [Ship Mode]
ORDER BY Segment,  [Ship Mode], sum(Sales);

--SORT OUT customers who made more than 10000 total sales
SELECT [Customer ID], sum(Sales) AS t_sales
FROM superstore
GROUP BY [Customer ID]
HAVING SUM(sales) > 10000
ORDER BY t_sales desc


--Find out how much each customer spend per year
SELECT [Customer ID], YEAR([Order Date]) as yr, 
       sum(Sales) as sales_yr_person 
FROM superstore
GROUP BY [Customer ID], YEAR([Order Date])
ORDER BY [Customer ID], YEAR([Order Date])


--Sales by Customers Segment:
SELECT Segment, sum(Sales) as t_sales, sum(Sales)/(select SUM(Sales) from superstore)*100 as pct
FROM superstore
GROUP BY Segment
ORDER BY sum(Sales) desc

--Sales by State:
SELECT State, 
       sum(Sales) as state_sales
FROM superstore
GROUP BY State
ORDER BY state_sales desc


--Sales by City:
SELECT City, 
       sum(Sales) as City_sales
FROM superstore
GROUP BY City
ORDER BY City_sales desc


--Sales by Region, State, City:
SELECT Region, State, City, 
       sum(Sales) as City_sales
FROM superstore
GROUP BY Region, State, City
ORDER BY City_sales desc


--Sales by Region:
SELECT Region, sum(Sales) as r_sales, sum(Sales)/(select SUM(sales) from superstore)*100 as pct
FROM superstore
GROUP BY Region
ORDER BY r_sales desc

--Analyze sales by product: 

--Sales by Category, sub catogory:
SELECT Category, [Sub-Category], 
       sum(Sales) as Cat_sales
FROM superstore
GROUP BY Category, [Sub-Category]
ORDER BY Cat_sales desc;

--sales by catogory %
SELECT Category, sum(Sales) as Cat_sales, sum(Sales)/(select SUM(sales) from superstore)*100 as cat_pct
FROM superstore
GROUP BY Category
ORDER BY Cat_sales desc


--Sales by Product:
SELECT [Product ID],
       sum(Sales) as prod_sales
FROM superstore
GROUP BY [Product ID]
ORDER BY prod_sales desc;