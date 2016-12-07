# check_fews_geocoding


# set defaults ------------------------------------------------------------
library(readr)
library(leaflet)
library(ggplot2)
library(llamar)
library(dplyr)
base_dir = '~/Documents/USAID/FEWSNET/processeddata/'

# import data -------------------------------------------------------------


mkts = read.csv(paste0(base_dir, '2016_11_fews_makets_gps.csv'))

mkts = mkts %>% dplyr::filter(!is.na(lon))
# ggplot map --------------------------------------------------------------

ggplot(mkts, aes(x = lon, y = lat, colour = country)) +
  geom_point() +
  coord_equal() +
  llamar::theme_blank()


# quick map ---------------------------------------------------------------
# color scale
categPal = colorFactor(palette = 'Pastel1', domain = unique(mkts$country))


# tooltip
info_popup <- paste0("<strong>Country: </strong>", 
                     mkts$country,
                     "<br><strong>market: </strong> <br>",
                     mkts$market)

leaflet() %>%
  addProviderTiles("Esri.WorldGrayCanvas",
                   options = tileOptions(minZoom = 1, maxZoom  = 11, opacity = 0.8)) %>%
  addCircleMarkers(lng = ~lon, lat = ~lat, 
             data = mkts,  fillOpacity = 1, radius = 5,
             color = ~categPal(country),
             popup = info_popup)
  
