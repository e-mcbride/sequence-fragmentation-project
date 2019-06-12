
##' Process activities table
library(tidyverse); library(here)


###' What we need from the activities dataset is a place-level dataset with:

####' * Overall activity category for the place (10-option plus mixed)
####' * Multitasking indicator (total activity duration > place duration)
####' * Activity categories and purpose of activities 1-3, with duration of each


###' To create this, we need to load the activity category aggregator / crosswalk table we created and join it to the activities dataset, then aggregate the activities to the level of places.

activities_crosswalk <- readxl::read_excel(here("data-raw", "activity_purps_crosswalk.xlsx")) %>% 
  select(APURP,Act_Cat)
activities_with_time <- readr::read_rds(here("data", "activities-time-vars.rds")) %>% select(-Act_Cat)

chts_acts_classed <- activities_with_time %>% left_join(activities_crosswalk, by='APURP')

# convert activity rows to columns for Activity 1-3 Category/Purpose/Duration in each place
# first, rename columns and convert to very long format (three rows per activity)
chts_acts_indiv_long <- chts_acts_classed %>% 
  select(SAMPN:ACTNO, place_duration, 
         category_A=Act_Cat, purpose_A=APURP, xduration_A=act_duration) %>%
  gather(key='avar',value='aval', -(SAMPN:place_duration))

# then convert to wide with activity data from each place side-by-side rather than sequential
chts_acts_indiv_wide <- chts_acts_indiv_long %>% 
  mutate(newvar = paste0(avar,ACTNO)) %>% 
  select(-ACTNO, -avar) %>%
  spread(newvar, aval, convert=T)

# finally, determine overall activity category and check for multitasking
# case_when is sequential: gives the first option that evaluates to TRUE; if A2 is NA, A3 is too
# rearrange columns so that category, purpose, and duration are together for each activity
locations_activity <- chts_acts_indiv_wide %>%
  mutate(activity_type = case_when(is.na(category_A2) ~ 
                                     category_A1, 
                                   category_A1 == category_A2 & is.na(category_A3) ~ 
                                     category_A1,
                                   category_A1 == category_A2 & category_A1 == category_A3 ~ 
                                     category_A1, 
                                   TRUE ~ 
                                     'Mixed'),
         multitasking = rowSums(select(., starts_with('xduration')), na.rm=T) > place_duration) %>%
  select(SAMPN:PLANO, activity_type, multitasking, ends_with('A1'), ends_with('A2'), ends_with('A3'))

locations_activity %>% 
  count(activity_type,multitasking) %>% 
  spread(multitasking,n,sep='_', fill=0) %>% 
  mutate(Places = multitasking_FALSE + multitasking_TRUE, 
         pct_multitasking = 100*multitasking_TRUE/Places) %>% 
  select(activity_type,Places, pct_multitasking) %>% arrange(desc(Places))

locations_activity %>% readr::write_rds(here("data", "locations-activity-vars_places.rds"))



