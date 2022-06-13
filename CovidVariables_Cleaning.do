cd "C:\Users\vitor\OneDrive\Research_Resources\VaccineMandate_Research\Data"

* Reshaping and saving covid cases data
clear
insheet using "covid_confirmed_usafacts.csv"
save covid_county.dta, replace

clear
use covid_county.dta

drop if countyfips == 0
reshape long v, i(countyfips) j(year, string)

rename countyfips fips
destring year, replace force
sort fips year
rename v total_cases


save covid_county_long.dta, replace

* Reshaping and saving covid deaths data
clear
insheet using "covid_deaths_usafacts.csv"

drop if countyfips == 0
reshape long v, i(countyfips) j(year, string)

rename countyfips fips
destring year, replace force
sort fips year

rename v total_covid_deaths

save covid_deaths_county.dta, replace

* Save population datasets
clear 
insheet using "covid_county_population_usafacts.csv"


drop if countyFIPS == 0

rename countyFIPS fips

save covid_county_population

* Merge both datasets on county covid and population

clear
use covid_deaths_county.dta


merge 1:1 fips year using covid_county_long.dta
drop _merge

merge m:m fips using covid_county_population.dta, force
drop if _merge==2
drop _merge

* Generating total covid vars per 1000 residents
gen county_cases_pcp = total_cases/population*1000
gen county_coviddeaths_pcp = total_covid_deaths/population*1000

save combined_countycovid, replace

clear
use combined_countycovid.dta
* Cleaning data variable and creating daily and weekly cases variables

gen weeks_cases = total_cases - total_cases[_n-7] if fips == fips[_n-7]
gen weeks_covid_deaths = total_covid_deaths - total_covid_deaths[_n-7] if fips == fips[_n-7]

gen daily_cases = total_cases - total_cases[_n-1] if fips == fips[_n-1]
gen daily_covid_deaths = total_covid_deaths - total_covid_deaths[_n-1] if fips == fips[_n-1]

* Creating daily and weekly cases variables per 1000 residents

gen weeks_cases_pcp = weeks_cases/population*1000
gen weeks_covid_deaths_pcp = weeks_covid_deaths/population*1000

gen daily_cases_pcp = daily_cases/population*1000
gen daily_covid_deaths_pcp = daily_covid_deaths/population*1000

rename year date2
gen date = date2 + 21931
drop date2

save Covid_Deaths_Cases, replace


* -----------------------------------------------------------------------------
* Cleaning Covid Vaccination rates
clear
insheet using "COVID19_Vaccinations.csv"
save COVID19_Vaccinations.dta, replace

clear 
use COVID19_Vaccinations.dta

* Cleaning date variable 
gen mo = substr(date,1,2)
gen day = substr(date,4,2)
gen year = substr(date,9,2)
destring mo, replace
destring day, replace
destring year, replace
replace year = year+2000


gen date2 = mdy(mo, day, year)

rename date date_string
rename date2 date

order date

save Covid_Vaccinations, replace









