Select *
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not NULL
ORDER BY 3,4

Select *
FROM PortfolioProject..covidvaccinations
WHERE continent is not NULL
ORDER BY 3,4
--Select data we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not NULL
ORDER BY 1,2

-- convert from nvarchar to float for division
SELECT *
FROM PortfolioProject..coviddeaths

EXEC sp_help 'PortfolioProject..coviddeaths'

ALTER TABLE PortfolioProject..coviddeaths
ALTER COLUMN total_deaths float

--looking at total cases against total deaths
-- percent chance of death after contracting covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.coviddeaths
WHERE location = 'Kenya'
ORDER BY 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 AS infectedPercentage
FROM PortfolioProject.dbo.coviddeaths
WHERE location = 'Kenya'
ORDER BY 1,2

--convert population into bigint
EXEC sp_help 'PortfolioProject..coviddeaths'

ALTER TABLE PortfolioProject..coviddeaths
ALTER COLUMN population bigint

--Highest infection rate per capita
Select location, population, MAX(total_cases) AS totalinfectioncount, MAX((total_cases/population)*100) AS infectedPercentage
FROM PortfolioProject.dbo.coviddeaths
GROUP BY population, location
ORDER BY infectedPercentage DESC

--Analysis of death by continent
Select location, MAX(total_deaths) AS totaldeathcount, MAX((total_deaths/population)*100) AS deathrate
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is  NULL
GROUP BY location
ORDER BY totaldeathcount DESC

-- Highest death rate per capita
Select location, population, MAX(total_deaths) AS totaldeathcount, MAX((total_deaths/population)*100) AS deathrate
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not NULL
GROUP BY population, location
ORDER BY totaldeathcount DESC

-- convert from new_cases nvarchar to float for division
SELECT *
FROM PortfolioProject..coviddeaths

EXEC sp_help 'PortfolioProject..coviddeaths'

ALTER TABLE PortfolioProject..coviddeaths
ALTER COLUMN new_cases float

--Global Numbers per day
Select date, SUM(new_cases) AS newcases, SUM(new_deaths) AS newdeaths
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not NULL
GROUP BY date 
ORDER BY 1

--Global numbers as total cases, deaths and death percentage
Select date, SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, (SUM(new_deaths) / nullif(SUM(new_cases),0))*100 AS DeathPercentage
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

with Popvsvac (continent, Location, date, population,new_vaccinations, Cumulativevaccinesgiven)
AS
(
--Total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS Cumulativevaccinesgiven
--Cumulative vaccines given
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)

Select *, (CONVERT(float,Cumulativevaccinesgiven))/(convert(float,population))*100 AS vaccinetopopulationpercet
FROM Popvsvac

DROP Table if exists #percentvaccinesperperson
CREATE TABLE #percentvaccinesperperson
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
cumulativevaccinesgiven numeric
)
--TEMP TABLE
Insert into #percentvaccinesperperson
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS Cumulativevaccinesgiven
--Cumulative vaccines given
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

Select *, (CONVERT(float,Cumulativevaccinesgiven))/(convert(float,population))*100 AS vaccinetopopulationpercet
FROM #percentvaccinesperperson

--creating view for data for visualisations

Create view percentvaccinesperperson as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS Cumulativevaccinesgiven
--Cumulative vaccines given
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

select *
FROM percentvaccinesperperson