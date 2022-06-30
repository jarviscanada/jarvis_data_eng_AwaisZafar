how table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail limit 10;

-- Check # of records
select count(*) from public.retail;

-- number of clients (e.g. unique client ID)
select count(distinct customer_id) as clients from public.retail;

--invoice date range (e.g. max/min dates)
Select max(invoice_date) as MAX_Date, min(invoice_date) as MIN_Date from public.retail;

--number of SKU/merchants (e.g. unique stock code)
select count(distinct stock_code) as merchants from public.retail;

--Calculate average invoice amount excluding invoices with a negative amount (e.g. canceled orders have negative amount)
Select avg(unit_price) as AVG_invoice from public.retail  where unit_price>0;

-- Calculate total revenue (e.g. sum of unit_price * quantity)
Select sum(unit_price*quantity) as Total from public.retail;

--Calculate total revenue by YYYYMM 
SELECT to_char(invoice_date,'YYYYMM') as date,sum(unit_price*quantity) as Total from public.retail group by date order by date;
