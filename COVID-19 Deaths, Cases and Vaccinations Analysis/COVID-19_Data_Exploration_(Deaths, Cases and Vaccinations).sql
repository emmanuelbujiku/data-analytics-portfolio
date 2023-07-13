/*
COVID-19 Data Exploration (Deaths and Vaccinations)

Skills applied: Aggregate Functions, Windows Functions, Table Joins, CTE's, Temp Tables, Creating Views, Data Types Conversions

*/

-- Taking a look at the whole dataset
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Selecting Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Total Cases Vs Total Deaths
-- Likelihood of dying if you contract covid in your country (Tanzania)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Tanzania%'
ORDER BY 1, 2


-- Total Cases Vs Population
-- Shows what percentage of population infected by covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Tanzania%'
ORDER BY 1, 2


-- Looking at Countries with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC


-- Showing Locations with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- Showing Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC


--- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Total Population Vs Vaccinations
SELECT CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidV.new_vaccinations, 
SUM(CAST(CovidV.new_vaccinations AS INT)) OVER (PARTITION BY CovidD.location ORDER BY CovidD.location, CovidD.date) AS RollingPeopleVaccinated
FROM
PortfolioProject..CovidDeaths CovidD
JOIN PortfolioProject..CovidVaccinations CovidV
	ON CovidD.location = CovidV.location
	AND CovidD.date = CovidV.date
WHERE CovidD.continent IS NOT NULL
ORDER BY 2, 3


-- CTE to calculate percentage of RollingPeopleVaccinated
WITH PopulationVersusVaccinations (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidV.new_vaccinations, 
SUM(CAST(CovidV.new_vaccinations AS INT)) OVER (PARTITION BY CovidD.location ORDER BY CovidD.location, CovidD.date) AS RollingPeopleVaccinated
FROM
PortfolioProject..CovidDeaths CovidD
JOIN PortfolioProject..CovidVaccinations CovidV
	ON CovidD.location = CovidV.location
	AND CovidD.date = CovidV.date
WHERE CovidD.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulationVersusVaccinations


-- Alternative: Temp Table to calculate percentage of RollingPeopleVaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidV.new_vaccinations, 
SUM(CAST(CovidV.new_vaccinations AS INT)) OVER (PARTITION BY CovidD.location ORDER BY CovidD.location, CovidD.date) AS RollingPeopleVaccinated
FROM
PortfolioProject..CovidDeaths CovidD
JOIN PortfolioProject..CovidVaccinations CovidV
	ON CovidD.location = CovidV.location
	AND CovidD.date = CovidV.date
WHERE CovidD.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating Views to store data for later visualization
GO
CREATE VIEW 
PercentPopulationVaccinated AS
SELECT CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidV.new_vaccinations, 
SUM(CAST(CovidV.new_vaccinations AS INT)) OVER (PARTITION BY CovidD.location ORDER BY CovidD.location, CovidD.date) AS RollingPeopleVaccinated
FROM
PortfolioProject..CovidDeaths CovidD
JOIN PortfolioProject..CovidVaccinations CovidV
	ON CovidD.location = CovidV.location
	AND CovidD.date = CovidV.date
WHERE CovidD.continent IS NOT NULL

GO
SELECT *
FROM PercentPopulationVaccinated


