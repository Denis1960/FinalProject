library(plyr)
library(datasets)
library(dplyr)

##
flights <- read.csv("c:/users/DEDWARD2/Documents/GitHub/DataProductsFinal/data/mergeFlightRaw.csv",header=TRUE)
flights$DelayMinutes <- flight$DepartDelay + flight$ArrivalDelay

