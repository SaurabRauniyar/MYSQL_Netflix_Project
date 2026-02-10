-- Netflix Project
USE Netflix1;


-- CREATE TABLE netflix
-- (
-- 	show_id	VARCHAR(6),
-- 	type    VARCHAR(10),
-- 	title	VARCHAR(150),
--  director VARCHAR(210),
-- 	casts	VARCHAR(1050),
-- 	country	VARCHAR(200),
-- 	date_added	VARCHAR(55),
-- 	release_year	INT,
-- 	rating	VARCHAR(15),
-- 	duration	VARCHAR(15),
-- 	listed_in	VARCHAR(100),
-- 	description VARCHAR(300)
-- );


SELECT * FROM Netflix1.netflix;



select count(*) as total_content 
from netflix;

select 
	distinct type
from netflix;

select * from netflix;

-- 15 Business problems
-- 1. Count the number of Movies vs TV Shows


select 
	type,
	count(*) as total_content
 From netflix
 Group By type;


-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
    rating
FROM
(
SELECT 
	type, 
    rating, 
    count(*),
    RANK() OVER(PARTITION BY type ORDER BY count(*) DESC) as ranking
    
    FROM netflix
    GROUP BY 1, 2
) as t1
where 
    ranking = 1;
    
   --  ORDER BY 1, 3 DESC


-- 3. List all movies released in a specific year (e.g., 2020) --

SELECT * FROM netflix

WHERE 
	type = 'Movie'
    AND
    release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;


-- sol 1
SELECT
  TRIM(j.country) AS country,
  COUNT(*) AS total_content
FROM netflix
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(country, ', ', '","'), '"]'),
  '$[*]' COLUMNS (country VARCHAR(100) PATH '$')
) j
GROUP BY country
ORDER BY total_content DESC
LIMIT 100;

-- sol 2 this is exact from video (Zero Analyst youtube)
USE Netflix1;

SELECT
  j.new_country,
  COUNT(n.show_id) AS total_content
FROM netflix n
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(n.country, ',', '","'), '"]'),
  '$[*]' COLUMNS (new_country VARCHAR(100) PATH '$')
) j
GROUP BY 1
ORDER BY total_content DESC
LIMIT  6;


-- 5. Identify the longest movie

SELECT 
		* FROM netflix

where 
	type = 'Movie'
    AND
    duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y')
      >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
      

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
where 
	director LIKE '%Rajiv Chilaka%';
    

    SELECT COUNT(*) AS total_rows
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT *,
       SUBSTRING_INDEX(duration, ' ', 1) AS seasons
FROM netflix
WHERE type = 'TV Show';

-- to count

   SELECT COUNT(*) AS total_rows
FROM (
  SELECT
    SUBSTRING_INDEX(duration, ' ', 1) AS seasons
  FROM netflix
  WHERE type = 'TV Show'
) t;

-- Greater than 5 season
SELECT
  *,
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS seasons
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre

SELECT
  n.show_id,
  TRIM(j.genre) AS genre
FROM netflix n
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(n.listed_in, ',', '","'), '"]'),
  '$[*]' COLUMNS (genre VARCHAR(100) PATH '$')
) j;


SELECT
  TRIM(j.genre) AS genre,
  COUNT(n.show_id) AS total_content
FROM netflix n
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(n.listed_in, ',', '","'), '"]'),
  '$[*]' COLUMNS (genre VARCHAR(100) PATH '$')
) j
GROUP BY TRIM(j.genre)
ORDER BY total_content DESC;

SELECT
  COUNT(*) AS rows_total,
  COUNT(DISTINCT show_id) AS unique_titles
FROM netflix;


USE Netflix1;

SELECT
  j.genre AS genre,
  COUNT(n.show_id) AS total_content
FROM netflix n
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(n.listed_in, ',', '","'), '"]'),
  '$[*]' COLUMNS (genre VARCHAR(100) PATH '$')
) j
GROUP BY j.genre;




-- 10.Find each year and the average numbers of content release in India on netflix return top 5 year with highest avg content release!

USE Netflix1;

SELECT
  yr AS year,
  ROUND(total_releases / 12, 2) AS avg_content_per_month
FROM (
  SELECT
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS yr,
    COUNT(*) AS total_releases
  FROM netflix
  WHERE country IS NOT NULL
    AND country LIKE '%India%'
    AND date_added IS NOT NULL
    AND TRIM(date_added) <> ''
  GROUP BY YEAR(STR_TO_DATE(date_added, '%M %d, %Y'))
) t
WHERE yr IS NOT NULL
ORDER BY avg_content_per_month DESC
LIMIT 5;




USE Netflix1;

SELECT
  YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
  COUNT(*) AS yearly_content,
  ROUND(
    COUNT(*) /
    (
      SELECT COUNT(*)
      FROM netflix
      WHERE country = 'India'
    ) * 100,
    2
  ) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
  AND date_added IS NOT NULL
  AND TRIM(date_added) <> ''
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5;


-- 11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';
  
  -- count
  
  SELECT COUNT(*) AS total_documentary_movies
FROM netflix
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL
   OR TRIM(director) = '';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT COUNT(*) AS total_titles
FROM netflix
WHERE casts LIKE '%Salman Khan%';

SELECT title, type, release_year, date_added
FROM netflix
WHERE casts LIKE '%Salman Khan%';

SELECT COUNT(*) AS total_movies
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND type = 'Movie';
  
  SELECT COUNT(*) AS total_movies_last_10_years
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND type = 'Movie'
  AND STR_TO_DATE(date_added, '%M %d, %Y')
      >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR);
      
      
SELECT COUNT(*) AS total_movies_last_10_years
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND type = 'Movie'
  AND release_year >= YEAR(CURDATE()) - 11;
  
  SELECT title, release_year
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND type = 'Movie'
ORDER BY release_year;



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


USE Netflix1;

SELECT
  a.actor,
  COUNT(*) AS total_movies
FROM netflix n
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(n.casts, ',', '","'), '"]'),
  '$[*]' COLUMNS (actor VARCHAR(255) PATH '$')
) a
WHERE n.country = 'India'
  AND n.type = 'Movie'
GROUP BY a.actor
ORDER BY total_movies DESC
LIMIT 10;



-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.-- 

 SELECT
  CASE
    WHEN LOWER(description) LIKE '%kill%'
      OR LOWER(description) LIKE '%violence%'
    THEN 'Bad'
    ELSE 'Good'
  END AS content_category,
  COUNT(*) AS total_content
FROM netflix
GROUP BY content_category;



SELECT
  show_id,
  title,
  type,
  description,

  CASE
    WHEN LOWER(description) LIKE '%kill%'
      OR LOWER(description) LIKE '%violence%'
    THEN 'Bad'
    ELSE ''
  END AS bad_content,

  CASE
    WHEN LOWER(description) LIKE '%kill%'
      OR LOWER(description) LIKE '%violence%'
    THEN ''
    ELSE 'Good'
  END AS good_content

FROM netflix;










