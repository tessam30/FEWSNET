# import_CPI.R
# Import Consumer Price Index (CPI) data from the IMF: http://data.imf.org/
# Data downloaded 2017-05-22
# Laura Hughes, lhughse@usaid.gov, 23 May 2017, USAID | GeoCenter
# CPI for each country given at yearly, quarterly, and monthly level for each country

# Initially pulled the CPI data from the "bulk" download option
# However, the CPI, all items seemed to be based to inconsistent years between and within countries
# Therefore, using the "Data by Indictor, Consumer Price, Producer Price, and Labor" table
# http://data.imf.org/regular.aspx?key=60998125
# Pulled CPI data, originally from the IFS, all based to 2010 (100)


# import data -------------------------------------------------------------
library(dplyr)
library(readr)
library(readxl)
library(tidyr)
library(data.table)

base_dir = '~/Documents/USAID/FEWSNET/rawdata/'

# cpi_raw = read_csv(paste0(base_dir, 'CPI_IMF_05-22-2017.csv'))
cpi_raw = read_excel(paste0(base_dir, 'CPI_IMF_IFS_05-23-2017.xlsx'), skip = 6, na = '...')
# delete leading column
cpi_raw[,1] = NULL


# clean up CPI index ------------------------------------------------------

cpi = cpi_raw %>% 
  select(-Scale) %>% 
  gather(time_period, cpi, -Country, -`Base Year`) %>% 
  rename(base_year = `Base Year`) %>% 
  filter(time_period %like% 'M') %>% # select just the monthly data
  separate(time_period, into = c('year', 'month'), sep = 'M') %>% 
  mutate(year = as.numeric(year),
         month = as.numeric(month),
         base_year = as.numeric(base_year))


# testing merging conditions ----------------------------------------------

fc = fews %>% select(country) %>% distinct() %>% mutate(fews = 'fews')

cc = cpi %>% select(country = Country) %>% distinct() %>% mutate(cpi = 'cpi')


# Straight merge: 
# Not bad: 52 merges, 11 not.
merged = left_join(fc, cc)

merged %>% count(is.na(cpi))

merged %>% filter(is.na(cpi))

# Fuzzy joins seem like a good idea... but in practice, they're not very good
# Good for single point mutations, but not for partial matches.  
# So Zambia and Naimbia are the same.  Niger = Nigeria, etc. and doesn't catch Congo = Democratic...
# View(stringdist_left_join(fc %>% filter(!is.na(Country)), cc %>% filter(!is.na(Country)), 
#                           # max_dist = 1,
#                           method = 'jaccard', distance_col = 'dist'))

# So... back to manual joining.


# converting country names to mergeable values -----------------------------
# NOTE: Tajikistan and Somalia don't have any CPI data.

cpi = cpi %>% 
  mutate(country = case_when(cpi$Country %like% 'Afghanistan, Is' ~ 'Afghanistan',
                             cpi$Country %like% 'Congo, Demo' ~ 'Congo, The Democratic Republic of the',
                             cpi$Country %like% 'Ivoire' ~ "Côte d'Ivoire",
                             cpi$Country %like% 'Gambia' ~ 'Gambia',
                             cpi$Country %like% 'Kyrg' ~ 'Kyrgyzstan',
                             # cpi$Country %like% 'Afghan' ~ 'Somalia',
                             # cpi$Country %like% 'Afghan' ~ 'Tajikistan',
                             cpi$Country %like% 'Tanzania' ~ 'Tanzania, United Republic of',
                             cpi$Country %like% 'Venezuela' ~ 'Venezuela, Bolivarian Republic of',
                             cpi$Country %like% 'Vietnam' ~ 'Viet Nam',
                             cpi$Country %like% 'Yemen' ~ 'Yemen',
                              TRUE ~ cpi$Country))



# testing merge.
fc = fews %>% select(country) %>% distinct() %>% mutate(fews = 'fews')

cc = cpi %>% select(country, Country) %>% distinct() %>% mutate(cpi = 'cpi')


merged = left_join(fc, cc)

merged %>% count(is.na(cpi))

cpi = cpi %>% 
  select(-Country)
