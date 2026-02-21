# RTT PROJECT

This project cleans raw RTT XLSX files, processes it, and creates plots.

## Overview
- 'scripts/' contains all scripts for data cleaning and plotting.
- 'data_raw/' contains the original raw data.
- 'data_processed/' contains two subfolders:
  a) 'monthly_clean/', which stores cleaned monthly xlsx files
  and
  b) 'monthly_totals', which stores summaries of the cleaned monthly xlsx files
- 'outputs/' contains generated plots


## Project Workflow
1. Run clean_monthly_data.R. This will create 12 cleaned files, which are
  stored in 'data_processed/monthly_clean/'.
  
2. Run regional_summarise_monthly_data.R. This will create 12 cleaned summary
  files, which are stored in 'data_processed/monthly_totals'.
  
3. To generate Figure 1 in the accompanying report, 
  run create_Kings_Fund_graph.R. This creates an output file 
  'outputs/kings_fund_recreation.png'
  
4. To generate Figure 2 in the accompanying report, run create_choropleth.R.
  This creates an output file 'outputs/choropleth.png'.
  
5. To generate Figure 3 in the accompanying report, run create_ridgelines.R.
  This creates an output file 'outputs/distributions.png'.
  
6. To generate Figure 4 in the accompanying report, please run both
  create_52week_comparison.R and create_regional_comparison_over_2025.R.
  Figure 4 is a combination of the plots created by these two scripts, and so
  to create the graph, copy the following to the console:
  
  combined <- p1 + p2
  ggsave(
    filename = "outputs/combined_time_series.png",  
    plot = last_plot(),                          
    width = 10,                                  
    height = 12,                                 
    dpi = 600                                    
  )
  
  
## Descriptions of all script files
1. month_clean_function.R:
    Helper function to read in the raw data and remove redundant rows/columns
    
2. regional_summary_function.R:
    Helper function to read in data from 'data_processed/monthly_clean' and
    collapse rows with constant treatment type to obtain a monthly regional
    summary
    
3. clean_monthly_data.R
    Applies the month_clean_function.R to all files in 'data_raw' and creates
    new cleaned files in 'data_processed/monthly_clean'.
    
4. regional_summarise_monthly_data.R
  Applies the regional_summary_function.R to all files in 
  'data_processed/monthly_clean' and creates new summary files in
  'data_processed/monthly_totals'.

5. create_Kings_Fund_graph.R
    Reads in RTT-Overview.xlsx, cleans it and produces a recreation of the
    King's Fund graph (Note, this script is non-standard in that it contains
    both cleaning and graphing code. This is because the raw data is distinct
    from the monthly regional data that is later used).
    
6. create_choropleth.R.
  Reads in the December 2025 summary file, and creates the Figure 2 (choropleth
  map).
  
  
7. create_ridglines.R
  Reads in the cleaned December 2025 file, and creates Figure 3 (distributions
  of waiting times by region).
  
8. create_52week_comparison.R
  Reads in the monthly summary files for 2025, and creates panel (A) in 
  Figure 4.

9. create_regional_comparison_over_2025.R
  Reads in the monthly summary files for 2025, and creates panel (B) in 
  Figure 4.

## Additional notes
Raw data was obtained from:
https://www.england.nhs.uk/statistics/statistical-work-areas/rtt-waiting-times/

We select the 'Incomplete Comissioner Data', and renamed files in the format
RTT_YYYY_MM, such that YYYY and MM record the appropriate year and month.

AI was used as an aid in debugging, and to suggest more compact ways of writing
code.

For any further questions, contact jahanpeiris1@gmail.com
