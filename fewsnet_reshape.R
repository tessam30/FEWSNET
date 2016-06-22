# Convert fews net price anomalies to tidy data using R
# Data from https://www.usaid.gov/data/dataset/8357a7f6-2514-42ea-8069-ae260c9a4d98

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)

# Iterate through the
setwd("C:/Users/t/Documents/R")


# Function from stackoverflow to read all tabs in spreadsheet and return in a list of tibbles
read_excel_allsheets <- function(filename) {
  sheets <- readxl::excel_sheets(filename)
  x <-    lapply(sheets, function(X) readxl::read_excel(filename, sheet = X, col_names = FALSE))
  names(x) <- sheets
  x
}

fews_sheets = read_excel_allsheets("FEWS NET_G82002_2012_PriceVolatility (2).xlsx")

# Remove the first sheet as it only contains meta data not needed for transformations
fews_sheets$Sheet1 <- NULL

names(fews_sheets$BDI_CHG)
str(fews_sheets)

clean_tbl <- function(x){
  # Transpose to get data close to tidy data
  td = as.data.frame(t(x))
  
  # reapply column names for filtering and reshaping
  colnames(td) = as.character(unlist(td[1, ]))
  td = td[-1,]
  
  # Now to reshape the months to get tidy data; Need to convert to numeric to get dates correct
  fews_tidy = gather(td, "date", "price_anomaly", `37287`:`41274`) %>%
    mutate(date = as.numeric(date), price_anomaly = as.numeric(price_anomaly)) %>%
    mutate(date = as.Date(date, origin = "1899-12-30"))
  
  return(fews_tidy)
}

fewsList = lapply(fews_sheets, clean_tbl)


# Compress fewsList into a stacked db

# td = as.data.frame(t(fews_sheets[15]))
# colnames(td) = as.character(unlist(td[1, ]))
# td = td[-1,]
# 
# fews_tidy = gather(td, "date", "price_anomaly", `37287`:`41274`) %>%
#   mutate(date = as.numeric(date), price_anomaly = as.numeric(price_anomaly)) %>%
#   mutate(date = as.Date(date, origin = "1899-12-30")) %>%
#   arrange(`Market location`, date)
# 


fews_db <- (bind_rows(fewsList))
str(fews_db)

# For those not geocoding
# Konso  = karati, Ethiopia
# Red Light, Liberia = Monrovia
# Saclepea =  saglelpie, Liberia
# Togwajale = Tog-Wajale, Somalia 

# Need to replace the above markets to get geocoding to work

# Use car package to recode multiple variables at once
library(car)

# Should work, but doesn't for some reason
# fews_db$`Market location` = recode(fews_db$`Market location`, 
#                                   "Karati = Konso; Red Light = Monrovia; Saclepea = Saglelpie")


#fews_db = fews_db %>% mutate(`Market location` = ifelse(`Market location` == "Karati", "Konso", `Market location`))

fews_db$`Market location`[fews_db$`Market location` == "Karati"] = "Konso" 
fews_db$`Market location`[fews_db$`Market location` == "Red Light"] = "Monrovia" 
fews_db$`Market location`[fews_db$`Market location` == "Saclepea"] = "Saglelpie" 
fews_db$`Market location`[fews_db$`Market location` == "Togwajale"] = "Tog-Wajale" 

library(ggmap)

fews_geo = mutate(fews_db, market_loc = paste(`Market location`, Country, sep = ', '))
fews_geo = fews_geo %>% 
  group_by(market_loc) %>%
  summarise(freq = n())
  
df2 = geocode(fews_geo$market_loc, source = "google")

fews_geo = cbind(fews_geo, df2)


# For those not geocoding
# Konso  = karati, Ethiopia
# Red Light, Liberia = Monrovia
# Saclepea =  saglelpie, Liberia
# Togwajale = Tog-Wajale, Somalia 

# Ignore those not correctly geocoded for the moment
fews_geo2 = fews_geo %>% filter(!is.na(lat)) %>% filter(market_loc != "NA, NA")

# Combine the geocoded dataframe with the full dataframe
fews_db = mutate(fews_db, market_loc = paste(`Market location`, Country, sep = ', ')) 
fews_db_geo = left_join(fews_db, fews_geo, by = "market_loc")

fews_db_geo = arrange(fews_db_geo, Country, `Market location`, date)
#save a cut of the geocoded data as a .cvs
write.csv(fews_db_geo, file = "fews_geocoded.csv")


#Stopped here -- need to plot data and see what they look like over time
mw = filter(fews_db_geo, Country == "Malawi") 
glimpse(mw)


table(mw$Commodity)


mw_map = get_map(location = c(lon = mean(mw$lon), lat = mean(mw$lat)), zoom = 5)   
str(mw_map)
ggmap(mw_map)  
 
  
mapfews <- get_map(location = c(lon = mean(fews_geo2$lon), lat = mean(fews_geo2$lat)), zoom = 3,
                      maptype = "hybrid", source = "osm", scale = 2)

ggmap(mapfews) +
  geom_point(data = fews_geo2, aes(x = lon, y = lat, fill = "red", alpha = 0.8), size = 3, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)


leaflet(data = fews_geo2) %>% addTiles() %>%
  addMarkers(~lon, ~lat, popup = ~as.character(market_loc))
