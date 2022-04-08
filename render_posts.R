# This scripts renders the post with correct name format

# load packages
library(tidyverse)
library(rmarkdown)
library(here)

# define the date of the post
post_date <- format(lubridate::ymd("2022-03-13"),"%Y-%m-%d")  # This is the date of publication



# Render the appropriate post rmarkdown
# point this to the correct directory

render(
  here(
    
    # change this to correct folder and specify file name
    "web-scraping-in-R",                 
    "Web scraping using R.Rmd"
  ),
  # outputs into docs/_posts as .html files
  output_dir =  here(
    "docs", "_posts"
  ),
  output_file = paste0(post_date, "-Web scraping using R")
)