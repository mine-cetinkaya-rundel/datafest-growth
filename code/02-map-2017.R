# load packages -----------------------------------------------------
library(tidyverse)
library(leaflet)

# load data ---------------------------------------------------------
datafest <- read_csv("data/datafest.csv")

# filter for 2017 events --------------------------------------------
datafest_2017 <- filter(datafest, year == 2017 & df == "Yes")

# set colors --------------------------------------------------------
href_color <- "#A7C6C6"
marker_color <- "black"
part_color <- "#89548A"

# set map bounds ----------------------------------------------------
left <- floor(min(datafest$lon))
right <- ceiling(max(datafest$lon))
bottom <- floor(min(datafest$lat))
top <- ceiling(max(datafest$lat))


# define popups -----------------------------------------------------
host_text <- paste0(
  "<b><a href='", datafest_2017$url, "' style='color:", href_color, "'>", datafest_2017$host, "</a></b>"
)

other_inst_text <- paste0(
  ifelse(is.na(datafest_2017$other_inst), 
         "", 
         paste0("<br>", "with participation from ", datafest_2017$other_inst))
)

part_text <- paste0(
  "<font color=", part_color,">", datafest_2017$num_part, " participants</font>"
)

popups <- paste0(
  host_text, other_inst_text, "<br>" , part_text
)

# plot map ----------------------------------------------------------
leaflet() %>%
  addTiles() %>%
  fitBounds(lng1 = left, lat1 = bottom, lng2 = right, lat2 = top) %>%
  addCircleMarkers(lng = datafest_2017$lon, lat = datafest_2017$lat,
                   radius = log(datafest_2017$num_part) * 1.2, 
                   fillColor = marker_color,
                   color = marker_color,
                   weight = 1,
                   fillOpacity = 0.5,
                   popup = popups)
