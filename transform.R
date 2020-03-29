library(data.table)
library(dplyr)
library(stringr)

################################################################################
## U.S. Data
################################################################################

## Transform from .txt to .csv
for (i in 1880:2018) {
        readpath <- paste("data/raw/USA/yob", i, ".txt", sep = "")
        data <- fread(readpath, header = FALSE, 
                         col.names = c("name", "sex", "num_us"))
        data <- data %>% arrange(desc(num))
        writepath <- paste("data/US/", i, ".csv", sep = "")
        fwrite(data, writepath, row.names = FALSE)
}

################################################################################
## Ontario Data
################################################################################

## Read data
file_ON_f <- "data/raw/ON/ontario_top_baby_names_female_1917-2016_english.csv"
data_ON_f <- fread(file_ON_f, header = TRUE, skip = 1, 
                      col.names = c("year", "name", "num_on"))
file_ON_m <- "data/raw/ON/ontario_top_baby_names_male_1917-2016_english.csv"
data_ON_m <- fread(file_ON_m, header = TRUE, skip = 1,
                         col.names = c("year", "name", "num_on"))

## Combine & restructure data
data_ON_f <- data_ON_f %>% mutate(sex = "F")
data_ON_m <- data_ON_m %>% mutate(sex = "M")
data_ON <- rbind(data_ON_f, data_ON_m)
data_ON <- data_ON %>% arrange(desc(num_on)) %>% 
        select(name, sex, num_on, year)
data_ON[, 1] <- str_to_sentence(data_ON[, 1])

## Write tables for each year
for (i in 1917:2016) {
        filepath <- paste("data/ON/", i, ".csv", sep = "")
        data <- data_ON %>% filter(year == i) %>% select(-year)
        fwrite(data, file = filepath, row.names = FALSE)
}
