library(ggplot2)
library(dplyr)
library(stringr)
library(rvest)
library(lubridate)
library(tidyr)
library(geosphere)
library(leaflet)
library(RColorBrewer)

# Reading all data downloaded form the Ford Bike site
bikedata17 = read.csv("2017-fordgobike-tripdata.csv")
bikedata18_1 = read.csv("201801_fordgobike_tripdata.csv")
bikedata18_2 = read.csv("201802_fordgobike_tripdata.csv")
bikedata18_3 = read.csv("201803_fordgobike_tripdata.csv")

# Combine them into Single data
Bikedata=rbind(bikedata17,
               bikedata18_1,
               bikedata18_2,
               bikedata18_3)

# Data cleaning for the start and end time 
finalbikedata = Bikedata%>%
  separate(col= start_time,
           into = c("start_Time","Junk1"),
           sep = 19,remove = T )%>%
  separate(col= end_time,
           into = c("end_Time","Junk2"),
           sep = 19,remove = T )

#Removing Junk Created
finalbikedata = finalbikedata[,-c(3,5)]  
  
#Formatting date and Time using Lubridate
finalbikedata$start_Time = ymd_hms(finalbikedata$start_Time)
finalbikedata$end_Time = ymd_hms(finalbikedata$end_Time)


### For Spider Map
## Compile data specific for spider map
Spiderdata=finalbikedata%>%
  filter(start_station_id %in% c(3,5,144))%>% ## Input to be given from Shiny, with multiple select od start station_id
  group_by(start_station_id,
           start_station_longitude,
           start_station_latitude,
           end_station_id,
           end_station_longitude,
           end_station_latitude)%>%
  summarise(count=n())%>%
  filter(count>= 100)## Input from Shiny , with slider bar giving rang of frequency 


##Consolidate into flow pattern for path lines , 
##To compute distances for angular (longitude/latitude) locations

flows <- gcIntermediate(Spiderdata[,2:3],
                        Spiderdata[,5:6],
                        sp = TRUE,
                        addStartEnd = TRUE)

flows$count <- Spiderdata$count/100
flows$start_station_id <- Spiderdata$start_station_id
flows$end_station_id <- Spiderdata$end_station_id

##Creating spider MAp

##To create label on the line
hover <- paste0(flows$start_station_id, " to ", 
                flows$end_station_id, ': ', 
                as.character(flows$count*100))

## To map origin stations to colours as there are too many 
pal <- colorFactor(brewer.pal(4, 'Set2'), flows$start_station_id)

##Creating Interactive Spider MAp
leaflet() %>%
  addProviderTiles('CartoDB.Positron') %>%
  addPolylines(data = flows, weight = ~count, label = hover, 
               group = ~start_station_id, color = ~pal(start_station_id)) %>%
  addLayersControl(overlayGroups = unique(flows$start_station_id), 
                   options = layersControlOptions(collapsed = FALSE))


