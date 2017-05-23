# load packages -----------------------------------------------------
library(tidyverse)
library(leaflet)


# plot static 2017 --------------------------------------------------
left <- floor(min(datafest$lon))
bottom <- floor(min(datafest$lat))
right <- ceiling(max(datafest$lon))
top <- ceiling(max(datafest$lat))

popups <- paste0(
  "<b><a href='", datafest$url, "'>", datafest$host, "</a></b>",
  ifelse(is.na(datafest$other_inst_2017), "",
         paste0("<br>", "with participation from ", datafest$other_inst_2017)),
  "<br>", 
  datafest$num_part_2017, " participants")

leaflet() %>%
  addTiles() %>%
  setMaxBounds(lng1 = left, lat1 = bottom, lng2 = right, lat2 = top) %>%
  addCircleMarkers(lng = datafest$lon, lat = datafest$lat,
                   radius = 5, 
                   fillColor = "white",
                   color = "#6B6B6A",
                   stroke = TRUE, 
                   weight = 2,
                   fillOpacity = 0.8,
                   popup = popups)


