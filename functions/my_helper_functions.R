# This function takes an Rmd file and folder name
# Compiles a blog post and store sit in _post folder

build_blogPost <- function(date = NULL,
                           folder_name = NULL,
                           rmd_full_name= NULL,
                           post_name = NULL){
  
  # define the date of the post
  post_date <- format(lubridate::ymd(date),"%Y-%m-%d")  # This is the date of publication
  
  # Render the appropriate post rmarkdown
  # point this to the correct directory
  rmarkdown::render(
    here::here(
      # change this to correct folder and specify file name
      folder_name,                 
      rmd_full_name
    ),
    # outputs into docs/_posts as .html files
    output_dir =  here::here(
      "docs", "_posts"
    ),
    output_file = paste0(post_date, "-", post_name) # The name should not contain spaces
  )
  
  
}