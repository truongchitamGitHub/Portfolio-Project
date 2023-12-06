

Select * 
From PortfoilioProject..CovidDeaths$
order by total_deaths desc

Select location,date, total_cases, new_cases, total_deaths, population
From PortfoilioProject..CovidDeaths$
order by 1,2 

-- looking at total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfoilioProject..CovidDeaths$
where location like '%Vietnam%'
order by 1,2

-- looking at total cases vs population

Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Got_covid_percentage
from PortfoilioProject..CovidDeaths$
where location like '%vietnam%'
order by 1,2

-- looking at countries with highest infection rate compare to population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100) AS Got_covid_percentage
from PortfoilioProject..CovidDeaths$
--where location like '%vietnam%'
Group by location,population
order by Got_covid_percentage desc

-- showing the country with the highest death count per population 

Select location, MAX(cast(total_deaths as int)) as total_death_count 
From PortfoilioProject..CovidDeaths$
--where location like '%vietnam%'
where continent is not null
Group by location
order by total_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as total_death_count 
From PortfoilioProject..CovidDeaths$
--where location like '%vietnam%'
where continent is not null
Group by continent
order by total_death_count desc

-- showing continent with the hightest death count per population

Select continent, MAX(cast(total_deaths as int)/population*100) as percent_death_per_population
From PortfoilioProject..CovidDeaths$
--where location like '%vietnam%'
where continent is not null
Group by continent
order by percent_death_per_population desc

-- Global Numbers

-- total deaths per cases per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases)*100,0) as death_percentage
From PortfoilioProject..CovidDeaths$
--where location like '%vietnam%'
where continent is not null
Group by date
order by 1,2

-- total deaths per cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases)*100,0) as death_percentage
From PortfoilioProject..CovidDeaths$
--where location like '%vietnam%'
where continent is not null
order by 1,2



-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfoilioProject..CovidDeaths$  dea
join PortfoilioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 5

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
-- SUM(cast(vac.new_vaccinations as int)) = CONVERT(int, vac.new_vaccinations)
from PortfoilioProject..CovidDeaths$  dea
join PortfoilioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
-- SUM(cast(vac.new_vaccinations as int)) = CONVERT(int, vac.new_vaccinations)
from PortfoilioProject..CovidDeaths$  dea
join PortfoilioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100
from pop_vs_vac

--Temp Table

Drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
-- SUM(cast(vac.new_vaccinations as int)) = CONVERT(int, vac.new_vaccinations)
from PortfoilioProject..CovidDeaths$  dea
join PortfoilioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
Select *, (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated

-- Creating view to store data for later visualizations

create view percent_population_vaccinated3 as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
-- SUM(cast(vac.new_vaccinations as int)) = CONVERT(int, vac.new_vaccinations)
from PortfoilioProject..CovidDeaths$  dea
join PortfoilioProject..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

select * 
from percent_population_vaccinated3