# load packages -----------------------------------------------------
library(tidyverse)
library(leaflet)

# load data ---------------------------------------------------------
datafest <- read_csv("data/datafest.csv")

# filter for 2017 events --------------------------------------------
datafest_2017 <- datafest %>%
  filter(df_2017 == "Yes")

# set generic dataframe reference -----------------------------------
d <- datafest_2017 

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
popups <- paste0(
  "<b><a href='", d$url, "' style='color:", popup_color, "'>", d$host, "</a></b>",
  ifelse(is.na(d$other_inst_2017), "",
         paste0("<br>", "with participation from ", d$other_inst_2017)),
  "<br>", 
  paste0("<font color=", part_color,">", d$num_part_2017, " participants</font>"))

# plot map ----------------------------------------------------------
leaflet() %>%
  addTiles() %>%
  fitBounds(lng1 = left, lat1 = bottom, lng2 = right, lat2 = top) %>%
  addCircleMarkers(lng = d$lon, lat = d$lat,
                   radius = d$radius_2017 * 1.5, 
                   fillColor = marker_color,
                   weight = 1,
                   fillOpacity = 0.5,
                   popup = popups)
