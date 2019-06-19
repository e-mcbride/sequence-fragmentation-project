library(tidyverse); library(here)

chts <- read_rds(here("data", "original", "CHTS_all2018-03-05_.rds"))

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
library(tidyverse); library(here)

chts <- read_rds(here("data-raw","chts_all_2019-05-22.rds"))
place <- chts$PLACE
activity <- chts$ACTIVITY

# srbi_place <- place %>% filter(source == "SRBI")
srbi_act <- activity %>% filter(source == "SRBI")

srbi_arr_dep_times <- srbi_act %>% 
  select(SAMPN, PERNO, PLANO, ARRTM, DEPTM) %>% 
  distinct() %>% 
  group_by(SAMPN, PERNO) %>% 
  mutate(lastplace = PLANO == max(PLANO)) %>% 
  ungroup() %>% 
  
  mutate(ARRTM = ARRTM/60, DEPTM = DEPTM/60) %>% 
  
  mutate(arr_srbi   = case_when(!is.na(ARRTM)             ~ ARRTM,
                                PLANO == 1 & is.na(ARRTM) ~ 180),
         dep_srbi = case_when(!is.na(DEPTM)             ~ DEPTM,
                              # lastplace & is.na(DEPTM)  ~ 179)) %>%
                              lastplace & is.na(DEPTM)  ~ 1619)) %>%

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

write_rds(chts,here("data-raw","chts_all_2019-06-18.rds"))

