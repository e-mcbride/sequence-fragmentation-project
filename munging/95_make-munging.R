library(here); library(fs)

if (!dir_exists(here("data"))) {
  dir_create(here("data"))
}

if (!dir_exists(here("figs"))) {
  dir_create(here("figs"))
}

if (!dir_exists(here("munging"))) {
  dir_create(here("munging"))
}

#####
# First: input what you want the counties to be
#####

#' the end result of the following code will be `chts_rel`. This object will be used throughout the following munging scripts.

library(here);library(tidyverse); library(janitor)

#' Make vector of the counties you want (I WANNA MOVE THIS OUT TO MAKEFILE) 

chts_all <- readr::read_rds(here("data-raw", "chts_all_2019-06-18.rds"))

#' This is where you would pull the counties you want:


counties <- chts_all$HOUSEHOLD %>% 
  distinct(CTFIP) %>% 
  .$CTFIP

# params = list()
# params$counties <- "SANTA BARBARA, SAN LUIS OBISPO"
# params$counties <- chts_all$HOUSEHOLD %>% distinct(CTFIP)
# counties <- params$counties %>% 
#   str_split(pattern=',',simplify=T) %>%
#   str_trim() %>% 
#   str_to_upper()


#' Grab that subset of the data:
rel_hhids <- chts_all$HOUSEHOLD %>%
  filter(CTFIP %in% counties) %>% distinct(SAMPN)

# x <- chts_all$HOUSEHOLD %>% distinct(SAMPN) # testing to make sure the line above captured everyone and it did


#' Remove empty columns from all the CHTS tables:
chts_rel <- chts_all %>%
  map(semi_join, rel_hhids, by='SAMPN') %>% 
  map(janitor::remove_empty,which = "cols")

chts_rel %>% write_rds(here("data", "chts-all-tables_selection.rds"))

rm(chts_all)


# This section will put together the file `places_slo_sb.rds` used throughout the analysis
# source(here("R/01_01_extract-all-chts-tables_slo-sb.R"))
source(here("munging", "01_02_classify-places-HWSO.R"))
source(here("munging", "01_03_time-in-min-since-3am.R"))
source(here("munging", "01_04_activity-var-processing.R"))
# source(here("munging", "01_05_trip-dist-axx-processing.R")) # BROKEN TIL I GET FILES FROM ADAM
source(here("munging", "01_06_pr-hh-pl-vars.R"))

# WARNING: ONLY RUN THE FOLLOWING AFTER YOU HAVE FIXED 04 AND 05: (trying it without 5)
source(here("munging","01_95_make-place-file.R"))

source(here("munging","02_modify-place-file.R"))
source(here("munging","03_01_adding-travel-rows.R")) # FLAGGED FOR POTENTIAL ISSUES CAUSED
