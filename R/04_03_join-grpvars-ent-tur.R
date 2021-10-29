# 04_03 Combining grouping variables with entropy and turbulence to a table

library(tidyverse); library(here)

pl.en_tu_com <- read_rds(here("results", "ent-tur-com_place-seq.rds"))

grpvars <- read_rds(here("data", "grouping-variables.rds"))

grp_en_tu <- pl.en_tu_com %>% left_join(grpvars, by = c("SAMPN", "PERNO", "pid")) %>% 
  filter(!is.na(source))

write_rds(grp_en_tu, here("results","grpvars_ent-tur-com.rds"))


