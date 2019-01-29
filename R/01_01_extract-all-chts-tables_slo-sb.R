## This will be the first script in the TraMineR newly-organized scripts (at least round 1 of it)


library(here);library(tidyverse); library(janitor)

# Make vector of the counties you want (I WANNA MOVE THIS OUT TO MAKEFILE) 
counties <- c("SANTA BARBARA", "SAN LUIS OBISPO")

chts_all <- readr::read_rds(here("data", "CHTS_all2018-03-05_.rds"))

# Pull the counties you want:
params = list()
params$counties <- "SANTA BARBARA, SAN LUIS OBISPO"

counties <- params$counties %>% 
  str_split(pattern=',',simplify=T) %>% 
  str_trim() %>% 
  str_to_upper()


# Grab that subset of the data:
rel_hhids <- chts_all$HOUSEHOLD %>%
  filter(CTFIP %in% counties) %>% distinct(SAMPN)

rel_hhids %>% write_rds(here("data", "chts-hhids_slo-sb.rds"))


# Remove empty columns from all the CHTS tables:
chts_rel <- chts_all %>%
  map(semi_join, rel_hhids, by='SAMPN') %>% 
  map(janitor::remove_empty,which = "cols")

chts_rel %>% write_rds(here("data", "chts-all-tables_slo-sb.rds"))

