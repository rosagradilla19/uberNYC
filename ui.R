
library(shiny)
library(plotly)
library(lubridate)
library(dplyr)


# Define UI for application that draws a histogram
shinyUI(navbarPage(title = "NYC Uber",
               tabPanel("About",
                        div(img(src="https://raw.githubusercontent.com/jmhobbs29/uberNYC/master/skyline2.png", height = "25%", width="50%"), 
                            style="text-align: center;"), 
                        column(12, 
                               align='center', 
                               strong(p("City of New York", style = "font-family: 'arial'; font-size: 48px")))),
               tabPanel("Holidays in NYC", 
                        #column(12, align='center', strong(p("Uber During Holidays in NYC", style = "font-family: 'arial'; font-size: 28px"))), 
                        br(), 
                        br(), 
                        plotlyOutput('holidays'), 
                        br()),
               tabPanel("Uber by Burrow", 
                        div(plotlyOutput('burrow'),align ='center'), 
                        br(), 
                        plotlyOutput('burrowmap')),
               tabPanel("Taxi vs Uber", 
                        plotlyOutput("taxi"))
          )
)
