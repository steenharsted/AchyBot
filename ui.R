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
          tags$div("Patient Konsultation", style = "font-weight: 600; color: #2C3E50;"),
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


