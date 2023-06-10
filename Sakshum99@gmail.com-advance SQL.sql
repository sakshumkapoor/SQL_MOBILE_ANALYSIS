--SQL Advance Case Study


--Q1--BEGIN 

 select distinct(state) from
  fact_transactions left join dim_location 
 on fact_transactions.IDlocation = dim_location.IDlocation
 where year(date) between  2005 and getdate()
 
--Q1--END

--Q2--BEGIN

	select top 1  state, SUM(quantity) as samsung from fact_transactions 
	left join dim_location
	on 
	fact_transactions.IDlocation = dim_location.IDlocation
	left join 
	dim_model on fact_transactions.IDmodel = dim_model.IDmodel
	left join dim_manufacturer on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer
	where manufacturer_name = 'samsung' and country = 'US'
	group by state
	order by samsung  desc

	--Q2--END

--Q3--BEGIN 
     
	select  state, zipCode, model_name , COUNT(quantity) as count_of_TXN from fact_transactions 
	left join dim_location
	on 
	fact_transactions.IDlocation = dim_location.IDlocation
	left join 
	dim_model on fact_transactions.IDmodel = dim_model.IDmodel
	left join dim_manufacturer on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer
	group by  zipCode, state , model_name 
	order by count_of_TXN desc 
		

--Q3--END

--Q4--BEGIN

 select top 1  model_name , MIN(unit_price) as price from Dim_model
  group by model_name
  
--Q4--END

--Q5--BEGIN

select model_name , AVG(unit_price) as average 
	from Dim_model 
	left join dim_manufacturer
	 on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer
		where manufacturer_name in  (
select manufacturer_name from
(select  top 5 manufacturer_name , SUM(quantity) as qty 
  from fact_transactions 
		left join 
	dim_model on fact_transactions.IDmodel = dim_model.IDmodel
	left join dim_manufacturer 
	on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer
	group by manufacturer_name) as t )
	group by model_name
	order by average desc

--Q5--END

--Q6--BEGIN


select customer_name , AVG(totalprice) as average  from fact_transactions 
left join dim_customer
on fact_transactions.IDcustomer = DIM_customer.IDcustomer
where year(date) = 2009
group by customer_name 
having AVG(totalprice) > 500
--Q6--END
	
--Q7--BEGIN  

     select model_name  from ( 
	select top 5  model_name , sum(quantity) as qty from fact_transactions 
		left join 
	dim_model on fact_transactions.IDmodel = dim_model.IDmodel
	where year(date)= 2008
	group by model_name
	order by qty desc ) as a 

	intersect 
	select model_name from (
	select top 5  model_name , sum(quantity) as qty from fact_transactions 
		left join 
	dim_model on fact_transactions.IDmodel = dim_model.IDmodel
	where year(date)= 2009
	group by model_name
	order by qty desc) as b 

	intersect 

	select Model_name  from (
	select top 5  model_name , sum(quantity) as qty from fact_transactions 
		left join 
	dim_model on fact_transactions.IDmodel = dim_model.IDmodel
	where year(date)= 2010
	group by model_name
	order by qty desc) as c



--Q7--END	
--Q8--BEGIN
select * from ( 
select top 1 * from ( 
select top 2 manufacturer_name , sum(totalprice) as sum_sales, year(date) as year    from fact_transactions 
left join 
dim_model on fact_transactions.IDmodel = dim_model.IDmodel
left join dim_manufacturer on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer 
where year(date)  = 2009
group by manufacturer_name , year(date)
order by sum_sales  desc ) as A
order by sum_sales) as B

union 

select * from (
select top 1 * from (
select top 2 manufacturer_name , sum(totalprice) as sum_sales, year(date) as year    from fact_transactions 
left join 
dim_model on fact_transactions.IDmodel = dim_model.IDmodel
left join dim_manufacturer on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer 
where year(date)  = 2010
group by manufacturer_name , year(date)
order by sum_sales  desc ) as C 
order by sum_sales ) as D





--Q8--END
--Q9--BEGIN

     select manufacturer_name from ( 
	select manufacturer_name , year(date) as year , sum(quantity) as QTY   from fact_transactions 
left join 
dim_model on fact_transactions.IDmodel = dim_model.IDmodel
left join dim_manufacturer on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer 
where year(date) = 2010
group by manufacturer_name , year(date) 
) as A 
except 
select manufacturer_name from ( 
	select manufacturer_name , year(date) as year , sum(quantity) as QTY   from fact_transactions 
left join 
dim_model on fact_transactions.IDmodel = dim_model.IDmodel
left join dim_manufacturer on Dim_model.IDmanufacturer = Dim_manufacturer.IDmanufacturer 
where year(date) = 2009
group by manufacturer_name , year(date) 
) as B



--Q9--END

--Q10--BEGIN
	
SELECT TOP 100 year(Date) year, 
    Customer_Name, 
    AVG(TotalPrice) AS Avg_total_price, 
    AVG(Quantity) AS Avg_quantity,
    100 * (AVG(TotalPrice) - LAG(AVG(TotalPrice)) 
	OVER (PARTITION BY Customer_Name ORDER BY year(date))) / LAG(AVG(TotalPrice)) 
	OVER (PARTITION BY Customer_Name ORDER BY year(date)) AS Percent_Change
FROM DIM_CUSTOMER c
JOIN FACT_TRANSACTIONS t ON c.IDCustomer = t.IDCustomer
GROUP BY Customer_Name, year(Date)
ORDER BY Avg_total_price DESC

--Q10--END
	