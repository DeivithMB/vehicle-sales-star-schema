-- Vehicle Sales v2 · validation queries
-- Purpose: check the Power BI star schema against the PostgreSQL source (schema "sales").

-- 1. Monthly KPIs (leads by visit date, sales and revenue by payment date)
with leads as (
    select
        date_trunc('month', visit_page_date)::date as month,
        count(*) as leads
    from sales.funnel
    group by 1
),
payments as (
    select
        date_trunc('month', f.paid_date)::date as month,
        count(f.paid_date) as sales,
        sum(p.price * (1 + f.discount)) as revenue
    from sales.funnel as f
    left join sales.products as p
        on f.product_id = p.product_id
    where f.paid_date is not null
    group by 1
)
select
    l.month,
    l.leads,
    pm.sales,
    round(pm.revenue, 0) as revenue,
    round(pm.sales::numeric / l.leads, 2) as conversion,
    round(pm.revenue / pm.sales, 0) as avg_ticket
from leads as l
left join payments as pm
    on l.month = pm.month
order by l.month;

-- 2. Visits by weekday (0 = Sunday)
select
    extract(dow from visit_page_date) as weekday_num,
    count(*) as visits
from sales.funnel
group by weekday_num
order by weekday_num;

-- 3. Sales by weekday (payment date) -> no rows for Sunday (0)
select
    extract(dow from paid_date) as weekday_num,
    count(paid_date) as sales
from sales.funnel
where paid_date is not null
group by weekday_num
order by weekday_num;

-- 4. Top brands on Sundays -> returns 0 rows
select
    p.brand,
    count(f.paid_date) as sales
from sales.funnel as f
left join sales.products as p
    on f.product_id = p.product_id
where extract(dow from f.paid_date) = 0
group by p.brand
order by sales desc;
