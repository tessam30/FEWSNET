# import FEWS NET market locations ----------------------------------------
# Raw data provided by FEWS NET via Baboyma Kagniniwa on 12 May 2017
# Laura Hughes, USAID GeoCenter, 23 May 2017, lhughes@usaid.gov


library(leaflet)
library(readxl)
library(ggplot2)
library(dplyr)
library(ggmap)
library(llamar)

# read in data from FEWS NET, 12 May 2017 ---------------------------------
mkt_geo = read_excel('~/Documents/USAID/FEWSNET/rawdata/Market-2017-05-12_coordinates.xlsx') %>% 
  mutate(market_id = as.numeric(id)) %>% 
  rename(country_code = country) %>% 
  select(-id)

# read in full market data
# source('01_import_fews_price.R')

# summary by country ------------------------------------------------------
mkt_geo %>% count(country_code) 


# MAP: Quality control on the FEWS NET-supplied data points ----------------------------------
# # Filter out NAs for lat/lon; won't be plotted by leaflet
# mkts = mkt_geo %>% filter(!is.na(latitude), !is.na(longitude))
# 
# # color scale
# categPal = colorFactor(palette = 'Set1', domain = unique(mkts$country_code))
# 
# 
# # tooltip
# info_popup <- paste0("<strong>Country: </strong>",
#                      mkts$country_code,
#                      "<br><strong>market: </strong> <br>",
#                      mkts$market)
# 
# 
# 
# # !!!! NOTE: will stop plotting if encounters NAs
# 
# leaflet() %>%
#   addProviderTiles("Esri.WorldGrayCanvas",
#                    options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
#   addCircleMarkers(lng = ~longitude, lat = ~latitude,
#                    data = mkts,  fillOpacity = 1, radius = 5,
#                    color = ~categPal(country_code),
#                    popup = info_popup)
# 
# # static ggplot simple map
# ggplot(mkt_geo, aes(x = longitude, y = latitude, colour = country_code)) +
#   geom_point() +
#   coord_equal() +
#   theme_xygrid()

# After looking at the plot, only one point (at (0,0)) appears to be grossly wrong.
# Resetting to NA.

mkt_geo = mkt_geo %>% 
  mutate(latitude = ifelse(latitude == 0 & longitude == 0, NA, latitude),
         longitude = ifelse(latitude == 0 & longitude == 0, NA, longitude))


# geocoding the NAs. ------------------------------------------------------
test_join = left_join(fews, mkt_geo, by = 'market_id')

# using Google API to geocode the locations without lat/lon
missing_loc = test_join %>% filter(is.na(latitude) | is.na(longitude)) %>% 
  select(market = market.y, country, country_code, market_id) %>% 
  distinct() %>% 
  mutate(country = ifelse(country %like% "d'Ivoire", "Cote d'Ivoire", as.character(country)))


georef = geocode(paste(missing_loc$market, missing_loc$country, sep = " "), output = 'more') %>% 
  select(lon, lat, address, locality, contains('admin'), country_google = country)

georef = bind_cols(missing_loc, georef) 

georef %>% filter(as.character(country) != as.character(country_google)) %>% select(country, country_google, market)

# Filter out places where the results of the georeferencing have country names that don't agree.
# Don't count Cote d'Ivoire, Venezuela, which don't count b/c 
georef = georef %>% 
  filter(!is.na(lon), country_google == country | country %like% 'Ivoire' | country %like% 'Venezuela') %>% 
  mutate(google_georef = 1,
         # Fix one obvious mistake: (placed in US)
         lat = ifelse(market == 'Malaysia and Indonesia', NA, lat),
         lon = ifelse(market == 'Malaysia and Indonesia', NA, lon)
         )



# MAP: quality control of the fixed georeferenced points ------------------------


# # tooltip
# info_popup <- paste0("<strong>Country: </strong>", 
#                      georef$country,
#                      "<br><strong>market: </strong> <br>",
#                      georef$market)
# 
# 
# leaflet() %>%
#   addProviderTiles("Esri.WorldGrayCanvas",
#                    options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
#   addCircleMarkers(lng = ~lon, lat = ~lat, 
#                    data = georef,  fillOpacity = 1, radius = 5,
#                    color = ~categPal(country_code),
#                    popup = info_popup)


# merge together FEWS NET id’d points and the Google georeferenced --------

mkt_geo = left_join(mkt_geo, georef %>% select(market_id, country_code, lon, lat, google_georef), by = c('market_id', 'country_code')) %>% 
  mutate(latitude = ifelse(is.na(latitude), lat, latitude),
         longitude = ifelse(is.na(longitude), lon, longitude),
         google_georef = ifelse(is.na(google_georef) & !is.na(latitude), 0, google_georef)) %>% 
  select(-lat, -lon, -contains('admin'))





