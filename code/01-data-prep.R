# load packages -----------------------------------------------------
library(tidyverse)
library(googlesheets)
library(devtools)
# install dev version of ggmap where mutate_geocode works with tbl_df
# install_github("dkahle/ggmap") 
library(ggmap)

# get data ----------------------------------------------------------
datafest <- gs_title("DataFest over the years (Responses)") %>%
  gs_read()

# write raw data (for blog post) ------------------------------------
write_csv(datafest, path = "data/datafest-raw.csv")

# rename columns ----------------------------------------------------
yrs <- sort(rep(2011:2017, 3))
cols <- c("df_", "num_part_", "other_inst_")

names(datafest) <- c("timestamp", "host", "city", "state", "country", "url",
                     paste0(cols, yrs))

# geocode host location ---------------------------------------------
datafest <- datafest %>%
  mutate(address = paste(city, state, country)) %>%
  mutate_geocode(address)

# calculate radius size for points on map ---------------------------
min_part <- min(datafest$num_part_2011,
                datafest$num_part_2012,
                datafest$num_part_2013,
                datafest$num_part_2014,
                datafest$num_part_2015,
                datafest$num_part_2017, 
                na.rm = TRUE)

max_part <- max(datafest$num_part_2011,
                datafest$num_part_2012,
                datafest$num_part_2013,
                datafest$num_part_2014,
                datafest$num_part_2015,
                datafest$num_part_2017,
                na.rm = TRUE)

range_part <- max_part - min_part                                                                          

range_step <- range_part / 10

datafest <- datafest %>%
  mutate(
    radius_2017 = num_part_2017 / range_step,
    radius_2016 = num_part_2016 / range_step,
    radius_2015 = num_part_2015 / range_step,
    radius_2014 = num_part_2014 / range_step,
    radius_2013 = num_part_2013 / range_step,
    radius_2012 = num_part_2012 / range_step,
    radius_2011 = num_part_2011 / range_step
  )

# write prepped data ------------------------------------------------
write_csv(datafest, path = "data/datafest.csv")
