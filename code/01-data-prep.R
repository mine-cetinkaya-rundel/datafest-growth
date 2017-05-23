# load packages -----------------------------------------------------
library(tidyverse)
library(googlesheets)
library(devtools)
# install dev version of ggmap where mutate_geocode works with tbl_df
# install_github("dkahle/ggmap") 
library(ggmap)
library(stringr)

# get data ----------------------------------------------------------
datafest_wide <- gs_title("DataFest over the years (Responses)") %>%
  gs_read()

# write raw data (for blog post) ------------------------------------
write_csv(datafest_wide, path = "data/datafest-raw.csv")

# rename columns ----------------------------------------------------
yrs <- sort(rep(2011:2017, 3))
cols <- c("df_", "num_part_", "other_inst_")

names(datafest_wide) <- c("timestamp", "host", "city", "state", "country", "url",
                     paste0(cols, yrs))

# geocode host location ---------------------------------------------
datafest_wide <- datafest_wide %>%
  mutate(address = paste(city, state, country)) %>%
  mutate_geocode(address)

# convert data to long format ---------------------------------------
datafest_long <- datafest_wide %>% 
  gather(key, value, df_2011:other_inst_2017) %>%
  mutate(year = as.numeric(str_match(key, "[0-9]+"))) %>%
  mutate(key = str_replace(key, "_[0-9]+", "")) %>%
  spread(key, value) %>%
  mutate(num_part = as.numeric(num_part))

# calculate radius size for points on map ---------------------------
min_part <- min(datafest_long$num_part, na.rm = TRUE)
max_part <- max(datafest_long$num_part, na.rm = TRUE)

range_part <- max_part - min_part                                                                          
range_step <- range_part / 10

datafest_long <- mutate(datafest_long, radius = num_part / range_step)

# write prepped data ------------------------------------------------
write_csv(datafest_long, path = "data/datafest.csv")
