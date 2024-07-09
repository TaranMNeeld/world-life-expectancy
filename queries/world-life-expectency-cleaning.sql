SELECT * 
FROM world_life_expectency
;

/*
Using the ROW_NUMBER and OVER window functions to label
any duplicates with a 2nd Row_Num

Using a subquery within the FROM statement to allow me
to filter by the Row_Num column I created using the 
window functions

Using CONCAT(Country, Year) as a workaround for the
lack of a unique column
*/
SELECT *
FROM (
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectency
	) AS Row_Table
WHERE Row_Num > 1
;

/*
Created backup table

Deleting duplicates by using subquery from previous query
to filter out duplicates
*/
DELETE FROM world_life_expectency
WHERE Row_ID IN (
	SELECT Row_ID
	FROM (
		SELECT Row_ID,
		CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
		FROM world_life_expectency
	) AS Row_Table
	WHERE Row_Num > 1
)
;

/*
Populate empty Status cells by querying the list of
distinct countries where Status = 'Developing'

Error Code: 1093. You can't specify target table 
'world_life_expectency' for update in FROM clause
*/
UPDATE world_life_expectency
Set Status = 'Developing'
WHERE Country IN (
	SELECT DISTINCT(Country)
	FROM world_life_expectency
	WHERE Status = 'Developing'
)
;


UPDATE world_life_expectency t1
JOIN world_life_expectency t2
	ON t1.Country = t2.Country
Set t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'

