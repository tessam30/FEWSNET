# import_CPI.R
# Import Consumer Price Index (CPI) data from the IMF: http://data.imf.org/
# Data downloaded 2017-05-22
# CPI for each country given at yearly, quarterly, and monthly level for each country
# 10 separate CPI indicators; using XXX to normalize FEWS NET market data


# import data -------------------------------------------------------------
library(dplyr)
library(readr)
library(tidyr)
library(data.table)

base_dir = '~/Documents/USAID/FEWSNET/rawdata/'

cpi_raw = read_csv(paste0(base_dir, 'CPI_IMF_05-22-2017.csv'))



# clean up CPI index ------------------------------------------------------

cpi = cpi_raw %>% 
  filter(`Time Period` %like% 'M') %>% # select just the monthly data
  separate(`Time Period`, into = c('year', 'month'), sep = 'M') %>% 
  mutate(year = as.numeric(year),
         month = as.numeric(month))
