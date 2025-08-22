SELECT *
FROM company
LIMIT 5;

SELECT *
FROM fortune500
LIMIT 10;
-- 15 cols

SELECT *
FROM tag_company
LIMIT 10;
-- 2 cols

SELECT *
FROM stackoverflow
LIMIT 10;
-- 7 cols

SELECT *
FROM tag_type
LIMIT 10;
-- 3 cols

-- Count the number of null values in the ticker column
SELECT count(*) - COUNT(DISTINCT ticker) AS missing
  FROM fortune500;

  -- Count the number of null values in the industry column
SELECT count(*) - COUNT(industry) AS missing
  FROM fortune500;

  SELECT company.name
-- Table(s) to select from
  FROM company
       INNER JOIN fortune500
       on company.ticker = fortune500.ticker;

SELECT *
FROM prices;

SELECT COUNT(*) as total, COUNT(DISTINCT tag) as total_tag
FROM stackoverflow;

-- Count the number of tags with each type
SELECT type, COUNT(*) AS count
  FROM tag_type
 -- To get the count for each type, what do you need to do?
 GROUP BY type
 -- Order the results with the most common tag types listed first
 ORDER BY count DESC;

-- Select the 3 columns desired
SELECT company.name, tag_company.tag, tag_type.type
  FROM company
  	   -- Join to the tag_company table
       LEFT JOIN tag_company 
       ON company.id = tag_company.company_id
       -- Join to the tag_type table
       LEFT JOIN tag_type
       ON tag_company.tag = tag_type.tag
  -- Filter to most common type
  WHERE type='cloud';

-- Use coalesce
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       -- Don't forget to count!
       COUNT(*) AS count
  FROM fortune500 
-- Group by what? (What are you counting by?)
 GROUP BY industry2
-- Order results to see most common first
 ORDER BY count DESC
-- Limit results to get just the one value you want
LIMIT 1;

SELECT CAST(3.7 AS integer);

SELECT 3.7::integer;

-- Select the original value
SELECT profits_change, 
	   -- Cast profits_change
       CAST(profits_change AS integer) AS profits_change_int
  FROM fortune500;

-- Divide 10 by 3
SELECT 10/3, 
       -- Cast 10 as numeric and divide by 3
       10::numeric/3;

-- Now cast numbers that appear as text as numeric.
-- Note: 1e3 is scientific notation
SELECT '3.2'::numeric,
       '-123'::numeric,
       '1e3'::numeric,
       '1e-3'::numeric,
       '02314'::numeric,
       '0002'::numeric;

SELECT revenues_change::integer, COUNT(*)
  FROM fortune500
GROUP BY revenues_change::integer
 ORDER BY revenues_change;

-- Count rows 
SELECT COUNT(*)
  FROM fortune500
 -- Where...
 WHERE revenues_change > 0;

SELECT MIN(question_pct)
FROM stackoverflow;

SELECT MAX(question_pct)
FROM stackoverflow;

SELECT AVG(question_pct)
FROM stackoverflow;

--Variance Population
SELECT VAR_POP(question_pct)
FROM stackoverflow;

-- Variance Sample
SELECT VAR_SAMP(question_pct)
FROM stackoverflow;

SELECT VARIANCE(question_pct)
FROM stackoverflow;

-- Sample Std Dev
SELECT STDDEV_SAMP(question_pct)
FROM stackoverflow;

SELECT STDDEV_SAMP(question_pct)
FROM stackoverflow;

-- Population Std Dev
SELECT STDDEV_POP(question_pct)
FROM stackoverflow;


SELECT ROUND(42.1234, 2);

-- Select average revenue per employee by sector
SELECT sector, 
       AVG(revenues/employees::numeric) AS avg_rev_employee
  FROM fortune500
 GROUP BY sector
 -- Use the column alias to order the results
 ORDER BY avg_rev_employee;

-- Divide unanswered_count by question_count
SELECT unanswered_count/question_count::numeric AS computed_pct, 
       -- What are you comparing the above quantity to?
       unanswered_pct
  FROM stackoverflow
 -- Select rows where question_count is not 0
 WHERE question_count != 0
LIMIT 10;

