library(shiny)
library(dplyr)

shinyServer(function(input, output) {

    ## Generate data
    datar <- reactive({
        
        ## Grab input variables
        place <- input$place
        year <- input$year
        sexchoice <- input$sexchoice
        
        ## Grab relevant dataset
        file <- paste("data/", place, "/", year, ".csv", sep = "")
        rawdata <- read.csv(file, header = TRUE)
        
        ## Filter data by sex
        if (sexchoice == "male ") {
            data <- rawdata %>% filter(sex == "M")
        } else if (sexchoice == "female ") {
            data <- rawdata %>% filter(sex == "F")
        } else {
            data <- rawdata %>% arrange(desc(num))
        }
        
        data
    })
    

    ## Generate random number
    randor <- reactive({
        data <- datar()
        numsum <- sum(data$num)
        bounds <- input$bounds
        upper <- ifelse(bounds[1] == 0, numsum, numsum * (1 - (bounds[1] *.01)))
        lower <- ifelse(bounds[2] == 100, 1, numsum * (1 - (bounds[2] * .01)))
        sample(lower:upper, 1)
    })
    
    ## Generate random name    
    namer <- reactive({
        
        ## Set relevant global variables
        data <- datar()
        random <- randor()
        lowct <- 0
        highct <- 0
        
        ## Find where random number falls within dataset
        for (i in 1:nrow(data)) {
            highct <- lowct + data$num[i]
            if (lowct < random & random <= highct) {
                name <- data$name[i]
                rep <- data$num[i]
                pop <- i
            }
            lowct <- highct
        }
        
        ## Calculate rarity of generated name
        rarity <- (rep / sum(data$num)) * 100
        
        ## Print output message
        paste(name, "! ", 
              "This was the #", pop, " most popular ", input$sexchoice, 
              "baby name in ", input$year, ". There were ", (rep - 1), 
              " other babies born with this name in that year, representing ", 
              signif(rarity, 3), "% of the total population of ", 
              input$sexchoice, "babies.", sep = "")
    })

    ## Generate output message
    output$outputtext <- renderText({namer()})

})
