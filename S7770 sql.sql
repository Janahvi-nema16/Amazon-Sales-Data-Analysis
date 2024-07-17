-- SQL Capstone Project-"Amazon Sales Data Analysis"
create database sql_capstone;
use sql_capstone;

-- Changing column names so that they can be written without backtick

alter table amazon
rename column `Invoice ID` to Invoice_ID;

alter table amazon
rename column `Product line` to Product_line;

alter table amazon
rename column `Unit Price` to Unit_Price;

alter table amazon
rename column `Tax 5%` to Tax;

alter table amazon
rename column `gross margin percentage` to gross_margin_percentage;

alter table amazon
rename column `gross income` to gross_income;

alter table amazon
rename column `Customer type` to Customer_type;

-- Adding 3 new columns to get better information about the dataset
-- creating column timeofday
alter table amazon
add column timeofday VARCHAR(30);

update amazon
set timeofday=
case
when extract(hour from Time)>=0 and extract(hour from time)<12 then "Morning"
when extract(hour from Time)>=12 and extract(hour from time)<18 then "Afternoon"
else "Evening"
end;
-- timeofday column categorizes order as "morning","evening" and "afternoon" according to the time on which order was placed


-- creating dayname column
alter table amazon
add column day_name varchar(10);

-- dayname column categorizes order on the basis of day they were placed
update amazon 
set day_name=dayname(Date);


-- creating column monthname 
alter table amazon
add column month_name varchar(20);

update amazon 
set month_name=monthname(Date);
-- The month column will give us the month on which order got placed


-- Business Questions For The Analysis 


-- 1.What is the count of distinct cities in the dataset?
-- Query goes here
select count(distinct City) as cities from amazon;
-- This query returns the count of distinct cities
select City, count(*) as city_count
from amazon
group by City;
-- This query returns the city names with count of each city
-- There are 3 distinct cities namely-"Yangon","Naypyitaw" and "Mandalay"

-- 2.For each branch, what is the corresponding city?
-- Query goes here
select branch,city 
from amazon 
group by city,branch
order by branch;
-- This query returns the branch "A","B","C" with their respective city names

-- 3.What is the count of distinct product lines in the dataset?
-- Query goes here
select distinct product_line from amazon;
-- There are 6 different product lines across all branches.
select Product_line,count(*) as count
from amazon
group by Product_line;
-- This query returns the count of each product line in the dataset

-- 4. Which payment method occurs most frequently?
-- Query goes here
select Payment,count(*) as payment_count
from amazon
group by Payment
order by count(*) desc;
-- The payment method which occurs more frequently is Ewallet followed by cash and credit card


-- 5.Which product line has the highest sales?
-- Query goes here
select Product_line,sum(Quantity) as Quantity_sold
from amazon 
group by Product_line
order by sum(Quantity) desc
limit 1;
-- The product line which has highest sales is "Electronic accessories"

-- 6. How much revenue is generated each month?
-- Query goes here 
select month_name,round(sum(Total),2) as revenue_per_month
from amazon
group by month_name
order by sum(Total) desc;
-- This query returns the revenue generated by each month,the highest revenue was recorded in January month

-- 7.In which month did the cost of goods sold reach its peak?
-- Query goes here
select month_name,round(sum(cogs),2) as cost_of_goods_sold
from amazon
group by month_name
order by sum(cogs) desc
limit 1;
-- This query returns "January" month on which the cogs reached it's peak 


-- 8. Which product line generated the highest revenue?
-- Query goes here
select Product_line,round(sum(Total),2) as revenue_generated
from amazon 
group by Product_line
order by sum(Total) desc
limit 1;
-- This query fetches the highest revenue product line as "Food and beverages"


-- 9.In which city was the highest revenue recorded?
-- Query goes here
select City,round(sum(Total),2) as revenue
from amazon 
group by City 
order by sum(Total) desc
limit 1;
-- This query returns the output as "Naypyitaw" where highest revenue was recorded,which is the captital of myanamar


-- 10. Which product line incurred the highest Value Added Tax?
-- Query goes here 
select Product_line,round(sum(Tax),2) as Value_added_tax
from amazon 
group by Product_line 
order by sum(Tax) desc;
-- The highest tax was incurred by product line "Food and beverages"


-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- Query goes here
select Product_line, Quantity,Invoice_ID,
case
when Quantity > avg_sales then 'Good'
else 'Bad'
end as sales_status
from (
select Product_line,Quantity,Invoice_ID,
avg(Quantity) over(partition by Product_line) AS avg_sales
from amazon
) as abc;
-- This query creates a new column "sales_status" indicating good/bad for each product line



-- 12. Identify the branch that exceeded the average number of products sold.
-- Query goes here
select Branch,City
from(
select Branch, avg(Quantity) as avg_quantity_sold,City
from amazon
group by Branch,City
) as tbl
where avg_quantity_sold > (select avg(Quantity) from amazon);
-- This query first calculates the average quantity sold acroos each branch and then compares it to the overall avg of quantity



