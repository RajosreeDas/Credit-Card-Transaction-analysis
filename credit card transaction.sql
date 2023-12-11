select * from credit_card_transcations

--write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte1 as 
(select city, SUM(amount) as most_spent from credit_card_transcations
group by city)

select TOP 5 city, most_spent, 
ROUND((most_spent / SUM(most_spent) OVER ()) * 100.0, 2) as percent_spent
from cte1
order by most_spent desc

--write a query to print highest spend month and amount spent in that month for each card type

with cte2 as (
select card_type,
SUM(amount) as total_spent,
dense_rank() OVER(partition by card_type order by sum(amount) desc)
from credit_card_transcations
group by card_type


select MONTH(transaction_date) as spent_month,  sum(amount) from credit_card_transcations
group by MONTH(transaction_date) 

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of  1,000,000 total spends(We should have 4 rows in the o/p one for each card type)

with cte1 as (select  card_type, SUM(amount) as total_amount from credit_card_transcations
group by card_type)

select * from credit_card_transcations as c
JOIN cte1 on c.card_type=cte1.card_type
where total_amount>=1000000
group by cte1.card_type

--write a query to find city which had lowest percentage spend for gold card type

with cte1 as 
(select city , 
sum(amount) as total_spent,
(SUM(CASE when card_type='Gold' THEN amount END)) as gold_spent 
from credit_card_transcations
group by city, card_type)

select TOP 1 city, ROUND(SUM(gold_spent)/SUM(total_spent)*100.0 ,2) as percent_spent from cte1
group by city
HAVING count(gold_spent)>0
order by percent_spent 

--write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte1 as (select city ,exp_type, SUM(amount) as spent_amount from credit_card_transcations
group by city, exp_type)

with cte2 as (select city, 
MAX(spent_amount) as highest_expense_type,
MIN(spent_amount) as lowest_expense_type 
from cte1 
group by city)

select cte1.city,
MAX(case when highest



--write a query to find percentage contribution of spends by females for each expense type
with fpercent as 
(select exp_type, sum(amount) as amt_spent, 
SUM(CASE WHEN gender='Female' THEN amount END) as f_spent
from credit_card_transcations
group by exp_type)

select exp_type, ROUND((f_spent)/(amt_spent) * 100 ,2) as percent_spent from fpercent
order by percent_spent DESC


--which card and expense type combination saw highest month over month growth in Jan-2014
--select card_type, exp_type , 
--amount as amt_spent,
--MONTH(transaction_date) as month
--from credit_card_transcations
--group by card_type, exp_type, MONTH(transaction_date)


WITH MonthlyGrowth AS (
    SELECT
        card_type,
        exp_type,
        month,
        LAG(amount) OVER (PARTITION BY card_type, exp_type ORDER BY month) AS prev_amount,
        amount - LAG(amount) OVER (PARTITION BY card_type, exp_type ORDER BY month) AS growth
    FROM
        expenses
    WHERE
        YEAR(month) = 2014
)
SELECT
    card_type,
    exp_type,
    MAX(growth) AS max_monthly_growth
FROM
    MonthlyGrowth
WHERE
    month = '2014-01-01'
GROUP BY
    card_type,
    exp_type;








--during weekends which city has highest total spend to total no of transcations ratio 
select top 1 city , sum(amount)*1.0/count(1) as ratio
from credit_card_transcations
where datepart(weekday,transaction_date) in (1,7)
--where datename(weekday,transaction_date) in ('Saturday','Sunday')
group by city
order by ratio desc;




-- which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as (
select *
,row_number() over(partition by city order by transaction_date,transaction_id) as rn
from credit_card_transcations)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as datediff1
from cte
where rn=1 or rn=500
group by city
having count(1)=2
order by datediff1 