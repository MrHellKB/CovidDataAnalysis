
SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccinations

--Total Cases Vs Total Deaths And Percentages

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS "Percentages"
FROM CovidDeaths
ORDER BY 1, 4

--Total Population Vs Total Cases And Percentages

SELECT location, date, total_cases, population, (total_cases/population)*100 AS "Percentages"
FROM CovidDeaths
WHERE location='Faeroe Islands'
ORDER BY 1, 3

--Countries' Rank Of Infection Rate High To Low

SELECT location,  MAX(total_cases) AS "Highest Cases", population,MAX((total_cases/population)*100) AS "Percentages"
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

--Countries' Rank Of Death Rate High To Low

SELECT location,  MAX(total_deaths) AS "Highest Deaths", population,MAX((total_deaths/population)*100) AS "Percentages"
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

--Countries With Highest Death Count

SELECT location,  MAX(CAST(total_deaths AS INT)) AS "Highest Deaths"
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Death Counts Around The World

SELECT location,  MAX(CAST(total_deaths AS INT)) AS "Highest Deaths"
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

--Break Down By Continent

SELECT continent,  MAX(CAST(total_deaths AS INT)) AS "Highest Deaths"
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Global Numbers Day By Day

SELECT date,  SUM(new_cases) AS DAY_BY_DAY_CASES, SUM(CAST(new_deaths AS INT)) AS DAY_BY_DAY_DEATHS, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS "Percentages"
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--SELECT   SUM(new_cases) AS DAY_BY_DAY_CASES, SUM(CAST(new_deaths AS INT)) AS DAY_BY_DAY_DEATHS, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS "Percentages"
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1

--Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationCounts
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

--Use CTE

WITH PopVsVac (Continent, location, date,population, new_vaccinations, VaccinationCounts)
AS 
	(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationCounts
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL )

SELECT *, (VaccinationCounts/population)*100 AS PercantageOfVaccination
FROM PopVsVac

--Use TempTable

DROP TABLE IF Exists #PercantageOfPopulationVaccinated

CREATE TABLE #PercantageOfPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
VaccinationCounts numeric
)

INSERT INTO #PercantageOfPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationCounts
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL 

SELECT *, (VaccinationCounts/population)*100 AS PercantageOfVaccination
FROM #PercantageOfPopulationVaccinated	

--Creating View To Store Data For Later Visualizations

CREATE VIEW PercantageOfPopulationVaccinated AS 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationCounts
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 


SELECT *
FROM PercantageOfPopulationVaccinated