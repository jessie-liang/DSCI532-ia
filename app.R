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