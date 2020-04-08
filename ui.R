library(shiny)
library(plotly)
library(lubridate)
library(dplyr)


# Define UI for application that draws a histogram
shinyUI(
  navbarPage(
    title = "NYC Uber",
                   tabPanel("About",
                            div(img(src="https://raw.githubusercontent.com/jmhobbs29/uberNYC/master/skyline2.png", height = "25%", width="50%"), 
                                style="text-align: center;"), 
                            column(12, 
                                   align='center', 
                                   strong(p("City of New York", style = "font-family: 'arial'; font-size: 48px"))),
                            div(column(3, img(src="Jeeda.jpg", height="60%", width="60%")),style="text-align: center;"),
                            div(column(3, img(src="Rosa.jpg", height="60%", width="60%")),style="text-align: center;"),
                            div(column(3, img(src="jamie.jpg", height="60%", width="60%")),style="text-align: center;"),
                            div(column(3, img(src="Olivia.jpg", height="60%", width="60%")),style="text-align: center;"),
                            column(3, align='center', p("Jeeda AbuKhader", style = "font-family: 'arial'; font-size:16px")),
                            column(3, align='center', p("Rosa Gradilla", style = "font-family: 'arial'; font-size:16px")),
                            column(3, align='center', p("Jamie Hobbs", style = "font-family: 'arial'; font-size:16px")),
                            column(3, align='center', p("Olivia Roberts", style = "font-family: 'arial'; font-size:16px")),
                            p("Purpose:", style = "font-family: 'arial'; font-size:24px"),
                            p("As consultants, we have been hired by the City of New York to gather, analysis and present findings on ride share services, such as Uber.  This analysis is intended to influence regulation and planning boards alike by understanding patterns of activity within the 2014 historical data of Uber pick-up locations. ", style = "font-family: 'arial'; font-size:18px"),
                            p("Focus Areas:", style = "font-family: 'arial'; font-size:24px"),
                            p("In our scope of work on the consulation, we were given the following questions to answer from our research:", style = "font-family: 'arial'; font-size:18px"),
                            column(12, align="center", p("1. How does the frequency of rides change throughout the year? Per burrow?", style = "font-family: 'arial'; font-size:18px")),
                            column(12, align="center", p("2. What does a given holiday look like for the ride share company?", style = "font-family: 'arial'; font-size:18px")),
                            column(12, align="center", p("3. What does an 'Average' Day look like in NYC in regards to the ride share company and taxi services?", style = "font-family: 'arial'; font-size:18px"))),
                    
                   
                   
                   tabPanel("Uber by Burrow", 
                            sidebarLayout(
                              sidebarPanel(
                                radioButtons("uberburrow", "Select Visualization", choices =c("Burrow Bar Chart", "Top Locations Map", "Burrow by Day", "Burrow by Hour", "Top Locations Table"))
                              ),
                            mainPanel(
                              plotlyOutput('burrow')
                            )
                   )),

                   
                   tabPanel("Holidays in NYC", 
                            sidebarLayout(
                              sidebarPanel(
                                radioButtons("graph", "Select Visualization", choices = c("Holiday Line Graph", "Holiday Pick-up Map", "Independence Day Pick-ups", "Pride Day Pick-ups"), selected = "Holiday Line Graph")),
                                #radioButtons("table", "Select Visualization",choices =c("Independence Day Pick-ups", "Pride Day Pick-ups"))),
                             mainPanel(
                              plotlyOutput("WhichPlot")
                             )
                             )
                   ),
                   tabPanel("Taxi vs Uber",
                            sidebarLayout(
                              sidebarPanel(
                                radioButtons("taxi", "Select Visualization", choices = c("Ride Distribution Chart", "Top Locations Map", "Top Uber Table", "Top Taxi Table"))
                              ),
                              mainPanel(
                                plotlyOutput("taxiUber")
                              )
               
                            )
                  )
                            
                           
                   
)
)

