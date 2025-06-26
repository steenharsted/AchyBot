server <- function(input, output, session) {
  
  # Define selected prompts
  selected_prompts <- if (is_dev_mode()) {
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
  
  
  # Reactive values to store the current chat instance
  rv <- reactiveValues(chat = NULL, chat_id = 0)
  
  # Initialize chat when app starts
  observe({

    
    isolate({
      if (is.null(rv$chat)) {
        new_prompt <- if (is_dev_mode()) {
          generate_prompt_text_dev(
            start_choice = selected_prompts$start(),
            person_choice = selected_prompts$person(),
            diagnosis_choice = selected_prompts$diagnosis()
          )
        } else {
          generate_prompt_text()
        }
        
        rv$chat <- ellmer::chat_openai(
          model = selected_prompts$model(),
          system_prompt = new_prompt
        )
      }
    })
  })
  
  
  # Update chat when start button is clicked
  observeEvent({
    if (is_dev_mode()) selected_prompts$update_trigger()
    else input$start_chat
  }, {
    # Generate a new prompt for a new case
    if (is_dev_mode()) {
      new_prompt <- generate_prompt_text_dev(
        start_choice = selected_prompts$start(),
        person_choice = selected_prompts$person(),
        diagnosis_choice = selected_prompts$diagnosis()
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