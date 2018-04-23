library(ggplot2)
library(dplyr)
library(stringr)
library(rvest)
library(lubridate)

#Upload weather data from weatherunderground.com

page1 = "https://www.wunderground.com/history/airport/KSFO/2017/6/28/CustomHistory.html?dayend=31&monthend=12&yearend=2017&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo="

p1 = page1 %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="obsTable"]') %>%
  html_table()

#Get the dataframe from the list
weatherhist = p1[[1]]

#In the weatherhist data frame, the headers repeat each month, so we will need to clean that up. 
  #Will also need to change how the date appears in the first column and rename to something besides "2017". 
  #As the data is,it is just the number of the day with no association to which month. The month is only in the row header. 



