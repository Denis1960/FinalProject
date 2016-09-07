flights
library(plyr)
library(datasets)

flightJan <- read.csv("c:/users/DEDWARD2/Documents/GitHub/DataProductsFinal/data/airlineJan.csv",header=TRUE)
#flightFeb <- read.csv("c:/users/DEDWARD2/Desktop/GitHub/FinalProjectDataProducts/data/airlineFeb.csv",header=TRUE)
#flightMar <- read.csv("c:/users/DEDWARD2/Desktop/GitHub/FinalProjectDataProducts/data/airlineMar.csv",header=TRUE)
#flightApr <- read.csv("c:/users/DEDWARD2/Desktop/GitHub/FinalProjectDataProducts/data/airlineApr.csv",header=TRUE)
#flightMay <- read.csv("c:/users/DEDWARD2/Desktop/GitHub/FinalProjectDataProducts/data/airlineMay.csv",header=TRUE)
#flightJun <- read.csv("c:/users/DEDWARD2/Desktop/GitHub/FinalProjectDataProducts/data/airlineJun.csv",header=TRUE)

#flight <- do.call("rbind",list(flightJan))
flight <- flightJan
carrierNames <- read.csv("c:/users/DEDWARD2/Documents/GitHub/DataProductsFinal/data/carriers.csv",header=TRUE)

names(flight) <-c("Month","Day","Carrier","FlightNo","Origin","AirPortId","Destination","DepTime","DepartDelay","ArrivalTime","ArrivalDelay","Cancelled")
names(carrierNames) <- c("Carrier","Code")

actualCarriers <- data.frame(levels(flight$Carrier))
names(actualCarriers) <- c("Carrier")
actualCarrierNames <- merge(actualCarriers,carrierNames,by="Carrier",all.x = TRUE)

fDate <- paste0("2016-",flight$Month,"-",flight$Day)
flight$DOW <- weekdays(as.Date(fDate))


flight$Month <- mapvalues(flight$Month,
                          from = c("1","2"),
                          to = c("January","February"))
                          
flight$Cancelled <- mapvalues(flight$Cancelled,
                              from = c("0","1","?"),
                              to = c("No","Yes","N/A"))



mergeFlight <- merge( flight,actualCarrierNames,by = "Carrier",all.x = TRUE)
write.csv(mergeFlight, file = "c:/users/DEDWARD2/Documents/GitHub/DataProductsFinal/data/mergeFlightRaw.csv")
