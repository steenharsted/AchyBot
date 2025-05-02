library(shiny)
library(shinychat)
library(bslib)
library(here)
library(ellmer)
library(stringr)

# List files
start_prompts <- list.files(here("prompts", "start"), pattern = ".md$", recursive = TRUE) 
person_prompts <- list.files(here("prompts", "person"), pattern = ".md$", recursive = TRUE) 
diagnosis_prompts <- list.files(here("prompts", "diagnosis"), pattern = ".md$", recursive = TRUE) 
#feedback_prompts <- list.files(here("prompts", "feedback"), pattern = ".md$", recursive = TRUE) 

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

prompt <- generate_prompt_text()
prompt

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
      .prompt-preview {
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 0.25rem;
        padding: 1rem;
        margin-bottom: 1rem;
        max-height: 200px;
        overflow-y: auto;
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
          "Dette redskab er tilegnet kiropraktorstuderende, der ønsker at træne anamneseoptagelse, dertilhørende relevante objektive undersøgelser og diagnostisk tankegang. Derudover kan det bruges til at øve udarbejdelse af journaler."),
        p("Du står overfor en ny patient i din kiropraktiske klinik. Patienten har fået en diagnose og en personlighed, der afspejler en patient, du vil kunne møde i klinisk praksis."),
        p("Du skal optage en fokuseret anamnese og lave en fokuseret objektiv undersøgelse for at komme frem til diagnosen."),
        p("Håndter patienten som du ville gøre i praksis. Husk at man I praksis har begrænset tid til anamnese og objektive undersøgelser. Det er ikke muligt at lave parakliniske undersøgelser."),
        p("Når du vil udføre objektive undersøgelser, skriver du f.eks. “Jeg laver SBT”. Der vil komme de objektive fund, som du finder i undersøgelsen."),
        p("Du starter konsultationen ved at præsentere dig selv: “Hej jeg hedder xx og jeg er din behandler i dag, hvad er dit navn og cpr?”"),
        p("Når du er kommet frem til diagnosen, så skriver du: “Diagnosen er xx..”"), 
        p("Når du har fundet frem til den rigtige diagnose, skal du genindlæse siden for at starte en ny case."
        )
      )
    ), 
    # card(
    #   max_height = "600px",
    #   card_header(tags$div("Vælg Prompter", class = "small-font")),
    #   card_body(
    #     layout_column_wrap(
    #       width = 1/5,
    #       tags$div(
    #         selectInput("start_prompt", "Start Prompt:",
    #                     choices = start_prompts,
    #                     selected = start_prompts[1]),
    #         class = "tiny-font"
    #       ),
    #       tags$div(
    #         selectInput("person_prompt", "Person Prompt:",
    #                     choices = person_prompts,
    #                     selected = person_prompts[1]),
    #         class = "tiny-font"
    #       ),
    #       tags$div(
    #         selectInput("diagnosis_prompt", "Diagnose Prompt:",
    #                     choices = diagnosis_prompts,
    #                     selected = diagnosis_prompts[1]),
    #         class = "tiny-font"
    #       ),
    #       tags$div(
    #         selectInput("model", "Model:",
    #                     choices = c("gpt-4o", "gpt-4o-mini", "o3-mini-2025-01-31"),
    #                     selected = "gpt-4o"),
    #         class = "tiny-font"
    #       ),
    #       tags$div(
    #         selectInput("feedback_prompt", "Feedback:",
    #                     choices = c(feedback_prompts),
    #                     selected = feedback_prompts[1]),
    #         class = "tiny-font"
    #       )
    #     ),
    #     # Card to display the combined text
    #     card(
    #       max_height = "300px",
    #       card_header("System Prompt Preview"),
    #       card_body(
    #         div(
    #           verbatimTextOutput("combined_text"),
    #           class = "prompt-preview"
    #         )
    #       )
    #     ),
    #     tags$div(
    #       actionButton("update_chat", "Tryk her før din skriver i chatten første gang",
    #                    class = "btn-primary mt-3")
    #     )
    #   )
    #)
  ),
  
  layout_column_wrap(
    width = "100%",
    chat_ui("chat", 
            placeholder = "Patienten sidder foran dig...")
  )
)

server <- function(input, output, session) {
  # Reactive values to store the current chat instance
  rv <- reactiveValues(chat = NULL, chat_id = 0)
  
  # Function to generate the combined prompt text
  # generate_prompt_text <- reactive({
  #   # Make full paths to the files
  #   start_path <- here("prompts", "start", input$start_prompt)
  #   person_path <- here("prompts", "person", input$person_prompt)
  #   diagnosis_path <- here("prompts", "diagnosis", input$diagnosis_prompt)
  #   feedback_path <- here("prompts", "feedback", input$feedback_prompt)
  #   
  #   # Combine the text with spacing
  #   str_glue(
  #     "{ellmer::interpolate_file(start_path)}  ",
  #     "{ellmer::interpolate_file(person_path)}  ",
  #     "{ellmer::interpolate_file(diagnosis_path)} ",
  #     "{ellmer::interpolate_file(feedback_path)}"
  #   )
  # })
  
  # # Output for combined text
  # output$combined_text <- renderText({
  #   generate_prompt_text()
  # })
  
  # Initialize chat when app starts or when prompted
  create_chat <- function() {
    ellmer::chat_openai(
      model = input$model,
      system_prompt = prompt
    )
  }
  
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