-- Select sector and summary measures of fortune500 profits
SELECT sector,
        MIN(profits),
        AVG(profits) AS avg,
        MAX(profits),
        STDDEV(profits)
  FROM fortune500
 -- What to group by?
 GROUP BY sector
 -- Order by the average profits
 ORDER BY avg;

 -- Compute standard deviation of maximum values
SELECT STDDEV(maxval),
	   -- min
       MIN(maxval),
       -- max
       MAX(maxval),
       -- avg
       AVG(maxval)
  -- Subquery to compute max of question_count by tag
  FROM (SELECT MAX(question_count) AS maxval
          FROM stackoverflow
         -- Compute max by...
         GROUP BY tag) AS max_results; -- alias for subquery

SELECT TRUNC(42.122345, 2); --42.12

SELECT TRUNC(12345, -3); --12000

SELECT TRUNC(unanswered_count, -1) AS trunc_ua,
    count(*)
FROM stackoverflow
WHERE tag = 'amazon-ebs'
GROUP BY trunc_ua
ORDER BY trunc_ua;

SELECT GENERATE_SERIES(1, 10 , 2) AS series;
-- HELPS TO GROUP VALUES INTO BINS  

WITH bins AS(
    SELECT GENERATE_SERIES(30, 60,5) AS lower,
           GENERATE_SERIES(35, 65,5) AS upper
),
ebs AS (
    SELECT unanswered_count
    FROM stackoverflow
    WHERE tag = 'amazon-ebs'
)
SELECT lower, upper, COUNT(unanswered_count)
FROM bins
LEFT JOIN ebs
ON unanswered_count >= lower AND unanswered_count < upper
GROUP BY lower, upper
ORDER BY lower;

-- Truncate employees
SELECT TRUNC(employees, -4) AS employee_bin,
       -- Count number of companies with each truncated value
       COUNT(*)
  FROM fortune500
 -- Limit to which companies?
 WHERE employees > 100000
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;

 -- Select the min and max of question_count
SELECT MIN(question_count), 
       MAX(question_count)
  -- From what table?
  FROM stackoverflow
 -- For tag dropbox
 WHERE tag = 'dropbox';

-- Bins created in Step 2
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='dropbox') 
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count) 
  FROM bins  -- Created above
       -- Join to dropbox (created above), keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON question_count >= lower 
        AND question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;

SELECT CORR(assets, equity)
FROM fortune500;

