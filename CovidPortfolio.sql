use [Portfolio Database]
--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Database]..CovidDeaths
Order By 1,2



/****** LOOKING BY COUNTRIES ******/

-- Looking at Total Cases vs Total Death
-- Shows the likelihood of dying if you get Covid in United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS  death_percentage
From [Portfolio Database]..CovidDeaths
Where Location like '%states%'
Order By 1,2


-- Looking at the Total Cases vs Population
-- Shows the percentage of population got Covid (infection rate)

Select Location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
From [Portfolio Database]..CovidDeaths
Where Location like '%states%'
Order BY 1,2

-- Looking at countries with the highest infection rate

Select Location, MAX(total_cases) as highest_case , population, MAX((total_cases/population)*100) AS highest_infection_rate
From [Portfolio Database]..CovidDeaths
Group By Location, Population
Order By 4 desc


-- Looking at countries with highest death count 
Select Location, MAX(cast(total_deaths as int)) AS highest_death_count
From [Portfolio Database]..CovidDeaths
Where continent is not null
Group By Location
Order By 2 desc



/***** LOOKING BY CONTINENTS ****/
-- Looking at highest death count by continent

Select continent, MAX(cast(total_deaths as int)) AS highest_death_count
From [Portfolio Database]..CovidDeaths
Where continent is not null
Group By continent
Order By 2 desc


-- Showing continent with the hihest death count per population
Select continent, MAX(cast(total_deaths as int)*100/population) AS highest_death_count_per_pop
From [Portfolio Database]..CovidDeaths
Where continent is not null
Group By continent
Order By 2 desc



/**** GLOBAL NUMBERS ****/

-- Looking at global cases, global deaths and global death percentage

Select date, SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as global_death_percentage
From [Portfolio Database]..CovidDeaths
Where continent is not null 
Group By date
Order By 1,2



Select SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as global_death_percentage
From [Portfolio Database]..CovidDeaths
Where continent is not null 
--Group By date
Order By 1,2



/**** Joining Covid Vaccination ****/

Select * 
From [Portfolio Database]..CovidDeaths death
JOIN [Portfolio Database]..CovidVaccinations vacc
	On death.Location = vacc.Location
	and death.date = vacc.date

-- Looking at Total Population vs Vaccinations
-- Creating a counter for vaccinations

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order By death.location, 
death.date) AS vaccination_count 
 -- Starting over when it reaches a new location
From [Portfolio Database]..CovidDeaths death
JOIN [Portfolio Database]..CovidVaccinations vacc
	On death.Location = vacc.Location
	and death.date = vacc.date
Where death.continent is not null
Order By 2, 3



-- Temp Table

Drop Table if exists #VaccinatedPercentage
Create Table #VaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccination numeric,
vaccination_count numeric,)

Insert Into #VaccinatedPercentage
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order By death.location, 
death.date) AS vaccination_count  -- Starting over when it reaches a new location
From [Portfolio Database]..CovidDeaths death
JOIN [Portfolio Database]..CovidVaccinations vacc
	On death.Location = vacc.Location
	and death.date = vacc.date
Order By 2, 3

Select *, (vaccination_count/Population)/100
From #VaccinatedPercentage



-- Creating View to store data for later data viz

Create View VaccinatedPercentage as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order By death.location, 
death.date) AS vaccination_count  -- Starting over when it reaches a new location
From [Portfolio Database]..CovidDeaths death
JOIN [Portfolio Database]..CovidVaccinations vacc
	On death.Location = vacc.Location
	and death.date = vacc.date
Where death.continent  is not null
