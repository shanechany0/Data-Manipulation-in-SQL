-- Select all data from the two tables
select *
from covid_deaths_csv cdc;

select *
from covid_vaccinations_csv cvc;

-- Select some columns from cdc order by location and date
select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths_csv cdc
where continent != ''
order by 1,2;

-- Cases Vs Death in %
select location, date, total_cases, total_deaths, round((total_deaths*1.0 / total_cases)*100, 3) as deathpct
from covid_deaths_csv cdc
where continent != ''
order by 1,2;

-- Cases Vs Population in %
select location, date, total_cases, population, round((total_cases*1.0 / population)*100, 3) as populationpct
from covid_deaths_csv cdc
where continent != ''
order by 1,2;

-- Locations order by highest infection rate
select location, max(total_cases), population, round((max(total_cases)*1.0 / population)*100, 3) as infectionrate
from covid_deaths_csv cdc
where continent != ''
group by location, population
order by infectionrate desc;

-- Locations order by highest death count
select location, max(total_deaths) as deathcount
from covid_deaths_csv cdc
where continent != ''
group by location
order by deathcount desc;

-- Continents order by highest death count
select continent, max(total_deaths) as deathcount
from covid_deaths_csv cdc
where continent != ''
group by continent
order by deathcount desc;

-- Global daily new cases and new deaths
select date, sum(new_cases*1.0) as Total_Cases, sum(new_deaths*1.0) as Total_Deaths, round((sum(new_deaths*1.0) / sum(new_cases))*100, 3) as deathpct
from covid_deaths_csv cdc
where continent != ''
group by date
order by 1;


-- Join the two tables
select *
from covid_deaths_csv cdc 
join covid_vaccinations_csv cvc 
	on cdc.location = cvc.location
	and cdc.date = cvc.date
	
-- Population Vs Vaccination
select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations
from covid_deaths_csv cdc 
join covid_vaccinations_csv cvc 
	on cdc.location = cvc.location
	and cdc.date = cvc.date
where cdc.continent != ''
order by 1,2,3

-- Population Vs Rolling Sum of Vaccination
select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations, 
sum(cast(cvc.new_vaccinations as integer)) over (partition by cdc.location order by cdc.date) as Vac_Rolling_sum
from covid_deaths_csv cdc 
join covid_vaccinations_csv cvc 
	on cdc.location = cvc.location
	and cdc.date = cvc.date
where cdc.continent != '' and cvc.new_vaccinations != ''
order by 1,2,3;

-- CTE
with vaccinated as
(
select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations, 
sum(cast(cvc.new_vaccinations as integer)) over (partition by cdc.location order by cdc.date) as rolling_vac_sum
from covid_deaths_csv cdc 
join covid_vaccinations_csv cvc 
	on cdc.location = cvc.location
	and cdc.date = cvc.date
where cdc.continent != '' and cvc.new_vaccinations != ''
order by 1,2,3
)
select *, round((rolling_vac_sum*1.0/population)*100, 3) as rolling_vac_pct
from vaccinated

--Create view
drop view if exists vaccinatedpopulation_pct;
create view vaccinatedpopulation_pct as
with vaccinated as
(
select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations, 
sum(cast(cvc.new_vaccinations as integer)) over (partition by cdc.location order by cdc.date) as rolling_vac_sum
from covid_deaths_csv cdc 
join covid_vaccinations_csv cvc 
	on cdc.location = cvc.location
	and cdc.date = cvc.date
where cdc.continent != '' and cvc.new_vaccinations != ''
order by 1,2,3
)
select *, round((rolling_vac_sum*1.0/population)*100, 3) as rolling_vac_pct
from vaccinated
