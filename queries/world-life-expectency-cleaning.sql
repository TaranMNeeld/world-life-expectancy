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


# Self join workaround for the query directly above
UPDATE world_life_expectency t1
JOIN world_life_expectency t2
	ON t1.Country = t2.Country
Set t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

#Doing the same thing as above, but for the 'Developed' option
UPDATE world_life_expectency t1
JOIN world_life_expectency t2
	ON t1.Country = t2.Country
Set t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

#Quickly check if any Status values are NULL
SELECT * 
FROM world_life_expectency
WHERE Status = NULL
;

SELECT * 
FROM world_life_expectency
;

#Finding the missing values in the life expectancy column
SELECT * 
FROM world_life_expectency
WHERE `Life expectancy` = ''
;

/*
The life expectancy column seems to have a steady increase every
year

This means I will use the average of the before and after rows
to calculate the missing values

To accomplish this I used 2 self joins.
I am selecting the t2 row before the missing value
and the t3 row after the missing value.
We now have rows that include the before and after values
with the missing values.
*/
SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
FROM world_life_expectency t1
JOIN world_life_expectency t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectency t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

#Using the previous query logic to update the missing values
UPDATE world_life_expectency t1
JOIN world_life_expectency t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectency t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = ''
;

#Check the remaining rows for blanks or nulls using the same query
#If I do happen to run into anything in the EDA phase, I will fix it
SELECT *
FROM world_life_expectency
WHERE `Adult Mortality` = '' OR `Adult Mortality` = NULL
