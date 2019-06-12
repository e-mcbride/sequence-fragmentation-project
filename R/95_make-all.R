# This will be the eventual MAKEFILE-type thing with `source()` for each part of the code


library(here); library(fs)

if (!dir_exists(here("data"))) {
  dir_create(here("data"))
}

if (!dir_exists(here("figs"))) {
  dir_create(here("figs"))
}

#####
# First: input what you want the 
#####
library(here);library(tidyverse); library(janitor)

#' Make vector of the counties you want (I WANNA MOVE THIS OUT TO MAKEFILE) 

chts_all <- readr::read_rds(here("data-raw", "chts_all_2019-05-22.rds"))

#' Pull the counties you want:
params = list()
params$counties <- "SANTA BARBARA, SAN LUIS OBISPO"
# params$counties <- chts_all$HOUSEHOLD %>% distinct(CTFIP)

counties <- chts_all$HOUSEHOLD %>% 
  distinct(CTFIP) %>% 
  .$CTFIP


# counties <- params$counties %>% 
#   str_split(pattern=',',simplify=T) %>%
#   str_trim() %>% 
#   str_to_upper()


#' Grab that subset of the data:
rel_hhids <- chts_all$HOUSEHOLD %>%
  filter(CTFIP %in% counties) %>% distinct(SAMPN)

# x <- chts_all$HOUSEHOLD %>% distinct(SAMPN) # testing to make sure the line above captured everyone and it did


#' rel_hhids %>% write_rds(here("data", "chts-hhids_slo-sb.rds"))
#' 

#' Remove empty columns from all the CHTS tables:
chts_rel <- chts_all %>%
  map(semi_join, rel_hhids, by='SAMPN') %>% 
  map(janitor::remove_empty,which = "cols")

chts_rel %>% write_rds(here("data", "chts-all-tables_selection.rds"))

rm(chts_all)

#####
# Next, run the other stuff
#####

# This section will put together the file `places_slo_sb.rds` used throughout the analysis
# source(here("R/01_01_extract-all-chts-tables_slo-sb.R"))
source(here("R/01_02_classify-places-HWSO.R"))
source(here("R/01_03_time-in-min-since-3am.R"))
source(here("R/01_04_activity-var-processing.R"))
# source(here("R/01_05_trip-dist-axx-processing.R")) # BROKEN TIL I GET FILES FROM ADAM
source(here("R/01_06_pr-hh-pl-vars.R"))

# WARNING: ONLY RUN THE FOLLOWING AFTER YOU HAVE FIXED 04 AND 05: (trying it without 5)
source(here("R/01_95_make-place-file.R"))

source(here("R/02_modify-place-file.R"))
source(here("R/03_01_adding-travel-rows.R")) # FLAGGED FOR POTENTIAL ISSUES CAUSED

source(here("R","run-sequence-analysis.R")) 

#####
rmarkdown::render(here("README.Rmd"))
## I'm not really sure why this is being created, tbh
file_delete("README.html")
