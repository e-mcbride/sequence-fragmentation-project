# this is a data exploration script. Should go into "/notebook" or equivalent

#' this script does a few things:
#' Most important right now: it looks at what activities are in "Other"(place x activity)
#' this shows that there are locations catgorized as "other" that should be in other categories
#' Now, a script will be made to identify this

library(tidyverse); library(here)


#####
# Getting place type for all of CA 
#####

# chts_rel <- read_rds("data/original/CHTS_all2018-03-05_.rds")
chts_rel <- read_rds("data/chts_all_2019-05-22.rds") # trying with new dataset
# place <- chts_rel$PLACE

home_locs <- chts_rel$HOUSEHOLD %>% select(SAMPN, Home_Lat=HLAT, Home_Lon=HLON)

school_work_locs <- chts_rel$PERSON %>%
  select(SAMPN,PERNO, school_lat=SYCORD, school_lon=SXCORD, school_name=SNAME,
         work_lon=WLON, work_lat=WLAT, work_name=WNAME, work_name2=WNAME2)

school_work_activities <- chts_rel$ACTIVITY %>%
  group_by(SAMPN, PERNO, PLANO) %>%
  summarise(school_acts = any(APURP == 'IN SCHOOL/CLASSROOM/LABORATORY'),
            work_acts   = any(APURP == 'WORK/JOB DUTIES'))


#' A couple helper functions to identify place names with at least one word (by default length >= 4 characters) in common.

one_word_match <- function(string_col1, string_col2, len_min=4) {
  # match_key will set the rules for identifying words in every string passed to it
  # in this case, it will grab all sections of alphanumeric characters of at least match_len_min
  match_key = glue::glue('[:alnum:]{(len_min),}', .open='(', .close=')') 
  words_col1 = str_extract_all(string_col1, match_key)
  words_col2 = str_extract_all(string_col2, match_key)
  
  # check for any matching elements in each pair of word lists
  map2(words_col1, words_col2, any_matching_elements) %>% unlist()
}

any_matching_elements <- function(list1, list2) {
  any(list1 %in% list2)
}

#' Attach the values to the place table.

locs_rel <- chts_rel$PLACE %>%
  left_join(home_locs, by='SAMPN') %>%
  left_join(school_work_locs, by=c('SAMPN','PERNO')) %>%
  left_join(school_work_activities, by=c('SAMPN','PERNO','PLANO'))


#' Identify matches for each place category criterion.

lat_match <- 0.0001 # ~ 11.1 meters
lon_match <- lat_match * 0.829 # ~ 11.1 meters at latitude of Santa Maria, CA
locs_rel_matchpts <- locs_rel %>%
  mutate(home_match_loc     = abs(LAT - Home_Lat) < lat_match & abs(LON - Home_Lon) < lon_match,
         home_match_name    = PNAME == 'HOME',
         school_match_lat   = abs(LAT - school_lat) < lat_match,
         school_match_lon   = abs(LON - school_lon) < lon_match,
         school_match_name1 = PNAME == 'SCHOOL',
         school_match_name2 = one_word_match(PNAME, school_name) | (PNAME == school_name),
         school_match_acts  = school_acts * 2,
         work_match_lat     = abs(LAT - work_lat) < lat_match,
         work_match_lon     = abs(LON - work_lon) < lon_match,
         work_match_name1   = PNAME == 'WORK',
         work_match_name2   = one_word_match(PNAME, work_name) | one_word_match(PNAME, work_name2) |
           (PNAME == work_name) | (PNAME == work_name2),
         work_match_acts    = work_acts * 2)



#' Calculate total matches and choose place category.
#' this basically says: "if either the place name or place location match as expected, then 

locs_rel_matched <- locs_rel_matchpts %>%
  mutate(home_match_points   = home_match_loc + home_match_name,
         school_match_points = rowSums(select(., starts_with('school_match')), na.rm=T),
         work_match_points   = rowSums(select(., starts_with('work_match')), na.rm=T),
         place_type = case_when(home_match_points >= 1 ~ 'Home',
                                school_match_points >= 3 &
                                  school_match_points >= work_match_points ~ 'School',
                                work_match_points >= 3 &
                                  work_match_points > school_match_points ~ 'Work',
                                TRUE ~ 'Other'))

locs_rel_matched %>% group_by(place_type) %>% count() %>% View()
## Current best:
# Home
# 219141
# Other
# 230211
# School
# 11885
# Work
# 31084


pltype_frq <- locs_rel_matched %>% count(SAMPN,PERNO,place_type) %>%
  group_by(place_type) %>% summarise(`Total Place-Events` = sum(n), `People with this place type` = n())

pltype_frq

# pltype_frq %>% write_csv(here("figs", "place-type-freq-table-HOSW.csv"))

#' for each person, did they go to school/work on the diary day?
locs_place_cat <- locs_rel_matched %>% 
  group_by(SAMPN,PLANO) %>%
  mutate(any_work   = any(place_type == 'Work'),
         any_school = any(place_type == 'School'),
         any_other  = any(place_type == 'Other')) %>% 
  ungroup() %>%
  select(SAMPN,PERNO,PLANO,place_type,any_work:any_other)

#####
#' Attaching place type to activity type
#####
activity <- chts_rel$ACTIVITY
ac <- activity %>% select(SAMPN, PERNO, PLANO, ACTNO, APURP) 


#get the new activity categories AND clean up category names
# activities_crosswalk <- readxl::read_excel(here("data", "activity_purps_crosswalk_touppercase.xlsx"))
# gather(key = "key", value = "old.apurp", -new.apurp, -Act_Cat) %>% 
# select(-key)



# act.cat <- ac %>% 
#   left_join(activities_crosswalk, by = c("APURP" = "old.apurp")) %>% 
#   mutate(APURP = new.apurp) %>% select(-new.apurp)


act.place <- ac %>% left_join(locs_place_cat, by = c("SAMPN", 'PERNO', 'PLANO'))


#####
# place x activity
#####

#' what activities are done in place type other?
act.place %>% 
  filter(place_type == "Other") %>%
  # group_by(APURP, place_type) %>% 
  group_by(APURP) %>% 
  summarise(n=n()) %>% 
  # spread(place_type, n) %>% 
  View()
  # clipr::write_clip()
  # arrange(desc(n))

# clipr::write_clip()


#####
#
#####
# convert activity rows to columns for Activity 1-3 Category/Purpose in each place
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



