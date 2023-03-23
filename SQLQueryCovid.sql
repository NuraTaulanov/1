select * 
from portfolioProject..CovidDeaths
where continent is not null
order by 3,4




-- выбираем данные, которые будем использовать
select location,date,total_cases, new_cases,total_deaths,population 
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2

--анализ общего числа случаев в сравнении с общим числом смертей
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject..CovidDeaths
where location like '%Kazakhstan%' and
 continent is not null
order by 1,2

--анализ общего числа случаев в сравнении с населением 
-- показывает процент населения, заболевшего covid
select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
from portfolioProject..CovidDeaths
where location like '%Kazakhstan%' and continent is not null
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2


--анализ стран с самым высоким уровнем инфицирования по сравнению с населением
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as CovidPercentage
from portfolioProject..CovidDeaths
where continent is not null
group by location,population 
order by CovidPercentage desc


--страны с самым высоким показателем смертности на душу населения
select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

--разбивание данных по континентам
-- континенты с самым высоким уровнем смертности на душу населения
select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is  not null
group by continent 
order by TotalDeathCount desc


--глобальные значения
select SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as total_Deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from portfolioProject..CovidDeaths
where continent is not null

order by 1,2

--анализ общей численности населения в сравнении с количеством вакцинированных 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVAccinated
--,(RollingPeopleVAccinated/population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--использование обобщенных табличных выражении  

with PopulationVSVaccination (Continent,location,date,population,new_vaccinations,RollingPeopleVAccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVAccinated
--,(RollingPeopleVAccinated/population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVAccinated/population)*100 
from PopulationVSVaccination



--таблица временных параметров
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime, 
population numeric,
New_vaccinations numeric,
RollingPeopleVAccinated numeric
)




insert into #percentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVAccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date



select *,(RollingPeopleVAccinated/population)*100 
from #percentPopulationVaccinated


--создание представления данных для последующей визуализации 
use portfolioProject
go

Create view PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVAccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null




select *
from PercentPopulationVaccinated

