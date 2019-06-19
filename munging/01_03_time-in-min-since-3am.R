# 01_03_time-in-min-since-3am.R

library(tidyverse); library(here)

##' Crunch arrival/departure times to calculate stay duration

###' Since the survey asked for diaries from 3AM to 2:59AM the next day, it'll be helpful to recalculate times so that they are measured in minutes since 3AM.


###' Some functions to help with that:

get_time_srbi_Acts <- function(time_col) as.numeric(time_col) / 60
get_time_nust_Acts <- function(time_col) {
  times = lubridate::fast_strptime(time_col, '%H:%M') 
  60*lubridate::hour(times) + lubridate::minute(times)
}

# converts a time in minutes since midnight to time in minutes since 3AM
convert_time_3A <- function(ext_time_col) {
  t3 = ext_time_col - 180
  if_else(t3 < 0, t3 + 24*60, t3)
}

# converts all NA values into FALSE in a column of logicals/booleans
nas_to_false <- function(log_col) if_else(is.na(log_col),F,log_col)


###' Run these functions on the Activities and Places tables:

# chts_rel <- readr::read_rds(here("data", "chts-all-tables_selection.rds"))

locations_timevars <- chts_rel$PLACE %>% 
  mutate(arrival_time_3   = convert_time_3A(ARR_HR * 60 + ARR_MIN),
         departure_time_3 = convert_time_3A(DEP_HR * 60 + DEP_MIN),
         place_duration   = departure_time_3 - arrival_time_3 + 1,
         trip_duration    = TRIPDUR) %>%
  select(SAMPN,PERNO,PLANO, arrival_time_3, departure_time_3, place_duration)

locations_timevars %>% readr::write_rds(here("data", "locations-time-vars_places.rds"))

activities_with_time <- chts_rel$ACTIVITY %>%
  left_join(locations_timevars, by=c('SAMPN','PERNO','PLANO')) %>%
  mutate(act_start_time_3 = case_when(source == 'SRBI' ~ get_time_srbi_Acts(STIME),
                                      source == 'NuStats' ~ get_time_nust_Acts(STIME),
                                      TRUE ~ as.numeric(NA)) %>% convert_time_3A(),
         act_end_time_3   = case_when(source == 'SRBI' ~ get_time_srbi_Acts(ETIME),
                                      source == 'NuStats' ~ get_time_nust_Acts(ETIME),
                                      TRUE ~ as.numeric(NA)) %>% convert_time_3A(),
         act_duration     = act_end_time_3 - act_start_time_3 + 1) %>%
  select(-s_Generation, -STIME,-ETIME)

activities_with_time %>% readr::write_rds(here("data", "activities-time-vars.rds"))


