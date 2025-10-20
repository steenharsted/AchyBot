server <- function(input, output, session) {
  
  # Define the reactive flag
  dev_mode <- reactiveVal(FALSE)  
  
  # Define selected prompts
  selected_prompts <- reactive({
    if (dev_mode()) {
      mod_prompt_selector_server("prompt_ui")
    } else {
      list(
        start = reactive(sample(start_prompts, 1)),
        person = reactive(sample(person_prompts, 1)),
        diagnosis = reactive(sample(diagnosis_prompts, 1)),
        model = reactive("gpt-4o-mini"),
        feedback = reactive(NULL),
        update_trigger = reactive(input$start_chat)
      )
    }
  })
  
  
  
  # Reactive values to store the current chat instance
  rv <- reactiveValues(chat = NULL, chat_id = 0)
  
  # Initialize chat when app starts
  observe({
    req(is.null(rv$chat))  # only initialize if chat is NULL
    
    if (dev_mode()) {
      req(
        selected_prompts(),
        selected_prompts()$start(),
        selected_prompts()$person(),
        selected_prompts()$diagnosis(),
        selected_prompts()$model()
      )
      
      new_prompt <- generate_prompt_text_dev(
        start_choice = selected_prompts()$start(),
        person_choice = selected_prompts()$person(),
        diagnosis_choice = selected_prompts()$diagnosis()
      )
      
      rv$chat <- ellmer::chat_openai(
        model = selected_prompts()$model(),
        system_prompt = new_prompt
      )
    } else {
      new_prompt <- generate_prompt_text()
      
      rv$chat <- ellmer::chat_openai(
        model = "gpt-4o-mini",
        system_prompt = new_prompt
      )
    }
  })
  
  # Toggle dev mode on/off

  
  # Toggle mode when button is clicked
  observeEvent(input$toggle_dev_mode, {
    dev_mode(!dev_mode())
  })
  
  # Dynamically render the dev/user banner + toggle button
  output$dev_mode_banner <- renderUI({
    if (dev_mode()) {
      div(
        style = "text-align: center;",
        actionButton("toggle_dev_mode", "🔁 Change to User mode", class = "btn-warning mb-2"),
        div("🚧 Developer Mode", style = "color: white; background-color: red; padding: 6px; border-radius: 4px; font-weight: bold; text-align: center;")
      )
    } else {
      div(
        style = "text-align: center;",
        actionButton("toggle_dev_mode", "🛠 Change to Developer mode", class = "btn-primary mb-2")
      )
    }
  })
  
  
  # Show selector pane if in dev mode
  output$dev_selector_ui <- renderUI({
    if (dev_mode()) {
      layout_column_wrap(
        width = "800px",
        mod_prompt_selector_ui(
          id = "prompt_ui",
          start_prompts = start_prompts,
          person_prompts = person_prompts,
          diagnosis_prompts = diagnosis_prompts
        )
      )
    } else {
      NULL  # Do not show anything in non-dev mode
    }
  })
  
  output$is_dev_mode <- reactive({
    dev_mode()
  })
  outputOptions(output, "is_dev_mode", suspendWhenHidden = FALSE)
  
  new_prompt_reactive <- reactive({
    req(dev_mode())
    req(selected_prompts()$start())
    req(selected_prompts()$person())
    req(selected_prompts()$diagnosis())
    
    generate_prompt_text_dev(
      start_choice = selected_prompts()$start(),
      person_choice = selected_prompts()$person(),
      diagnosis_choice = selected_prompts()$diagnosis()
    )
  })
  
  output$prompt_preview <- renderText({
    new_prompt_reactive()
  })
  
  
  
  # Update chat when start button is clicked
  observeEvent({
    if (dev_mode()) selected_prompts()$update_trigger()
    else input$start_chat
  }, {
    # Generate a new prompt for a new case
    if (dev_mode()) {
      new_prompt <- generate_prompt_text_dev(
        start_choice = selected_prompts()$start(),
        person_choice = selected_prompts()$person(),
        diagnosis_choice = selected_prompts()$diagnosis()
      )
    } else {
      new_prompt <- generate_prompt_text()
    }
    
    # Create a new chat instance
    rv$chat <- ellmer::chat_openai(
      model = input$model,
      system_prompt = new_prompt
    )
    
    # Clear the chat history
    shinychat::chat_clear("chat")
    
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