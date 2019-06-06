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

