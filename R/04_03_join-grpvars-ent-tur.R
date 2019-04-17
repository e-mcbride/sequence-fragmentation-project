# 04_03 Combining grouping variables with entropy and turbulence to a table

library(tidyverse); library(TraMineR); library(here)

pl.en_tu <- read_rds()

grpvars <- read_rds()

grp_en_tu <- pl.en_tu %>% left_join(grpvars, by = c("SAMPN", "PERNO", "pid")) %>% 
  select(SAMPN, PERNO, pid, HHSIZ, RACE, HISP, NTVTY, DISAB, GEND, INCOM, pov_lvl, AGE, Und16, Entropy, Turbulence)


write_rds(grp_en_tu, here("data",""))

