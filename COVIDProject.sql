SELECT*
FROM CovidProject..CovidDeaths
WHERE location like 'Canada'
ORDER BY 3,4

--SELECT*
--FROM CovidProject..CovidVaccination
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2

--likelihood
SELECT location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/cast(total_cases as float)*100) AS 'Death_Percantage'
FROM CovidProject..CovidDeaths
WHERE location like '%Indonesia%' 
ORDER BY 1,2

SELECT location, date, Population, total_cases, 
(cast(total_cases as float)/cast(population as float)*100) AS 'Percentage_Got_Covid'
FROM CovidProject..CovidDeaths
WHERE location like '%Indonesia%' 
ORDER BY 1,2

SELECT location, Population, MAX(cast(total_cases AS int)) AS 'Highest_Infection', 
MAX(cast(total_cases as float)/cast(population as float)*100) AS 'Highest_Percentage_Covid'
FROM CovidProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Indonesia%'
GROUP BY location, Population 
ORDER BY 'Highest_Infection' desc

SELECT location, Population, MAX(cast(total_cases AS int)) AS 'Highest_Infection', 
MAX(cast(total_cases as float)/cast(population as float)*100) AS 'Highest_Percentage_Covid'
FROM CovidProject..CovidDeaths
--WHERE location like '%Indonesia%' 
GROUP BY location, Population
ORDER BY 'Highest_Percentage_Covid' desc

SELECT location, MAX(cast(total_deaths AS int)) AS 'Total_Death_Count'
FROM CovidProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Indonesia%'
GROUP BY location, Population 
ORDER BY 'Total_Death_Count' desc

SELECT continent, MAX(cast(total_deaths AS int)) AS 'Total_Death_Count'
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
--WHERE location like '%Indonesia%'
GROUP BY continent
ORDER BY 'Total_Death_Count' desc

SELECT date, max(cast(total_cases AS int)) AS 'TotalCases' --total_deaths, (cast(total_deaths as float)/cast(total_cases as float)*100) AS 'Death_Percantage'
FROM CovidProject..CovidDeaths 
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 'TotalCases' DESC

SELECT SUM(new_cases) as 'Total_Cases', SUM(CAST(new_deaths AS int)) as 'Total_Deaths', 
SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 AS 'Death_Percentage'
FROM CovidProject..CovidDeaths 
WHERE continent is NOT NULL AND new_cases != 0 AND new_deaths != 0
ORDER BY 'Death_Percentage' DESC

SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations,
SUM(CAST(new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.date) AS 'Total_Day_by_Day_People_Vaccinated'
FROM CovidProject..CovidVaccination AS Vacc
JOIN CovidProject..CovidDeaths AS Death
	ON Vacc.location = Death.location AND
	Vacc.date = Death.date
WHERE death.continent is NOT NULL
ORDER BY 2,3

WITH PopVacc (continent,location,date,population, new_vaccinations,Total_Day_by_Day_People_Vaccinated) 
AS
(
SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations,
SUM(CAST(new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.date) AS 'Total_Day_by_Day_People_Vaccinated'
FROM CovidProject..CovidVaccination AS Vacc
JOIN CovidProject..CovidDeaths AS Death
	ON Vacc.location = Death.location AND
	Vacc.date = Death.date
WHERE death.continent is NOT NULL
)
SELECT *, (Total_Day_by_Day_People_Vaccinated/Population)*100
FROM PopVacc

DROP TABLE IF EXISTS #PercentagePopVacc
CREATE TABLE #PercentagePopVacc
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacc numeric,
Total_DBD_PeopVacc Numeric
)
INSERT INTO #PercentagePopVacc
SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations,
SUM(CAST(new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.date) AS 'Total_Day_by_Day_People_Vaccinated'
FROM CovidProject..CovidVaccination AS Vacc
JOIN CovidProject..CovidDeaths AS Death
	ON Vacc.location = Death.location AND
	Vacc.date = Death.date
--WHERE death.continent is NOT NULL
SELECT *, (Total_DBD_PeopVacc/Population)*100 AS Percentage
FROM #PercentagePopVacc
WHERE New_Vacc is NOT NULL
ORDER BY 'Percentage' DESC	

CREATE VIEW PercentPopVacc AS 
SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations,
SUM(CAST(new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.date) AS 'Total_Day_by_Day_People_Vaccinated'
FROM CovidProject..CovidVaccination AS Vacc
JOIN CovidProject..CovidDeaths AS Death
	ON Vacc.location = Death.location AND
	Vacc.date = Death.date
	WHERE death.continent is NOT NULL

SELECT *
FROM PercentPopVacc

