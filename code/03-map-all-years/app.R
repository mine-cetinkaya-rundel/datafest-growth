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
part_count <- datafest %>%
  group_by(year) %>%
  summarise(tot_part = sum(num_part, na.rm = TRUE))

min_tot_part <- min(part_count$tot_part)
max_tot_part <- max(part_count$tot_part)

# define ui ---------------------------------------------------------
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("year", "Year", value = 2011, 
                  min = 2011, max = 2017, step = 1,  
                  animate = animationOptions(interval = 1500), 
                  sep = ""),
      br(),
      HTML("This app is designed to demonstrate the growth and spread
           of <a href='http://www.amstat.org/education/datafest/'>ASA 
           DataFest</a> over the years. Click on the points to find out 
           more about each event. If your institution does not appear on 
           the list, email <a href='maito:mine@stat.duke.edu'>mine@stat.duke.edu</a>.")
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
    filter(datafest, year == input$year & df == "Yes")
  })
  
  output$leaflet <- renderLeaflet({
    
    popups <- paste0(
      "<b><a href='", d()$url, "' style='color:", href_color, "'>", d()$host, "</a></b>",
      ifelse(is.na(d()$other_inst), "",
             paste0("<br>", "with participation from ", d()$other_inst)),
      "<br>",
      paste0("<font color=", part_color,">", d()$num_part, " participants</font>"))
    
    leaflet() %>%
      addTiles() %>%
      fitBounds(lng1 = left, lat1 = bottom, lng2 = right, lat2 = top) %>%
      addCircleMarkers(lng = d()$lon, lat = d()$lat,
                       radius = d()$radius, 
                       fillColor = marker_color,
                       color = marker_color,
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
