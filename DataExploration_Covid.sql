
-- Death percentage- cases vs deaths - India
select location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths 
where location like '%india%'
order by 1,2


--Cases vs population - India
select location , date, total_cases, population, (total_cases/population)*100 as Cases_percentage
from PortfolioProject..CovidDeaths 
where location like '%india%'
order by 1,2

--High infection rate compared to population
select location , population, max(total_cases) as Highest_Cases_Count, max((total_cases/population)*100) as Infected_Population
from PortfolioProject..CovidDeaths 
group by location, population
order by Infected_Population desc

--Countries with high death count per population
select location, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc

--Continent with high death count per population
select continent, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc

--Highest single day cases
select location, max(cast(new_cases as int)) as Highest_SingleDay_Cases
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Highest_SingleDay_Cases desc

--Globally
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Joining Deaths table and Vaccination table - India
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%india%'
order by 2,3


--Total population vs Vaccination - Worldwide
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where 
dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3



--Total population vs Vaccination - India
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where 
dea.location like '%india%' 
and dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3


--Percentage of people per population who got vaccinated in India
with pop_percent (Country, Date, Population, Vaccination_per_day, Total_Vaccinated)
as
(
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where 
dea.location like '%india%' 
and dea.continent is not null
and vac.new_vaccinations is not null
)
select *, (Total_Vaccinated/population)*100 as Vaccinated_percentage 
from pop_percent




--Temp table

drop table if exists #vaccinatedpopulation
create table #vaccinatedpopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_Vaccinated numeric
)

insert into #vaccinatedpopulation
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%india%' 
and dea.continent is not null
and vac.new_vaccinations is not null

select *, (Total_Vaccinated/population)*100 as Vaccinated_Percentage
from #vaccinatedpopulation


--Creating View
create view #vaccinated_population_india as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%india%' 
and dea.continent is not null
and vac.new_vaccinations is not null


--Select query for view
select * from vaccinated_population_india