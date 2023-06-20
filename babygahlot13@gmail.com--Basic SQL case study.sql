create database case_study;
--Q1--
select sum(tbl.eachtable)
from(
select count(*) as eachtable from Customer
union all
(select count(*) as eachtable from  Transactions)
union all
(select count(*) as eachtable from prod_cat_info)
)tbl;

--Q2--
select count(transaction_id) from Transactions
where transaction_id is not null;


--Q3--
alter table Customer add DOB_DATE as(convert(date,DOB,3));
alter table Transactions add TRANN_DATE as (convert(date,tran_date,3));


--Q4--
select min(TRANN_DATE)[START_DATE]
,max(TRANN_DATE)[END_DATE],
abs(DATEDIFF(DAY,  MAX(TRANN_DATE), MIN(TRANN_DATE) )) AS Difference_Days,
abs( DATEDIFF(MONTH,MAX(TRANN_DATE), MIN(TRANN_DATE) )) AS Difference_Months,
 abs(   DATEDIFF(YEAR, MAX(TRANN_DATE), MIN(TRANN_DATE) )) AS Difference_Years
FROM Transactions;


--Q5--
select prod_cat,prod_subcat
from prod_cat_info
where prod_subcat='DIY';


----------------DATA ANALYSIS----------------
---Q1--
SELECT top(1)
store_type,count(store_type)[count_trans] from Transactions
group by Store_type
order by count_trans desc;


--Q2--
select Gender,count(gender)[count_gender]
from Customer
group by Gender;


--Q3--
select top(1)
city_code,count(customer_Id)[count_customer]
from Customer
group by city_code
order by count_customer desc;


--Q4--
select prod_subcat,count(prod_subcat)[count]
from prod_cat_info 
where prod_cat='Books'
group by prod_subcat;

--Q5--
select top(1)
*from
(
select prod_cat_code,
max(Qty) [maxquantity],
sum(Qty)[sold]
from Transactions
group by prod_cat_code
) [X]
order by sold desc;

--Q6--
select sum(total_amt)[total_reveue]
from Transactions t
inner join prod_cat_info p
on p.prod_cat_code=t.prod_cat_code
and p.prod_sub_cat_code=p.prod_sub_cat_code
where prod_cat in ('Books','Electronics');


--Q7--
select count(customer_Id)[customerss] from Customer
where customer_Id in(
select cust_id
from Transactions t
left join Customer c 
on c.customer_Id=t.cust_id
where total_amt like '-%'
group by cust_id
having count(transaction_id)>10);


--Q8--

select * from Transactions

select sum(total_amt) [revenue]
from Transactions t
inner join prod_cat_info p
on p.prod_cat_code=t.prod_cat_code
and p.prod_sub_cat_code=t.prod_subcat_code
where prod_cat in ('Electronics','Clothing')
and Store_type ='Flagship store';

--Q9--
select sum(total_amt) [total_amount],prod_subcat
from Transactions t
left join Customer c on t.cust_id=c.customer_Id
left join prod_cat_info p on p.prod_sub_cat_code=t.prod_subcat_code and p.prod_cat_code=t.prod_cat_code
where Gender='M' and prod_cat in ('Electronics')
group by prod_subcat;

--Q10--
 SELECT TOP 5 
prod_subcat_code, (SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM Transactions))*100 AS PERCANTAGE_OF_SALES, 
(COUNT(CASE WHEN QTY< 0 THEN QTY ELSE NULL END)/SUM(QTY))*100 AS PERCENTAGE_OF_RETURN
FROM Transactions t
INNER JOIN prod_cat_info p ON t.prod_cat_code =p.prod_cat_code AND t.prod_subcat_code= p.prod_sub_cat_code
GROUP BY PROD_SUBCAT
ORDER BY SUM(TOTAL_AMT) DESC

select prod_subcat,(sum(total_amt)/(select sum(total_amt) from Transactions))*100 [%_of_sales],
(count(case when Qty<0 
then Qty else null 
end)/sum(Qty))*100 [%_of_return]
from Transactions t
 inner join prod_cat_info p on  t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
 group by prod_subcat
 order by sum(total_amt)desc;


 --Q11--

 select cust_id,sum(total_amt)[Revenue] from Transactions
where cust_id in (
select customer_Id from Customer
where DATEDIFF(year,convert(date,dob,103),getdate()) between 25 and 35)
and CONVERT(date,tran_date,103) between DATEADD(day,-30,(select max(convert(date,tran_date,103)) from Transactions))
and (select max(convert(date,tran_date,103)) from Transactions)
group by cust_id;

--Q12--
select top(1)
prod_cat,sum(total_amt) from Transactions t
join prod_cat_info p on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
where total_amt<0 and 
CONVERT(date,tran_date,103) between DATEADD(month,-3,(select max(convert(date,tran_date,103)) from Transactions))
and ( select max(convert(date,tran_date,103)) from Transactions)
group by prod_cat
order by sum(total_amt) desc;

--Q13--
select Store_type,sum(total_amt),sum(Qty) from Transactions
group by Store_type
having sum(total_amt)>=all(select sum(total_amt)from Transactions group by Store_type)
and sum(Qty)>=all(select sum(Qty) from Transactions group by Store_type)

--Q14--
select prod_cat, AVG(total_amt)[average] from Transactions t
join prod_cat_info p on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
group by prod_cat
having AVG(total_amt)>(select AVG(total_amt) from Transactions)

--Q15--
select prod_cat,prod_subcat,AVG(total_amt)[avg_rev],sum(total_amt)[total] from Transactions t
join prod_cat_info p on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
where prod_cat in 
(
select top(5)
prod_cat from Transactions t
join prod_cat_info p on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
group by prod_cat
order by sum(Qty) desc)
group by prod_subcat,prod_cat;

