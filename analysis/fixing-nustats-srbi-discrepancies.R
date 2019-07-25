library(tidyverse); library(here)

# chts <- read_rds(here("data", "original", "CHTS_all2018-03-05_.rds"))
chts <- readr::read_rds(here::here("data-raw","chts_all_2019-06-18.rds"))
place <- chts$PLACE

#####
# Mode discrepancies in PLACE file
#####

place %>% 
  # mutate(caps.mode = str_to_upper(MODE)) %>% 
  group_by(MODE) %>% 
  count %>% 
  View()
  # clipr::write_clip()

mode.xw <- read_csv(here("data","mode_crosswalk.csv"))
modes <- place %>% 
  group_by(MODE) %>% 
  count %>% 
  ungroup() %>% 
  select(-n) %>% 
  left_join(mode.xw, by = c("MODE" = "old.mode")) %>% 
  mutate(new.mode = str_to_upper(new.mode))

pl.new <- place %>% left_join(modes, by = "MODE") %>% 
  mutate(MODE = new.mode) %>% select(-new.mode)


chts$PLACE <- pl.new

chts$PLACE$MODE %>% unique

pl.new$MODE %>% unique

place$MODE %>% unique

chts %>% readr::write_rds(here::here("data-raw","chts_all_2019-06-18.rds"))


#####
# Fixing the messed up APURP variable with a crosswalk
#####

activity <- chts$ACTIVITY
ac <- activity %>% select(SAMPN, PERNO, PLANO, ACTNO, APURP) 

unique(ac$APURP) %>% View

#get the new activity categories AND clean up category names
activities_crosswalk <- readxl::read_excel(here("data", "activity_purps_crosswalk_touppercase.xlsx"))
# gather(key = "key", value = "old.apurp", -new.apurp, -Act_Cat) %>% 
# select(-key)

ac <- activity %>% 
  select(APURP) %>% 
  distinct() %>% 
  left_join(activities_crosswalk, by = c("APURP" = "old.apurp"))

act.new <- activity %>% 
  left_join(ac, by = "APURP") %>% 
  mutate(APURP = new.apurp) %>%
  select(-new.apurp)

act.new$APURP %>% unique() %>% View()


act.new %>% 
  group_by(APURP) %>% 
  count %>% 
  arrange(desc(n)) %>% 
  View()

chts$ACTIVITY <- act.new

chts$ACTIVITY$APURP %>% unique() %>% View()

write_rds(chts,here("data-raw","chts_all_2019-05-22.rds"))


#####
# Fixing the missing arrival/departure times from SRBI 
#####
library(tidyverse); library(lubridate);library(here)

chts <- read_rds(here::here("data-raw","chts_all_2019-05-22.rds"))
# place <- chts$PLACE

#' Try reading in the place file by itself instead of from the new chts one to make sure it's legit
place <- readr::read_rds(here::here("data-raw", "CHTS_PLACE_2018-03-05.rds"))

# activity <- chts$ACTIVITY

# srbi_place <- place %>% filter(source == "SRBI")
# srbi_act <- activity %>% filter(source == "SRBI")

plsrbi <- place %>% select(source, SAMPN, PERNO, PLANO, ARRTM, DEPTM) %>% filter(source == "SRBI")


converttime <- plsrbi %>% 
  mutate(arr_min = (hm(ARRTM) %>% as.numeric())/60,
         dep_min = (hm(DEPTM) %>% as.numeric())/60)


srbi_arr_dep_times <- converttime %>% 
  group_by(SAMPN, PERNO) %>% 
  mutate(lastplace = PLANO == max(PLANO)) %>% 
  ungroup() %>%
  mutate(arr_srbi   = case_when(!is.na(arr_min)             ~ arr_min,
                                PLANO == 1 & is.na(arr_min) ~ 180),
         dep_srbi = case_when(!is.na(dep_min)             ~ dep_min,
                              # lastplace & is.na(dep_min)  ~ 179)) %>%
                              lastplace & is.na(dep_min)  ~ 1619)) %>%
  
  mutate(arr_hr_srbi  = if_else(condition = (arr_srbi %/% 60) > 24, # change to match nustats
                                true      = (arr_srbi %/% 60)-24, 
                                false     =(arr_srbi %/% 60)),
         arr_min_srbi = arr_srbi %% 60,
         # dep_hr_srbi  = dep_srbi %/% 60,
         dep_hr_srbi  = if_else(condition = (dep_srbi %/% 60) > 24, # change to match nustats
                                true      = (dep_srbi %/% 60)-24, 
                                false     =(dep_srbi %/% 60)),
         dep_min_srbi = dep_srbi %% 60) %>%
  
  mutate_at(vars(ends_with("_srbi")), as.integer) %>% 
  
  select(SAMPN, PERNO, PLANO, arr_hr_srbi, arr_min_srbi, dep_hr_srbi, dep_min_srbi)


place_timefix <- place %>% left_join(srbi_arr_dep_times, by = c("SAMPN", "PERNO", "PLANO")) %>% ungroup()

plnew <- place_timefix %>% 
  mutate(arr_h  = case_when(source == "SRBI"    ~ arr_hr_srbi,
                            source == "NuStats" ~ ARR_HR),
         arr_m = case_when(source == "SRBI"    ~ arr_min_srbi,
                           source == "NuStats" ~ ARR_MIN),
         dep_h = case_when(source == "SRBI"    ~ dep_hr_srbi,
                           source == "NuStats" ~ DEP_HR),
         dep_m = case_when(source == "SRBI"    ~ dep_min_srbi,
                           source == "NuStats" ~ DEP_MIN)) %>% 
  select(-ARR_HR, -ARR_MIN, -DEP_HR, -DEP_MIN, -arr_hr_srbi, -arr_min_srbi, -dep_hr_srbi, -dep_min_srbi) %>%
  rename(ARR_HR  = arr_h,
         ARR_MIN = arr_m,
         DEP_HR = dep_h,
         DEP_MIN = dep_m)

chts$PLACE <- plnew

write_rds(chts,path = here::here("data-raw","chts_all_2019-06-18.rds"))


#####
# PNAME is not what it's called for SRBI
#####


#####
# RELAT in person file
#####
library(tidyverse); library(here)
chts <- readr::read_rds(here::here("data-raw","chts_all_2019-06-18.rds"))
relat_xw <- readr::read_csv(here::here("data", "pr-xwalk-RELAT.csv"))
pr <- chts$PERSON

new_pr <- pr %>% 
  # select(SAMPN, PERNO, RELAT) %>% 
  left_join(relat_xw, by = "RELAT") %>% 
  select(-RELAT, RELAT = new_relat) %>% 
  select(source:GEND, RELAT, everything())

new_pr$RELAT %>% unique

chts$PERSON <- new_pr

write_rds(chts,path = here::here("data-raw","chts_all_2019-06-18.rds"))
