# cleans a monthly function by removing redundant rows and columns,
# and ensures data that should be numeric is numeric.
# Stores output in data_processed/monthly_clean

# load relevant packages
library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)
library(dplyr)
library(writexl)


clean_month_file <- function(input_path, output_path, whichsheet) {
  
  # read in excel file
  df <- read_excel(input_path,
                   sheet = whichsheet,
                   col_names = FALSE)
  
  # remove irrelevant rows/columns and set column names appropriately
  df <- df[-(1:12),]
  df <- df[,-c(1,3)]
  headers <- df[1,]
  headers <- gsub(">", "greater", headers)
  colnames(df) <- make_clean_names(headers)
  df <- df %>% 
    rename(greater104 = x104_plus)
  df <- df[-1,] 


  # (preventative) make sure data is numeric and insert NA appropriately
  numeric_cols <- setdiff(names(df), 
                          c("region_name",
                            "treatment_function"))
  df[numeric_cols] <- lapply(df[numeric_cols], function(x) {
    x <- trimws(x)              
    x[x == "-"] <- NA 
    as.numeric(x) 
  })
  
  write_xlsx(df, output_path)
  
  return(invisible(NULL))
  
}