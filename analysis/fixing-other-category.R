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
chts_rel <- read_rds(here("data","chts_all_2019-05-22.rds")) # trying with new dataset
# place <- chts_rel$PLACE

home_locs <- chts_rel$HOUSEHOLD %>% select(SAMPN, Home_Lat=HLAT, Home_Lon=HLON)

school_work_locs <- chts_rel$PERSON %>%
  select(SAMPN,PERNO, school_lat=SYCORD, school_lon=SXCORD, school_name=SNAME,
         work_lon=WLON, work_lat=WLAT, work_name=WNAME, work_name2=WNAME2)

school_work_activities <- chts_rel$ACTIVITY %>%
  group_by(SAMPN, PERNO, PLANO) %>%
  # summarise(school_acts = any(APURP == 'IN SCHOOL/CLASSROOM/LABORATORY'),
  #           work_acts   = any(APURP == 'WORK/JOB DUTIES', str_detect(APURP, "AT WORK")))
  summarise(school_acts = any(APURP == 'IN SCHOOL/CLASSROOM/LABORATORY',
                           str_detect(APURP, "AT SCHOOL")),
         work_acts   = any(APURP == 'WORK/JOB DUTIES', 
                           str_detect(APURP, "AT WORK"), 
                           str_detect(APURP, "AT MY WORK")))

# school_work_activities$work_acts %>% as.numeric() %>% sum(na.rm = TRUE)
# 1. 39837
# 2. 40373
# 3. 40763

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
         school_match_acts  = school_acts * 3,
         work_match_lat     = abs(LAT - work_lat) < lat_match,
         work_match_lon     = abs(LON - work_lon) < lon_match,
         work_match_name1   = PNAME == 'WORK',
         work_match_name2   = one_word_match(PNAME, work_name) | one_word_match(PNAME, work_name2) |
           (PNAME == work_name) | (PNAME == work_name2),
         work_match_acts    = work_acts * 2)


#' Calculate total matches and choose place category.
#' this basically says: "if either the place name or place location match as expected, then 

locs_rel_matched <- locs_rel_matchpts %>%
  mutate(home_match_points   = rowSums(select(., starts_with('home_match')), na.rm=T),
         school_match_points = rowSums(select(., starts_with('school_match')), na.rm=T),
         work_match_points   = rowSums(select(., starts_with('work_match')), na.rm=T),
         place_type = case_when(home_match_points >= 1 ~ 'Home',
                                school_match_points >= 3 &
                                  school_match_points >= work_match_points ~ 'School',
                                work_match_points >= 3 &
                                  work_match_points > school_match_points ~ 'Work',
                                TRUE ~ 'Other'))

#####
# override with "at my work", "in school", "at school", "at work"
#####


