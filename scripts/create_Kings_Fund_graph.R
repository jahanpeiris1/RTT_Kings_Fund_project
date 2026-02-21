# for entries that were previously 52+, in x92nd_percentile_weeks,
# these are now stored as 52.00000

# load relevant packages
library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(janitor)

##### FORMAT DATA #####

raw <- read_excel(
  "data_raw/RTT-Overview.xlsx",
    sheet = "Full Time Series",
  col_names = FALSE
)

# chop excess rows/columns and put headers in first row
raw <- raw[-(1:9),-(25:44)]
raw[2, 1:2] <- raw[1, 1:2]
raw <- raw[-1,]
raw <- raw[-(227:241),]

# clean and set column names
headers <- raw[1,]
headers <- gsub(">", "greater", headers)
colnames(raw) <- make_clean_names(headers)

# remove early rows with no data
raw <- raw[-(1:5), ]

# manually fix the February 2024 entry
raw[199,2] <- "45323"

# ensure data is numeric (precautionary) and NA inserted appropriately
numeric_cols <- setdiff(names(raw), c("year", "month"))
raw[numeric_cols] <- lapply(raw[numeric_cols], function(x) {
  x <- trimws(x)              # remove any spaces
  x[x == "-"] <- NA           # only standalone dashes become NA
  x <- gsub("\\+", "", x)     # remove + symbol
  as.numeric(x) 
})

# convert month column to human readable date
raw <- raw %>%
  mutate(
    month = as.Date(as.numeric(month), origin = "1899-12-30")
  )

# find the most recent month that the standard was met 
threshold_met <- raw %>%
  filter(no_within_18_weeks_with_estimates_for_missing_data / 
           total_waiting_mil_with_estimates_for_missing_data > 0.92)
last_met_month <- max(threshold_met$month, na.rm = TRUE)

###### PLOT DATA ######

ggplot(raw, aes(x = month,
                y = no_within_18_weeks_with_estimates_for_missing_data)) +
  geom_col(aes(fill = "Patients waiting <18 weeks")
           ) +
  geom_rect(aes(xmin = as.Date("2020-02-01"), xmax = as.Date("2022-03-01"),
                ymin = -Inf, ymax = Inf),
            fill = "darkorchid1", alpha = 0.002
            ) +
  annotate("text",
           x = as.Date("2021-02-01"),
           y = 7.8e6,
           label = "Covid-19",
           color = "black",
           size = 5) +
  geom_line(aes(y = total_waiting_mil_with_estimates_for_missing_data,
                colour = "Total waiting list"),
            size = 1
            ) +
    geom_line(aes(y = 0.92 * total_waiting_mil_with_estimates_for_missing_data,
                colour = "92% of waiting list",
                linetype = "92% of waiting list"),
            size = 1
            ) +
    geom_vline(xintercept = last_met_month,
             linetype = "dashed",
             color = "black",
             size = 0.8
             ) +
  annotate("text",
           x = last_met_month - 2000,
           y = 7.5e6,
           label = "Last time standard was met",
           hjust = 0, vjust = 0.5, size = 5
           ) +
  labs(title = "Patients waiting less than 18 weeks per month",
       x = "",
       y = ""
       ) +
  scale_x_date(date_labels = "%b-%y",
               date_breaks = "6 months",
               expand = c(0,0)
               ) +
  scale_y_continuous(labels = comma,
                     limits = c(0,8e6),
                     breaks = seq(0, 8e6, by = 1e6),
                     expand = expansion(mult = c(0, 0))
                     ) +
    scale_fill_manual(name = "",
    values = c("Patients waiting <18 weeks" = "#006d2c")
  ) +
  scale_colour_manual(name = "",
    values = c("Total waiting list" = "black",
               "92% of waiting list" = "darkorchid2")
  ) +
  scale_linetype_manual(name = "",
    values = c("92% of waiting list" = "11")
  ) +
  guides(fill = guide_legend(
      override.aes = list(linetype = 0, shape = NA),
      order = 1
    ),
    colour = guide_legend(
      override.aes = list(fill = NA),
      order = 2
    ),
    linetype = "none"
  ) +
  theme_minimal() +
  theme(legend.position = "top",
    panel.grid.minor  = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 18),
    legend.text = element_text(size = 12)
  )

ggsave(
  filename = "outputs/kings_fund_recreation.png",  
  plot = last_plot(),                          
  width = 10,                                  
  height = 5,                                 
  dpi = 600                                    
)





