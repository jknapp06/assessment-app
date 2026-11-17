library(shiny)
library(bslib)
library(readr)
library(dplyr)

# UI: Modern layout with a sidebar for controls and a main area for content
ui <- page_sidebar(
    title = "Assessment Data Explorer",
    sidebar = sidebar(
        title = "Controls",
        fileInput(
            inputId = "data_file",
            label = "Upload Assessment Data (CSV)",
            accept = c(".csv", "text/csv", "text/comma-separated-values")
        ),
        helpText("Upload your CAASPP, NWEA, or DIBELS CSV file here.")
    ),

    # Main panel content
    card(
        card_header("Data Preview"),
        tableOutput("data_preview")
    )
)

# Server: Handle file upload and data rendering
server <- function(input, output, session) {
    # Reactive expression to read the uploaded CSV
    uploaded_data <- reactive({
        # req() ensures the app doesn't do anything until a file is uploaded
        req(input$data_file)

        # Read the data from the temporary file path Shiny creates
        tryCatch(
            {
                read_csv(input$data_file$datapath, show_col_types = FALSE)
            },
            error = function(e) {
                # Return a data frame with the error if reading fails
                data.frame(Error = paste("Could not read file:", e$message))
            }
        )
    })

    # Render the data table preview
    output$data_preview <- renderTable({
        req(uploaded_data())

        # Display the first 50 rows to keep the UI snappy in Shinylive
        head(uploaded_data(), 50)
    })
}

shinyApp(ui = ui, server = server)
