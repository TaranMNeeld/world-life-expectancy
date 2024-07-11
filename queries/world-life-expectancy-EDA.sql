# This is a demonstration of the EDA process. I will be leaving a lot of notes.
SELECT *
FROM world_life_expectancy
;

/*
I am looking at the min and max life expectancy for each country.

I also want to note that each row in the following query is over the course of 16 years.

Some countries have 0 for min and max as well as 1 year.
I missed that in the first phase, so I am filtering out those rows for now.

I also want to see each country's increase in life expectancy.
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

I am filtering out the life expectancy.
*/
SELECT Year, 
ROUND(AVG(`Life expectancy`), 2) AS Averge_World_Life_Expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

/*
I want to see the correlation between average life expectancy and average GDP.

I am filtering out the countries with a 0 life expectancy and/or 0 GDP.

There seems to be a strong positive correlation, though the data will have to be visualized to know for sure.
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

/*
I am using a case statement to categorize the high and low GDPs as 1s and 0s, then selecting the counts of both categories.

I am also selecting the average life expectancies within those categories.

I can see that within the top and lower halves of the GDPs there
is a positive correlation between GDPs and life expectancies.

This is another method to visualize correlations within mysql.
*/
SELECT
SUM(CASE WHEN GDP >= 1150 THEN 1 ELSE 0 END) AS High_GDP_Count,
AVG(CASE WHEN GDP >= 1150 THEN `Life expectancy` ELSE NULL END) AS High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1150 THEN 1 ELSE 0 END) AS Low_GDP_Count,
AVG(CASE WHEN GDP <= 1150 THEN `Life expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM world_life_expectancy
;

/*
Now I want to look at the correlation between country status and average life expectancy.

There are 32 developed countries and 161 developing countries.

This means the numbers are skewed in favor of the developed countries as the low count is giving them a high average.
*/
SELECT Status, 
COUNT(DISTINCT Country),
ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Exp
FROM world_life_expectancy
GROUP BY Status
;

/*
I am noticing that lower BMIs are more positively correlated with lower life expectancies

That goes against my intuition as I was thinking the risk of
heart attacks would make higher BMIs more correlated with lower life expectancies.

This could mean that there is a lurking variable. I think maybe I should also look at how BMI is correlated with GDP.
*/
SELECT Country,
ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Exp,
ROUND(AVG(BMI), 2) AS Avg_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_Life_Exp <> 0
AND Avg_BMI <> 0
ORDER BY Avg_BMI DESC
;

/*
I am looking at a rolling total of adult mortality over the 16 years.

I may also want to merge a new dataset here to get the total population for a comparison.
*/
SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;
