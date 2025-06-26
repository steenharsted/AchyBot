# libaries
library(shiny)
library(shinychat)
library(bslib)
library(here)
library(ellmer)
library(stringr)
library(fontawesome)
library(shinybusy)
library(stringr)

# List files
start_prompts <- list.files(here("prompts", "start"), pattern = ".md$", recursive = TRUE) 
person_prompts <- list.files(here("prompts", "person"), pattern = ".md$", recursive = TRUE) 
diagnosis_prompts <- list.files(here("prompts", "diagnosis"), pattern = ".md$", recursive = TRUE) 

generate_prompt_text <- function(){
  # Make full paths to the files
  start_path <- here("prompts", "start", sample(start_prompts, 1))
  person_path <- here("prompts", "person", sample(person_prompts,1))
  diagnosis_path <- here("prompts", "diagnosis", sample(diagnosis_prompts,1))
  
  # Combine the text with spacing
  str_glue(
    "{ellmer::interpolate_file(start_path)}  ",
    "{ellmer::interpolate_file(person_path)}  ",
    "{ellmer::interpolate_file(diagnosis_path)} "
  )
} 