# install_packages.R
if (!require("remotes")) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

# Set timeout to be longer
options(timeout = 300)

# Try to install with more detailed error reporting
tryCatch({
  remotes::install_github("tidyverse/ellmer", 
                          force = TRUE, 
                          upgrade = "never",
                          quiet = FALSE,
                          verbose = TRUE)
}, error = function(e) {
  message("Error installing elmer: ", e$message)
  print(sessionInfo())
})