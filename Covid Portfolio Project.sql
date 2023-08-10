-- Selecting on condition from dataset

SELECT *
FROM roktim.dbo.Covid_Death
ORDER BY
  3,
  4

-- Select Data we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
from roktim.dbo.Covid_Death
order by 1, 2

-- Looking at Total Cases vs Total Deaths in Bangladesh

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from roktim.dbo.Covid_Death
where Location = 'Bangladesh'
order by 1, 2

-- Looking at total cases vs Population
-- Show what percentage of population got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulation
from `covid_data.covid_death`
where Location = 'Bangladesh'
order by 1, 2

-- Looking at countries with highest infection rate

SELECT Location, max(total_cases), population, max((total_cases/population))*100 as CasesPerPopulation
from roktim.dbo.Covid_Death
--where Location = 'Bangladesh'
Group by Location, population
order by CasesPerPopulation DESC

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From roktim.dbo.Covid_Death
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From roktim.dbo.Covid_Death
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From roktim.dbo.Covid_Death
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking aty Total Population vs vaccination

SELECT *
FROM roktim..Covid_Vaccination

SELECT dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations
from roktim.dbo.Covid_Death dea
join roktim..Covid_Vaccination vac
on dea.location = vac.location
and dea.date = vac. date
where dea.continent is not null
and new_vaccinations > 0
ORDER BY 2,3

-- Rolling People Vaccinated & Vaccination Percentage

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From roktim.dbo.Covid_Death dea
Join roktim..Covid_Vaccination vac
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
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From roktim.dbo.Covid_Death dea
Join roktim..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store Data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From roktim.dbo.Covid_Death dea
Join roktim..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

-- Selecting on condition from temp table	
Select *
from PercentPopulatonVaccinated
where dea. continent is distinct

