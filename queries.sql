-- Задание 4
--Подсчёт числа уникальних значений customer_id в таблице customers.
select COUNT(distinct customer_id) as customers_count
from
    customers;

--Задание 5.1. 
--Выводит 10 продавцов с наибольшей выручкой
-- (Имя-фамилия, количество продаж, выручка).
-- Сортировка по убыванию выручки.

select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
left join employees as e
    on s.sales_person_id = e.employee_id
group by 1
order by 3 desc
limit 10;

--Задание 5.2. 
--Выводит всех продавцов, чья выручка ниже средней выручки всех продавцов 
--(Не средней суммы продажи или средней выручки по всей компании,
-- это разные суммы.)
--(Имя-фамилия, средняя выручка за сделку). 
--Сортировка по общей выручке продавца (в таблице не отражена)

with avg_sales as (
    select
        CONCAT(e.first_name, ' ', e.last_name) as seller,
        COUNT(s.sales_id) as operations,
        FLOOR(SUM(s.quantity * p.price)) as income,
        FLOOR(AVG(s.quantity * p.price)) as average_income
    from sales as s
    left join products as p
        on s.product_id = p.product_id
    left join employees as e
        on s.sales_person_id = e.employee_id
    group by 1
)

select
    seller,
    average_income
from
    avg_sales
where average_income < (select AVG(average_income) from avg_sales)
order by 2 asc;

--Задание 5.3. 
--Выводит суммарные продажи каждого продавца в определённый день недели. 
--Напр.:Сколько всего Джон продал за все понедельники.
--(Имя-фамилия, день недели, выручка).
-- Сортировка по порядковому дню недели и продавцу.

with day_of_week_income as (
    select
        s.sales_person_id,
        EXTRACT(isodow from s.sale_date) as day_num,
        TO_CHAR(s.sale_date, 'day') as day_name,
        -- Вывожу день двумя разными способами для дальнейшей сортировки.
        -- Название нужно для чтения таблицы, номер - для сортировки.
        FLOOR(SUM(s.quantity * p.price)) as income
    from sales as s
    left join products as p
        on s.product_id = p.product_id
    group by s.sales_person_id, day_of_week_income.day_num, day_of_week_income.day_name
    order by day_num, s.sales_person_id
)

select
    day_of_week_income.day_name as day_of_week,
    day_of_week_income.income,
    e.first_name || ' ' || e.last_name as seller
from day_of_week_income
left join employees as e
    on day_of_week_income.sales_person_id = e.employee_id
order by day_of_week_income.day_num, seller;

--Задание 6.1.
--Запрос выводит 3 возрастные группы: 16-25 лет, 26-40 и 40+
-- и количество покупателей в каждой из них

select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    COUNT(customer_id) as age_count
from customers
group by 1
order by 1;

--Задание 6.2.
--Запрос выводит данные о количестве уникальных покупателей в каждом месяце
-- и выручке, которую они принесли.
--(месяц в формате YYYY-MM, число уникальных покупателей, сумма выручки).
-- Сортировка по дате по возрастанию.

select
    total_customers,
    income,
    TO_CHAR(selling_month, 'YYYY-MM') as selling_month
from
    (select
        DATE_TRUNC('month', s.sale_date) as selling_month,
        COUNT(distinct s.customer_id) as total_customers,
        FLOOR(SUM(s.quantity * p.price)) as income
    from sales as s
    left join
        products as p
        on s.product_id = p.product_id
    group by 1
    order by 1 asc) as t;

--Задание 6.3.
--Запрос выводит перечень покупателей, чья первая покупка была за 0 рублей,
-- т.е. по акции, дату первой покупки и продавца.
--(Имя-фамилия покупателя, дата первой покупки, имя-фамилия продавца)
-- Сортировка по customer_id, индивидуальному идентификатору покупателя.

select distinct on (customer)
    c.first_name || ' ' || c.last_name as customer,
    MIN(s.sale_date) as sale_date,
    e.first_name || ' ' || e.last_name as seller
from sales as s
left join customers as c
    on s.customer_id = c.customer_id
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
where p.price = 0
group by 1, 3, s.customer_id
order by customer;
