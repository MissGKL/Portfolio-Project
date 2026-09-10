
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Looking at Total Cases Vs Total Deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Looking at Total Cases Vs Total Deaths in South Africa
-- Shows likelihood of dying if you contract covid in SA

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%South Africa%'
Order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid 

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%South Africa%'
Order by 1,2

-- Looking at Coutries with Highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location, population
Order by PopulationInfectedPercentage desc

-- Looking at Countries with the Highest Death Count per Popoulation

Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location, population
Order by TotalDeathCount desc

-- ANALYSIS BY CONTINENT

-- Looking at Continents with the Highest Death Count per Popoulation

Select Continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

-- More accurate 

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is null
Group by Location
Order by TotalDeathCount desc

--GLOBAL NUMBERS

-- Looking at Total Cases Vs Total Deaths

Select date, SUM(new_cases) as Total_cases, SUM(CAST (new_deaths as int)) as Total_deaths, SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Looking at global deaths overall 

Select SUM(new_cases) as Total_cases, SUM(CAST (new_deaths as int)) as Total_deaths, SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null

-- Looking at Total population VS Total vaccinations
-- Showing how many people in the world were vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USING CTE
With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac

-- USING TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations nvarchar(255),
total_vaccinations numeric);

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated