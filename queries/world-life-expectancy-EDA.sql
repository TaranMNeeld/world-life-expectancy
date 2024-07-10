SELECT *
FROM world_life_expectancy
;

/*
I am looking at the min and max life expectancy for each country.
I also want to note that each row is over the course of 16 years

Some countries have 0 for min and max as well as 1 year.
I missed that in the first phase, so I am filtering out those rows for now.

I also want to see each country's increase in life expectancy
*/
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_Increase_16_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_16_Years ASC
;

/*
I am looking at the world's average life expectancy by year.

I am filtering out the life expectancy
*/
SELECT Year, 
ROUND(AVG(`Life expectancy`), 2) AS Averge_World_Life_Expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

/*
I want to see the correlation between average life expectancy and average GDP

I am filtering out the countries with a 0 life expectancy and/or 0 GDP

There seems to be a strong positive correlation, though the data will have to be visualized to know for sure
*/
SELECT Country,
ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Exp,
ROUND(AVG(GDP), 2) AS Avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_Life_Exp <> 0
AND Avg_GDP <> 0
ORDER BY Avg_GDP
;