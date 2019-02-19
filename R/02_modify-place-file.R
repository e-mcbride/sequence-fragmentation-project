# 02_

library(TraMineR); library(tidyverse); library(here)

places_dat <- read_rds(here("data","places_slo_sb.rds"))

### Recoding variables: Make personID variable, change starting times to 1 instead of 0 by adding one minute to everything, simpler place_types names, AND saving it as a data.frame so traminer can use it
#' I did this because traminer requires the sequence data to have no values <1 
#' 

places_mod <- places_dat %>% 
  #mutate(pid = as.numeric(str_c(SAMPN, PERNO))) %>% 
  mutate(pid = str_c(SAMPN, PERNO)) %>% 
  #mutate(place_fac = as.factor(place_type), place_int = as.integer(place_fac)) %>%
  mutate(arr_time3_add1 = arrival_time_3 + 1, dep_time3_add1 = departure_time_3 + 1) %>%
  mutate(pltype = recode(place_type, Other = "O", Home = "H", Work = "W", School = "S")) %>%
  data.frame()

places_mod %>% readr::write_rds(here("data","modified_pldat.rds"))


