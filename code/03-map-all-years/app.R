# load packages -----------------------------------------------------
library(tidyverse)
library(leaflet)
library(shiny)

# load data ---------------------------------------------------------
datafest <- read_csv("../../data/datafest.csv")

# set colors --------------------------------------------------------
href_color <- "#A7C6C6"
marker_color <- "black"
part_color <- "#89548A"

# set map bounds ----------------------------------------------------
left <- floor(min(datafest$lon))
right <- ceiling(max(datafest$lon))
bottom <- floor(min(datafest$lat))
top <- ceiling(max(datafest$lat))

# define ui ---------------------------------------------------------
ui <- fluidPage(
  leafletOutput("map"),
  sliderInput("year", "Select Year", value = 2011, 
              min = 2011, max = 2017, step = 1,  
              animate = animationOptions(interval = 1500), 
              sep = "")
)

# define server logic -----------------------------------------------
server <- function(input, output, session) {
  
  d <- reactive({
    year_var <- paste0("df_", input$year)
    filter_(datafest, paste(year_var, "== 'Yes'"))
  })
  
  output$map <- renderLeaflet({
    
    other_inst <- paste0("other_inst_", input$year)
    num_part <- paste0("num_part_", input$year)
    radius <- paste0("radius_", input$year)
    
    popups <- paste0(
        "<b><a href='", d()$url, "' style='color:", href_color, "'>", d()$host, "</a></b>",
        ifelse(is.na(d()[[other_inst]]), "",
               paste0("<br>", "with participation from ", d()[[other_inst]])),
        "<br>",
        paste0("<font color=", part_color,">", d()[[num_part]], " participants</font>"))
  
    leaflet() %>%
      addTiles() %>%
      fitBounds(lng1 = left, lat1 = bottom, lng2 = right, lat2 = top) %>%
      addCircleMarkers(lng = d()$lon, lat = d()$lat,
                       radius = d()[[radius]] * 1.5, 
                       fillColor = marker_color,
                       weight = 1,
                       fillOpacity = 0.5,
                       popup = popups)
  
    })
  
}

# run app -----------------------------------------------------------
shinyApp(ui, server)
