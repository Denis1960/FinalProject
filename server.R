## Server.r
## Denis Edwards - Author

library(shiny)
library(datasets)
library(dplyr)
library(ggplot2)
library(scales)
library(plyr)
library(tidyr)
library(lubridate)

#initialization of server.R
shinyServer(function(input, output)
{
  
  #What is the average flight delay in minutes for each carrier for this origin/destination combo. Average considers
  #all flights not just delays (delayMinutes / total # flights per carrier)
  output$delayHist = renderPlot ({
       subset_delay = subset(flights, 
                           Origin == input$origin_select & Destination == input$dest_select &
                             Month == input$month_select)
                             
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
        ggtitle(paste(" Flights sorted by average delays from ", input$origin_select, "to ", input$dest_select, 
                       " for month of ",input$month_select)) +
        xlab('Airline') + ylab("Average Minutes Per Delay")
      
  })
  
  #Average delays by Carrier For the Month By Flight Number - (best available flights)
  output$delayPct = renderTable({
    subset_delay = subset(flights, Origin == input$origin_select & Destination == input$dest_select &
                            Month == input$month_select)
      sDelay <- subset_delay %>%
      group_by(Code,FlightNo) %>%
      select(ArrivalDelay, DepartDelay) %>%
      summarise(
        arrivalDelay = mean(ArrivalDelay, na.rm = TRUE),
        departureDelay = mean(DepartDelay, na.rm = TRUE),
        totalDelay = mean(ArrivalDelay + DepartDelay, na.rm = TRUE)
      )
      arrange(sDelay,totalDelay)
  },caption = paste(" Average delay minutes for all flights by carrier from", input$origin_select, "to ", input$dest_select," for month of ",input$month_select),
      caption.placement = getOption("xtable.caption.placement", "top"), 
      caption.width = getOption("xtable.caption.width", NULL))
    
  
  #Arrival and departure delays based on departure time. What time is best to leave
  #to avoid delays?
  output$bestFlyTime = renderPlot({
     subset_delay = subset(flights, 
                          Origin == input$origin_select & 
                            Destination == input$dest_select &
                            Month == input$month_select)
                           
    subset_delay <- subset_delay[c(4,5,2,6,9,10,12)]
    subset_delay$hour <- round(subset_delay$DepTime/100,0)
    subset_delay$DepartDelay=ifelse(subset_delay$DepartDelay<0,0,subset_delay$DepartDelay)
    subset_delay$ArrivalDelay =ifelse(subset_delay$ArrivalDelay<0,0,subset_delay$ArrivalDelay)
    subset_delay <- filter(subset_delay,hour >5,hour <24)
    
    gTitle <- paste("Flight Delays by Departure Time from ",input$origin_select," to ",input$dest_select, 
                    "for month of ",input$month_select)
    
    plot_data = subset_delay %>%
      gather(delay_type,newdelay,DepartDelay:ArrivalDelay) %>%
      mutate(delay_type = ifelse(delay_type=="DepartDelay","Departure Delay","Arrival Delay")) %>%
      group_by(hour,delay_type) %>%
      dplyr::summarise(mu=mean(newdelay,na.rm=TRUE),
                       se=sqrt(var(newdelay,na.rm=TRUE)/length(na.omit(newdelay))),
                       obs=length(na.omit(newdelay)))

    p=ggplot(plot_data,aes(x=hour,y=mu,min=mu-se,max=mu+se,group=delay_type,color=delay_type)) +
      geom_line() +
      geom_point() +
      geom_errorbar(width=.33) +
      scale_x_continuous(breaks=seq(0,24)) +
      labs(x="Hour of Day",y="Average Delay (Minutes)",title=gTitle) +
      theme(legend.position="bottom") +
      scale_color_discrete(name="Delay Type")
  p
})
 
  #Average delays by day of week. What day of week is best to fly?
  output$bestDay= renderTable({
    subset_delay = subset(flights, Origin == input$origin_select & Destination == input$dest_select &
                            Month == input$month_select)
    sDelay <- subset_delay %>%
      group_by(DOW) %>%
      select(ArrivalDelay, DepartDelay) %>%
      summarise(
        arrivalDelay = mean(ArrivalDelay, na.rm = TRUE),
        departureDelay = mean(DepartDelay, na.rm = TRUE),
        totalDelay = mean(ArrivalDelay + DepartDelay, na.rm = TRUE)
      )
    arrange(sDelay,totalDelay)
  },caption = paste(" Average delay minutes by day of week from", input$origin_select, "to ", input$dest_select," for month of ",input$month_select),
  caption.placement = getOption("xtable.caption.placement", "top"), 
  caption.width = getOption("xtable.caption.width", NULL))
  
  output$aboutApp = renderText({
    txt <- 'Simply select where you wish to fly from and where you wish to fly to and the month you wish
     to travel from the drop down lists. You can then see which flights have the best records based on delays, which days are best to fly to avoid delays, which carriers have the 
     best ontime records, and what time to depart to avoid delays by selecting the tabs corresponding to the information you 
     destination will demonstrate changes in tab data'
  })
  
})
