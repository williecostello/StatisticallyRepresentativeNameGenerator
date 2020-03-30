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

################################################################################
## B.C. Data
################################################################################

## Read data
file_BC_f <- "data/raw/BC/bc-popular-girls-names.csv"
data_BC_f <- fread(file_BC_f, header = TRUE)
file_BC_m <- "data/raw/BC/bc-popular-boys-names.csv"
data_BC_m <- fread(file_BC_m, header = TRUE)

## Combine & restructure data
data_BC_f <- data_BC_f[-1, ]
setnames(data_BC_f, "Name", "name")
data_BC_m <- data_BC_m[-1, ]
setnames(data_BC_m, "Name", "name")
data_BC_f <- data_BC_f %>% mutate(sex = "F")
data_BC_m <- data_BC_m %>% mutate(sex = "M")
## data_ON <- data_ON %>% arrange(desc(num_on)) %>% select(name, sex, num_on, year)
data_BC_f[, 1] <- str_to_sentence(data_BC_f[, 1])
data_BC_m[, 1] <- str_to_sentence(data_BC_m[, 1])

## Write tables for each year
for (i in 1919:2018) {
        filepath <- paste("data/BC/", i, ".csv", sep = "")
        data_f <- data_BC_f %>% select(name, sex, num_bc = as.character(i))
        data_m <- data_BC_m %>% select(name, sex, num_bc = as.character(i))
        data_f <- data_f[data_f$num_bc != 0, ]
        data_m <- data_m[data_m$num_bc != 0, ]
        data <- rbind(data_f, data_m)
        data$num_bc <- as.numeric(data$num_bc)
        data <- data %>% arrange(desc(num_bc))
        fwrite(data, file = filepath, row.names = FALSE)
}