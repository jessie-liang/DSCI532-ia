# Shiny for R: Vancouver Park Dashboard

## Purpose

Vancouver has many parks, but it can be hard to quickly compare locations, 
and amenities in one place. This dashboard makes that information easy to browse 
and filter so residents, visitors, and planners can make faster and better decisions.

## How to install the packages

- Open R studio

- Type the following code in console:

```{r}
install.packages(c("shiny", "bslib", "plotly", "dplyr", "stringr"))
```

## How to run the app locally

- Clone this project repo locally

- Open R studio and set the working directory to the root project directory

- Run the following code in R studio console:

```{r}
shiny::runApp("app.R")
```

- Then a window will pop up with the local version of dashboard
