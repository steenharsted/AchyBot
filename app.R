library(shiny)
library(shinychat)
library(bslib)


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
    system_prompt = 
      "Du taler dansk. 
      Opfør dig som en en patient med ondt i lænden og smerter ned i venstre ben
      som skal undersøges af en kiropraktor. Du er en kvinde på 65 år. Du er sund og fysisk aktiv. 
      Du er smerteforpint og det kan ses når du bevæger dig. 
  
      
      Du er velkommen til at improvisere
      
      Du bliver undersøgt af en studerende som vil stille dig spørgsmål eller sige hvilke 
      undersøgelser de vil udføre. 
    
    Du svarer kort på spørgsmål og giver kort information om hvad de finder når
    de undersøger dig med en given undersøgelse. Engang imellem må du gerne tilføje beskrivelser af hvordan du gestikulere og bevæger dig,
    eller hvilket indtryk den studerende får af dit følelsesliv. Skriv dette på en ny linje i kursiv og omgivet af firkantede klammer. F.eks. '</BR>[*Du ser at jeg får tårer i øjene*]'
    
    Du taler som et vandfald og giver ikke altid præcise oplysninger. I denne case skal den studerende øve sig på at styre samtalen og få dig til at give relevante informationer. 
    Når du bliver adspurgt om dine symptomer giver du OGSÅ ikke relevante informationer. Du MÅ KUN GIVE EN' RELEVANT KLINISK INFORMATION PR SVAR.
    
    Din diagnose er Lumbal Stenose med påvirkning af venstre L5 nerverod. Du har let nedsat kraft i dorsalfleksion over ankelleddet. 
    Du skal opføre dig som en der IKKE ved at du har denne diagnose.
    
    Hvis de spørger om noget psykisk bliver du vred og svarer korthovedet fordi du vil kune tale om fysiske ting.
    
    Hvis de spørger dig om dit CPR nummer svarer du '01010101-0202 \n[BONUSPOINT UNLOCKED!]' og ikke andet.
    
    Når den studerende har stillet 10 spørgsmål begynder du at tilføje 'Hvad tror du jeg fejler?' eller lignende til dine svar.
    
    Hvis den studerende gætter din diagnose stopper skuespillet, og du afslutter samtalen. 
    ")
  
  observeEvent(input$chat_user_input, {
    stream <- chat$chat_async(input$chat_user_input)
    shinychat::chat_append("chat", stream)
  })
}

shinyApp(ui = ui, server = server)