
##
#  FEWSNET HTIC FDW DATA
#  URL: BFS.PUB(P):\Climate Smart Agriculture\GIS-GFSS\Projects\C4R\data\FewsNet\
##

# Library
library(stringr)
library(dplyr)
library(plyr)
library(tidyr)
library(ggplot2)

## data dir
#currDir = "P:/Climate Smart Agriculture/GIS-GFSS/Projects/C4R/data/FewsNet/"
currDir = "C:/myhtdocs/projects/usaid/bfs/FewsNet/"

htic_data_file1 = "HFIC_FDW_Submission_Data_20160526.csv"
htic_meta_file1 = "HFIC_FDW_Submission_FS_World_20160526.csv"

htic_data_file2 = "HFIC_FDW_Submission_Data_20170201.csv"
htic_meta_file2 = "HFIC_FDW_Submission_FS_World_20170201.csv"

## set working dir
setwd(currDir)

m_abr <- c("JAN","FEB","MAR","APR","MAI","JUN","JUL","AUG","SEP","OCT","NOV","DEC")
m_num <- c("01","02","03","04","05","06","07","08","09","10","11","12")
months <- data.frame(midx = m_num, mabr = m_abr)

## options

options(stringsAsFactors = FALSE)

## read data

htic_data1 <- read.csv(htic_data_file1)
htic_meta1 <- read.csv(htic_meta_file1)

htic_data2 <- read.csv(htic_data_file2)
htic_meta2 <- read.csv(htic_meta_file2)

## data

str(htic_data1)
head(htic_data1)
tail(htic_data1)

str(htic_data2)
head(htic_data2)
tail(htic_data2)

## meta

str(htic_meta1)
head(htic_meta1)
tail(htic_meta1)

str(htic_meta2)
head(htic_meta2)
tail(htic_meta2)

## Merge data

#data <- merge(htic_data1, htic_data2)
data <- rbind(htic_data1, htic_data2)

head(htic_data1, 2)
head(htic_data1, 2)

str(data)
head(data)
tail(data)


## Filter data by country
countries = c("MZ", "ET", "KE", "HT")

for (cnt in countries) {
  
  print(cnt)

  data_cs <- data[data$COUNTRY == cnt & data$SCENARIO == "CS", ]
  data_cs <- data_cs[, c(5:6,12)]
  
  #head(data_cs)
  
  data_cs2 <- separate(data_cs, REPORTING, c("REP_YEAR", "REP_MONTH", "REP_DAY"), sep = "-")
  data_cs2 <- data_cs2[, c(1:3,5)]
  
  #str(data_cs2)
  
  data_cs3 <- merge(data_cs2, months, by.x = "REP_MONTH", by.y = "midx")
  
  #str(data_cs3)
  head(data_cs3)
  #tail(data_cs3)
  
  #head(months)
  
  #data_cs4 <- unite(data_cs3, REP_DATE, c("mabr", "REP_MONTH"), sep = "_")
  data_cs4 <- unite(data_cs3, REP_DATE, c(mabr, REP_YEAR), sep = "_")
  
  #head(data_cs4)
  
  data_cs5 <- data_cs4[, c(2:4)]
  
  #head(data_cs5)
  
  data_cs6 <- spread(data_cs5, REP_DATE, PHASE)
  
  #str(data_cs6)
  #head(data_cs6)
  #colnames(data_cs6)
  
  ## get frequencies of IPCs
  
  for(i in c(1:5)) {
    ipc = paste("IPC", i, sep = "")
    
    data_cs6[ipc] <- apply(data_cs6[,c(2:30)], 1, function(d){
      return(length(which(d == i)))
    })
    
    print(ipc)
  }
  
  
  data_cs6$IPC2PLUS <- apply(data_cs6[,c(2:30)], 1, function(d){
    return(length(which(d >= 2)))
  })
  
  data_cs6$IPC3PLUS <- apply(data_cs6[,c(2:30)], 1, function(d){
    return(length(which(d >= 3)))
  })
  
  data_cs6$IPC4PLUS <- apply(data_cs6[,c(2:30)], 1, function(d){
    return(length(which(d >= 4)))
  })
  
  data_cs6$RECORDS <- length(data_cs6[, c(2:30)])
  
  
  # write files
  write.csv(data_cs6, file = paste(cnt, "Historical-IPCs.csv", sep = "-"), row.names = FALSE)
  
  # filter out FNID
  fnidList <- substr(data_cs6$FNID, 1, 6)
  # get unique years
  fnidDist <- unique(fnidList)
  
  print(length(fnidDist))
  
  if( length(fnidDist) > 1 ) {
    
    for ( fn in fnidDist ) {
      print(fn)
      # split data by year ==> The year is based on the shapefile. Admin boundaries being used for data collection / analysis
      write.csv(data_cs6[substr(data_cs6$FNID, 1, 6) == fn, ], file = paste(cnt, "-Historical-IPCs-", fn , ".csv", sep = ""), row.names = FALSE)
    }
  }

}
















