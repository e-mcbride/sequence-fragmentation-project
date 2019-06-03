library(tidyverse); library(here)

chts_rel <- read_rds(here("data", "original", "CHTS_all2018-03-05_.rds"))

place <- chts_rel$PLACE

place %>% 
  # mutate(caps.mode = str_to_upper(MODE)) %>% 
  group_by(MODE) %>% 
  count %>% 
  clipr::write_clip()

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

chts <- chts_rel
chts$PLACE <- pl.new

chts$PLACE$MODE %>% unique

write_rds(chts,"data/chts_all_2019-05-22.rds")

pl.new$MODE %>% unique

place$MODE %>% unique


# %>% 
#   arrange(desc(n))

#' car driving alone, car driving others, car passengers, transit/pool passengers, walk, other motorized, other nonmotorized

# TOTTR is total people traveling on trip, tottr >1 is more than 1 person
pl.mode <- place %>% 
  left_join(modes, by = c("MODE")) %>%
  mutate(mode.simple = 
           case_when(
             str_detect(new.mode, "PASSENGER") ~ "vehicle passenger",
             str_detect(new.mode, "DRIVER") & PARTY < 2 ~ "vehicle driving alone",
             str_detect(new.mode, "DRIVER") & PARTY > 1 ~ "vehicle driving others",
             str_detect(new.mode, "WALK") ~ "walk",
             str_detect(new.mode, "BIKE") ~ "bike",
             str_detect(new.mode, "BUS") ~ "transit",
             str_detect(new.mode, "METRO")  ~ "transit",
             str_detect(new.mode, "STREET CAR") ~ "transit", 
             str_detect(new.mode, "MOTORCYCLE") ~ "other motorized",
             str_detect(new.mode, "STREET CAR") ~ "transit", 
             str_detect(new.mode, "SHUTTLE") ~ "transit", 
             str_detect(new.mode, "") ~ "other non-motorized", 
             TRUE ~ "other"
           )) %>% 
  select(new.mode, mode.simple) %>% 
  distinct()


# modes %>% 
#   # left_join(modes, by = c("MODE")) %>%
#   mutate(mode.simple = 
#            case_when(
#              str_detect(new.mode, "PASSENGER") ~ "car passenger",
#              str_detect(new.mode, "DRIVER") ~ "driver",
#              str_detect(new.mode, "WALK") ~ "walk",
#              str_detect(new.mode, "BIKE") ~ "bike",
#              str_detect(new.mode, "BUS") ~ "PT",
#              TRUE ~ "other"
#            )) %>% 
#   View


place %>% 
  select(SAMPN, PERNO, PLANO, PARTY, HHMEM) %>% 
  # distinct() %>% 
  mutate(party.n = as.numeric(PARTY),
         hhmem.n = as.numeric(HHMEM),
         party.n - hhmem.n) %>% 
  View()

place %>% group_by(PARTY) %>% count() %>% View()
place %>% group_by(HHMEM) %>% count() %>% View()

#####
# Fixing the messed up APURP variable with a crosswalk
#####
chts_rel <- read_rds(here("data", "original", "CHTS_all2018-03-05_.rds"))


activity <- chts_rel$ACTIVITY
ac <- activity %>% select(SAMPN, PERNO, PLANO, ACTNO, APURP) 


#get the new activity categories AND clean up category names
activities_crosswalk <- readxl::read_excel(here("data", "activity_purps_crosswalk_touppercase.xlsx"))
# gather(key = "key", value = "old.apurp", -new.apurp, -Act_Cat) %>% 
# select(-key)



act.cat <- ac %>% 
  left_join(activities_crosswalk, by = c("APURP" = "old.apurp")) %>% 
  mutate(APURP = new.apurp) %>% select(-new.apurp)

act.cat$APURP %>% unique

act.cat %>% group_by(APURP) %>% count %>% arrange(desc(n))

