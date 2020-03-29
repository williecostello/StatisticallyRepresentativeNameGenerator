library(shiny)
library(shinythemes)

shinyUI(fluidPage(

    theme = shinytheme("lumen"),
    
    titlePanel("The Statistically Representative Name Generator"),

    sidebarLayout(
        
        sidebarPanel(
            h4("Generate a name with..."),
            sliderInput("year",
                        "Year of birth:",
                        min = 1880,
                        max = 2018,
                        step = 1,
                        value = 1986),
            radioButtons("sexchoice", "Birth sex:", 
                         c("Female" = "female ", 
                           "Male" = "male ",
                           "Either" = ""),
                         selected = ""),
            sliderInput("bounds", "Popularity range:",
                        min = 0,
                        max = 100,
                        value = c(0, 100))
        ),
    
        mainPanel(
            tabsetPanel(type = "tabs",

                tabPanel("App",
                         h3("Your randomly generated name is..."),
                         textOutput("outputtext"),
                ),
                
                tabPanel("Documentation",
                         h3("Instructions for use"),
                         p("The Statistically Representative Name Generator 
                           generates a random name based on three adjustable 
                           variables: the person's year of birth, their birth 
                           sex, and the relative popularity of their name in 
                           their birth year."),
                         p("To use this application, simply set the parameters
                           as desired using the sidebar panel."),
                         p(strong("Year of birth "), "can be set to any year 
                           between 1880 and 2018."),
                         p(strong("Birth sex "), "can be set to either female, 
                           male, or either."),
                         p(strong("Popularity range "), "can be set to anywhere 
                           within a range of 0 to 100. A lower range will generate 
                           rarer names; a higher range will generate more 
                           popular one. If the full range is selected, a name 
                           will be generated from the complete set of data from 
                           that year."),
                         p("Names are generated using the ",
                           a("Baby Names from Social Security Card Applications dataset", href = "https://catalog.data.gov/dataset/baby-names-from-social-security-card-applications-national-level-data"),
                           " released by ",
                           a("Data.gov", href = "http://www.data.gov/"), 
                           " (last updated: November 27, 2019)."),
                )
                
            )
        )
        
    )
))