-- 13. Which product line is most frequently associated with each gender?
-- Query goes here
select tbl.Gender, tbl.Product_line,tbl.frequency
from (select Gender,Product_line,count(*) as frequency,
row_number() over (partition by Gender order by count(*) desc) as row_num
from amazon
group by Gender, Product_line
) as tbl
where tbl.row_num = 1;
-- The popular product line among male gender is "Health and beauty"
-- The popular product line among female gender is "fashion accessories"

-- 14. Calculate the average rating for each product line.
-- Query goes here
select Product_line,round(avg(Rating),1) as average_rating
from amazon 
group by Product_line;
-- This query gives us the average rating of each product line 


-- 15. Count the sales occurrences for each time of day on every weekday.
select timeofday,count(Quantity) as orders_placed
from amazon 
where day_name="Monday" or "Tuesday" or "Wednesday" or "Thursday" or "Friday"
group by timeofday
order by count(Quantity) desc;
-- The output of this query results that most sales have occurred in "Afternoon" followed by Evening and Morning


-- 16. Identify the customer type contributing the highest revenue
-- Query goes here
select Customer_type,round(sum(Total),2) as revenue_generated 
from amazon
group by Customer_type
order by sum(Total) desc;
-- The customer type contributing the highest revenue are the "Member" who have taken membership from the ecommerce branch 

-- 17. Determine the city with the highest VAT percentage.
-- Query goes here
select City,
round(sum(Tax),2) as tax_total, round(sum(Total),2) as total_revenue,
round(((sum(Tax) /sum(Total))*100),3) as vat_percentage
from amazon 
group by City;
-- All the three cities have equal vat percentages although they have generated different revenues



-- 18. Identify the customer type with the highest VAT payments.
-- Query goes here
select Customer_type,round(sum(Tax),2) as total_tax_payed 
from amazon 
group by Customer_type 
order by sum(Tax) desc
limit 1;
-- The customer type with the highest vat payments are the "Member" customers


-- 19. What is the count of distinct customer types in the dataset?
-- Query goes here 
select distinct Customer_type,count(*) as count_of_each_type 
from amazon 
group by Customer_type; 
-- There are only two distinct customer type in dataset- "Normal" and "Member" with count of "499" and "501" respectively



-- 20. What is the count of distinct payment methods in the dataset?
select  distinct Payment,count(*) as count_of_payment_mode
from amazon
group by Payment;
-- There are three payment methods namely- "Ewallet","Cash" and "Credit card" 
-- Most frequently used payment methods are "Ewallet" and "Cash"


-- 21. Which customer type occurs most frequently?
-- Query goes here 
select Customer_type, count(*) as count_of_cust_type
from amazon
group by Customer_type
limit 1;
-- The customer type occurring most frequently are the "Member" customers


-- 22. Identify the customer type with the highest purchase frequency.
-- Query goes here
select Customer_type,count(*) as frequency
from amazon 
group by Customer_type
order by count(*) desc
limit 1;
-- The "Member" type customers have placed most orders as their frequency of occurring is the highest



-- 23. Determine the predominant gender among customers.
-- Query goes here
select Gender,count(*) as count_of_gender
from amazon 
group by Gender
order by count(*) desc
limit 1;
-- The predominant gender among customers is the "Female" gender with a count of "501"


-- 24. Examine the distribution of genders within each branch.
-- Query goes here
select Gender,Branch,count(*) as gender_count
from amazon 
group by Gender,Branch
order by Branch;
-- This query gives us the distribution of male and female in branch "A", "B" & "C" and the count of each gender in the respective branches



-- 25. Identify the time of day when customers provide the most ratings.
-- Query goes here 
select timeofday,count(Rating) as rating_count
from amazon 
group by timeofday 
order by count(Rating) desc
limit 1;
-- During "Afternoon" customers have given most ratings with a count of "528" 


-- 26. Determine the time of day with the highest customer ratings for each branch.
-- Query goes here
select timeofday,Branch,count(Rating) as rating_count
from amazon 
group by timeofday,Branch 
order by Branch;
-- This query gives us the count of rating in each branch during afternnon,morning and evening 



-- 27. Identify the day of the week with the highest average ratings.
-- Query goes here
select day_name, round(avg(Rating),2) as avg_rating
from amazon 
group by day_name 
order by avg(Rating) desc
limit 1;
-- On "Monday", the highest average rating was given 


-- 28. Determine the day of the week with the highest average ratings for each branch.
-- Query goes here
select Branch, day_name, highest_average_rating
from( select Branch, day_name, round(avg(Rating),2) as highest_average_rating,
rank() over (partition by Branch order by round(avg(Rating),2) desc) as my_rank
from amazon
group by Branch, day_name
)as branch_averages
where my_rank = 1;
-- This query first calculates the average rating acroos each branch and gives all those 3 columns ranks but we want only the highest average rating so we have given condition on where clause
-- On "Friday" branch "A" got highest avg rating as 7.31
-- On "Monday" branch "B" got highest avg rating as 7.34
-- On "Friday" branch "C" got highest avg rating as 7.28

-- End of analysis







