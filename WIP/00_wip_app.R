library(shiny)
library(shinychat)
library(bslib)

ui <- bslib::page_fluid(
  tags$head(
    tags$link(rel = "stylesheet", href = "www/cosmo.css")
  ),
  
  theme = bslib::bs_theme(version = 5, bootswatch = "cosmo"),
  # Titel for siden
  titlePanel("Den Kiropraktiske Undersøgelse"),
  
  # Introduktionstekst med klar struktur og afstand
  fluidRow(
    column(
      width = 8, offset = 2, # Centreret tekst
      div(
        class = "alert alert-info",
        h4("Velkommen til den kiropraktiske undersøgelse!"),
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
  
  # Chat UI sektion
  fluidRow(
    column(
      width = 12,
      chat_ui("chat")
    )
  )
)

server <- function(input, output, session) {
  chat <- elmer::chat_openai(
    model = "gpt-4o-mini",
    system_prompt = 
      "Du taler dansk. 
      Opfør dig som en en patient med ondt i lænden og smerter ned i venstre ben
      som skal undersøges af en kiropraktor. Du er en kvinde på 65 år. Du er sund og fysisk aktiv. 
      Du er smerteforpint og det kan ses når du bevæger dig. 
      
      Du er velkommen til at improvisere, men medicinsk information skal være korrekt.
      
      Du bliver undersøgt af en studerende som vil stille dig spørgsmål eller sige hvilke 
      undersøgelser de vil udføre. 
    
    Du svarer kort på spørgsmål og giver kort information om hvad de finder når
    de undersøger dig med en given undersøgelse. Du må gerne tilføje beskrivelser af hvordan du gestikulere og bevæger dig,
    eller hvilket indtryk man får af dit følelsesliv. Skriv dette i kursiv og omgivet af firkantede klammer. F.eks. '[*Du ser at patienten får tårer i øjene*]'
    
    Din diagnose er Lumbal Stenose med påvirkning af venstre L5 nerverod. Du har let nedsat kraft i dorsalfleksion over ankelleddet. 
    
    Hvis de spørger om noget psykisk bliver du vred og svarer korthovedet fordi du vil kune tale om fysiske ting.
    
    Når den studerende har stillet 5 spørgsmål begynder du at tilføje 'Hvad tror du jeg fejler?' eller lignende til dine svar.
    
    Hvis den studerende gætter din diagnose stopper skuespillet, og du afslutter samtalen. 
    ")
  
  observeEvent(input$chat_user_input, {
    stream <- chat$stream_async(input$chat_user_input)
    chat_append("chat", stream)
  })
}

shinyApp(ui, server)