-- Correlation between revenues and profit
SELECT CORR(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       CORR(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       CORR(revenues, equity) AS rev_equity 
  FROM fortune500;

  -- What groups are you computing statistics by?
SELECT sector,
       -- Select the mean of assets with the avg function
       AVG(assets) AS mean,
       -- Select the median
       percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median
  FROM fortune500
 -- Computing statistics for each what?
 GROUP BY sector
 -- Order results by a value of interest
 ORDER BY mean;

CREATE TEMP TABLE top_companies AS
SELECT rank, title
  FROM fortune500
WHERE rank < 10 ;

SELECT *
FROM top_companies

INSERT INTO top_companies 
SELECT rank, title
FROM fortune500
WHERE rank BETWEEN 11 AND 20
;

DROP table top_companies;

DROP TABLE IF EXISTS top_companies;

-- To clear table if it already exists; fill in name of temp table
DROP TABLE IF EXISTS profit80;

-- Create the temporary table
CREATE TEMP TABLE profit80 AS 
  -- Select the two columns you need; alias as needed
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    -- What table are you getting the data from?
    FROM fortune500
   -- What do you need to group by?
   GROUP BY sector;
   
-- See what you created: select all columns and rows from the table you created
SELECT * 
  FROM profit80;

-- Code from previous step
DROP TABLE IF EXISTS profit80;

CREATE TEMP TABLE profit80 AS
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500 
   GROUP BY sector;

-- Select columns, aliasing as needed
SELECT title, fortune500.sector, 
       profits, profits/pct80 AS ratio
-- What tables do you need to join?  
  FROM fortune500 
       LEFT JOIN profit80
-- How are the tables joined?
       ON fortune500.sector=profit80.sector
-- What rows do you want to select?
 WHERE profits > pct80;

 -- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

CREATE TEMP TABLE startdates AS
SELECT tag, min(date) AS mindate
  FROM stackoverflow
 GROUP BY tag;
 
-- Select tag (Remember the table name!) and mindate
SELECT startdates.tag, 
       mindate, 
       -- Select question count on the min and max days
	   so_min.question_count AS min_date_question_count,
       so_max.question_count AS max_date_question_count,
       -- Compute the change in question_count (max- min)
       so_max.question_count - so_min.question_count AS change
  FROM startdates
       -- Join startdates to stackoverflow with alias so_min
       INNER JOIN stackoverflow AS so_min
          -- What needs to match between tables?
          ON startdates.tag = so_min.tag
         AND startdates.mindate = so_min.date
       -- Join to stackoverflow again with alias so_max
       INNER JOIN stackoverflow AS so_max
          -- Again, what needs to match between tables?
          ON startdates.tag = so_max.tag
         AND so_max.date = '2018-09-25';

DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Select each column, rounding the correlations
SELECT measure, 
       round(profits::numeric, 2) AS profits,
       round(profits_change::numeric, 2) AS profits_change,
       round(revenues_change::numeric, 2) AS revenues_change
  FROM correlations;

  -- Working with Categorigal data
  SELECT priority, COUNT(*)
  FROM evanston311
  GROUP BY priority;

-- Find values of zip that appear in at least 100 rows
-- Also get the count of each value
SELECT zip, COUNT(*)
  FROM evanston311
  GROUP BY zip
  HAVING COUNT(*) >= 100;

-- Find values of source that appear in at least 100 rows
-- Also get the count of each value
SELECT source, COUNT(*)
  FROM evanston311
 GROUP BY source
HAVING COUNT(*) <= 100;

SELECT street, COUNT(*)
FROM evanston311
GROUP BY street
ORDER BY COUNT(*) DESC
LIMIT 5;

SELECT street, COUNT(*)
FROM evanston311
GROUP BY street
ORDER BY street
;

SELECT trim('Wow!', '!wW') AS trimmed_string;

SELECT trim('Wow!', '!') AS trimmed_string;

SELECT trim(lower('Wow!'), '!w') AS trimmed_string;

SELECT DISTINCT street,
  trim(street, '0123456789 #/.') AS trimmed_street
FROM evanston311
ORDER BY street;

-- Count rows
SELECT description
  FROM evanston311
 -- Where description includes trash or garbage
 WHERE description ILIKE '%trash%'
    AND description ILIKE '%garbage%';

-- Count rows
SELECT COUNT(*)
  FROM evanston311 
 -- description contains trash or garbage (any case)
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
 -- category does not contain Trash or Garbage
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%';

SELECT left('abcde', 2) AS left_string,
       right('abcde', 2) AS right_string,
       substring('abcde', 2, 3) AS substring_string;

SELECT substring('abcdef' FROM 2 FOR 3) AS substring_string;

SELECT split_part('abcde', 'c', 1) AS split_part_string;

SELECT split_part('ab,cd,e', ',', 3) AS split_part_string;

SELECT split_part('cats and dogs and fish', ' and', 2);

SELECT concat('a', 2, 'cc') AS concat_string;

SELECT 'a' || 2 || 'cc' AS concat_string;

-- Concatenate house_num, a space, and street and trim spaces from the start of the result
SELECT LTRIM(CONCAT_WS(' ', house_num, street)) AS address
  FROM evanston311;

-- Select the first word of the street value
SELECT split_part(street, ' ', 1) AS street_name, 
       count(*)
  FROM evanston311
 GROUP BY street_name
 ORDER BY count DESC
 LIMIT 20;

 -- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50
            THEN LEFT(description, 50 ) || '...'
       -- otherwise just select description
       ELSE description
       END
  FROM evanston311
 -- limit to descriptions that start with the word I
 WHERE description LIKE 'I %'
 ORDER BY description;

 SELECT CASE WHEN zipcount < 100 THEN 'other'
       ELSE zip
       END AS zip_recoded,
       sum(zipcount) AS zipsum
  FROM (SELECT zip, count(*) AS zipcount
          FROM evanston311
         GROUP BY zip) AS fullcounts
 GROUP BY zip_recoded
 ORDER BY zipsum DESC;

 -- Create table and then replace values in column, then put back in original table
DROP TABLE IF EXISTS recode;
CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
  FROM evanston311;
UPDATE recode SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';
UPDATE recode SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow%Removal%';
UPDATE recode SET standardized='UNUSED' 
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart', 
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 'NO LONGER IN USE');

-- Select the recoded categories and the count of each
SELECT standardized, COUNT(*)
-- From the original table and table with recoded values
  FROM evanston311 
       LEFT JOIN recode 
       -- What column do they have in common?
       ON evanston311.category = recode.category
 -- What do you need to group by to count?
 GROUP BY standardized
 -- Display the most common val values first
 ORDER BY count(*) DESC;


-- Create a table with indicator variables
 -- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the temp table
CREATE TEMP TABLE indicators AS
  SELECT id, 
         CAST (description LIKE '%@%' AS integer) AS email,
         CAST (description LIKE '%___-___-____%' AS integer) AS phone 
    FROM evanston311;
  
-- Select the column you'll group by
SELECT priority,
       -- Compute the proportion of rows with each indicator
       SUM(email)/COUNT(*)::NUMERIC AS email_prop, 
       SUM(phone)/COUNT(*)::NUMERIC AS phone_prop
  -- Tables to select from
  FROM evanston311
       left JOIN indicators
       -- Joining condition
       ON evanston311.id=indicators.id
 -- What are you grouping by?
 GROUP BY priority;

 SELECT NOW();

 SELECT '2010.01.01'::date + 1;

 SELECT '2018.12.23'::date + '1 year 2 days 3 minutes'::interval;

 -- Count requests created on March 13, 2017
SELECT count(*)
  FROM evanston311
 WHERE date_created >= '2017-03-13'
   AND date_created < '2017-03-13'::date + '1 day'::interval;

-- Select the current timestamp, 
-- and the current timestamp + 5 minutes
SELECT now(), now()+'5 minutes'::interval;

-- Select the category and the average completion time by category
SELECT category, 
       AVG(date_completed-date_created) AS completion_time
  FROM evanston311
GROUP BY category
-- Order the results
 order by completion_time desc;

 SELECT date_part('month', now()), EXTRACT(MONTH FROM now());

 SELECT date_trunc('month', now());

 -- Count requests completed by hour
SELECT date_part('hour', date_completed) AS hour,
       count(*) as count
  FROM evanston311
 GROUP BY hour
 ORDER BY hour;

-- Select name of the day of the week the request was created 
SELECT to_char(date_created, 'day') AS day, 
       -- Select avg time between request creation and completion
       AVG(date_completed - date_created) AS duration
  FROM evanston311 
 -- Group by the name of the day of the week and 
 -- integer value of day of week the request was created
 GROUP BY day, EXTRACT(DOW FROM date_created)
 -- Order by integer value of the day of the week 
 -- the request was created
 ORDER BY EXTRACT(DOW FROM date_created);

 -- Aggregate daily counts by month
SELECT date_trunc('month', day) AS month,
       AVG(count)
  -- Subquery to compute daily counts
  FROM (SELECT date_trunc('day', date_created) AS day,
               count(*) AS count
          FROM evanston311
         GROUP BY day) AS daily_count
 GROUP BY month
 ORDER BY month;

 SELECT generate_series('2018-01-01', '2018-01-15', '2 days'::interval);

 SELECT generate_series('2018-02-01', '2019-01-01', '1 month'::interval) - '1 day'::interval ;

 WITH hour_series AS(
   SELECT generate_series('2018-04-23 09:00:00', '2018-04-23 14:00:00', '1 hour'::interval) AS hours
 )
 SELECT hours, count(date_created)
 FROM hour_series
 LEFT JOIN evanston311
 ON date_trunc('hour', date_created) = hours
 GROUP BY hours
 ORDER BY hours;

WITH bins AS (
  SELECT generate_series('2018-04-23 09:00:00', '2018-04-23 15:00:00', '3 hours'::interval) AS lower, 
          generate_series('2018-04-23 12:00:00', '2018-04-23 18:00:00', '3 hours'::interval) AS upper
)
SELECT lower, upper, COUNT(date_created)
FROM bins
LEFT JOIN evanston311
ON date_created >= lower AND date_created < upper
GROUP BY lower, upper
ORDER BY lower;

SELECT day
-- 1) Subquery to generate all dates
-- from min to max date_created
  FROM (SELECT generate_series(min(date_created),
                               max(date_created),
                               '1 day')::date AS day
          -- What table is date_created in?
          FROM evanston311) AS all_dates
