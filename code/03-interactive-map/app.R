# load packages -----------------------------------------------------
library(tidyverse)
library(leaflet)
library(shiny)

# load data ---------------------------------------------------------
datafest <- read_csv("../../data/datafest.csv")
popup_fill <- "#FF6100"
popup_stroke <- "#632500"

# define ui ---------------------------------------------------------
ui <- fluidPage(
  plotOutput("map"),
  sliderInput("year", "Select Year", value = 2011, 
              min = 2011, max = 2017, step = 1,  
              animate = animationOptions(interval = 500, loop = TRUE), 
              sep = "")
)

# define server logic -----------------------------------------------
server <- function(input, output, session) {
  
  d <- reactive({
    year_var <- paste0("df_", input$year)
    filter_(datafest, paste(year_var, "== 'Yes'"))
  })
  
  output$map <- renderLeaflet({
    
    popups <- paste0(
        "<b><a href='", d()$url, "' style='color:", popup_fill, "'>", d()$host, "</a></b>",
        ifelse(is.na(d()$other_inst_2017), "",
               paste0("<br>", "with participation from ", d()$other_inst_2017)),
        "<br>", 
        d()$num_part_2017, " participants")
  
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(lng = d()$lon, lat = d()$lat,
                       radius = 5, 
                       fillColor = popup_fill,
                       color = popup_stroke,
                       stroke = TRUE, 
                       weight = 1,
                       fillOpacity = 0.7,
                       popup = popups)
  })
  
}

# run app -----------------------------------------------------------
shinyApp(ui, server)
