# 02_

library(tidyverse); library(here)

places_dat <- read_rds(here("data","places_county-selection.rds"))

### Recoding variables: Make personID variable, change starting times to 1 instead of 0 by adding one minute to everything, simpler place_types names, AND saving it as a data.frame so traminer can use it
#' I did this because traminer requires the sequence data to have no values <1
#' # Also Making the overall id variable, a shortened placetype variable, and recoding the already-included travel as "loop" and "transfer" since those were wrongly placed in the "Other" category.


places_mod <- places_dat %>% 
  mutate(
    pid =            as.numeric(str_c(SAMPN, PERNO)),
    pltype =         recode(place_type, Other = "O", Home = "H", Work = "W", School = "S"), 
    arr_time3_add1 = arrival_time_3 + 1, 
    dep_time3_add1 = departure_time_3 + 1,
    activity_type =  if_else(condition = (purpose_A1 == "CHANGE TYPE OF TRANSPORTATION/TRANSFER (WALK TO BUS, WALK TO/FROM PARKED CAR)"),
                             true = "Transfer",
                             false = activity_type),
    activity_type =  if_else(condition = (purpose_A1 == "LOOP TRIP (FOR INTERVIEWER ONLY-NOT LISTED ON DIARY)"),
                             true = "Loop",
                             false = activity_type)) %>% 
  data.frame()

places_mod %>% readr::write_rds(here("data","modified_pldat.rds"))

