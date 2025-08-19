-- Datacamp Functions for manipulating data in PostgreSQL

select payment_date
from payment
limit 10;

SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name in ('title', 'description', 'special_features')
AND table_name = 'film';

SELECT create_date
FROM customer
LIMIT 10;

SELECT rental_date, rental_date + INTERVAL '3 days' as expected_return
FROM rental;

SELECT column_name,
	data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name in ('rental_date')
	AND table_name = 'rental';
	

SELECT
 	-- Select the rental and return dates
	rental_date,
	return_date,
 	-- Calculate the expected_return_date
	rental_date + INTERVAL '3 days' AS expected_return_date
FROM rental;

-- Working with Arrays

CREATE TABLE grades (
	student_id int,
	email text [][],
	test_scores int []
);

INSERT INTO grades
	VALUES (1, 
	'{{"work", "work1@datacamp.com"}, {"other", "other1@datacamp.com"}}',
	'{92,85,98,88}');
	)
)

SELeCT *
FROM grades;

SELECT
	email[1][1] AS type,
	email[1][2] AS address,
	test_scores[1]
FROM grades;

SELECT
	email[1][1] AS type,
	email[1][2] AS address,
	test_scores
FROM grades
WHERE email[1][1] = 'work';

SELECT
	email[2][1] AS type,
	email[2][2] AS address,
	test_scores[1]
FROM grades
WHERE 'other' = ANY (email);

SELECT
	email[2][1] AS type,
	email[2][2] AS address,
	test_scores[1]
FROM grades
Where email @> ARRAY['other'];

-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';

SELECT
  title, 
  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = ANY (special_features);

SELECT 
  title, 
  special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];

--Overview of basic arithmetic operators
SELECT date '2005-09-01' + integer '3';

SELECT timestamp '2005-09-11 00:00:00' - timestamp '2005-09-09 12:00:05';

SELECT AGE(timestamp '2005-09-11 00:00:00', timestamp '2005-09-09 12:00:00');

SELECT AGE(rental_date)
FROM rental;

SELECT rental_date
FROM rental;

SELECT rental_date + INTERVAL '3 days' as expected_return
FROM rental;

SELECT timestamp '2009-06-01' + 21 * INTERVAL '1 day';

SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
	AGE(r.return_date,r.rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

SELECT
	f.title,
 	-- Convert the rental_duration to an interval
    INTERVAL '1' day * f.rental_duration,
 	-- Calculate the days rented as we did previously
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
-- Filter the query to exclude outstanding rentals
WHERE r.return_date IS NOT NULL
ORDER BY f.title;

SELECT
    f.title,
	r.rental_date,
    f.rental_duration,
    -- Add the rental duration to the rental date
    INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-- Functions for retrieving current date/time
SELECT NOW();

SELECT NOW()::timestamp;

SELECT CAST(NOW() as timestamp);

SELECT CURRENT_TIMESTAMP;

SELECT CURRENT_TIMESTAMP(2);

SELECT CURRENT_DATE;

SELECT CURRENT_TIME;

SELECT
	CURRENT_TIMESTAMP(2)::timestamp AS right_now,
    interval '5 days' + CURRENT_TIMESTAMP(2) AS five_days_from_now;

-- Extracting and transforming date/ time data

SELECT EXTRACT(quarter FROM timestamp '2005-01-21 05:12:00') As quarter;

SELECT DATE_PART('quarter', timestamp '2005-01-21 05:12:00') As quarter;

SELECT *
FROM payment;

SELECT 
	EXTRACT(quarter FROM payment_date) As quarter,
	EXTRACT(year FROM payment_date) AS year,
	SUM(amount) AS total_payments
FROM payment
GROUP BY 1, 2
ORDER BY 2, 1;

SELECT DATE_TRUNC('year', TIMESTAMP '2005-05-21 05:12:00' );

SELECT DATE_TRUNC('month', TIMESTAMP '2005-05-21 05:12:00' 

SELECT 
  -- Extract day of week from rental_date
  EXTRACT(dow FROM rental_date) AS dayofweek 
FROM rental 
LIMIT 100;

-- Extract day of week from rental_date
SELECT 
  EXTRACT(dow FROM rental_date) AS dayofweek, 
  -- Count the number of rentals
  COUNT(*) as rentals 
FROM rental 
GROUP BY 1;

-- Truncate rental_date by year
SELECT DATE_TRUNC('year', rental_date) AS rental_year
FROM rental;

-- Truncate rental_date by month
SELECT DATE_TRUNC('month', rental_date) AS rental_month
FROM rental;

-- Truncate rental_date by day of the month 
SELECT DATE_TRUNC('day', rental_date) AS rental_day 
FROM rental;

SELECT 
  DATE_TRUNC('day', rental_date) AS rental_day,
  -- Count total number of rentals 
  COUNT(*) AS rentals 
FROM rental
GROUP BY 1;

SELECT 
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM rental_date) AS dayofweek,
  AGE(return_date, rental_date) AS rental_days
FROM rental AS r 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  rental_date BETWEEN CAST('2022-05-01' AS timestamp)
   AND CAST('2022-05-01' AS timestamp) + INTERVAL '90 day';

SELECT 
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  -- Use DATE_TRUNC to get days from the AGE function
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) > 
  -- Calculate number of d
    f.rental_duration * INTERVAL '1' day 
  THEN TRUE 
  ELSE FALSE END AS past_due 
