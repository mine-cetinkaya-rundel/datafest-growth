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

# calculate total participants for each year ------------------------
part_count <- data_frame(year = 2011:2017,
                         tot_part = colSums(datafest[grep("num_part", names(datafest))], na.rm = TRUE))
min_tot_part <- min(part_count$tot_part)
max_tot_part <- max(part_count$tot_part)

# define ui ---------------------------------------------------------
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("year", "Select Year", value = 2011, 
                  min = 2011, max = 2017, step = 1,  
                  animate = animationOptions(interval = 1500), 
                  sep = "")
    ),
    mainPanel(
      leafletOutput("leaflet"),
      plotOutput("line", height = "200px")
    )
  )
)

# define server logic -----------------------------------------------
server <- function(input, output, session) {
  
  d <- reactive({
    year_var <- paste0("df_", input$year)
    filter_(datafest, paste(year_var, "== 'Yes'"))
  })
  
  output$leaflet <- renderLeaflet({
    
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
  
  output$line <- renderPlot({
    
    sel_part_count <- filter(part_count, year <= input$year)
    
    ggplot(sel_part_count, aes(x = year, y = tot_part)) +
      geom_line() +
      geom_point() +
      scale_x_continuous("Year",
                         limits = c(2011, 2017),
                         breaks = c(2011:2017)) +
      scale_y_continuous("",
                         limits = c(0, max_tot_part)) +
      labs(title = "DataFest participants over time", 
           subtitle = "Total number of participants for each year")
    
  })
  
}

# run app -----------------------------------------------------------
shinyApp(ui, server)
