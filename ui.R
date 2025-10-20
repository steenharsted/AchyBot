


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
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  # App title with logo
  div(
    class = "app-title",
    h1("AchyBot", style = "margin-right: 40px; display: inline-block;"), 
    tags$img(src = 'logo.png', height="10%", width="10%", align = "right"),
    style = "text-align: center;"
  ),
  
  
  # Somewhere in your page_fluid(...)
  uiOutput("dev_mode_banner"),
  
  
  layout_column_wrap(
    width = "800px",
    # Welcome card
    card(
      card_header(
        h4("Welcome to AchyBot", style = "color: #2C3E50; margin-bottom: 0;"), 
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
        p("AchyBot is a tool designed for chiropractic students who want to practice taking patient histories and developing diagnostic reasoning.",
          
          style = "font-size: 1.05rem; color: #2C3E50;"
        ),
        hr(),
        p("You are facing a new patient in your chiropractic clinic. The patient has been assigned a diagnosis and a personality that reflects someone you might encounter in clinical practice."),
        p("Manage the patient as you would in real life. Remember that in practice, time for history taking and physical examination is limited. Paraclinical tests are not available."),
        
        p(
          strong("Your tasks are:"), style = "font-size: 1.1rem; color: #2C3E50; margin-bottom: 0.5rem;"
        ),
        
        
        tags$ul(
          class = "task-list",
          tags$li("Conduct a focused patient history"),
          tags$li("When you want to perform physical examinations, write e.g., 'I perform SBT'. You will then receive the objective findings corresponding to that examination."),
          tags$li("When you have reached a diagnosis, write: 'The diagnosis is xx..'"),
          tags$li("Once you have identified the correct diagnosis, reload the page to start a new case.")
        ),
        
        br(),
        div(
          style = "background-color: #e8f4f8; border-left: 4px solid #3498db; padding: 1rem; border-radius: 4px;",
          p(
            icon("info-circle"), " ", 
            em("You begin the consultation by introducing yourself, for example:"), 
            br(),
            em("'Hi, my name is xx and I’ll be your clinician today. What is your name and patient identification number?'"),
            style = "margin-bottom: 0; color: #2C3E50;"
          )
        )
      )
    )
  ),
  
  ## Add selector pane if dev mode
  uiOutput("dev_selector_ui"),
  
  ## Add prompt pane if in dev mode
  conditionalPanel(
    condition = "output.is_dev_mode",
    layout_column_wrap(
      width = "800px",
      card(
        card_header("🔍 Prompt Preview"),
        card_body(
          verbatimTextOutput("prompt_preview")
        )
      )
    )
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
                placeholder = "The patient sits in front of you...", 
                assistant_img = "logo.png"
        )
      )
    )
  )
)


