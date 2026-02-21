# Percent of patients waiting less than 18 Weeks - Dec 2025 (with DTA)

# load relevant packages
library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)
library(dplyr)
library(purrr)
library(tools)
library(writexl)
library(RColorBrewer)

# read in the monthly summary files
Jan_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-01_clean_summary.xlsx",
)
Feb_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-02_clean_summary.xlsx",
)
Mar_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-03_clean_summary.xlsx",
)
Apr_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-04_clean_summary.xlsx",
)
May_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-05_clean_summary.xlsx",
)
Jun_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-06_clean_summary.xlsx",
)
Jul_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-07_clean_summary.xlsx",
)
Aug_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-08_clean_summary.xlsx",
)
Sep_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-09_clean_summary.xlsx",
)
Oct_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-10_clean_summary.xlsx",
)
Nov_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-11_clean_summary.xlsx",
)
Dec_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-12_clean_summary.xlsx",
)

# combine monthly data into one data frame
monthly_data <- bind_rows(
  Jan_2025_summary %>% mutate(month = "Jan"),
  Feb_2025_summary %>% mutate(month = "Feb"),
  Mar_2025_summary %>% mutate(month = "Mar"),
  Apr_2025_summary %>% mutate(month = "Apr"),
  May_2025_summary %>% mutate(month = "May"),
  Jun_2025_summary %>% mutate(month = "Jun"),
  Jul_2025_summary %>% mutate(month = "Jul"),
  Aug_2025_summary %>% mutate(month = "Aug"),
  Sep_2025_summary %>% mutate(month = "Sep"),
  Oct_2025_summary %>% mutate(month = "Oct"),
  Nov_2025_summary %>% mutate(month = "Nov"),
  Dec_2025_summary %>% mutate(month = "Dec")
)

# ensure months appear in correct order
monthly_data$month <- factor(
  monthly_data$month,
  levels = c("Jan","Feb","Mar","Apr","May","Jun",
             "Jul","Aug","Sep","Oct","Nov","Dec")
)

# ensure regions appear in a specific order (for clearer graphs)
monthly_data$region_name <- factor(
  monthly_data$region_name, 
  levels = c(
    "SOUTH WEST COMMISSIONING REGION",
    "NHS ENGLAND",
    "NORTH EAST AND YORKSHIRE COMMISSIONING REGION",
    "LONDON COMMISSIONING REGION",
    "SOUTH EAST COMMISSIONING REGION",
    "MIDLANDS COMMISSIONING REGION",
    "NORTH WEST COMMISSIONING REGION",
    "EAST OF ENGLAND COMMISSIONING REGION")
)

# exclude the NHS ENGLAND region
monthly_data_no_nhs <- monthly_data %>%
  filter(region_name != "NHS ENGLAND")

##### GRAPH DATA #####
p2 <- ggplot(monthly_data_no_nhs,
       aes(x = month,
           y = pct_under18,
           group = region_name,
           colour = region_name)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "(B)",
    x = "Month",
    y = "Percent",
    colour = "Region"
  ) +
  geom_smooth(
    method = "lm",      
    se = FALSE,         
    linetype = "11",
    size = 0.8
  ) +
  scale_colour_brewer(palette = "Paired",
                      labels = c("South West",
                                 "North East and Yorkshire",
                                 "London",
                                 "South East",
                                 "Midlands",
                                 "North West",
                                 "East England"))+
  scale_y_continuous(breaks = seq(0, 100, by = 1))+
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)
  )

