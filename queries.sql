-- Задание 4
--Подсчёт числа уникальних значений customer_id в таблице customers.
select 
COUNT(distinct customer_id) customers_count 
from 
customers; 

--Задание 5.1. 
--Выводит 10 продавцов с наибольшей выручкой (Имя-фамилия, количество продаж, выручка). Сортировка по убыванию выручки.

select 
CONCAT(e.first_name, ' ', e.last_name) seller,
COUNT (s.sales_id) operations, 
FLOOR(SUM(quantity * price)) income 
from sales s 
left join products p 
on s.product_id = p.product_id 
left join employees e 
on e.employee_id = s.sales_person_id
group by seller
order by income DESC
limit 10
;

--Задание 5.2. 
--Выводит всех продавцов, чья выручка ниже средней выручки всех продавцов (Не средней суммы продажи или средней выручки по всей компании, это разные суммы.)
--(Имя-фамилия, средняя выручка за сделку). Сортировка по общей выручке продавца (в таблице не отражена)

with avg_sales as 
(
select 
CONCAT(e.first_name, ' ', e.last_name) seller, 
COUNT (s.sales_id) operations, 
FLOOR(SUM(quantity * price)) income, 
FLOOR(AVG(quantity * price)) average_income
from sales s 
left join products p 
on s.product_id = p.product_id 
left join employees e 
on e.employee_id = s.sales_person_id
group by seller
)
select 
seller, 
average_income
from
avg_sales 
where average_income < (select AVG(average_income) from avg_sales)
order by income ASC
;

--Задание 5.3. 
--Выводит суммарные продажи каждого продавца в определённый день недели. Напр.:Сколько всего Джон продал за все понедельники.
--(Имя-фамилия, день недели, выручка). Сортировка по порядковому дню недели и продавцу.

with day_of_week_income AS(
 select 
  s.sales_person_id, 
  EXTRACT(ISODOW from s.sale_date) day_num,
  TO_CHAR(s.sale_date, 'Day') AS day_name,
  -- Вывожу день двумя разными способами для дальнейшей сортировки: название нужно для чтения таблицы, номер - для сортировки.
  FLOOR(SUM(s.quantity * p.price)) income
  from sales s 
  left join products p 
  on s.product_id = p.product_id 
  group by s.sales_person_id, day_num, day_name
  order by day_num, s.sales_person_id
  )
  select 
  CONCAT(e.first_name, ' ', e.last_name) seller, 
  day_name day_of_week, 
  income 
  from day_of_week_income 
  left join employees e 
  on e.employee_id = day_of_week_income.sales_person_id 
  order by day_num, seller
 ;

--Задание 6.1.
--Запрос выводит 3 возрастные группы: 16-25 лет, 26-40 и 40+ и количество покупателей в каждой из них

select 
case 
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
end as age_category,
COUNT(customer_id) age_count
from Customers
group by age_category
order by age_category
;

--Задание 6.2.
--Запрос выводит данные о количестве уникальных покупателей в каждом месяце и выручке, которую они принесли.
--(месяц в формате YYYY-MM, число уникальных покупателей, сумма выручки). Сортировка по дате по возрастанию.

select to_char(selling_month, 'YYYY-MM') selling_month, total_customers, income from 
(select 
date_trunc('month', sale_date) selling_month, 
COUNT(distinct customer_id) total_customers, 
FLOOR(SUM(quantity*price)) income
from sales s 
left join 
products p 
on s.product_id = p.product_id 
group by selling_month 
order by selling_month asc) t;
 
--Задание 6.3.
--Запрос выводит перечень покупателей, чья первая покупка была за 0 рублей, т.е. по акции, дату первой покупки и продавца.
--(Имя-фамилия покупателя, дата первой покупки, имя-фамилия продавца) Сортировка по customer_id, индивидуальному идентификатору покупателя.

select customer, sale_date, seller from
(select CONCAT(c.first_name, ' ', c.last_name) customer,
MIN(sale_date) sale_date,
CONCAT(e.first_name, ' ', e.last_name) seller,
price, s.customer_id
from sales s 
left join customers c 
on s.customer_id = c.customer_id 
left join employees e 
on e.employee_id = s.sales_person_id 
left join products p
on p.product_id = s.product_id 
group by customer, price, seller, s.customer_id
) tab
where price = 0
order by customer_id;
