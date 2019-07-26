# creating the modified, shrunken mode categories

#' car driving alone, car driving others, car passengers, transit/pool passengers, walk, other motorized, other nonmotorized

# TOTTR is total people traveling on trip, tottr >1 is more than 1 person
library(tidyverse);library(here)
chts_rel <- readr::read_rds(here::here("data-raw","chts_all_2019-06-18.rds"))



place <- chts_rel$PLACE


place %>% 
  # mutate(caps.mode = str_to_upper(MODE)) %>% 
  group_by(MODE) %>% 
  count %>% 
  View()
# clipr::write_clip()


pl.mode <- place %>% 
  # left_join(modes, by = c("MODE")) %>%
  mutate(PARTY = as.numeric(PARTY),
         mode.simple = 
           case_when(
             str_detect(MODE, "PASSENGER")                            ~ "vehicle passenger",
             str_detect(MODE, "DRIVER") & (PARTY < 2 | is.na(PARTY))  ~ "vehicle driving alone",
             str_detect(MODE, "DRIVER") & PARTY > 1                   ~ "vehicle driving others",
             str_detect(MODE, "WALK")                                 ~ "walk",
             str_detect(MODE, "BIKE")                                 ~ "bike",

             str_detect(MODE, "MOTORCYCLE")                           ~ "other motorized",
             str_detect(MODE, "CARPOOL / VANPOOL")                    ~ "other motorized",
             str_detect(MODE, "RENTAL CAR/VEHICLE")                   ~ "other motorized",
             str_detect(MODE, "OTHER PRIVATE TRANSIT")                ~ "other motorized",
             str_detect(MODE, "TAXI / HIRED CAR / LIMO")              ~ "other motorized",
             
             str_detect(MODE, "BUS")                                  ~ "transit",
             str_detect(MODE, "METRO")                                ~ "transit",
             str_detect(MODE, "STREET CAR")                           ~ "transit", 
             str_detect(MODE, "STREET CAR")                           ~ "transit", 
             str_detect(MODE, "SHUTTLE")                              ~ "transit", 
             str_detect(MODE, "OTHER RAIL")                           ~ "transit", 
             str_detect(MODE, "DIAL-A-RIDE")                          ~ "transit", 
             str_detect(MODE, "AIRBART / LAX FLYAWAY")                ~ "transit", 
             
             str_detect(MODE, "WHEELCHAIR / MOBILITY SCOOTER")        ~ "other non-motorized", 
             str_detect(MODE, "OTHER NON-MOTORIZED")                  ~ "other non-motorized", 
             is.na(MODE)                                              ~ NA_character_,
             TRUE                                                     ~ "other"
           )) 
# %>% 
  # mutate(mode.simple = if_else(mode.simple == "FLAG", true = NA_character_, false = mode.simple)) %>% 
  # select(MODE, mode.simple) %>% #, PARTY) %>% 
  # distinct()

## below: checkign to see wiether the PARTY variable is the total count of ppl with you. It does seem to be

z <- pl.mode %>% 
  select(source, SAMPN, PERNO, PLANO, MODE, mode.simple, PARTY, HHMEM, NONHH, PNAME, PTYPE) %>% 
  # distinct() %>%
  mutate(party.n = if_else(is.na(PARTY), 0, PARTY),
         hhmem.n = as.numeric(HHMEM),
         hhmem.n = if_else(condition = is.na(hhmem.n), true = 0, false = hhmem.n),
         nonhh.n = as.numeric(NONHH),
         nonhh.n = if_else(condition = is.na(nonhh.n), true = 0, false = nonhh.n),
         tot = party.n - hhmem.n-nonhh.n) %>%
  # filter(is.na(tot)) %>%
  filter(PLANO > 1)

z$MODE %>% unique %>% View

##### it does seem to be



place %>% filter(PLANO > 1) %>% group_by(PARTY) %>% count() %>% View()
place %>% group_by(HHMEM) %>% count() %>% View()

rm(z)
#####



