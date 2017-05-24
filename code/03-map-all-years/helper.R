# load packages -----------------------------------------------------
library(tidyverse)
library(leaflet)
library(shiny)

# load data ---------------------------------------------------------
datafest <- read_csv("data/datafest.csv")

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