library(readr)
library(tidyverse)
library(plotly)
library(leaflet)
library(lubridate)
library(forcats)
library(revgeo)
library(kableExtra)

#Read in csv's from github
stpatricks<- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/stpatricks.csv")
fourthjuly<- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/fourthjuly.csv")
nycpride <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/nycpride.csv")
burrows <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/burrows.csv")
rides <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/rides.csv")
holiday <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/mergedholiday.csv")

#Holiday data frames
nycpride.df<- nycpride[,c("Time", "Label")]
fourthjuly.df<- fourthjuly[,c("Time", "Label")]
stpatricks.df<- stpatricks[,c("Time", "Label")]
data<- rbind(nycpride.df, fourthjuly.df, stpatricks.df)

#Burrow data frames
burrows_day <- read_csv('https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/burrows_day.csv')
burrows_day <- as.data.frame(burrows_day)

burrow_by_day2 <- burrows_day %>%
  group_by(day,Burrow) %>%
  ungroup()

burrow_by_day2 <- burrow_by_day2 %>%
  select(X1, day, Burrow, hour)
burrow_by_hour <- burrows_day %>%
  group_by(hour, Burrow) %>%
  ungroup()
burrow_by_hour <- burrow_by_hour %>%
  select(X1, hour, Burrow, Lat,Lon)

burrow_by_day2 <- burrow_by_day2 %>%
  dplyr::mutate(day = factor(day, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))
burrow_by_hour <- burrow_by_hour %>%
  dplyr::mutate(hour = factor(hour, levels = seq(0:24)))


#Uber vs Taxi data frames
uber_locations_full <- rides %>% filter(Label == "Uber") %>% mutate(Lat_Long = paste(Lat, Lon, sep = ","))
taxi_locations_full <- rides %>% filter(Label == "Taxi") %>% mutate(Lat_Long = paste(Lat, Lon, sep = ","))

#uber_top_locations
uber_top_locations <- rides %>% filter(Label == "Uber") %>% mutate(Lat_Long = paste(Lat, Lon, sep = ",")) %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n = 50, wt =count) 

#taxi_top_locations
taxi_top_locations <- rides %>% filter(Label == "Taxi") %>% mutate(Lat_Long = paste(Lat, Lon, sep = ",")) %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n = 50, wt =count) 

#uber_top
uber_top <- uber_top_locations %>% left_join(uber_locations_full, by = "Lat_Long") %>% distinct(Lat_Long, .keep_all = TRUE) %>% top_n(n = 50, wt = count)

#taxi_top
taxi_top <- taxi_top_locations %>% left_join(taxi_locations_full, by = "Lat_Long") %>% distinct(Lat_Long, .keep_all = TRUE) #%>% top_n(n = 50, wt = count)
taxi_top <- taxi_top[order(-taxi_top$count),]
taxi_top <- taxi_top[1:50,]

#top_uber_taxi
top_uber_taxi <- rbind(uber_top, taxi_top)


#######################################Burrow Map ########################################################################################################################Top 50 grouped by Month
burrows2 <- burrows %>% mutate(Lat_Long= paste(Lat,Lon, sep= ","))
#top_50 <- burrows2 %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
#burrows_top_50 <- top_50 %>% left_join(burrows2, by = "Lat_Long") %>% distinct(Lat_Long, .keep_all = TRUE) %>% top_n(n = 50, wt = count)
top_april <- burrows2 %>% filter(Month == "April") %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
top_may <- burrows2 %>% filter(Month == "May") %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
top_june <- burrows2 %>% filter(Month == "June") %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
top_june <- burrows2 %>% filter(Month == "July") %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
top_july <- burrows2 %>% filter(Month == "August") %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
top_august <- burrows2 %>% filter(Month == "September") %>% group_by(Lat_Long) %>% summarise(count = n()) %>% top_n(n=50, wt=count)
top_all <- rbind(top_april,top_may,top_june,top_july,top_august)
burrows_top_50 <- top_all %>% left_join(burrows2, by = "Lat_Long") %>%  distinct(Lat_Long, .keep_all = TRUE) %>% top_n(n = 50, wt = count)
burrows_top_50$Month <- as.factor(burrows_top_50$Month)
order = c('April', 'May', 'June', 'July', 'August', 'September')
burrows_top_50$Month <- factor(burrows_top_50$Month, levels=order)



