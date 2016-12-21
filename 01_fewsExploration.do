* Data Exploration on FEWS Net data
* Date: 2016/11/30
* Purpose: Explore the FEWS Net price data for usability 
* License: MIT / copyright Tim Essam 2016

clear
capture log close
cd 
log using "fewsExplore.log", replace
import delimited C:\Users\Tim\Downloads\2016_11_fews.csv, clear
	
	tab country, mi
	tab product, mi
	mdesc
	
	
* Convert date strings to formatted dates
	g date = date(period_date, "MDY")
	format date %td
	
* Subset a cut of data for Mike
keep if regexm(country,("Angola|Botswana|Lesotho|Madagascar|Comoros|Malawi|/*
*/Mauritus|Seychelles|Mozambique|Namibia|South Africa|Swaziland|Zambia|Zimbabwe"))
	
export delimited using "C:\Users\Tim\Documents\FEWSNetPrices\FEWSnet_SouthernAfricaRegional.csv", replace
