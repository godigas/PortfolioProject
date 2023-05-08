select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PortfolioProject..Covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'portugal'
order by 1, 2
  

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like 'portugal'
order by 1, 2
  
-- Looking at Countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like 'portugal'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent IS NOT NULL
--group by date
order by 1, 2


-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedOverTime
, (PeopleVaccinatedOverTime/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3	

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinatedOverTime)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedOverTime
--, (PeopleVaccinatedOverTime/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3	
)
Select*, (PeopleVaccinatedOverTime/population)*100
from PopvsVac
order by 2,3

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedOverTime numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedOverTime
--, (PeopleVaccinatedOverTime/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent IS NOT NULL
--order by 2,3	
Select*, (PeopleVaccinatedOverTime/population)*100
from #PercentPopulationVaccinated
where continent IS NOT NULL
order by 2,3	



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedOverTime
--, (PeopleVaccinatedOverTime/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3

select*
from PercentPopulationVaccinated