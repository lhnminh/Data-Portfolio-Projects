/*
Minh Le 
Queries used for Tableau Project
*/

Use [Portfolio Database]


-- 1. Global Statistics

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Database]..CovidDeaths
where continent is not null 
order by 1,2



-- 2. Total Death Count by continent 

-- Note: Have to exclude some "continent" such as Upper middle income, European Union

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Database]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High Income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3. Highest infection rate by country

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Database]..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Infection rate by country throughtime 


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Database]..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc