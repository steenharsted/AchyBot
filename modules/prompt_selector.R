# modules/prompt_selector.R

mod_prompt_selector_ui <- function(id, start_prompts, person_prompts, diagnosis_prompts) {
  ns <- NS(id)
  
  card(
    max_height = "600px",
    card_header(
      div(
        style = "display: flex; justify-content: space-between; align-items: center;",
        tags$div("Developer Mode Configuration Panel", style = "font-weight: 600; color: #2C3E50;"),
        tags$div(icon("sliders"), style = "color: #3498DB;")
      )
    ),
    card_body(
      div(
        style = "background-color: white; border-radius: 0.5rem; padding: 1rem;",
        layout_column_wrap(
          width = 1/3,
          tags$div(
            selectInput(ns("start_prompt"), "Initial Scenario:",
                        choices = start_prompts,
                        selected = start_prompts[1]),
            class = "tiny-font"
          ),
          tags$div(
            selectInput(ns("person_prompt"), "Patient Personality:",
                        choices = person_prompts,
                        selected = person_prompts[3]),
            class = "tiny-font"
          ),
          tags$div(
            selectInput(ns("diagnosis_prompt"), "Clinical Condition:",
                        choices = diagnosis_prompts,
                        selected = diagnosis_prompts[6]),
            class = "tiny-font"
          )
        ),
        tags$div(
          actionButton(
            ns("update_chat"),
            "Press here before you write in the chat the first time",
            class = "btn-primary mt-3",
            style = "width: 100%; background: linear-gradient(135deg, #18BC9C 0%, #3498DB 100%); border: none;"
          )
        )
      )
    )
  )
}

mod_prompt_selector_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(
      list(
        start = reactive(input$start_prompt),
        person = reactive(input$person_prompt),
        diagnosis = reactive(input$diagnosis_prompt),
        model = reactive(input$model),
        feedback = reactive(input$feedback_prompt),
        update_trigger = reactive(input$update_chat)
      )
    )
  })
}
