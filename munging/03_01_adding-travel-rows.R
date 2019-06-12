library(tidyverse); library(here)

# places_mod <- readr::read_rds(here("data","modified_pldat.rds"))

# Data into nested format (nested by person ID)
pl_nest <- places_mod %>% 
  mutate(PLANO = as.character(PLANO)) %>% 
  select(pid, PLANO, arr_time3_add1, dep_time3_add1, pltype, place_type, activity_type) %>% 
  group_by(pid) %>% 
  nest()


## Adding Travel Rows In Between

# It should go like this:
#   if the current arrival time is >= 1 minute more than previous departure time, 
# then add a new row where arrival time = previous departure time, 
# departure time = next arrival time,
# pid = pid,
# PLANO = previous PLANO + letter T(?), 
# pltype = T,
# place_type = Travel
# 
# Then, need to deal with the PLANO. Maybe by making a new column with the new PLANO's

# Function below makes the new rows with travel in them and uses a rowbind to combine them with the original rows.
TravRows <- function(x) {
  plno = x[["PLANO"]]
  dep_time = x[["dep_time3_add1"]]
  arr_time = x[["arr_time3_add1"]]
  
  
  PLANO = NA
  arr_time3_add1 = NA
  dep_time3_add1 = NA
  pltype = NA
  place_type = NA
  activity_type = NA
  
  
  for(i in 1:length(plno)){
    if(length(dep_time[i-1]!=0)){
      
      PLANO[i] = paste(plno[i], "T", sep = "")
      arr_time3_add1[i] = dep_time[i-1]
      dep_time3_add1[i] = arr_time[i]
      pltype[i] = "T"
      place_type[i] = "Travel"
      activity_type[i] = "Travel"
      
    }
  }
  
  travdf = tibble(PLANO, arr_time3_add1, dep_time3_add1, pltype, place_type, activity_type) %>%
    filter(!is.na(PLANO))
  
  combodf <- travdf %>% bind_rows(x)
  
  return(combodf)
}

# running function above to add the new set of rows that contain the travel
trav_added <- pl_nest %>% mutate(trav = map(data, TravRows))


## unnest to make into a tibble:
travel_dat <- trav_added %>% 
  unnest(trav) %>% 
  arrange(pid, dep_time3_add1)

travel_dat %>% readr::write_rds(here("data", "places_travel-added.rds"))



