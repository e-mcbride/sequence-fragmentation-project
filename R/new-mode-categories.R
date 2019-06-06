# creating the modified, shrunken mode categories

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