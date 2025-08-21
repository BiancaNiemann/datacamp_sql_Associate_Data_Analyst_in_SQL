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