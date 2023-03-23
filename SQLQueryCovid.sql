select * 
from portfolioProject..CovidDeaths
where continent is not null
order by 3,4




-- �������� ������, ������� ����� ������������
select location,date,total_cases, new_cases,total_deaths,population 
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2

--������ ������ ����� ������� � ��������� � ����� ������ �������
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject..CovidDeaths
where location like '%Kazakhstan%' and
 continent is not null
order by 1,2

--������ ������ ����� ������� � ��������� � ���������� 
-- ���������� ������� ���������, ����������� covid
select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
from portfolioProject..CovidDeaths
where location like '%Kazakhstan%' and continent is not null
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2


--������ ����� � ����� ������� ������� ������������� �� ��������� � ����������
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as CovidPercentage
from portfolioProject..CovidDeaths
where continent is not null
group by location,population 
order by CovidPercentage desc


--������ � ����� ������� ����������� ���������� �� ���� ���������
select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

--���������� ������ �� �����������
-- ���������� � ����� ������� ������� ���������� �� ���� ���������
select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is  not null
group by continent 
order by TotalDeathCount desc


--���������� ��������
select SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as total_Deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from portfolioProject..CovidDeaths
where continent is not null

order by 1,2

--������ ����� ����������� ��������� � ��������� � ����������� ��������������� 
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


--������������� ���������� ��������� ���������  

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



--������� ��������� ����������
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


--�������� ������������� ������ ��� ����������� ������������ 
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

