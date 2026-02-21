# Applies clean_month_function to every raw file and
# stores cleaned monthly files in 'data_processed/monthly_clean'

library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)
library(dplyr)
library(purrr)
library(tools)
library(writexl)

source("scripts/month_clean_function.R")

# obtain list of raw file names
raw_files <- list.files(
  "data_raw",
  pattern = "^RTT_[0-9]{4}-[0-9]{2}\\.xlsx$",
  full.names = TRUE
)

# create list of clean file names
processed_files <- file.path(
  "data_processed/monthly_clean",
  paste0(
    file_path_sans_ext(basename(raw_files)),
    "_clean.xlsx"
  )
)

# apply clean_month_file to every raw file
map2(raw_files, 
     processed_files, 
     clean_month_file, 
     "Region with DTA")