####################################################SERVER.R########################################################
shinyServer(function(input, output, session) {

    
##############################Tab 1 Uber By Burrow#########################################
   output$burrow <- renderPlotly({
     if(input$uberburrow == "Burrow Bar Chart"){
       month<- burrows %>% group_by(Month) %>% summarise(count = n())
       burrow_month<- burrows %>% group_by(Month, Burrow) %>% summarise(count = n())
       
       data<- left_join(burrow_month, month, by = 'Month')
       data<- data %>% mutate(Percent = (count.x/count.y)*100)
       
       xform <- list(categoryorder = "array", categoryarray = c("April", "May", "June", "July", "August", "September"))
       
       fig <- plot_ly(data, x = ~Month, y = ~count.x, color = ~Burrow, colors = c("#B29DD9","#FDFD98", "#FE6B64", "#77DD77", "#779ECB"), type = 'bar') %>% layout(width= 800, height=400, yaxis = list(title = 'Count'), xaxis = xform, barmode = 'group', title = "Uber Counts by Month and Burrow")
     }
     
     
     
     
     if(input$uberburrow =="Top Locations Map"){
       mapboxToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ'
       Sys.setenv("MAPBOX_TOKEN" = mapboxToken)
       top_50_map <-  burrows_top_50 %>% plot_mapbox(lat= ~Lat, lon= ~Lon,
                                                     mode='scattermapbox', opacity=0.8, size=~count, frame = ~Month, sizeref=0.5) #marker=list( sizeref=3))
       top_50_map <- top_50_map %>% layout(title='Top 50 pickup locations in NYC', height=600,
                                           mapbox = list(zoom=10,
                                                         center= list(lat = 40.7426,
                                                                      lon = -73.9831),
                                                         style = 'outdoors'
                                           ))
       top_50_map <- top_50_map %>% config(mapboxAccessToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ')
       #fig <- fig %>% animation_opts(redraw=TRUE)
       fig <- top_50_map
     }
     
     
     
     if(input$uberburrow == "Burrow by Day"){
       plotly.burrow <- burrow_by_day2 %>% group_by(day,Burrow) %>% summarise(count = n()) %>% ungroup()
       burrow.by.day <- plot_ly(plotly.burrow, x=~day, y=~count, type='bar', split=~Burrow, color = ~Burrow, colors = c("#B29DD9","#FDFD98", "#FE6B64", "#77DD77", "#779ECB"))
       burrow.by.day <- burrow.by.day %>% layout(title ="Burrow Count By Day",barmode= 'stack',yaxis = list(title = 'Count'), xaxis = list(title = "Day"))
       fig <- burrow.by.day
       
     }
     if(input$uberburrow == "Burrow by Hour"){
       plotly.hour <-  burrow_by_hour %>% group_by(hour,Burrow) %>% summarise(count = n()) %>% ungroup()
       burrow.by.hour <- plot_ly(plotly.hour, x=~hour, y=~count, type='bar', split=~Burrow, color = ~Burrow, colors = c("#B29DD9","#FDFD98", "#FE6B64", "#77DD77", "#779ECB"))
       burrow.by.hour <- burrow.by.hour %>% layout(title = "Burrow Count By Hour",barmode= 'stack', yaxis = list(title = 'Count'), xaxis = list(title = 'Hour'))
       fig <- burrow.by.hour
     }
     if(input$uberburrow == "Top Locations Table"){
       df <- read_csv('https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/burrow_add_df.csv')
       df <- as.data.frame(df)
       
       fig <- plot_ly(
         type = 'table',
         columnwidth = c(125,30,30,15),
         columnorder = c(0,1,2,3),
         header = list(
           values = c("Address", "Burrow", "Month","Count"),
           align = c("left", "left", "left", "left"),
           line = list(width = 1, color = 'black'),
           fill = list(color = c("#FE6B64", "#FE6B64","#FE6B64","#FE6B64")),
           font = list(family = "Arial", size = 14, color = "white")
         ),
         cells = list(
           values = rbind(df[,1], df[,2], df[,3], df[,4]),
           align = c("left", "left", "left", "left"),
           list = list(color = "black", width = 1),
           font = list(family = "Arial", size = 12, color = c("black"))
         )
       )
     }
     fig
   })
   

##############################Tab 3 Uber vs Taxi#########################################   
   output$taxiUber <- renderPlotly({
     if (input$taxi =="Ride Distribution Chart"){
       data<- rides[-130001,]
       fig <- plot_ly(data, type = 'violin') %>% 
         add_trace(x = ~Day[data$Label == 'Uber'], y = ~Time[data$Label == 'Uber'], 
                   legendgroup = 'Uber', scalegroup = 'Uber', name = 'Uber', box = list(visible = T), 
                   meanline = list(visible = T), color = I("#779ECB")) %>% 
         add_trace(x = ~Day[data$Label == 'Taxi'], y = ~Time[data$Label == 'Taxi'],
                   legendgroup = 'Taxi', scalegroup = 'Taxi', name = 'Taxi', box = list(visible = T), 
                   meanline = list(visible = T), color = I("#77DD77")) %>% 
         layout(title = "Ride Distribution By Day", 
                yaxis = list(zeroline = F, title = "Time"), 
                xaxis = list(title = "Day", categoryorder = "array", 
                             categoryarray = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")), 
                violinmode = 'group')
     }
     
     if(input$taxi == "Top Locations Map"){
       mapboxToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ'
       
       Sys.setenv("MAPBOX_TOKEN" = mapboxToken)
       
       fig <-  top_uber_taxi %>% plot_mapbox(lat= ~Lat, lon= ~Lon, split=~Label,color = ~ Label, colors = c("#77DD77", "#779ECB"),
                                              mode='scattermapbox', opacity=0.7, size=~count, sizeref=0.5) #marker=list( sizeref=3))
       
       fig <- fig %>% layout(title='Top 50 Pick-up Locations Uber vs Taxi', height=600,
                               mapbox = list(zoom=10,
                                             center= list(lat = 40.7426,
                                                          lon = -73.9831),
                                             style = 'outdoors'
                               ))
       
       fig <- fig %>% config(mapboxAccessToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ')
       
       
     }

     if(input$taxi == "Top Uber Table"){
       df <- read_csv('https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/uber_add_df.csv') 
       df <- as.data.frame(df)
       
       fig <- plot_ly(
         type = 'table',
         columnwidth = c(125,15),
         columnorder = c(0,1),
         header = list(
           values = c("Address", "Count"),
           align = c("left", "left"),
           line = list(width = 1, color = 'black'),
           fill = list(color = c("#779ECB","779ECB")),
           font = list(family = "Arial", size = 14, color = "white")
         ),
         cells = list(
           values = rbind(df[,1], df[,2]),
           align = c("left", "left"),
           list = list(color = "black", width = 1),
           font = list(family = "Arial", size = 12, color = c("black"))
         )
       )
     }
     if(input$taxi == "Top Taxi Table"){
       df <- read_csv('https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/taxi_add_df.csv')
       df <- as.data.frame(df)
       
       fig <- plot_ly(
         type = 'table',
         columnwidth = c(125,15),
         columnorder = c(0,1),
         header = list(
           values = c("Address","Count"),
           align = c("left", "left"),
           line = list(width = 1, color = 'black'),
           fill = list(color = c("#77DD77", "#77DD77")),
           font = list(family = "Arial", size = 14, color = "white")
         ),
         cells = list(
           values = rbind(df[,1], df[,2]),
           align = c("left", "left"),
           list = list(color = "black", width = 1),
           font = list(family = "Arial", size = 12, color = c("black"))
         )
       )
     }
     fig
     
   })

   
   
   
##############################Tab 2 Holidays in NYC#########################################  
  output$WhichPlot <- renderPlotly({
    if(input$graph == "Holiday Line Graph"){
      data %>% group_by(Label) %>% summarise(count = n())
      data_plot<- data %>% group_by(Label, Time) %>% summarise(count = n())
      nycpride<- subset(data_plot, Label == "NYC Pride" & Time > 0)
      stpatricks<- subset(data_plot, Label == "St. Patrick's Day")
      fourthjuly<- subset(data_plot, Label == "Fourth of July")
       
      a <- nycpride[which.max(nycpride$count), ]
      b <- stpatricks[which.max(stpatricks$count), ]
      c <- fourthjuly[which.max(fourthjuly$count), ]
       
      point_a <- list(x = a$Time, y = a$count, text = "3pm", xref = "x", yref = "y", showarrow = TRUE, arrowhead = 7, ax = 20, ay = -40)
      point_b <- list(x = b$Time, y = b$count, text = "9pm", xref = "x", yref = "y", showarrow = TRUE, arrowhead = 7, ax = 20, ay = -40)
      point_c <- list(x = c$Time, y = c$count, text = "10pm", xref = "x", yref = "y", showarrow = TRUE, arrowhead = 7, ax = 20, ay = -40)
       
      fig <- plot_ly(data_plot, x = ~Time, y = ~count, color = ~Label, 
                     mode = 'lines+markers', colors = c("#779ECB","#B29DD9","#77DD77")) %>% 
        layout(title = "Uber Counts By Time of Day and Holiday",
               yaxis = list(title = "Uber Counts"), 
               annotations = list(point_a, point_b, point_c))
    }
     
     
     if (input$graph == "Holiday Pick-up Map"){

       mapboxToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ'

       Sys.setenv("MAPBOX_TOKEN" = mapboxToken)

       fig <- holiday %>% plot_mapbox(lat= ~Lat, lon= ~Lon, split= ~Label, frame=~Time,color = ~ Label, colors = c("#779ECB","#B29DD9","#77DD77"),
                                      mode='scattermapbox', opacity=0.5, marker=list(size=5))
       fig <- fig %>% layout(title='Holidays in NYC', height=600,
                             mapbox = list(zoom=10,
                                           center= list(lat = 40.7426,
                                                        lon = -73.9831)
                             ))

       fig <- fig %>% config(mapboxAccessToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ')
       fig <- fig %>% animation_opts(redraw=TRUE)
       
     }

     if (input$graph == "Independence Day Pick-ups"){
       df <- read_csv('https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/fourthjuly_add_df.csv')
       df <- as.data.frame(df)

       fig <- plot_ly(
         type = 'table',
         columnwidth = c(125, 15,15),
         columnorder = c(0,1,2),
         header = list(
           values = c("Address", "Time","Count"),
           align = c("left", "left", "left"),
           line = list(width = 1, color = 'black'),
           fill = list(color = c("779ECB", "779ECB","779ECB")),
           font = list(family = "Arial", size = 14, color = "white")
         ),
         cells = list(
           values = rbind(df[,1], df[,2], df[,3]),
           align = c("left", "left", "left"),
           list = list(color = "black", width = 1),
           font = list(family = "Arial", size = 12, color = c("black"))
         )
       )
     }


     if (input$graph == "Pride Day Pick-ups"){
       df <- read_csv('https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/nycpride_add_df.csv')
       df <- as.data.frame(df)
    
       fig <- plot_ly(
         type = 'table',
         columnwidth = c(125, 15,15),
         columnorder = c(0,1,2),
         header = list(
           values = c("Address", "Time","Count"),
           align = c("left", "left", "left"),
           line = list(width = 1, color = 'black'),
           fill = list(color = c("#B29DD9","#B29DD9","#B29DD9")),
           font = list(family = "Arial", size = 14, color = "white")
         ),
         cells = list(
           values = rbind(df[,1], df[,2], df[,3]),
           align = c("left", "left", "left"),
           list = list(color = "black", width = 1),
           font = list(family = "Arial", size = 12, color = c("black"))
         )
       )
     }
   fig
  })
})