
# Manually code FEWS NET Seasonal Calendar data ------------------------
# 
# Converting FEWS NET typical seasonal calendar, by country, into a tidy data frame.
# Since the underlying data don't exist, manually, by hand, recreating the .pngs.
# Assumption: units of calendars are 1/2 or 1/4 months
# Example file source: http://www.fews.net/east-africa/rwanda/seasonal-calendar/december-2013
#
# Laura Hughes, lhughes@usaid.gov, 2 December 2016
# Copyright 2016 Laura Hughes via MIT license



library(readxl)
library(dplyr)
library(ggplot2)
library(llamar)

# manually coded into excel sheet -----------------------------------------

sc = read_excel('~/Documents/USAID/FEWSNET/processeddata/FEWS_seasonal_calendars.xlsx')

sc = sc %>% 
  mutate(circ = start_month > end_month)

# relevel -----------------------------------------------------------------
sc$category = factor(sc$category, levels = c('labor', 'livestock', 'food_security', 'harvest', 'rain', 'field_status'))


# recreating FEWS NET seasonal calendars ----------------------------------
width_bar = 0.25

sc = sc %>% 
  mutate(categ_ymin = as.numeric(category),
         categ_ymax = as.numeric(category) + width_bar)

# -- plot --
ggplot(sc %>% filter(region %like% 'East'), aes(xmin = start_month, xmax = end_month, 
               ymin = categ_ymin, ymax = categ_ymax, 
               fill = cat_color)) +
  geom_rect(alpha = 0.5, colour = 'white', size = 2) +
  
  geom_text(aes(x = (start_month + end_month)/2, y = (categ_ymin + categ_ymax)/2,
                label = event), colour = grey90K, size = 3, family = 'Lato') +
  
  scale_x_continuous(breaks = 1:12, labels = month.name,
                     position = 'top') +
  scale_y_continuous(breaks = 1:5, labels = c('labor', 'food_security', 'harvest', 'rain', 'field_status')) +
  
  scale_fill_identity() +
  facet_wrap(~country, nrow = 2) +
  theme_xgrid()


