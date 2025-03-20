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
  
  titlePanel("AchyBot"),
  
  layout_column_wrap(
    width = "800px",
    card(
      card_header(
        h4("Velkommen til den kiropraktiske undersøgelse!"), 
        h6(
          tags$i("Steen Flammild Harsted & Søren O'Neill"),
          style = "text-align: right; font-style: italic;")
      ),
      card_body(
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
    )
  ),
  
  # Add dropdown selection cards
  layout_column_wrap(
    width = "800px",
    card(
      card_header("Vælg Prompter"),
      card_body(
        layout_column_wrap(
          width = 1/3,
          selectInput("start_prompt", "Start Prompt:", 
                      choices = start_prompts, 
                      selected = start_prompts[1]),
          selectInput("person_prompt", "Person Prompt:", 
                      choices = person_prompts, 
                      selected = person_prompts[1]),
          selectInput("diagnosis_prompt", "Diagnose Prompt:", 
                      choices = diagnosis_prompts, 
                      selected = diagnosis_prompts[1])
        ),
        actionButton("update_chat", "Tryk her før din skriver i chatten første gang", class = "btn-primary mt-3")
      )
    )
  ),
  
  layout_column_wrap(
    width = "100%",
    chat_ui("chat")
  )
)

server <- function(input, output, session) {
  # Reactive values to store the current chat instance
  rv <- reactiveValues(chat = NULL)
  
  # Initialize chat when app starts or when prompted
  create_chat <- function() {
    ellmer::chat_openai(
      model = "gpt-4o-mini",
      system_prompt = str_glue(
        interpolate_file(here("prompts", "start", input$start_prompt)), "  ",
        interpolate_file(here("prompts", "person", input$person_prompt)), "  ",
        interpolate_file(here("prompts", "diagnosis", input$diagnosis_prompt))
      )
    )
  }
  
  # Initialize chat on startup
  # observe({
  #   req(input$start_prompt, input$person_prompt, input$diagnosis_prompt)
  #   if (is.null(rv$chat)) {
  #     rv$chat <- create_chat()
  #   }
  # })
  
  # Update chat when button is clicked
  observeEvent(input$update_chat, {
    rv$chat <- create_chat()
    # Increment the chat_id to trigger a UI refresh
    rv$chat_id <- rv$chat_id + 1
  })
  
  observeEvent(input$chat_user_input, {
    req(rv$chat)
    stream <- rv$chat$chat_async(input$chat_user_input)
    shinychat::chat_append("chat", stream)
  })
}

shinyApp(ui = ui, server = server)
