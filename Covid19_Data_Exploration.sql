-- COVID 19 DATA EXPLORATION 

-- Skills used : Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating views, Converting data types


-- COVID DEATHS

select *
from project..CovidDeaths 
where continent is not null
order by 3


-- COVID VACCINATIONS

Select *
from project..CovidVaccinations 
where continent is not null
order by 3


-- Select the required data

select location,date,total_cases,new_cases,total_deaths,population
from project..CovidDeaths 
where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying due to contaction of covid in a particular country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent 
from project..CovidDeaths 
where location like '%india%' and continent is not null 
order by 2


-- Total cases vs Population
-- Shows what percentage of population is infected with covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from project..CovidDeaths 
where location like '%india%' and continent is not null 
order by 2


-- Countries with the Highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
from project..CovidDeaths 
where continent is not null 
group by location,population
order by 4 desc


-- Countries with Highest Death Count per Population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc



-- STATS BY CONTINENTS 
-- Death Count by Continents

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths 
where continent is not null 
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
-- Total cases, total deaths, death percentage across the world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 
as death_percentage
from project..CovidDeaths 
where continent is not null 
order by 1,2


-- Total Population vs Total Vaccination 
-- Percentage of Population thas has recieved atleast one dose of Covid Vaccine

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Total_Vaccinations,
(Total_Vaccinations/dea.population)*100 as percent_vaccinated
from project..CovidDeaths dea
join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- AND dea.location like '%india%'
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
-- Creating a temporary table using the 'with' clause 
-- Total Population vs Total Vaccination 

With PopvsVac (continent,location,Date,population, new_vaccinations,Total_Vaccinations)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Total_Vaccinations
from project..CovidDeaths dea
join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- AND dea.location like '%india%'
-- order by 2,3
)
select *, (Total_Vaccinations/population)*100 as percent_vaccinated
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
-- Total Population vs Total Vaccination 

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Total_Vaccinations
from project..CovidDeaths dea
join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *, (Total_Vaccinations/population)*100 as percent_vaccinated
from #PercentPopulationVaccinated


-- Creating views for Visualizations 
-- Death Count by Continents

Create view DeathRate as
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths 
where continent is not null 
group by continent
--order by TotalDeathCount desc


-- Total Population vs Total Vaccination

create view PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Total_Vaccinations
from project..CovidDeaths dea
join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- AND dea.location like '%india%'
-- order by 2,3

select * 
from PercentPopulationVaccinated 
