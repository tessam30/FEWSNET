
# Merge together FEWS NET market price data -------------------------------
# Merge together 3 datasets:
# 1) FEWS NET market price data, per month, country, market, commodity
# 2) FEWS NET georeferenced market locations
# 3) IMF CPI per month, country

library(fuzzyjoin)


# load the data -----------------------------------------------------------

# FEWS NET market prices
source('01_import_fews_price.R')

# FEWS NET market locations
source('02_import_mkt_location.R')

# CPI
source('import_CPI.R')


# merge price + market lat/lon --------------------------------------------

# Market names could (in theory) be used as additional merging variable between the market locations and the price data.
# However... One market in Senegal doesn't match (Ziguichor).  Therefore, just using the market id.
df = left_join(fews, mkt_geo, by = 'market_id')


# Double checking market ids are the same, aside from accents...
df %>% select(geographic_group, country, market_id, market.x, market.y, latitude, longitude) %>% 
  distinct() %>% filter(market.x != market.y)

# check if any mkt not geocoded
# Originially: 51 markets don't merge, and one mis-identified, just based on the info supplied by FEWS NET.
# After geocoding the missing 52 markets, only 8 remain: 3 in Cameroon, 1 in Ghana, 
# Kong Chang in Myanmar, 1 in Sudan, Malaysia & Indonesia, Composite (incl. Brazil)

df %>% select(geographic_group, country, market_id, market.x, market.y, latitude, longitude) %>% 
  distinct() %>% 
  filter(is.na(latitude) | is.na(longitude))

df2map = df %>% 
  # select(geographic_group, country, country_code, market_id, market = market.x, latitude, longitude) %>% 
  filter(!is.na(latitude), !is.na(longitude)) %>% 
  group_by(country, country_code, market = market.x) %>% 
  summarise(latitude = mean(latitude),
            longitude = mean(longitude),
            min_year = min(year),
            max_year = max(year),
            num_commodities = length(unique(product)))

df = df %>% 
  rename(market = market.x) %>% 
  select(-market.y)

# map of markets ----------------------------------------------------------
# color scale
# categPal = colorFactor(palette = 'Set1', domain = unique(df2map$country_code))
# 
# info_popup <- paste0("<strong>Country: </strong>", 
#                      df2map$country,
#                      "<br><strong>market: </strong> <br>",
#                      df2map$market,
#                      "<br><strong>years: </strong> <br>",
#                      paste0(df2map$min_year, '-', df2map$max_year),
#                      "<br><strong>number of commodities: </strong> <br>",
#                      df2map$num_commodities)
# 
# leaflet() %>%
#   addProviderTiles("Esri.WorldGrayCanvas",
#                    options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
#   addCircleMarkers(lng = ~longitude, lat = ~latitude, 
#                    data = df2map,  fillOpacity = 1, radius = 5,
#                    color = ~categPal(country_code),
#                    popup = info_popup)



# Merge prices + CPI data --------------------------------------------------

df = left_join(df, cpi, by = c('country', 'month', 'year'))

df %>% count(base_year)


# CALCULATE “REAL” DOLLARS FOR VALUES -------------------------------------
df = df %>% 
  mutate(price_norm = common_currency_price / cpi)



# plots -------------------------------------------------------------------
ggplot(df %>% filter(country == "Ethiopia",
                     product %in% c('Cattle', 'Cattle (Export quality)',
                                    'Mixed Teff', 'Maize (White)',
                                    'Sheep (Export quality)', 'Wheat Grain',
                                    'Sorghum (Yellow)', 'Goats (Local Quality)')
                     ), aes(x = start_date, y = price_norm,
                                                 colour = market)) +
  geom_line(size = 2, alpha = 0.5) +
  geom_smooth(colour = grey75K, se = FALSE) +
  facet_wrap(~ product, scales = 'free_y') +
  theme_xygrid()

