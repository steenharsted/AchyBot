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

# Set devmode 
dev_mode <- reactiveVal(FALSE)  # default = user mode




# List files
start_prompts <- list.files(here("prompts", "start"), pattern = ".md$", recursive = TRUE) 
person_prompts <- list.files(here("prompts", "person"), pattern = ".md$", recursive = TRUE) 
diagnosis_prompts <- list.files(here("prompts", "diagnosis"), pattern = ".md$", recursive = TRUE) 
feedback_prompts <- list.files(here("prompts", "feedback"), pattern = ".md$", recursive = TRUE) 


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


generate_prompt_text_dev <- function(start_choice, person_choice, diagnosis_choice) {
  start_path <- here("prompts", "start", start_choice)
  person_path <- here("prompts", "person", person_choice)
  diagnosis_path <- here("prompts", "diagnosis", diagnosis_choice)
  
  str_glue(
    "{ellmer::interpolate_file(start_path)}  ",
    "{ellmer::interpolate_file(person_path)}  ",
    "{ellmer::interpolate_file(diagnosis_path)} "
  )
}



# modules
source("modules/prompt_selector.R")


