# -*- coding: utf-8 -*-
"""
Created on Fri Jun 24 22:09:51 2016

@author: Baboyma Kagniniwa

Purpose: Extract unique market location from commodity prices dataset
"""

#import sys
import csv, json, datetime

orgFile = "./fews_geocoded2.csv"
mFile = "./geodata/markets_data.csv"
cFile = "./geodata/markets_commodities.csv"

tday = str(datetime.datetime.now())
print "--- Date: " + tday + " ---"
print "File: " + orgFile

csvFile = open(orgFile, 'r')

csvmFile = open(mFile, 'wb')
csvmWriter = csv.writer(csvmFile)

csvcFile = open(cFile, 'wb')
csvcWriter = csv.writer(csvcFile)

cols = []
mCols = []
cCols = []

mID = 0
uRows = []

try:
    csvCont = csv.reader(csvFile)
    
    for i, csvRow in enumerate(csvCont):
        # Stop here for testing
        #if i > 3:
            #break
        
        # Extract table headers and reformat
        if i == 0:
            print "File Headers: " + str(len(csvRow))
            #print csvRow
            cols = csvRow
            
            #mmarkets columns
            mCols.append("MID")
            mCols.append(csvRow[1].upper()) #COUNTRY
            #mCols.append(csvRow[2].upper()) #MARKET_LOCATION
            mCols.append("MARKET") #MARKET_LOCATION
            mCols.append(csvRow[10].upper()) #MARKET_LOC
            #mCols.append(csvRow[3].upper()) #MARKET_NAME
            mCols.append("NAME") #MARKET_NAME
            mCols.append(csvRow[13].upper()) #LAT
            mCols.append(csvRow[12].upper()) #LON
            
            mCols = map(str.lower, mCols)
            
            print
            print "Markets Columns:"
            print mCols
            
            csvmWriter.writerow(mCols)
            
            #commodity columns
            cCols = ["MID"] + cols
            cCols.insert(9, "d_month")
            cCols.insert(10, "d_day")
            cCols.insert(11, "d_year")
            
            cCols = map(str.lower, cCols)
            
            print
            print "Commodities Columns"
            print cCols
            
            csvcWriter.writerow(cCols)
            
        # Compile data based on 
        else:  
            id = csvRow[0] #ID
            m = csvRow[10] #MARKET_LOC
            lat = csvRow[13]
            lon = csvRow[12]
            
            print "Lat: " + str(lat) + ", Lon: " + str(lon)
            
            if uRows.count(m) == 0 and lat != 'NA':
                mID += 1
                uRows.append(m)
                
                mData = []
                
                mData.append(mID)
                mData.append(csvRow[1]) #COUNTRY
                mData.append(csvRow[2]) #MARKET_LOCATION
                mData.append(csvRow[10]) #MARKET_LOC
                mData.append(csvRow[3]) #MARKET_NAME
                mData.append(csvRow[13]) #LAT
                mData.append(csvRow[12]) #LON
                
                print
                print "------"
                print "Row #" + str(i + 1) + " cells count: " + str(len(csvRow))
                print "Data #" + str(mID)
                print mData
            
                # Write all markets data to new table
                csvmWriter.writerow(mData)
                
            cData = [mID] + csvRow
            cDates = cData[8].split("/")
            print cDates
            cData.insert(9, cDates[0])
            cData.insert(10, cDates[1])
            cData.insert(11, cDates[2])
            print cData
            
            
            # Write all commodities data to new table
            csvcWriter.writerow(cData)
                
                
                #for j, csvCell in enumerate(csvRow):
                    #print cols[j].upper() + " #" + str(j) + ": " + str(csvCell)
                
    print
    print "--END--"
    print "Total: " + str(len(uRows))
    print uRows

finally:
    csvFile.close()
    csvmFile.close() 
    csvcFile.close()

# convert commidity data to json    

