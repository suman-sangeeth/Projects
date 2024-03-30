/*

Queries used for Tableau Project

*/

use portfolio_project;

-- 1. overall info on cases deaths and death percentage -- overall world

select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from Covid_Deaths
where continent is not null 
order by 1,2


-- 2.  total deaths by continent
-- European Union has been accounted for under EU


select 
	location, 
	SUM(cast(new_deaths as int)) as TotalDeathCount
from Covid_Deaths
where continent is null 
	and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

-- 3.

select  Location, 
		Population, 
		MAX(total_cases) as HighestInfectionCount,  
		Max((total_cases/population))*100 as PercentPopulationInfected
from Covid_Deaths
group by Location, Population
order by PercentPopulationInfected desc

-- 4.percent infected in each country, by date


select 
	Location, 
	Population,
	date, 
	max(total_cases) as HighestInfectionCount,  
	max((total_cases/population))*100 as PercentPopulationInfected
from Covid_Deaths

Group by Location, Population, date
order by PercentPopulationInfected desc