library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(stringr)

parks_df <- read.csv("data/raw/parks.csv",
                     sep = ";",
                     stringsAsFactors = FALSE)
valid_neighbourhoods <- sort(unique(na.omit(parks_df$NeighbourhoodName)))

ui <- page_sidebar(title = "Vancouver Park Dashboard",
                   theme = be_theme(bootswatch = "flatly",
                                    primary = "#285F2A",
                                    bg = "#b1ceb1",
                                    fg = "#2e2e2e"),
                   sidebar = sidebar(title = "Filters",
                                     textInput("search", "Search Park by Name",
                                               placeholder = "Enter park name..."),
                                     selectizeInput("neighbourhood", "Neighbourhood",
                                                    choices = valid_neighbourhoods,
                                                    selected = "Downtown", multiple = TRUE),
                                     sliderInput("size", "Hectare",
                                                 min = min(parks_df$Hectare, na.rm = TRUE),
                                                 max = max(parks_df$Hectare, na.rm = TRUE),
                                                 value = range(parks_df$Hectare, na.rm = TRUE)),
                                     checkboxGroupInput("facilities", "Facilities",
                                                        choices = c("Washrooms", "Facilities", "SpecialFeatures")),
                                     actionButton("reset_all", "Reset filters")),
                   layout_column_wrap(width = 1/2,
                                      card(card_header("Filtered Parks"), uiOutput("table_out")),
                                      card(card_header("Washrooms by Neighbourhood"), plotlyOutput("bar_chart"))))

server <- function(input, output, session) {
  filtered <- reactive({
    df <- parks_df
    
    if (nchar(trimws(input$search)) > 0)
      df <- df[str_detect(df$Name, regex(input$search, ignore_case = TRUE)), ]
    if (length(input$neighbourhood) > 0)
      df <- df[df$NeighbourhoodName %in% input$neighbouhood, ]
    
    df <- df[df$Hectare >= input$size[1] & df$Hectare <= input$size[2], ]
    
    for (fac in input$facilities)
      df <- df[df[[fac]] == "Y", ]
    
    df
  })
  
  output$table_out <- renderUI({
    df <- filtered()
    
    if (nrow(df) == 0)
      return (HTML("<p><b>No parks match your filters. </b></p>"))
    
    display <- data.frame(Name = df$Name,
                          Address = paste(df$StreetNumber, df$StreetName),
                          Neighbourhood = df$Neighbourhood)
    
    HTML(knitr::kable(display, format = "html",
                      table.attr = 'class="table table-striped table-sm"'))
  })
  
  output$bar_chart <- renderPlotly({
    selected <- input$neighbourhood
    
    all_counts <- parks_df |>
      filter(Washrooms == "Y") |>
      count(NeighbourhoodName, name = "Count")
    
    all_counts$Color <- ifelse(
      length(selected == 0) | (all_counts$NeighbourhoodName %in% selected), "#285F2A", "#bdbdbd")
    
    avg <- mean(all_counts$Count)
    
    plotly_ly(all_counts, x = ~NeighbourhoodName, 
              y = ~Count, type = "bar", marker = list(color = ~Color)) |>
      layout(xaxis = list(title = "Neighbourhood", tickangle = -45),
             yaxis = list(title = "Parks with Washroom"),
             shapes = list(list(type = "line", x0=0, x1=1,
                                xref="paper", y0=avg, y1=avg,
                                line = list(dash = "dot", color = "#ef9a9a"))))
  })
  
  observeEvent(input$reset_all, {
    updateTextInput(session, "search", value = "")
    updateSelectizeInput(session, "neighbourhood", selected = "Downtown")
    updateSliderInput(session, "size", value = range(parks_df$Hectare, na.rm = TRUE))
    updateCheckboxGroupInput(session, "facilities", selected = character(0))
  })
  
}

shinyApp(ui, server)