# SuperStore_Sales_time_series_Project
Use SQL to analyze time-series data from sales of Super Store & create PowerBI sales dashboard over time series


# Time Series Analysis

## Dataset: 
Use the SuperStore Time Series Dataset to work on this project. 
The dataset contains 20 columns, namely, Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment, Country, and City.

## Skills Used:
   --Creating temp table, CTE with clause, aggregation, Windows funstion(RANK LEAD LAG SUM()over ...), moving average, rolling avg, time/date/month convert format
   --Creating PowerBI Sales overview Dashboard to display the sales matrix (by time, location, product, customers)

## Project task:

  1. Analyze the daily, monthly, yearly sales, profit ,quantity using date format functions & aggretations
  2. Use the LEAD/LAG window function to create new columns of sales_next/sales_previous that displays the daily sales of the next/above row
  3. Rank the monthly sales data based on sales in descending order using the RANK function.
  4. Use common SQL commands and aggregate functions to show the monthly and daily sales averages.
  5. Evaluate moving averages using the window functions to show the moving avg by every 3 months' sales.
  6. Evaluate the rolling total sales by month, partition by each year
  7. Calculate the growth% by monthly, yearly sales
  8. Analyze the customers by segment, location, sales
  9. Analyze the products by catogory, ship mode
  10. Build a PowerBI dashboard for Sales over time serie
  
![Super Store Sales Dashboard_1](https://github.com/CassieHUANGpan/SuperStore_Sales_time_series_Project/assets/117584592/cb3592dd-c840-4902-81e3-04f73e37764e)
![Super Store Sales Dashboard_2](https://github.com/CassieHUANGpan/SuperStore_Sales_time_series_Project/assets/117584592/20179589-0bf8-4924-9eed-a71102e0ceb3)
