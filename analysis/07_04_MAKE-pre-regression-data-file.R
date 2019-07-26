# making the pr data with everything
library(tidyverse); library(here)

cluster_ses <- readr::read_rds(here::here("data","cluster_ses.rds"))
min_by_state <-  readr::read_rds(here("data", "min-by-state.rds"))
CHTS_LUgrp <- readr::read_rds(here::here("data", "lpa-LU-grps_chts-srbi-nust.rds"))



pr_dat <-cluster_ses %>% 
  left_join(CHTS_LUgrp, by = c("source", "SAMPN")) %>% 
  left_join(min_by_state, by = c("pid")) # %>% 
# mutate(i = 1) %>% 
# spread(pov_lvl, i, fill = 0, sep = ".") 
# age.grp.f = factor(AgeGrp, ordered = FALSE, exclude = "Unknown"))


pr_dat %>% write_rds(here::here("data","pr-dat_for-lm.rds"))
# pr_dat <- read_rds(here::here("data","pr-dat_for-lm.rds"))