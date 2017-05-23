
# Function to import and clean FEWS NET price data ------------------------

# Laura Hughes, lhughes@usaid.gov, with Tim Essam (tessam@usaid.gov) and Baboyma Kagninwa (bkagninwa@usaid.gov)
# Copyright 2016 Laura Hughes via MIT license


# setup -------------------------------------------------------------------
base_dir = '~/Documents/USAID/FEWSNET/rawdata/'
base_date = '2016_11'

# libraries ---------------------------------------------------------------

library(llamar)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)
library(readr)
library(ggplot2)
library(dtplyr)
library(data.table)
library(readxl)

# import raw data ---------------------------------------------------------
# Reading in using read.csv doesn't retain accent marks.
fews_raw = read_excel(paste0(base_dir, base_date, '_fews.xlsx'))

# explore data ------------------------------------------------------------
table(fews_raw$product)

qplot(x = common_currency_price, data = fews_raw, facets = ~product)

qplot(x = common_currency_price, data = fews_raw %>% filter(common_currency_price > 100))

# get rid of the derived data ---------------------------------------------
fews = fews_raw %>% 
  mutate(year = lubridate::year(start_date),
         month = lubridate::month(start_date),
         end_date = (period_date)) %>%
  select(-contains('value_'), 
         -contains('average'), 
         -pct_change_from_one_month_ago,
         -common_currency,
         -period_date,
         -created,
         -collection_status_changed, 
         -status_changed,
         -modified, 
         -specialization_type,
         -dataseries_specialization_type)


# exploring rwanda data ---------------------------------------------------
rw = fews %>% 
  filter(country == 'Nigeria') %>% 
  mutate(filtered_price = ifelse(common_currency_price > 50, NA, common_currency_price))

# product, cpcv2 (code), and cpcv2_description (group) all same
table(rw$product)

ggplot(rw %>% filter(!product %like% 'Pal'), aes(x = start_date, y = filtered_price, colour = market)) +
  geom_line(size = 3, alpha = 0.2) +
  stat_summary(colour = grey75K, fun.y = 'mean', size = 0.75, geom = 'line') +
  facet_wrap(~product, scales = 'free_y') +
  theme_xygrid(legend.position = c(0.8, 0.2))

ggplot(rw %>% filter(!is.na(common_currency_price)), aes(x = start_date, y = common_currency_price, colour = market)) +
  geom_line(size = 3, alpha = 0.2) +
  stat_summary(colour = grey75K, fun.y = 'mean', size = 0.75, geom = 'line') +
  facet_wrap(~product, scales = 'free_y') +
  theme_xygrid(legend.position = c(0.8, 0.2))

# Identify unusual markets

# calculate average over time
rw_mean = rw %>% 
  group_by(start_date, product) %>% 
  summarise(avg = mean(filtered_price, na.rm = TRUE))

rw = left_join(rw, rw_mean)


rw = rw %>% 
  mutate(diff = (filtered_price - avg)/avg)

priciest_mkt = rw %>% 
  group_by(market) %>% 
  summarise(tot = mean(diff, na.rm = TRUE)) %>% 
  arrange(tot)

rw$market = factor(rw$market, levels = priciest_mkt$market)

# market differential from the average
ggplot(rw, aes(x = diff)) +
  geom_vline(xintercept = 0, colour = 'red') +
  geom_density() +
  facet_wrap(~market) +
  scale_x_continuous(labels = percent) +
  ggtitle('Difference from Rwandan average (all commodities)') +
  theme_ygrid()

# market differential -- Huye
ggplot(rw %>% filter(market %like% 'Huye'), aes(x = diff)) +
  geom_vline(xintercept = 0, colour = 'red') +
  geom_histogram() +
  facet_wrap(~product, scales = 'free_y') +
  theme_ygrid()

# market differential -- Huye
ggplot(rw %>% filter(market %like% 'Ruhango'), aes(x = diff)) +
  geom_vline(xintercept = 0, colour = 'red') +
  geom_histogram() +
  facet_wrap(~product, scales = 'free_y') +
  theme_ygrid()


ggplot(fews %>% filter(country %like% 'Malaw'), aes(x = start_date, y = common_currency_price, colour = market)) +
  geom_line(size = 3, alpha = 0.2) +
  stat_summary(colour = grey75K, fun.y = 'mean', size = 0.75, geom = 'line') +
  facet_wrap(~product, scales = 'free_y') +
  theme_xygrid() +
  scale_x_date(limits = c(as.Date('2011-01-01'), as.Date('2016-10-01')))
