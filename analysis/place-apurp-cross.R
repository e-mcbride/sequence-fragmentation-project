# this is a data exploration script. Should go into "/notebook" or equivalent

#####
# NOTE: THIS IS A DIFFERENT THING COMPLETELY
# place x activity for multitasking:
# convert activity rows to columns for Activity 1-3 Category/Purpose in each place
#####
source(here("analysis","fixing-other-category.R"))
# first, rename columns and convert to very long format (three rows per activity)
chts_acts_indiv_long <- act.cat %>% 
  select(SAMPN:ACTNO, 
         category_A=Act_Cat, purpose_A=APURP) %>%
  
  gather(key='avar',value='aval', -(SAMPN:ACTNO))

# then convert to wide with activity data from each place side-by-side rather than sequential
chts_acts_indiv_wide <- chts_acts_indiv_long %>% 
  mutate(newvar = paste0(avar,ACTNO)) %>% 
  select(-ACTNO, -avar) %>%
  spread(newvar, aval, convert=T)

# finally, determine overall activity category and check for multitasking
# case_when is sequential: gives the first option that evaluates to TRUE; if A2 is NA, A3 is too
# rearrange columns so that category, purpose, and duration are together for each activity
locs_activity <- chts_acts_indiv_wide %>%
  mutate(activity_type = case_when(is.na(category_A2) ~ 
                                     category_A1, 
                                   category_A1 == category_A2 & is.na(category_A3) ~ 
                                     category_A1,
                                   category_A1 == category_A2 & category_A1 == category_A3 ~ 
                                     category_A1, 
                                   TRUE ~ 
                                     'Mixed')) %>%
  select(SAMPN:PLANO, activity_type, ends_with('A1'), ends_with('A2'), ends_with('A3'))


locs_activity %>% group_by(activity_type) %>% count %>% 
  View()
  # clipr::write_clip()



