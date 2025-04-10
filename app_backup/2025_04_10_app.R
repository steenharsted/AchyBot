library(shiny)
library(shinychat)
library(bslib)
library(here)
library(ellmer)
library(stringr)

start_prompts <- list.files(here("prompts", "start"), pattern = ".md$", recursive = TRUE) 
person_prompts <- list.files(here("prompts", "person"), pattern = ".md$", recursive = TRUE) 
diagnosis_prompts <- list.files(here("prompts", "diagnosis"), pattern = ".md$", recursive = TRUE) 
feedback_prompts <- list.files(here("prompts", "feedback"), pattern = ".md$", recursive = TRUE) 


ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "cosmo"),
  
  # Add custom CSS
  tags$head(
    tags$style(HTML("
      .small-font {
        font-size: 0.85rem !important;
      }
      .tiny-font {
        font-size: 0.75rem !important;
      }
      .small-font .selectize-input,
      .small-font .selectize-dropdown,
      .small-font label,
      .small-font .btn,
      .tiny-font .selectize-input,
      .tiny-font .selectize-dropdown,
      .tiny-font label {
        font-size: inherit !important;
      }
    "))
  ),
  
  titlePanel("AchyBot"),
  
  layout_column_wrap(
    width = "800px",
    card(
      card_header(
        h4("Velkommen til den kiropraktiske undersøgelse!"), 
        h6(
          tags$i("Steen Flammild Harsted, Henrik Hein Lauridsen & Søren O'Neill"),
          style = "text-align: right; font-style: italic;"),
        h6(
          tags$i("Magnus Mortensen & Martin Sand Jensen"),
          style = "text-align: right; font-style: italic;"),
      ),
      card_body(
        p(
          "Du står over for en ny patient i din kiropraktiske klinik. "
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
    card(
      max_height = "250px",
      card_header(tags$div("Vælg Prompter", class = "small-font")),
      card_body(
        layout_column_wrap(
          width = 1/5,
          tags$div(
            selectInput("start_prompt", "Start Prompt:",
                        choices = start_prompts,
                        selected = start_prompts[1]),
            class = "tiny-font"
          ),
          tags$div(
            selectInput("person_prompt", "Person Prompt:",
                        choices = person_prompts,
                        selected = person_prompts[1]),
            class = "tiny-font"
          ),
          tags$div(
            selectInput("diagnosis_prompt", "Diagnose Prompt:",
                        choices = diagnosis_prompts,
                        selected = diagnosis_prompts[1]),
            class = "tiny-font"
          ),
          tags$div(
            selectInput("model", "Model:",
                        choices = c("gpt-4o", "gpt-4o-mini", "o3-mini-2025-01-31"),
                        selected = "gpt-4o"),
            class = "tiny-font"
          ),
          tags$div(
            selectInput("feedback_prompt", "Feedback:",
                        choices = c(feedback_prompts),
                        selected = feedback_prompts[1]),
            class = "tiny-font"
          )
        ),
        tags$div(
          actionButton("update_chat", "Tryk her før din skriver i chatten første gang",
                       class = "btn-primary mt-3")
        )
      )
    )
  ),
  
  layout_column_wrap(
    width = "100%",
    # p("TO DO.. Info om patienten baseret på hvilken person der er valgt."),
    # p("e.g. du ser en ældre kvinde bla bla... evt med et billede"),
    # p("iconet på chatbotten skal ændres efter person"),
    chat_ui("chat", 
            placeholder = "Patienten sidder foran dig...")
  )
)
server <- function(input, output, session) {
  # Reactive values to store the current chat instance
  rv <- reactiveValues(chat = NULL)
  
  # Output for combined text
  output$combined_text <- renderText({
    str_glue(
      interpolate_file(here("prompts", "start", input$start_prompt)), "  ",
      interpolate_file(here("prompts", "person", input$person_prompt)), "  ",
      interpolate_file(here("prompts", "diagnosis", input$diagnosis_prompt)), " ",
      interpolate_file(here("prompts", "feedback", input$feedback_prompt))
    )
  })
  
  # Initialize chat when app starts or when prompted
  create_chat <- function() {
    ellmer::chat_openai(
      model = input$model,
      system_prompt = str_glue(
        interpolate_file(here("prompts", "start", input$start_prompt)), "  ",
        interpolate_file(here("prompts", "person", input$person_prompt)), "  ",
        interpolate_file(here("prompts", "diagnosis", input$diagnosis_prompt)), " ",
        interpolate_file(here("prompts", "feedback", input$feedback_prompt))
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
