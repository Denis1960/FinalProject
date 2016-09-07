library(ggplot2)
library(dplyr)
library(datasets)
library(scales)
library(plyr)
library(tidyr)
library(lubridate)

flights <- read.csv("mergeFlightRaw.csv",header=TRUE)

subset_delay = subset(flights, 
                      Origin == "Dallas/Fort Worth, TX" & Destination == "Seattle, WA" &
                        Month == "January")

sDelay <- subset_delay %>%
  group_by(Code) %>%
  select(ArrivalDelay, DepartDelay) %>%
  summarise(
    arrivalDelay = mean(ArrivalDelay, na.rm = TRUE),
    departureDelay = mean(DepartDelay, na.rm = TRUE),
    totalDelay = mean(ArrivalDelay + DepartDelay, na.rm = TRUE)
  )

# make plot
p = ggplot(sDelay,aes(Code,totalDelay,fill=Code))
p + geom_bar(stat = "identity") +
  ggtitle(paste(" Flights sorted by average delays from Dallas/Fort Worth, Tx to Seattle, WA 
                        for month of January")) +
  xlab('Airline') + ylab("Average Minutes Per Delay")
p 