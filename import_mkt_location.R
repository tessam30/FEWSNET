library(leaflet)
library(readxl)
library(ggplot2)
library(dplyr)
library(ggmap)

# read in data from FEWS NET, 12 May 2017 ---------------------------------
mkt_geo = read_excel('~/Documents/USAID/FEWSNET/rawdata/Market-2017-05-12_coordinates.xlsx') %>% 
  mutate(market_id = as.numeric(id)) %>% 
  rename(country_code = country) %>% 
  select(-id)



# summary by country ------------------------------------------------------
mkt_geo %>% count(country_code) 


# geocoding the NAs. ------------------------------------------------------
# using Google API to geocode the locations without lat/lon
missing_loc = df %>% filter(is.na(latitude) | is.na(longitude) | latitude == 0) %>% 
  select(market.y, country, country_code, market_id) %>% 
  distinct() %>% 
  mutate(country = ifelse(country %like% "d'Ivoire", "Cote d'Ivoire", as.character(country)))


georef = geocode(paste(missing_loc$market.y, missing_loc$country, sep = " "), output = 'more') %>% 
  select(lon, lat, address, locality, contains('admin'), country_google = country)

georef = bind_cols(missing_loc, georef) 

georef %>% filter(as.character(country) != as.character(country_google)) %>% select(country, country_google, market.y)

georef = georef %>% filter(!is.na(lon), country_google == country | country %like% 'Ivoire' | country %like% 'Venezuela')

# tooltip
info_popup <- paste0("<strong>Country: </strong>", 
                     georef$country,
                     "<br><strong>market: </strong> <br>",
                     georef$market.y)


leaflet() %>%
  addProviderTiles("Esri.WorldGrayCanvas",
                   options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
  addCircleMarkers(lng = ~lon, lat = ~lat, 
                   data = georef,  fillOpacity = 1, radius = 5,
                   color = ~categPal(country_code),
                   popup = info_popup)

# cleaning up the points that seem wrong. ---------------------------------




# quick map ---------------------------------------------------------------
mkts = mkt_geo %>% filter(!is.na(latitude), !is.na(longitude))

# color scale
categPal = colorFactor(palette = 'Set1', domain = unique(mkts$country_code))


# tooltip
info_popup <- paste0("<strong>Country: </strong>", 
                     mkts$country_code,
                     "<br><strong>market: </strong> <br>",
                     mkts$market)


  
# !!!! NOTE: will stop plotting if encounters NAs
leaflet() %>%
  addProviderTiles("Esri.WorldGrayCanvas",
                   options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
  addCircleMarkers(lng = ~longitude, lat = ~latitude, 
                   data = mkts,  fillOpacity = 1, radius = 5,
                   color = ~categPal(country_code),
                   popup = info_popup)


ggplot(mkt_geo, aes(x = longitude, y = latitude, colour = country_code)) +
  geom_point() +
  coord_equal() +
  theme_xygrid()
