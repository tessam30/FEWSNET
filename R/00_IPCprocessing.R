
##
#  By: Tim Essam
#  FEWSNET HTIC FDW DATA - verify Baboyma's code
#  URL: BFS.PUB(P):\Climate Smart Agriculture\GIS-GFSS\Projects\C4R\data\FewsNet\
##

# Library
library(stringr)
library(tidyverse)

setwd("~/FEWSNET/datain")
# setwd("~/FEWSNET/dataout")

  htic_data_file1 = "HFIC_FDW_Submission_Data_20160526.csv"
  htic_meta_file1 = "HFIC_FDW_Submission_FS_World_20160526.csv"
  
  htic_data_file2 = "HFIC_FDW_Submission_Data_20170201.csv"
  htic_meta_file2 = "HFIC_FDW_Submission_FS_World_20170201.csv"


# Create a data frame of months and 
  m_abr <- c("JAN","FEB","MAR","APR","MAI","JUN","JUL","AUG","SEP","OCT","NOV","DEC")
  m_num <- c("01","02","03","04","05","06","07","08","09","10","11","12")
  months <- data.frame(midx = m_num, mabr = m_abr)

## options - do not want to factorize strings at this point
  options(stringsAsFactors = FALSE)
  
  htic_data1 <- read.csv(htic_data_file1)
  htic_meta1 <- read.csv(htic_meta_file1)
  
  htic_data2 <- read.csv(htic_data_file2)
  htic_meta2 <- read.csv(htic_meta_file2)
  
# Function to retunr glimpse, head and tail
  df_detail <- function(x) {
    glimpse(x)
    list(HEAD = head(x), TAIL = tail(x))
  }

  htic_df <- list(htic_data1, htic_meta1, htic_data2, htic_meta2)
  lapply(htic_df, df_detail)

## Append the data frames together to create updated set
  data <- rbind(htic_data1, htic_data2)
  glimpse(data)  
  
  
  data_cs = data %>%
    filter(COUNTRY == "MZ" & SCENARIO == "CS") %>% 
    select(
  
  
  
  
  
  
  for (cnt in countries) {
    
    print(cnt)
    
    data_cs <- data[data$COUNTRY == cnt & data$SCENARIO == "CS", ]
    data_cs <- data_cs[, c(5:6,12)]
    
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
  
  