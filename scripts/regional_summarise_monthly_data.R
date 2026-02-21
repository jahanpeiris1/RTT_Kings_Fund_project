# Applies regional_summary_function to every cleaned monthly file
# stores cleaned monthly summary files in 'data_processed/monthly_totals'


library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)
library(dplyr)
library(purrr)
library(tools)
library(writexl)

source("scripts/regional_summary_function.R")

monthly_files <- list.files(
  "data_processed/monthly_clean",
  full.names = TRUE
)

summarised_files <- file.path(
  "data_processed/monthly_totals",
  paste0(
    file_path_sans_ext(basename(raw_files)),
    "_clean_summary.xlsx"
  )
)

map2(monthly_files, 
     summarised_files, 
     regional_summary_file)
