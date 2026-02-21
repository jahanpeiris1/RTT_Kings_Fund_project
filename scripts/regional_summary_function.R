# Function to create a summary of regional performance
# Requires the input function already be a cleaned monthly function
# Adds columns to store 'total under 18 weeks' and 'percent under 18 weeks'

# load relevant packages
library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)
library(dplyr)
library(writexl)

regional_summary_file <- function(input_path, output_path) {
  
  # read in excel file
  df <- read_excel(input_path)
  df <- df %>% 
    filter(grepl("Total", treatment_function))
  
  # add total_under18 and pct_under18 columns to the summary
  week_bins <- grep("^greater", names(df), value = TRUE)
  df <- df %>%
    rowwise() %>%
    mutate(
      total_under18 = sum(c_across(all_of(week_bins[1:18]))),
      pct_under18 = 100 * total_under18 / total_number_of_incomplete_pathways_with_a_decision_to_admit_for_treatment
    ) %>%
    ungroup()
  
  write_xlsx(df, output_path)
  
  return(invisible(NULL))
  
}