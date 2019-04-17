# 01_95_make-place-file.R

library(fs); library(here); library(tidyverse)

#' pull in all the place file pieces we just built (marked by ending in "_places.rds") and join them together
locations_mainvars <- dir_ls(here("data"), glob = "*_places.rds") %>% 
  map(read_rds) %>% 
  reduce(left_join)


# write this dataset to disk
# ... can be connected with other chts tables later using left_join
locations_mainvars %>% write_rds('data', 'places_slo_sb.rds')
locations_mainvars %>% write_csv('data', 'places_slo_sb.csv')









