
global pathout "C:/Users/Tim/Documents/FEWSNET/dataout"
import delimited "$pathout\2016_11_fews_makets_gps.csv", clear
 
keep if inlist(country, "Rwanda", "Mozambique")
replace lon = "" if lon == "NA"
replace lat = "" if lat == "NA"
destring lon, replace
destring lat, replace

* Fill in missing lat/lon for Rwanda/Moz markets
* Chokwe, MZB
replace lon = 32.983330 if market_id == 505
replace lat = -24.533330 if market_id == 505

* Rutsiro, RWA (could not find market location)
replace lat = -1.962426 if market_id == 756
replace lon = 29.387457 if market_id == 756

* Kirehe, RWA (assuming market on map is market)
replace lat = -2.265683 if market_id == 633
replace lon = 30.647736  if market_id == 633

* Save a cut to be merged in w/ Stata files
saveold "$pathout/rwa_mzb_markets_gps.dta", replace
