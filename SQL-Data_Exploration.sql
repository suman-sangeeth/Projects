Select *
from portfolio_project..Covid_Deaths;

use portfolio_project;

Select Location,continent, date, total_cases, new_cases, total_deaths, population
From Covid_Deaths
Where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death by location and date
SELECT location,
       date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 as death_percentage
From Covid_Deaths
where location like '%India%'
Order By 1,2;

-- Looking at Total Cases vs Population
SELECT  location,
		date,
		total_cases,
		population,
		(total_cases/population)*100 as population_infected_percent
FROM Covid_deaths
Where location like '%India%'
Order by 1,2;


-- Looking at countries with highest infection rate compared to population
SELECT  location,
		population,
		max(total_cases) as highest_infection_count,
		max((total_cases/population))*100 as population_infected_percent
From covid_deaths
Group by location,population
Order by population_infected_percent desc;

-- Showing countries with highest death counts

SELECT location,
	   max(cast(total_deaths as int)) as death_count
from covid_deaths
where continent is not null
group by location
order by death_count desc;

-- CONTINENT-WISE BREAKDOWN

/* with cte1 as
(
SELECT continent,
	   location,
	   max(cast(total_deaths as int)) as death_count
	   --sum(max(cast(total_deaths as int))) over (partition by continent) as continent_deaths
from covid_deaths
where continent is not null 
group by continent,location
having  max(cast(total_deaths as int)) is not null
--order by continent, death_count desc
)

select  continent,
		sum(death_count) over (partition by continent) as continent_deaths
from cte1 
group by continent
order by continent_deaths desc;
*/

select 
	location, 
	SUM(cast(new_deaths as int)) as TotalDeathCount
from Covid_Deaths
where continent is null 
	and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;


-- GLOBAL NUMBERS, to find global death percentage overall

select  SUM(new_cases) as total_cases, 
		SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from covid_deaths  
where continent is not null 
order by 1,2

-- looking at total population vs total vaccinations
-- shows population vaccinated at least once

SELECT 
	cd.continent, 
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
from covid_deaths cd 
		join covid_vaccinations cv 
			on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3;


-- doing the above population vaccinated calculation with cte, to find percent of people vaccinated at least once

With vacpop (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
	cd.continent, 
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
from covid_deaths cd 
		join covid_vaccinations cv 
			on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From vacpop;

-- using temporary tables for the above

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select	cd.continent, 
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated

from covid_deaths cd 
		join covid_vaccinations cv 
			on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select	cd.continent, 
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated

from covid_deaths cd 
		join covid_vaccinations cv 
			on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

SELECT *
FROM PercentPopulationVaccinated;
