USE [Portfolio Database]
-- Checking the data type
select * from information_schema.columns

SELECT TOP 100 *
From dbo.[MinhInternSearch]



-- Checking out how to select column with space
SELECT TOP 100 [Date Applied]
FROM dbo.[MinhInternSearch]


--
SELECT [Date Applied], COUNT([Date Applied])
FROM dbo.MinhInternSearch
GROUP BY [Date Applied]

-- Creating min, max date
DECLARE @min_date As datetime
DECLARE @max_date As datetime


SELECT @min_date = Min([Date Applied]) 
FROM dbo.[MinhInternSearch];

SELECT @max_date = Max([Date Applied]) 
FROM dbo.[MinhInternSearch];

/*
Here I tried to use CTE and join with the table but failed so I have to scrapped it

-- CTE for all dates 
With Dates_CTE (date, Application) as (
	SELECT @min_date, 0
	UNION ALL
	SELECT DATEADD(day , 1, date), 0
	from Dates_CTE
	where date < @max_date
)

Select *
From Dates_CTE
ORDER BY date ASC
option (maxrecursion 0)
*/

-- Making a temp table to join with the original table
Drop Table IF EXISTS #Dates_Temp
Create Table #Dates_Temp(
	date DATETIME,
	PRIMARY KEY (date)
)

WHILE (@min_date <= @max_date)
BEGIN 
	INSERT INTO #Dates_Temp VALUES (@min_date)
	SELECT @min_date = DATEADD(DAY, 1, @min_date)
END

/* Checking
SELECT * 
FROM #Dates_Temp
*/

ALTER TABLE #Dates_Temp
ADD Application REAL DEFAULT 0 WITH VALUES;


/* Checking
SELECT * 
FROM #Dates_Temp
*/

-- FINALLY!!, Creating a queries with all the date and the correct number of applications
SELECT temp.date, COUNT(org.[Date Applied]) AS Applications
FROM #Dates_Temp temp
LEFT JOIN MinhInternSearch org ON org.[Date Applied] = temp.date
GROUP BY temp.date, org.[Date Applied]
