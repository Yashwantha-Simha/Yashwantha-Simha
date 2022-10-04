--Inspecting Data
SELECT *
  FROM [Sales RFM].[dbo].[sales_data_sample]


--Checking unique values
select distinct status from [dbo].[sales_data_sample] 
select distinct year_id from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample]
select distinct COUNTRY from [dbo].[sales_data_sample]
select distinct DEALSIZE from [dbo].[sales_data_sample] 
select distinct TERRITORY from [dbo].[sales_data_sample]
select distinct MONTH_ID From [dbo].[sales_data_sample] where year_id = 2005

SELECT *
  FROM [Sales RFM].[dbo].[sales_data_sample]
where year_id = 2005
--Analysis
--Highest revenue generating product. Ans: classic cars, vintage cars, motorcycles
select PRODUCTLINE, SUM(sales) as Revenue
from [Sales RFM].[dbo].[sales_data_sample]
group by PRODUCTLINE
order by Revenue desc

--Highest revenue generating Year. Ans:2004
select YEAR_ID, SUM(sales) as Revenue
from [Sales RFM].[dbo].[sales_data_sample]
group by YEAR_ID
order by Revenue desc

--Highest revenue generating deal. Ans: medium
select DEALSIZE, SUM(sales) as Revenue
from [Sales RFM].[dbo].[sales_data_sample]
group by DEALSIZE
order by Revenue desc

--Best performing month Answer:November, october.
select MONTH_ID, SUM(sales) as Revenue, COUNT(ORDERNUMBER) Frequency
from [Sales RFM].[dbo].[sales_data_sample]
Where YEAR_ID = 2004
group by MONTH_ID
order by Revenue desc

--Highest selling products in November. Ans:Classic Cars, vintage cars
select PRODUCTLINE, SUM(sales) as Revenue, COUNT(ORDERNUMBER) Frequency
from [Sales RFM].[dbo].[sales_data_sample]
Where YEAR_ID = 2003 and MONTH_ID = 11
group by PRODUCTLINE
order by Revenue desc

--RFM Analysis. To understand our best customer

DROP TABLE  IF EXISTS #RFM  
;with rfm as
(
	select CUSTOMERNAME,
		SUM(sales) as Monetary_value,
		avg(sales) as AvgMonetary_value,
		COUNT(ORDERNUMBER) as Frequency,
		MAX(ORDERDATE) as last_order_date,
		(SELECT MAX(ORDERDATE) from [Sales RFM].[dbo].[sales_data_sample]) as max_order_date,
		DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) from [Sales RFM].[dbo].[sales_data_sample])) as Recency
	from [Sales RFM].[dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		NTILE(4) OVER (Order by Recency desc) rfm_recency,
		NTILE(4) OVER (Order by Frequency) rfm_Frequency,
		NTILE(4) OVER (Order by Monetary_value) rfm_Monetary
	from rfm r
)
select 
	c.*, rfm_recency+rfm_Frequency+rfm_Monetary as rfm_score,
	cast (rfm_recency as varchar)+ cast (rfm_Frequency as varchar)+ cast (rfm_Monetary as varchar) as rfm_score_string
into #RFM
from rfm_calc c


Select CUSTOMERNAME, rfm_recency,rfm_Frequency,rfm_Monetary,
	CASE 
		when rfm_score_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_score_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_score_string in (311, 411, 331) then 'new customers'
		when rfm_score_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_score_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_score_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #RFM

--To understand which products are bought together
--select * from [dbo].[sales_data_sample] where ORDERNUMBER =10148


select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [Sales RFM].[dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [Sales RFM].[dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [Sales RFM].[dbo].[sales_data_sample] s
order by 2 desc

--What city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from [Sales RFM].[dbo].[sales_data_sample]
where country = 'UK'
group by city
order by 2 desc



---What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from [Sales RFM].[dbo].[sales_data_sample]
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc