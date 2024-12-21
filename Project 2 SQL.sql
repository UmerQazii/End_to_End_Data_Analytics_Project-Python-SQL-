SELECT * from dbo.df_orders
--find top 10 highest reveue generating products 
select top 10 "Product Id",sum(sale_price) as sales
from df_orders
group by "Product Id"
order by sales desc

--find top 5 highest selling products in each region
with cte as (
select region,"Product Id",sum(sale_price) as sales
from df_orders
group by region,"Product Id")
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select year("Order Date") as order_year,month("Order Date") as order_month,
sum(sale_price) as sales
from df_orders
group by year("Order Date"),month("Order Date")
--order by year("Order Date"),month("Order Date")
)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

--for each category which month had highest sales 
with cte as (
select category,format("Order Date",'yyyyMM') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,format("Order Date",'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1

--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select "Sub Category",year("Order Date") as order_year,
sum(sale_price) as sales
from df_orders
group by "Sub Category",year("Order Date")
--order by year(order_date),month(order_date)
	)
, cte2 as (
select "Sub Category"
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by "Sub Category"
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc