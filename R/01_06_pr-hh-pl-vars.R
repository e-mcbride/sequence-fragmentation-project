# 01_06_pr-hh-pl-vars.R
library(here); library(tidyverse)

# chts_rel <- readr::read_rds(here("data", "chts-all-tables_slo-sb.rds"))

## Extract additional place-level fields


# place_chars_other <- 
chts_rel$PLACE %>%
  select(SAMPN,PERNO,PLANO,PLAT=LAT,PLON=LON,MODE,TRIPDUR,PNAME:ZIP) %>% 
  readr::write_rds(here("data", "pl-vars_places.rds"))

## Extract relevant person-level fields


# person_chars <- 
chts_rel$PERSON %>% 
  select(SAMPN:AGE,WKSTAT,JOBS,INDUS,OCCUP,STUDE,EDUCA) %>%
  readr::write_rds(here("data", "pr-vars_places.rds"))

## Extract relevant household-level fields

# household_chars <- 
chts_rel$HOUSEHOLD %>% 
  select(SAMPN,HLAT,HLON,CTFIP,HHSIZ:HHVEH,RESTY,INCOM,HHTRIPS) %>%
  readr::write_rds(here("data", "hh-vars_places.rds"))