FROM 
  film AS f 
  INNER JOIN inventory AS i 
  	ON f.film_id = i.film_id 
  INNER JOIN rental AS r 
  	ON i.inventory_id = r.inventory_id 
  INNER JOIN customer AS c 
  	ON c.customer_id = r.customer_id 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  r.rental_date BETWEEN CAST('2022-05-01' AS DATE) 
  AND CAST('2022-05-01' AS DATE) + INTERVAL '90 day';

 -- Reformatting string and character data

 SELECT 
 	first_name,
	last_name,
  	first_name || ' ' || last_name AS customer_name
FROM customer;

SELECT
	CONCAT(first_name, ' ', last_name) AS full_name
FROM customer;

SELECT 
  customer_id || ': ' || first_name || ' ' || last_name AS customer_info
FROM customer;

SELECT UPPER(email)
FROM customer;

SELECT LOWER(title)
FROM film;

SELECT INITCAP(title)
FROM film;

SELECT 
  REPLACE(description, 'A Astounding', 'An Astounding') 
FROM film;

SELECT title, REVERSE(title) FROM film;

-- Concatenate the first_name and last_name and email 
SELECT first_name || ' ' || last_name || ' <' || email || '>' AS full_email 
FROM customer;

-- Concatenate the first_name and last_name and email
SELECT CONCAT(first_name, ' ', last_name, '<', email) AS full_email 
FROM customer;

SELECT 
  -- Concatenate the category name to coverted to uppercase
  -- to the film title converted to title case
  UPPER(name)  || ': ' || INITCAP(title) AS film_category, 
  -- Convert the description column to lowercase
  LOWER(description) AS description
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;

SELECT 
  -- Replace whitespace in the film title with an underscore
  REPLACE(title, ' ', '_') AS title
FROM film; 

-- Parsing string and character data

SELECT 
  title,
  CHAR_LENGTH(title) AS title_length
FROM film;

SELECT 
  title,
  LENGTH(title) AS title_length
FROM film;

SELECT 
  email,
  POSITION('@' IN email) AS at_sign_position
FROM customer;

SELECT 
  email,
  STRPOS(email, '@') AS at_sign_position
FROM customer;

SELECT 
  LEFT(description, 30) AS short_description
FROM film;

SELECT 
  RIGHT(description, 30) AS short_description
FROM film;

SELECT SUBSTRING(description, 10, 50)
FROM film;

SELECT SUBSTRING(email FROM 0 FOR POSITION('@' IN email))
FROM customer;

SELECT SUBSTRING(email FROM POSITION('@' IN email) +1 FOR CHAR_LENGTH(email))
FROM customer;

SELECT SUBSTR(description, 10, 50)
FROM film;

SELECT 
  -- Select the title and description columns
  title,
  description,
  -- Determine the length of the description column
  CHAR_LENGTH(description) AS desc_len
FROM film;

SELECT 
  -- Select the first 50 characters of description
  LEFT(description, 50) AS short_desc
FROM 
  film AS f; 

SELECT 
  -- Select only the street name from the address table
  SUBSTRING(address FROM POSITION(' ' IN address)+1 FOR CHAR_LENGTH(address))
FROM 
  address;

SELECT
  -- Extract the characters to the left of the '@'
  LEFT(email, POSITION('@' IN email)-1) AS username,
  -- Extract the characters to the right of the '@'
  SUBSTRING(email FROM POSITION('@' IN email)+1 FOR CHAR_LENGTH(email)) AS domain
FROM customer;

-- Truncating and padding string data
SELECT TRIM('   padded   ');

