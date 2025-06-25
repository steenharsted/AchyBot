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