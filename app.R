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


ui <- page_fluid(
  
  # Modern theme with improved colors
  theme = bs_theme(
    version = 5, 
    bootswatch = "flatly",
    primary = "#5b99b6",
    success = "#ff944b",
    info = "#0d1f29",
    danger = "#ed3421"
  ),
  
  # Custom CSS for styling
  tags$head(
    tags$style(HTML("
      /* Core styling */
      body { background-color: #5b99b6; }
      
      .card {
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        border-radius: 0.5rem;
        transition: all 0.3s ease;
        border: none;
      }
      
      .card:hover {
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
      }
      
      .card-header {
        border-bottom: 2px solid rgba(44, 62, 80, 0.1);
        background-color: white;
        padding: 1rem 1.5rem;
      }
      
      .card-body { padding: 1.5rem; }
      
      /* Font utilities */
      .small-font { font-size: 0.85rem !important; }
      .tiny-font { font-size: 0.75rem !important; }
      
      .small-font .selectize-input,
      .small-font .selectize-dropdown,
      .small-font label,
      .small-font .btn,
      .tiny-font .selectize-input,
      .tiny-font .selectize-dropdown,
      .tiny-font label {
        font-size: inherit !important;
      }
      
      /* App header styling */
      .app-title {
        color: #0d1f29;
        padding: 1.5rem 0;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .app-title h1 {
        margin: 0;
        font-weight: 700;
        margin-left: 10px;
      }
      
      /* Button styling */
      .btn-primary {
        font-weight: 600;
        padding: 0.6rem 1.5rem;
        border-radius: 50px;
        transition: all 0.3s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
      }
      
      .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
      }
      
      /* Chat message styling */
      .chat-message-user {
        background-color: #e9f5fd;
        border-radius: 18px 18px 0 18px;
        padding: 12px 15px;
        margin-bottom: 15px;
        border-left: 4px solid #3498db;
      }
      
      .chat-message-bot {
        background-color: #f8f9fa;
        border-radius: 18px 18px 18px 0;
        padding: 12px 15px;
        margin-bottom: 15px;
        border-left: 4px solid #18BC9C;
      }
      
      /* Target multiple possible selectors for the assistant image */
     .chat-message-assistant img, 
     .chat-assistant-message img,
     .chat-message-bot img,
     .shiny-chat-assistant img,
     .shiny-chat-container [data-role='assistant'] img {
        height: 40px !important;
        width: auto !important;
        object-fit: contain !important;
      }
      
      /* Prompt preview styling */
      .prompt-preview {
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 0.25rem;
        padding: 1rem;
        margin-bottom: 1rem;
        max-height: 200px;
        overflow-y: auto;
      }
      
      /* Task list styling */
      .task-list {
        padding-left: 0;
        list-style: none;
      }
      
      .task-list li {
        position: relative;
        padding-left: 30px;
        margin-bottom: 10px;
        line-height: 1.5;
      }
      
      .task-list li:before {
        content: '';
        position: absolute;
        left: 0;
        top: 4px;
        width: 18px;
        height: 18px;
        background-color: #0d1f29;
        border-radius: 50%;
        opacity: 0.8;
      }
      
      .task-list li:after {
        content: '✓';
        position: absolute;
        left: 4px;
        top: 1px;
        color: white;
        font-size: 12px;
      }
    "))
  ),
  
  # App title with logo
  div(
    class = "app-title",
    h1("AchyBot", style = "margin-right: 40px; display: inline-block;"), 
    tags$img(src = 'logo.png', height="10%", width="10%", align = "right"),
    style = "text-align: center;"
  ),
  
  
  layout_column_wrap(
    width = "800px",
    # Welcome card
    card(
      card_header(
        h4("Velkommen til AchyBot", style = "color: #2C3E50; margin-bottom: 0;"), 
        div(
          p(
            tags$i("Created by Steen Flammild Harsted, Henrik Hein Lauridsen & Søren O'Neill"),
            style = "text-align: right; font-style: italic; margin-bottom: 0.25rem; color: #7b8a8b; font-size: 0.9rem;"
          ),
          p(
            tags$i("Master students: Magnus Mortensen & Martin Sand Jensen"),
            style = "text-align: right; font-style: italic; margin-bottom: 0; color: #7b8a8b; font-size: 0.9rem;"
          )
        )
      ),
      card_body(
        p("AchyBot er et redskab tilegnet kiropraktorstuderende, der ønsker at træne anamneseoptagelse og diagnostisk tankegang.",
        
          style = "font-size: 1.05rem; color: #2C3E50;"
        ),
        hr(),
        p("Du står overfor en ny patient i din kiropraktiske klinik. Patienten har fået en diagnose og en personlighed, der afspejler en patient, du vil kunne møde i klinisk praksis."),
        p("Håndter patienten som du ville gøre i praksis. Husk at man I praksis har begrænset tid til anamnese og objektive undersøgelser. Det er ikke muligt at lave parakliniske undersøgelser."),
        
        
        p(
          strong("Dine opgaver er:"), style = "font-size: 1.1rem; color: #2C3E50; margin-bottom: 0.5rem;"
        ),

  
        tags$ul(
          class = "task-list",
          tags$li("Optag en fokuseret anamnese"),
          tags$li("Når du vil udføre objektive undersøgelser, skriver du f.eks. 'Jeg laver SBT'. Der vil komme de objektive fund, som du finder i undersøgelsen."),
          tags$li("Når du er kommet frem til diagnosen, så skriver du: 'Diagnosen er xx..'"),
          tags$li("Når du har fundet frem til den rigtige diagnose, skal du genindlæse siden for at starte en ny case.")
        ),
        br(),
        div(
          style = "background-color: #e8f4f8; border-left: 4px solid #3498db; padding: 1rem; border-radius: 4px;",
          p(
            icon("info-circle"), " ", 
            em("Du starter konsultationen ved at præsentere dig selv, f.eks."), 
            br(),
            em("'Hej, jeg hedder xx og jeg er din behandler i dag, hvad er dit navn og cpr?'"),
            style = "margin-bottom: 0; color: #2C3E50;"
          )
        )
      )
    ), 
    
    # # Control panel card
    # card(
    #   max_height = "600px",
    #   card_header(
    #     div(
    #       style = "display: flex; justify-content: space-between; align-items: center;",
    #       tags$div("Configuration Panel", style = "font-weight: 600; color: #2C3E50;"),
    #       tags$div(icon("sliders"), style = "color: #3498DB;")
    #     )
    #   ),
    #   card_body(
    #     div(
    #       style = "background-color: white; border-radius: 0.5rem; padding: 1rem;",
    #       layout_column_wrap(
    #         width = 1/5,
    #         tags$div(
    #           selectInput("start_prompt", "Initial Scenario:",
    #                       choices = start_prompts,
    #                       selected = start_prompts[1]),
    #           class = "tiny-font"
    #         ),
    #         tags$div(
    #           selectInput("person_prompt", "Patient Personality:",
    #                       choices = person_prompts,
    #                       selected = person_prompts[3]),
    #           class = "tiny-font"
    #         ),
    #         tags$div(
    #           selectInput("diagnosis_prompt", "Clinical Condition:",
    #                       choices = diagnosis_prompts,
    #                       selected = diagnosis_prompts[6]),
    #           class = "tiny-font"
    #         ),
    #         tags$div(
    #           selectInput("model", "AI Model:",
    #                       choices = c("gpt-4o", "gpt-4o-mini", "o3-mini-2025-01-31"),
    #                       selected = "gpt-4o"),
    #           class = "tiny-font"
    #         ),
    #         tags$div(
    #           selectInput("feedback_prompt", "Feedback Mode:",
    #                       choices = c(feedback_prompts),
    #                       selected = feedback_prompts[1]),
    #           class = "tiny-font"
    #         )
    #       ),
    #       tags$div(
    #         actionButton(
    #           "update_chat", 
    #           "Press here before you write in the chat the first time",
    #           class = "btn-primary mt-3",
    #           style = "width: 100%; background: linear-gradient(135deg, #18BC9C 0%, #3498DB 100%); border: none;"
    #         )
    #       )
    #   )
    # )
    #)
  ),
  
  # Chat UI
  layout_column_wrap(
    width = "100%",
    card(
      max_height = "600px",
      card_header(
        div(
          style = "display: flex; justify-content: space-between; align-items: center;",
          tags$div("Patient Consultation", style = "font-weight: 600; color: #2C3E50;"),
          tags$div(icon("comments"), style = "color: #3498DB;")
        )
      ),
      card_body(
        style = "padding: 0;",
        chat_ui("chat", 
                placeholder = "Patienten sidder foran dig...", 
                assistant_img = "logo.png"
        )
      )
    )
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