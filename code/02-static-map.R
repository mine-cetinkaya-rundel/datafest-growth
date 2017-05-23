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
popup_fill <- "#FF6100"
popup_stroke <- "#632500"

# define popups -----------------------------------------------------
popups <- paste0(
  "<b><a href='", d$url, "' style='color:", popup_fill, "'>", d$host, "</a></b>",
  ifelse(is.na(d$other_inst_2017), "",
         paste0("<br>", "with participation from ", d$other_inst_2017)),
  "<br>", 
  d$num_part_2017, " participants")

# plot map ----------------------------------------------------------
leaflet() %>%
  addTiles() %>%
  addCircleMarkers(lng = d$lon, lat = d$lat,
                   radius = 5, 
                   fillColor = popup_fill,
                   color = popup_stroke,
                   stroke = TRUE, 
                   weight = 1,
                   fillOpacity = 0.7,
                   popup = popups)
