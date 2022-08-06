
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- looking at Total Cases vs Total Deaths
-- Shows likleihood of dying if you contract covid in you contry
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Egypt' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid 

SELECT location, date,population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Egypt' AND  continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location = 'Egypt'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- Showing Countries with Highest Death count per Popultation

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'Egypt'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'Egypt'
WHERE continent IS  NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS 

SELECT sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'Egypt' 
WHERE continent IS NOT NULL
--Group by date
ORDER BY 1,2


-- Looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeoplenVaccinated
, --(RollingPeoplenVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3


-- USE CTE

WITH PopvsVac (Continenct,location,date,population,new_vaccinations,RollingPeoplenVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeoplenVaccinated
 --(RollingPeoplenVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

)

Select *, (RollingPeoplenVaccinated/population)*100
from PopvsVac



-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continenct nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplenVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeoplenVaccinated
 --(RollingPeoplenVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--order by 2,3

Select *, (RollingPeoplenVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store date for later visualizations

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeoplenVaccinated
 --(RollingPeoplenVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

select *
from PercentPopulationVaccinated