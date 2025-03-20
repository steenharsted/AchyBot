library(shiny)
library(shinychat)
library(bslib)
library(here)
library(ellmer)
library(stringr)

start_prompts <- list.files(here("prompts", "start"), pattern = ".md$")
person_prompts <- list.files(here("prompts", "person"), pattern = ".md$")
diagnosis_prompts <- list.files(here("prompts", "diagnosis"), pattern = ".md$")


ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "cosmo"),
  
  titlePanel("Den Kiropraktiske Undersøgelse"),
  
  layout_column_wrap(
    width = "800px",
    card(
      card_header(
        h4("Velkommen til den kiropraktiske undersøgelse!"), 
        h6(
          tags$i("Steen Flammild Harsted & Søren O'Neill"),
          style = "text-align: right; font-style: italic;"),
        br(),
      p(
        "Du står over for en ny patient i din kiropraktiske klinik. ",
        "Patienten er en kvinde på 65 år, der søger hjælp til sine helbredsproblemer."
      ),
      hr(),
      p(
        strong("Dine opgaver:"),
        tags$ul(
          tags$li("Optag en grundig anamnese."),
          tags$li("Planlæg og beskriv relevante kliniske tests."),
          tags$li("Vurdér testresultater og stil en mulig diagnose.")
        ),
        br(),
        em("Tag dig god tid og brug din viden som kiropraktor til at hjælpe patienten.")
      )
    )
  ),
  
  layout_column_wrap(
    width = "100%",
    chat_ui("chat")
  )
))

server <- function(input, output, session) {
  chat <- ellmer::chat_openai(
    model = "gpt-4o-mini",
    system_prompt = str_glue(
      interpolate_file(here("prompts", "start", start_prompts)), "  ",
      interpolate_file(here("prompts", "person", person_prompts)), "  ",
      interpolate_file(here("prompts", "diagnosis", diagnosis_prompts))
      )
  )
  
  observeEvent(input$chat_user_input, {
    stream <- chat$chat_async(input$chat_user_input)
    shinychat::chat_append("chat", stream)
  })
}

shinyApp(ui = ui, server = server)