-- 4) Select dates (day from above) that are NOT IN the subquery
 WHERE day NOT IN  
       -- 2) Subquery to select all date_created values as dates
       (SELECT date_created::date
          FROM evanston311);

-- Count number of requests made per day 
SELECT day, count(date_created) AS count
-- Use a daily series from 2016-01-01 to 2018-06-30 
-- to include days with no requests
  FROM (SELECT generate_series('2016-01-01',  -- series start date
                               '2018-06-30',  -- series end date
                               '1 day'::interval)::date AS day) AS daily_series
       LEFT JOIN evanston311
       -- match day from above (which is a date) to date_created
       ON day = date_created::date
 GROUP BY day;

 -- Bins from Step 1
WITH bins AS (
	 SELECT generate_series('2016-01-01',
                            '2018-01-01',
                            '6 months'::interval) AS lower,
            generate_series('2016-07-01',
                            '2018-07-01',
                            '6 months'::interval) AS upper),
-- Daily counts from Step 2
     daily_counts AS (
     SELECT day, count(date_created) AS count
       FROM (SELECT generate_series('2016-01-01',
                                    '2018-06-30',
                                    '1 day'::interval)::date AS day) AS daily_series
            LEFT JOIN evanston311
            ON day = date_created::date
      GROUP BY day)
