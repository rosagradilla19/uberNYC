library(readr)
library(tidyverse)
library(plotly)
library(leaflet)
library(lubridate)
library(forcats)

stpatricks<- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/stpatricks.csv")
fourthjuly<- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/fourthjuly.csv")
nycpride <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/nycpride.csv")
burrows <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/burrows.csv")
rides <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/rides.csv")
holiday <- read_csv("https://raw.githubusercontent.com/rosagradilla19/uberNYC/master/mergedholiday.csv")

nycpride<- nycpride[,c("Time", "Label")]
fourthjuly<- fourthjuly[,c("Time", "Label")]
stpatricks<- stpatricks[,c("Time", "Label")]
data<- rbind(nycpride, fourthjuly, stpatricks)

shinyServer(function(input, output, session) {

##############################Tab 1 Holidays in NYC#########################################  
    output$holidays <- renderPlotly({
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
       
        plot_ly(data_plot, x = ~Time, y = ~count, color = ~Label, mode = 'lines+markers', colors = c("#879BAF", "#c28285", "#2e8b57")) %>% layout(title = "Uber Counts By Time of Day and Holiday", yaxis = list(title = "Uber Counts"), annotations = list(point_a, point_b, point_c))
       })
    
    output$holidaysmap <- renderPlotly({
       
       mapboxToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ'
       
       Sys.setenv("MAPBOX_TOKEN" = mapboxToken)
       
       fig <- holiday %>% plot_mapbox(lat= ~Lat, lon= ~Lon, split= ~Label, frame=~Time,
                                      mode='scattermapbox', opacity=0.5, marker=list(size=5))
       fig <- fig %>% layout(title='Holidays in NYC', height=600,
                             mapbox = list(zoom=10,
                                           center= list(lat = 40.7426,
                                                        lon = -73.9831)
                             ))
       
       fig <- fig %>% config(mapboxAccessToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ')
       fig <- fig %>% animation_opts(redraw=TRUE)
       fig
       })
   
##############################Tab 2 Uber By Burrow#########################################
   output$burrow <- renderPlotly({
       month<- burrows %>% group_by(Month) %>% summarise(count = n())
       burrow_month<- burrows %>% group_by(Month, Burrow) %>% summarise(count = n())
       
       data<- left_join(burrow_month, month, by = 'Month')
       data<- data %>% mutate(Percent = (count.x/count.y)*100)
       
       xform <- list(categoryorder = "array", categoryarray = c("April", "May", "June", "July", "August", "September"))
       
       plot_ly(data, x = ~Month, y = ~count.x, color = ~Burrow, type = 'bar') %>% layout(width= 800, height=400, yaxis = list(title = 'Count'), xaxis = xform, barmode = 'group', title = "Uber Counts by Month and Burrow")
   })
   
   output$burrowmap <- renderPlotly({
      
      m <- as.factor(burrows$Month)
      order = c('April', 'May', 'June', 'July', 'August', 'September')
      m <- factor(m, levels=order)
      
      mapboxToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ'
      Sys.setenv("MAPBOX_TOKEN" = mapboxToken)
      fig <- burrows %>% plot_mapbox(lat= ~Lat, lon= ~Lon, split= ~Burrow, frame = ~m,
                                     size=1, opacity=0.5, marker=list(size=3),
                                     mode='scattermapbox')
      fig <- fig %>% layout(title='Uber Pickup Locations', height = 600,
                            mapbox = list(zoom=10,
                                          center= list(lat = median(burrows$Lat),
                                                       lon = median(burrows$Lon))
                            ))
      fig <- fig %>% config(mapboxAccessToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ')
      fig <- fig %>% animation_opts(redraw=TRUE)
      fig
   })

##############################Tab 3 Uber vs Taxi#########################################   
   output$taxi <- renderPlotly({
       data<- rides[-130001,]
       plot_ly(data, type = 'violin') %>% 
           add_trace(x = ~Day[data$Label == 'Uber'], y = ~Time[data$Label == 'Uber'], legendgroup = 'Uber', scalegroup = 'Uber', name = 'Uber', box = list(visible = T), meanline = list(visible = T), color = I("#807aa5")) %>% 
           add_trace(x = ~Day[data$Label == 'Taxi'], y = ~Time[data$Label == 'Taxi'], legendgroup = 'Taxi', scalegroup = 'Taxi', name = 'Taxi', box = list(visible = T), meanline = list(visible = T), color = I("#2e8b57")) %>% 
           layout(title = "Ride Distribution By Day", yaxis = list(zeroline = F, title = "Time"), xaxis = list(title = "Day", categoryorder = "array", categoryarray = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")), violinmode = 'group')
   })
   
   output$taximap <- renderPlotly({
      
      mapboxToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ'
      Sys.setenv("MAPBOX_TOKEN" = mapboxToken)
      fig <- rides %>% plot_mapbox(lat= ~Lat, lon= ~Lon, split= ~Label, frame = ~Time,
                                     size=1, opacity=0.5, marker=list(size=3),
                                     mode='scattermapbox')
      fig <- fig %>% layout(title='Taxi vs Uber', height = 600,
                            mapbox = list(zoom=10,
                                          center= list(lat = 40.7426,
                                                       lon = -73.9831)
                            ))
      fig <- fig %>% config(mapboxAccessToken = 'pk.eyJ1Ijoicm9zYWdyYWRpbGxhIiwiYSI6ImNrN25wb21mZTAxMG4zcHQzam1qaTF5MTYifQ.OHXhzQkkdmT9aH3A8-5ftQ')
      fig <- fig %>% animation_opts(redraw=TRUE)
      fig
   })
   
   
})
