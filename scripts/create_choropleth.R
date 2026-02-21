library(sf)
library(dplyr)
library(ggplot2)
library(viridis)
library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)
library(dplyr)
library(purrr)
library(tools)
library(writexl)
library(ggtext)
library(shadowtext)


# finds the time-bin containing median observation,
# and returns the midpoint of that time-bin
median_wait_from_bins <- function(row_counts, col_names) {
  
  # ensure values are numeric
  counts <- as.numeric(row_counts)
  
  # compute total patients
  total <- sum(counts, na.rm = TRUE)
  
  # find the halfway point
  cum_counts <- cumsum(counts)
  half_total <- total / 2
  
  # find which bin contains the median
  idx <- which(cum_counts >= half_total)[1]
  
  # get the median bin name
  bin_name <- col_names[idx]
  
  # extract the numbers from the bin name
  if(str_detect(bin_name, "_")) {
    nums <- str_extract_all(bin_name, "\\d+")[[1]]
    midpoint <- mean(as.numeric(nums))
  } else {
    midpoint <- as.numeric(str_extract(bin_name, "\\d+"))
  }
  return(midpoint)
  
}

# read in the geojson file
geojson_path <- "data_raw/NHS_England_Regions.geojson"
nhs_regions <- st_read(geojson_path)

# read in the Dec_2025 summary file
Dec_2025_summary <- read_excel(
  "data_processed/monthly_totals/RTT_2025-12_clean_summary.xlsx",
)

# create nicer naming for region names, and store
# in same order that data appears so that the percents 
# correspond
regions <- c("London",
             "South West",
             "South East",
             "Midlands",
             "East of England",
             "North West",
             "North East and Yorkshire")
percent <- Dec_2025_summary$pct_under18[2:8]


# find median wait time for each region, making sure
# to exclude NHS ENGLAND
wait_cols <- names(Dec_2025_summary) %>% 
  keep(~ str_starts(.x, "greater"))
Dec_2025_summary <- Dec_2025_summary %>%
  rowwise() %>%
  mutate(
    median_wait_time = median_wait_from_bins(
      c_across(all_of(wait_cols)),
      wait_cols
    )
  ) %>%
  ungroup()
medians <- Dec_2025_summary$median_wait_time[2:8]

# reorder regions in nhs_regions to match our order in the regions vector
nhs_regions <- nhs_regions[match(regions, nhs_regions$NHSER24NM), ]

# find centres and adjust certain labels
centroids <- st_point_on_surface(nhs_regions)
labels_df <- centroids %>%
  mutate(
    median_wait = medians,
    coords = st_coordinates(geometry),
    x = coords[,1],  
    y = coords[,2]
  )
labels_df$x[1] <- labels_df$x[1] + 5000  
labels_df$y[1] <- labels_df$y[1] + 6000


##### GRAPH DATA #####
ggplot(nhs_regions) +
  geom_sf(aes(fill = percent), color = "white", size = 0.3
          ) +
  geom_shadowtext(
    data = labels_df,
    aes(x = x, y = y, label = round(median_wait, 1), colour = percent),
    size = 4.4,
    colour = "black",
    bg.colour = "white",  
    fontface = "bold",
    bg.r = 0.2,           
  ) +
    scale_fill_gradient(low = "#006d2c", high = "#e5f5e0") +

  theme_minimal() +
  labs(
    title = "Percent of patients waiting less than 18 weeks by region - Dec 2025 (with DTA)", 
    fill = "Percent", 
    x = NULL, 
    y = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(size = 18),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14)
  )

ggsave(
  filename = "outputs/choropleth.png",  
  plot = last_plot(),                          
  width = 10,                                  
  height = 12,                                 
  dpi = 600                                    
)




