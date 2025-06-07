library(shiny)
library(shinychat)
library(shinybusy)
library(bslib)
library(here)
library(ellmer)  
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
        p("Når du vil udføre objektive undersøgelser, skriver du f.eks. 'Jeg laver SBT'. Der vil komme de objektive fund, som du finder i undersøgelsen."),
        p("Når du er kommet frem til diagnosen, så skriver du: 'Diagnosen er xx..'"), 
        p("Når du har fundet frem til den rigtige diagnose, skal du genindlæse siden for at starte en ny case."),
        p(strong("Du starter konsultationen ved at præsentere dig selv, f.eks.")),
        p(strong("'Hej jeg hedder xx og jeg er din behandler i dag, hvad er dit navn og cpr?'"))
      )
    ), 
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
  
  # Initialize chat when app starts
  observe({
    # Only run once at app initialization
    isolate({
      if (is.null(rv$chat)) {
        new_prompt <- generate_prompt_text()
        rv$chat <- ellmer::chat_openai(
          model = "gpt-4o",  # Default model
          system_prompt = new_prompt
        )
      }
    })
  })
  
  # Update chat when start button is clicked
  observeEvent(input$start_chat, {
    # Generate a new prompt for a new case
    new_prompt <- generate_prompt_text()
    
    # Create a new chat instance
    rv$chat <- ellmer::chat_openai(
      model = input$model,
      system_prompt = new_prompt
    )
    
    # Clear the chat history
    shinychat::chat_reset("chat")
    
    # Increment the chat_id to trigger a UI refresh
    rv$chat_id <- rv$chat_id + 1
  })
  
  # Handle user messages with proper error catching
  observeEvent(input$chat_user_input, {
    req(rv$chat)
    
    # Use tryCatch to handle potential errors
    tryCatch({
      # Start a busy indicator
      shinybusy::show_modal_spinner(spin = "cube-grid", text = "Thinking...")
      
      # Get chat response
      stream <- rv$chat$chat_async(input$chat_user_input)
      shinychat::chat_append("chat", stream)
      
      # Hide the busy indicator when done
      shinybusy::remove_modal_spinner()
    }, error = function(e) {
      # Handle error
      shinybusy::remove_modal_spinner()
      shinychat::chat_append("chat", 
                             paste("An error occurred: ", e$message, 
                                   "\nPlease try again or start a new case."))
    })
  })
}

shinyApp(ui = ui, server = server)