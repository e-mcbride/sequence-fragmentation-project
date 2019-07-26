# modes: summary of percent of modes of trips in each of the 9 clusters
library(tidyverse);library(here)

chts_rel <- readr::read_rds(here::here("data-raw","chts_all_2019-06-18.rds"))



place <- chts_rel$PLACE

pl_mode <- place %>% 
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




# read in the 
pr_dat <- read_rds(here::here("data","pr-dat_for-lm.rds"))

cl_ids <- pr_dat %>% select(pid, SAMPN, PERNO, cluster, namedcluster)
pids <- cl_ids$pid
# percent of modes

z <- pl_mode %>% inner_join(cl_ids, by = c("SAMPN", "PERNO"))
# 
# y <- pl_mode %>% mutate(pid = str_c(SAMPN, PERNO, sep = "") %>% as.numeric()) %>% filter(pid %in% pids)


z %>% group_by(namedcluster, mode.simple) %>% 
  summarise(n())

y <- z %>% 
  select(pid, PLANO, namedcluster, mode.simple) %>% 
  filter(!is.na(mode.simple)) %>%
  mutate(temp =1) %>%
  group_by(namedcluster) %>%
  # mutate(tot_trips = sum(temp)) %>% select(-temp) %>%
  # ungroup() %>%
  summarise(tot_trips = n())
  
x <- z %>% 
  select(pid, PLANO, namedcluster, mode.simple) %>% 
  filter(!is.na(mode.simple)) %>%
  
  group_by(namedcluster, mode.simple) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  # group_by(namedcluster) %>%
  # summarise(sum(n)) %>% 
  spread(key = mode.simple, value = n, fill = 0)
  # mutate(tot = bike + other + `other motorized` + `other non-motorized` + transit + `vehicle driving alone` +
  #          `vehicle driving others` + `vehicle passenger`)




ratios <- x %>% left_join(y) %>% 
  mutate_at(vars(-namedcluster, -tot_trips), list(ratio = ~./tot_trips))

ratios %>% readr::write_csv(here::here("figs", "mode-ratios.csv"))
