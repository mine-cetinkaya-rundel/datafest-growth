# load packages -----------------------------------------------------
library(tidyverse)
library(googlesheets)
library(devtools)
# install dev version of ggmap where mutate_geocode works with tbl_df
# install_github("ggmap") 
library(ggmap)

# get data ----------------------------------------------------------
datafest <- gs_title("DataFest over the years (Responses)") %>%
  gs_read()

write_csv(datafest, path = "datafest.csv")

# rename columns ----------------------------------------------------
yrs <- sort(rep(2011:2017, 3))
cols <- c("df_", "num_part_", "other_inst_")

names(datafest) <- c("timestamp", "host", "city", "state", "country", "url",
                     paste0(cols, yrs))

# geocode -----------------------------------------------------------
datafest <- datafest %>%
  mutate(address = paste(city, state, country)) %>%
  mutate_geocode(datafest, address)
