# load helpers ------------------------------------------------------
source("helper.R", local = TRUE)

# define ui ---------------------------------------------------------
ui <- fluidPage(
  titlePanel("ASA DataFest over the years"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("year", "Year", value = 2011, 
                  min = 2011, max = 2017, step = 1,  
                  animate = animationOptions(interval = 1500), 
                  sep = ""),
      br(),
      p("This app is designed to demonstrate the growth and spread of",
        tags$a(href = "http://www.amstat.org/education/datafest/", "ASA DataFest"),
        "over the years. Click on the points to find out more about each event.",
        "If your institution does not appear on the list, email",
        tags$a(href = "mailto:mine@stat.duke.edu", "mine@stat.duke.edu."))
    ),
    mainPanel(
      leafletOutput("map"),
      plotOutput("line", height = "200px")
    )
  )
)

# define server logic -----------------------------------------------
server <- function(input, output, session) {
  
  d <- reactive({
    filter(datafest, year == input$year & df == "Yes")
  })
  
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      fitBounds(left, bottom, right, top)
  })
  
  observeEvent(d(), {
    
    mapProxy <- leafletProxy("map", session)
    
    # clear previous controls and markers each time input$year changes
    clearControls(mapProxy)
    clearMarkers(mapProxy)
    
    # define popups
    host_text <- paste0(
      "<b><a href='", d()$url, "' style='color:", href_color, "'>", d()$host, "</a></b>"
    )
    
    other_inst_text <- paste0(
      ifelse(is.na(d()$other_inst), 
             "", 
             paste0("<br>", "with participation from ", d()$other_inst))
    )
    
    part_text <- paste0(
      "<font color=", part_color,">", d()$num_part, " participants</font>"
      )
    
    popups <- paste0(
      host_text, other_inst_text, "<br>" , part_text
    )
    
    mapProxy %>%
      addControl(h1(input$year), position = "topright") %>%
      addCircleMarkers(lng = d()$lon, lat = d()$lat,
                       radius = log(d()$num_part), 
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
