
# Manually code FEWS NET Seasonal Calendar data ------------------------
# 
# Converting FEWS NET typical seasonal calendar, by country, into a tidy data frame.
# Since the underlying data don't exist, manually, by hand, recreating the .pngs.
# Assumption: units of calendars are 1/2 or 1/4 months
# Example file source: http://www.fews.net/east-africa/rwanda/seasonal-calendar/december-2013
#
# Laura Hughes, lhughes@usaid.gov, 2 December 2016
# Copyright 2016 Laura Hughes via MIT license



# rwanda ------------------------------------------------------------------

data.frame(
  country = rep('Rwanda', 12),
  region = c(rep('country'))
  start_month = c(2, 3, 4, 6, 8, 9.5, 10.5),
  end_month   = c(3, 4, 5.5, 7, 9.5, 10.5, 12),
  class = c(rep('field-status', 7), rep('rain', 2), rep('harvest', 4), rep('food-security', 2), rep('labor', 3)),
  event = c('land preparation', 'planting season B', 'weeding', 'planting season C', 'land preparation', 'planting season A', 'weeding')
)
