
-- select data that we are going to be using
select Location, date, total_cases, new_cases,total_deaths, population
From portfolioProject..deaths
order by 1,2
-- changing variable types to perform calculations

Alter table portfolioProject..deaths alter column total_cases float
alter table portfolioProject..deaths alter column total_deaths float

-- Looking at total cases vs total deaths in tunisia 
select Location,date,total_cases,total_deaths, (total_deaths / total_cases)*100 as percentage_of_deaths
from portfolioProject..deaths
where location like '%tunisia%'
order by 1,2 DESC

-- looking at total cases vs population 
select Location,date,total_cases, population,(total_cases / population)*100 as percentage_of_population_infected
from portfolioProject..deaths
where location like '%tunisia%'
order by 1,2 DESC

-- Looking at ccountries to highest infection rates compared to population infected 
select Location,population, MAX (total_cases) as highest_infection_count, MAX ((total_cases / population)*100) as percentage_of_population_infected
from portfolioProject..deaths
where continent is not null 
Group by population,location
order by 4 DESC
-- highest death count by population and added in not null to get rid of continents showing in location column
select Location, MAX(total_deaths) as totaldeathcount
from portfolioProject..deaths
where continent is not null 
Group by location
order by totaldeathcount DESC
-- Let's see the total death count by continent 
select continent, MAX(total_deaths) as totaldeathcount
from portfolioProject..deaths
where continent is not null 
Group by continent
order by totaldeathcount DESC

-- showing the continents with highest death counnt per population
select continent, MAX(total_deaths) as totaldeathcount
from portfolioProject..deaths
where continent is not null 
Group by continent
order by totaldeathcount DESC

-- looking at total population vs new vaccinations in tunisia
Select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations
From portfolioProject..deaths dea
join portfolioProject..vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location = 'Tunisia'
ORDER BY 2  ,3 desc
-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated, --(rollingpeoplevaccinated/population)*100
From portfolioProject..deaths dea
join portfolioProject..vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2 ,3 

--USING A CTE to create a rolling percentage of vaccinted people
with popVsvac (Continent, location, date, population,rollingpeoplevaccinated, new_vaccinations)
as 
(Select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --(rollingpeoplevaccinated/population)*100
From portfolioProject..deaths dea
join portfolioProject..vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location = 'tunisia'
--ORDER BY 2 ,3 
)
select*, (cast(rollingpeoplevaccinated as float)/population)*100 as rollingpercentageofvac
from popVsvac


-- creating a view
Create View percentPopulationVaccinated2 as 
Select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --(rollingpeoplevaccinated/population)*100
From portfolioProject..deaths dea
join portfolioProject..vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
