select *
from Portfolioproject.dbo.CovidDeaths$
order by 3,4

select *
from Portfolioproject.dbo.CovidDeaths$
where continent is not NULL	
order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject.dbo.CovidDeaths$
order by 1,2

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject.dbo.CovidDeaths$
where Location like '%states%'
order by 1,2

select Location,date,total_cases,population,(total_cases/population)*100 as Percentofpopulationinfected
from Portfolioproject.dbo.CovidDeaths$
where Location like '%states%'
order by 1,2


--Countries with highest infection rate compared to population
select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as Percentofpopulationinfected
from Portfolioproject.dbo.CovidDeaths$
--where Location like '%states%'
Group by Location,population
order by Percentofpopulationinfected desc

--showing countries with highest death count per population
select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from Portfolioproject.dbo.CovidDeaths$
--where Location like '%states%'
where continent is not NULL
Group by Location
order by TotalDeathCount desc

--showing continents with highest death count
select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from Portfolioproject.dbo.CovidDeaths$
--where Location like '%states%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Portfolioproject.dbo.CovidDeaths$
--where Location like '%states%'
where continent is not NULL
group by date
order by 1,2


select *
from Portfolioproject.dbo.CovidDeaths$ dea
join Portfolioproject.dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

--Total populations vs new vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolioproject.dbo.CovidDeaths$ dea
join Portfolioproject.dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated