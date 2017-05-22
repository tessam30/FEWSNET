
# Merge together FEWS NET market price data -------------------------------
# Merge together 3 datasets:
# 1) FEWS NET market price data, per month, country, market, commodity
# 2) FEWS NET georeferenced market locations
# 3) IMF CPI per month, country

library(fuzzyjoin)


# load the data -----------------------------------------------------------

# FEWS NET market prices
source('import_fews_price.R')

# FEWS NET market locations
source('import_mkt_location.R')

# CPI
source('import_CPI.R')


# merge price + market lat/lon --------------------------------------------

# Market names could (in theory) be used as additional merging variable between the market locations and the price data.
# However... One market in Senegal doesn't match (Ziguichor).  Therefore, just using the market id.
df = left_join(fews, mkt_geo, by = 'market_id')


# Double checking market ids are the same, aside from accents...
df %>% select(geographic_group, country, market_id, market.x, market.y, latitude, longitude) %>% distinct() %>% filter(market.x != market.y)

# check if any mkt not geocoded
# 51 markets don't merge, just based on the info supplied by FEWS NET.
df %>% select(geographic_group, country, market_id, market.x, market.y, latitude, longitude) %>% distinct() %>% filter(is.na(latitude) | is.na(longitude))

df2map = df %>% 
  # select(geographic_group, country, country_code, market_id, market = market.x, latitude, longitude) %>% 
  filter(!is.na(latitude), !is.na(longitude)) %>% 
  group_by(country, country_code, market = market.x) %>% 
  summarise(latitude = mean(latitude),
            longitude = mean(longitude),
            min_year = min(year),
            max_year = max(year),
            num_commodities = length(unique(product)))



# map of markets ----------------------------------------------------------

info_popup <- paste0("<strong>Country: </strong>", 
                     df2map$country,
                     "<br><strong>market: </strong> <br>",
                     df2map$market,
                     "<br><strong>years: </strong> <br>",
                     paste0(df2map$min_year, '-', df2map$max_year),
                     "<br><strong>number of commodities: </strong> <br>",
                     df2map$num_commodities)

leaflet() %>%
  addProviderTiles("Esri.WorldGrayCanvas",
                   options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
  addCircleMarkers(lng = ~longitude, lat = ~latitude, 
                   data = df2map,  fillOpacity = 1, radius = 5,
                   color = ~categPal(country_code),
                   popup = info_popup)