-- Select bin bounds
SELECT lower, 
       upper, 
       -- Compute median of count for each bin
       percentile_disc(0.5) WITHIN GROUP (ORDER BY count) AS median
  -- Join bins and daily_counts
  FROM bins
       LEFT JOIN daily_counts
       -- Where the day is between the bin bounds
       ON day >= lower
          AND day < upper
 -- Group by bin bounds
 GROUP BY lower, upper
 ORDER BY lower;

 -- generate series with all days from 2016-01-01 to 2018-06-30
WITH all_days AS 
     (SELECT generate_series('2016-01-01',
                             '2018-06-30',
                             '1 day'::interval) AS date),
     -- Subquery to compute daily counts
     daily_count AS 
     (SELECT date_trunc('day', date_created) AS day,
             count(*) AS count
        FROM evanston311
       GROUP BY day)
-- Aggregate daily counts by month using date_trunc
SELECT date_trunc('month', date) AS month,
       -- Use coalesce to replace NULL count values with 0
       avg(coalesce(count, 0)) AS average
  FROM all_days
       LEFT JOIN daily_count
       -- Joining condition
       ON all_days.date=daily_count.day
 GROUP BY month
 ORDER BY month; 


SELECT date_created,
     LAG(date_created) OVER (ORDER BY date_created) AS previous_date,
     LEAD(date_created) OVER (ORDER BY date_created) AS next_date,
     date_created - LAG(date_created) OVER (ORDER BY date_created) AS gap
FROM evanston311
LIMIT 10;

SELECT AVG(gap)
FROM (
  SELECT date_created::timestamp - LAG(date_created::timestamp) OVER (ORDER BY date_created) AS gap
FROM evanston311
) AS gaps;

-- Compute the gaps
WITH request_gaps AS (
        SELECT date_created,
               -- lead or lag
               LAG(date_created) OVER (ORDER BY date_created) AS previous,
               -- compute gap as date_created minus lead or lag
               date_created - LAG(date_created) OVER (ORDER BY date_created) AS gap
          FROM evanston311)
-- Select the row with the maximum gap
SELECT *
  FROM request_gaps
-- Subquery to select maximum gap from request_gaps
 WHERE gap = (SELECT MAX(gap)
                FROM request_gaps);

                -- Compute monthly counts of requests created
WITH created AS (
       SELECT date_trunc('month', date_created) AS month,
              count(*) AS created_count
         FROM evanston311
        WHERE category='Rodents- Rats'
        GROUP BY month),
-- Compute monthly counts of requests completed
      completed AS (
       SELECT date_trunc('month', date_completed) AS month,
              count(*) AS completed_count
         FROM evanston311
        WHERE category='Rodents- Rats'
        GROUP BY month)
-- Join monthly created and completed counts
SELECT created.month, 
       created_count, 
       completed_count
  FROM created
       INNER JOIN completed
       ON created.month=completed.month
 ORDER BY created.month;
