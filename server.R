library(shiny)
library(data.table)
library(dplyr)

shinyServer(function(input, output) {

    ## Generate data
    datar <- reactive({
        
        ## Grab input variables
        year <- input$year
        sexchoice <- input$sexchoice
        include_us <- input$from_us
        include_on <- input$from_on
        include_bc <- input$from_bc
        
        ## Perform various validation tests
        validate(
            need((include_us | include_on | include_bc) == TRUE, 
                 "Please select at least one region.")
        )
        
        if (include_on == TRUE) {
            validate(
                need(year >= 1917 & year <= 2016, 
                     "Ontario data available only between 1917 and 2016; please select a different year.")
            )
        }
        
        if (include_bc == TRUE) {
            validate(
                need(year >= 1919 & year <= 2018, 
                     "British Columbia data available only between 1919 and 2018; please select a different year.")
            )
        }

        ## Grab US data, if selected
        if (include_us == TRUE) {
            file <- paste("data/US/", year, ".csv", sep = "")
            data_us <- fread(file)
        } else {
            data_us <- data.table(name = character(), sex = character(), 
                                  num_us = numeric())
        }
        
        ## Grab ON data, if selected
        if (include_on == TRUE) {
            file <- paste("data/ON/", year, ".csv", sep = "")
            data_on <- fread(file)
        } else {
            data_on <- data.table(name = character(), sex = character(), 
                                  num_on = numeric())
        }
        
        ## Grab BC data, if selected
        if (include_bc == TRUE) {
            file <- paste("data/BC/", year, ".csv", sep = "")
            data_bc <- fread(file)
        } else {
            data_bc <- data.table(name = character(), sex = character(), 
                                  num_bc = numeric())
        }
        
        ## Merge & sum data
        rawdata <- merge(data_us, data_on, all = TRUE)
        rawdata <- merge(rawdata, data_bc, all = TRUE)
        rawdata[is.na(rawdata)] <- 0
        rawdata[, num := num_us + num_on + num_bc]
        rawdata <- rawdata %>% arrange(desc(num)) %>% select(name, sex, num)
        
        ## Filter data by sex
        if (sexchoice == "male ") {
            data <- rawdata %>% filter(sex == "M") %>% select(name, num)
        } else if (sexchoice == "female ") {
            data <- rawdata %>% filter(sex == "F") %>% select(name, num)
        } else {
            data <- rawdata %>% select(name, num)
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
