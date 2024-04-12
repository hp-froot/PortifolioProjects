/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Select that date that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortifolioCOVIDProject..CovidDeaths
Order by Location, date

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortifolioCOVIDProject..CovidDeaths
Where location like '%spain%'
and continent is not null
Order by Location, date

-- Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
From PortifolioCOVIDProject..CovidDeaths
Where location like '%spain%'
and continent is not null
Order by Location, date

-- Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Percent_Population_Infected
From PortifolioCOVIDProject..CovidDeaths
Where continent is not null
Group by location, population
Order by Percent_Population_Infected desc


-- Showing the Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortifolioCOVIDProject..CovidDeaths
Where continent is not null
Group by location
Order by Total_Death_Count desc

-- Breaking things down by Continent
-- Showing the continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortifolioCOVIDProject..CovidDeaths
Where continent is null
Group by location
Order by Total_Death_Count desc

-- Global numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage 
From PortifolioCOVIDProject..CovidDeaths
Where continent is not null
Group By date
Order by date

-- Joining two tables

Select *
From PortifolioCOVIDProject..CovidDeaths as dea
Join PortifolioCOVIDProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortifolioCOVIDProject..CovidDeaths as dea
Join PortifolioCOVIDProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by dea.location, dea.date

-- Total Population vs Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_of_People_Vaccinated
-- This give an error, below how to fix it (Rolling_Count_of_People_Vaccinated/dea.population)*100
From PortifolioCOVIDProject..CovidDeaths as dea
Join PortifolioCOVIDProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by dea.location, dea.date

-- Using CTE

With Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count_of_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_of_People_Vaccinated
From PortifolioCOVIDProject..CovidDeaths as dea
Join PortifolioCOVIDProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Rolling_Count_of_People_Vaccinated/Population)*100 as Total_Pop_vs_Vac
From Pop_vs_Vac

-- Using Temp Table

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Count_of_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_of_People_Vaccinated
From PortifolioCOVIDProject..CovidDeaths as dea
Join PortifolioCOVIDProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (Rolling_Count_of_People_Vaccinated/Population)*100 as Total_Pop_vs_Vac
From #Percent_Population_Vaccinated

-- Creating View to store data for later vizualization

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_of_People_Vaccinated
From PortifolioCOVIDProject..CovidDeaths as dea
Join PortifolioCOVIDProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From Percent_Population_Vaccinated
