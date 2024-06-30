
select COUNT(distinct customer_id) as customers_count
from
    customers;
   
   select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(quantity * price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
left join employees as e
    on s.sales_person_id = e.employee_id
group by seller
order by income desc
limit 10;

with avg_sales as (
    select
        CONCAT(e.first_name, ' ', e.last_name) as seller,
        COUNT(s.sales_id) as operations,
        FLOOR(SUM(quantity * price)) as income,
        FLOOR(AVG(quantity * price)) as average_income
    from sales as s
    left join products as p
        on s.product_id = p.product_id
    left join employees as e
        on s.sales_person_id = e.employee_id
    group by seller
)

select
    seller,
    average_income
from
    avg_sales
where average_income < (select AVG(average_income) from avg_sales)
order by average_income asc;

with day_of_week_income as (
    select
        s.sales_person_id,
        EXTRACT(isodow from s.sale_date) as day_num,
        TO_CHAR(s.sale_date, 'day') as day_name,
        -- Вывожу день двумя разными способами для дальнейшей сортировки: название нужно для чтения таблицы, номер - для сортировки.
        FLOOR(SUM(s.quantity * p.price)) as income
    from sales as s
    left join products as p
        on s.product_id = p.product_id
    group by s.sales_person_id, day_num, day_name
    order by day_num, s.sales_person_id
)

select
    day_name as day_of_week,
    income,
    CONCAT(e.first_name, ' ', e.last_name) as seller
from day_of_week_income
left join employees as e
    on day_of_week_income.sales_person_id = e.employee_id
order by day_num, seller;

select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    COUNT(customer_id) as age_count
from customers
group by age_category
order by age_category;

select
    total_customers,
    income,
    to_char(selling_month, 'YYYY-MM') as selling_month
from
    (select
        date_trunc('month', sale_date) as selling_month,
        count(distinct customer_id) as total_customers,
        floor(sum(quantity * price)) as income
    from sales as s
    left join
        products as p
        on s.product_id = p.product_id
    group by selling_month
    order by selling_month asc) as t;


with tab as (
    select
        customer_id,
        MIN(sale_date) as min_date
    from
        sales
    group by customer_id
)
select
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    MIN(sale_date) as sale_date,
    CONCAT(e.first_name, ' ', e.last_name) as seller
from sales as s
left join customers as c
    on s.customer_id = c.customer_id
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
left join
    tab
    on c.customer_id = tab.customer_id
where price = 0 and sale_date = min_date
group by customer, seller, s.customer_id
order by s.customer_id;
   