SELECT LTRIM('   padded   ');

SELECT RTRIM('   padded   ');

SELECT LPAD('padded', 10, '#');

SELECT LPAD('padded', 5);

SELECT RPAD('padded', 10, '#');

SELECT 
	first_name || LPAD(last_name, LENGTH(last_name)+1) AS full_name
FROM customer; 

SELECT 
	RPAD(first_name, LENGTH(first_name)+1) 
    || RPAD(last_name, LENGTH(last_name)+2, ' <') 
    || RPAD(email, LENGTH(email)+1, '>') AS full_email
FROM customer; 

-- Concatenate the uppercase category name and film title
SELECT 
  CONCAT(UPPER(c.name), ': ', title) AS film_category, 
  -- Truncate the description remove trailing whitespace
  TRIM(LEFT(description, 50)) AS film_desc
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;

SELECT 
  UPPER(c.name) || ': ' || f.title AS film_category, 
  -- Truncate the description without cutting off a word
  LEFT(description, 50 - 
    -- Subtract the position of the first whitespace character
    POSITION(
      ' ' IN REVERSE(LEFT(description, 50))
    )
  ) 
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;

-- Introduction to full-text search
SELECT title
FROM film
WHERE title LIKE 'ELF%';

SELECT title
FROM film
WHERE title LIKE '%ELF';

-- This is case sensitive, if we say %elf% it wouldnt return anything
SELECT title
FROM film
WHERE title LIKE '%ELF%';

-- This is another way to do it that is not case sensitive
SELECT title, description
FROM film
WHERE to_tsvector(title) @@ to_tsquery('elf');

-- Select the film description as a tsvector
SELECT to_tsvector(description)
FROM film;

SELECT description
FROM film;

-- Extending PostgreSQL
CREATE TYPE dayofweek AS ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

SELECT typname, typcategory FROM pg_type Where typname = 'dayofweek';

SELECT column_name, data_type, udt_name
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'film';

CREATE FUNCTION squared(i integer)
RETURNS integer AS $$
BEGIN
  RETURN i * i;
END;
$$ LANGUAGE plpgsql;

SELECT squared(3);

-- User defined function in this database
-- get_customer_balance(cust_id, effective_data)
-- inventory held by customer(inventory_id)
-- inventory_in_stock(inventory_id)

-- Select the column name, data type and udt name columns
SELECT column_name, data_type, udt_name
FROM INFORMATION_SCHEMA.COLUMNS 
-- Filter by the rating column in the film table
WHERE table_name ='film' AND column_name='rating';

SELECT *
FROM pg_type 
WHERE typname='mpaa_rating';

-- Select the film title and inventory ids
SELECT 
	f.title, 
    i.inventory_id
FROM film AS f 
	-- Join the film table to the inventory table
	INNER JOIN inventory AS i ON f.film_id=i.film_id;

  -- Select the film title, rental and inventory ids
SELECT 
	f.title, 
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) AS held_by_cust
FROM film as f 
	-- Join the film table to the inventory table
	INNER JOIN inventory AS i ON f.film_id=i.film_id 

  -- Select the film title and inventory ids
SELECT 
	f.title, 
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) as held_by_cust
FROM film as f 
	INNER JOIN inventory AS i ON f.film_id=i.film_id 
WHERE
	-- Only include results where the held_by_cust is not null
    inventory_held_by_customer(i.inventory_id) IS NOT NULL

SELECT name
FROM pg_available_extensions;

SELECT extname
FROM pg_extension;

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
SELECT extname FROM pg_extension;

SELECT levenshtein('kitten', 'sitting');

SELECT similarity('kitten', 'sitting');

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Select all rows extensions
SELECT *
FROM pg_extension;

-- Select the title and description columns
SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(title, description)
FROM 
  film

-- Select the title and description columns
SELECT  
  title, 
  description, 
  -- Calculate the levenshtein distance
  levenshtein(title, 'JET NEIGHBOR') AS distance
FROM 
  film
ORDER BY 3

-- Select the title and description columns
SELECT  
  title, 
  description 
FROM 
  film
WHERE 
  -- Match "Astounding Drama" in the description
  to_tsvector(description) @@ 
  to_tsquery('Astounding & Drama');

  SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(description, 'Astounding Drama')
FROM 
  film 
WHERE 
  to_tsvector(description) @@ 
  to_tsquery('Astounding & Drama') 
ORDER BY 
	similarity(description, 'Astounding Drama') DESC;