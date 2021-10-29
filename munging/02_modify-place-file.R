# 02_modify-place-file

library(tidyverse); library(here)

places_dat <- read_rds(here("data","places_county-selection.rds"))

### Recoding variables: Make personID variable, change starting times to 1 instead of 0 by adding one minute to everything, simpler place_types names, AND saving it as a data.frame so traminer can use it
#' I did this because traminer requires the sequence data to have no values <1
#' # Also Making the overall id variable, a shortened placetype variable, and recoding the already-included travel as "loop" and "transfer" since those were wrongly placed in the "Other" category.


pl_mod <- places_dat %>% 
  mutate(
    pid =            as.numeric(str_c(SAMPN, PERNO)),
    arr_time3_add1 = arrival_time_3 + 1, 
    dep_time3_add1 = departure_time_3 + 1,
    activity_type =  if_else(condition = (purpose_A1 == "CHANGE TYPE OF TRANSPORTATION/TRANSFER (WALK TO BUS, WALK TO/FROM PARKED CAR)"),
                             true = "Transfer",
                             false = activity_type),
    activity_type =  if_else(condition = (purpose_A1 == "LOOP TRIP (FOR INTERVIEWER ONLY-NOT LISTED ON DIARY)"),
                             true = "Loop",
                             false = activity_type),
    place_type = if_else(condition = activity_type == "Transfer" | activity_type == "Loop",
                         true = "Travel",
                         false = place_type),
    pltype =         recode(place_type, Other = "O", Home = "H", Work = "W", School = "S", Travel = "T")) %>% 
  
  # below, we make the new arrival/departure times to fix issues with spending zero minutes in a place
  
  mutate(new_end = if_else((dep_time3_add1 - arr_time3_add1) == 0, 
                           true = (dep_time3_add1 + 1), 
                           false = dep_time3_add1)) %>% 

  group_by(pid) %>%
  mutate(a_vs_d = arr_time3_add1 - lag(new_end)) %>%
  ungroup() %>% 
  
  mutate(new_start = if_else(condition= a_vs_d >= 0 | is.na(a_vs_d), 
                             true = arr_time3_add1, 
                             false = arr_time3_add1 + 1)) %>% 
  
  select(-arr_time3_add1, -dep_time3_add1, -new_end, new_end) %>% 
  rename(arr_time3_add1 = new_start,
         dep_time3_add1 = new_end) %>% 
  
  #next, we fix the NA transfer rows
  group_by(pid) %>% 
  mutate(arr_time3_add1 = if_else(condition = is.na(arr_time3_add1) & activity_type == "Transfer",
                                  true = lag(dep_time3_add1),
                                  false = arr_time3_add1),
         dep_time3_add1 = if_else(condition = is.na(dep_time3_add1) & activity_type == "Transfer",
                                  true = lead(arr_time3_add1),
                                  false = dep_time3_add1)) %>% 
  
  ungroup() %>% 
  
  # here, we are removing the rows that are duplicates from salvageable cases
  filter(is.na(a_vs_d) | (a_vs_d > -1)) %>% 
  
  select(-a_vs_d)




#' Removing the people with NA's for their arrival/departure times
#' also removing people with negative durations (meaning their numbers were flipped)
#' also removing people whose times don't end at 1440 and whose times dont start at 1
pids_na_arr_dep <- pl_mod %>%
  select(pid, arr_time3_add1, dep_time3_add1) %>%
  gather(key = "key", value = "value", -pid) %>%
  filter(is.na(value)) %>%
  .$pid %>% unique

pids_neg_dur <- pl_mod %>% 
  select(pid, arr_time3_add1, dep_time3_add1) %>%
  mutate(duration = dep_time3_add1 - arr_time3_add1) %>% 
  filter(duration < 0) %>% 
  .$pid %>% unique

pids_no1440 <- pl_mod %>% 
  select(source, pid, PLANO, PTYPE, arr_time3_add1, dep_time3_add1) %>%
  group_by(pid) %>% 
  mutate(lastplace = max(PLANO),
         maxtime = max(dep_time3_add1)) %>% 
  ungroup() %>%
  filter(maxtime != 1440) %>% 
  .$pid %>% unique

pids_no_start1 <- pl_mod %>% 
  select(source, pid, PLANO, PTYPE, arr_time3_add1, dep_time3_add1) %>%
  group_by(pid) %>% 
  mutate(mintime = min(arr_time3_add1)) %>% 
  ungroup() %>%
  filter(mintime > 1) %>% 
  .$pid %>% unique

pids <- c(pids_na_arr_dep, pids_neg_dur, pids_no1440, pids_no_start1) %>% unique

hids <- pids %>% str_sub(end = -2) %>% as.numeric %>% unique()

places_mod <- pl_mod %>% ungroup() %>% 
  filter(!(SAMPN %in% hids)) %>% 
  data.frame()

nrow(pl_mod) - nrow(places_mod) # we lost 9800 place reports


# places_mod <- pl_mod %>% filter(!(pid %in% pids_na_arr_dep)) #for only removing person records


places_mod %>% readr::write_rds(here("data","modified_pldat.rds"))


