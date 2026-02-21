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
library(lubridate)

# read in the cleaned Dec 2025 xlsx file
Dec_2025 <- read_excel(
  "data_processed/monthly_clean/RTT_2025-12_clean.xlsx"
)

# specify the regions we want to plot (excludes NHS COMMISSIONING REGION)
regions_to_plot <- c(
  "LONDON COMMISSIONING REGION",
  "SOUTH WEST COMMISSIONING REGION",
  "SOUTH EAST COMMISSIONING REGION",
  "MIDLANDS COMMISSIONING REGION",
  "EAST OF ENGLAND COMMISSIONING REGION",
  "NORTH WEST COMMISSIONING REGION",
  "NORTH EAST AND YORKSHIRE COMMISSIONING REGION"
)

# prepare data for plotting distributions 
all_regions_dist <- Dec_2025 %>%
  
  # exclude NHS ENGLAND
  filter(region_name %in% regions_to_plot) %>%
  
  # keep waiting-time columns + region
  select(region_name, starts_with("greater")) %>%
  
  # pivot to long format
  pivot_longer(
    cols = starts_with("greater"),
    names_to = "waiting_bin",
    values_to = "patients"
  ) %>%
  
  # ensures one row per region per waiting-time bin
  group_by(region_name, waiting_bin) %>%
  summarise(patients = sum(patients), .groups = "drop") %>%
  
  # extract bin starting week
  mutate(
    bin_start = case_when(
      waiting_bin == "greater104" ~ 104,
      TRUE ~ as.numeric(str_extract(waiting_bin, "(?<=greater)\\d+(?=_)"))
    )
  ) %>%
  
  # sort data
  arrange(region_name, bin_start) %>%
  
  # create axis labels
  mutate(
    waiting_label = case_when(
      waiting_bin == "greater104" ~ "104+ weeks",
      TRUE ~ paste0(bin_start, "–", bin_start + 1)
    )
  )

# lock factor ordering globally so every facet uses same (chronological) 
# x-axis order
waiting_levels <- all_regions_dist %>%
  distinct(bin_start, waiting_label) %>%
  arrange(bin_start) %>%
  pull(waiting_label)

# convert waiting_label into an ordered factor for plotting
all_regions_dist$waiting_label <- factor(
  all_regions_dist$waiting_label,
  levels = waiting_levels
)

# compute median waiting-time for bin (both numeric and label versions)
median_data <- all_regions_dist %>%
  # split data by region
  group_by(region_name) %>%
  # order bins to ensure cumsum is calculated chronologically
  arrange(bin_start) %>%
  # calculate median
  mutate(
    cumulative_patients = cumsum(patients),
    half_total = sum(patients) / 2
  ) %>%
  # keep only rows where cumsum reaches or exceeds halfway
  filter(cumulative_patients >= half_total) %>%
  # pick the first row that meets the halfway condition
  slice(1) %>%
  ungroup() %>%
  # keep only essential columns
  select(region_name, median_bin = bin_start, median_label = waiting_label) %>%
  # reorder regions for plotting by descending median
  mutate(region_name = fct_reorder(region_name, median_bin, .desc = TRUE))


# reorder region factor by descending median
all_regions_dist <- all_regions_dist %>%
  left_join(median_data %>% select(region_name, median_bin), by = "region_name") %>%
  mutate(region_name = fct_reorder(region_name, median_bin, .desc = TRUE))


# create plotting data with filtered bins to
# chop off near-zero data on the tails
plot_data <- all_regions_dist %>% filter(bin_start <= 75)
plot_medians <- median_data

new_labels <- c(
  "LONDON COMMISSIONING REGION" = "London",
  "SOUTH WEST COMMISSIONING REGION" = "South West",
  "SOUTH EAST COMMISSIONING REGION" = "South East",
  "MIDLANDS COMMISSIONING REGION" = "Midlands",
  "EAST OF ENGLAND COMMISSIONING REGION" = "East of England",
  "NORTH WEST COMMISSIONING REGION" = "North West",
  "NORTH EAST AND YORKSHIRE COMMISSIONING REGION" = "North East and Yorkshire"
)

##### GRAPH DATA #####
ggplot(plot_data, aes(x = waiting_label, y = patients, fill = bin_start)) +
  geom_col() +
  geom_vline(
    data = plot_medians,
    aes(xintercept = median_label),
    colour = "red",
    linetype = "11",
    linewidth = 0.8
  ) +
  scale_fill_gradient(low = "#006d2c", high = "darkorchid2"
  ) +
  facet_wrap(~region_name, ncol = 1, labeller = as_labeller(new_labels)) +
  scale_x_discrete(limits = x_limits,
                   breaks = waiting_levels[seq(1, length(waiting_levels), by = 2)]) +
  labs(
    title = "Waiting time distribution by region — Dec 2025 (with DTA)",
    x = "Waiting time (weeks)",
    y = "Number of Patients"
  ) +
  theme_minimal() +
  guides(fill = "none") +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 12),
    axis.text.y = element_text(size = 10),
    strip.text = element_text(size = 10),
    plot.title = element_text(size = 18)
  )

ggsave(
  filename = "outputs/distributions.png",  
  plot = last_plot(),                          
  width = 10,                                  
  height = 12,                                 
  dpi = 600                                    
)
