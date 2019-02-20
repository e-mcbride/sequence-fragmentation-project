# 04_02 Building socioeconomic status grouping variables

library(tidyverse); library(TraMineR); library(here)


chts <- read_rds(here("data","original","CHTS_all2018-03-05_.rds"))
places <- read_rds(here("data","modified_pldat.rds"))

# pulling variables of interest from person data that were not already joined to the place data
chts_sel <- chts$PERSON %>%
  mutate(pid = as.numeric(str_c(SAMPN, PERNO))) %>%
  select(pid, HISP, RACE, NTVTY, DISAB, DTYPE, GEND, AGE)


pl.grpvars <- places %>% 
  select(pid, SAMPN, PERNO, HHSIZ, HHWRK, HHVEH, RESTY, INCOM) %>%
  distinct() %>%
  #mutate(gendnoRF = if_else(GEND == "RF", "FEMALE", GEND)) %>%
  left_join(chts_sel, by = "pid")

incomevals <- pl.grpvars %>% select(INCOM) %>% unique() %>% 
  mutate(renameinc = str_remove_all(INCOM,c("\\$|\\,| or more"))) %>%
  #split
  tidyr::separate(col = renameinc, into = c("lobound", "hibound"), sep = " to ", remove = F) %>%
  mutate(inc_hi = as.numeric(hibound),
         inc_lo = as.numeric(lobound)) %>%
  arrange(inc_lo)


npr_extra <- c(1,2,3,4,5,6,7,8)-1
extrainc <- npr_extra * 3960
povlines <- extrainc + 11170
npr <- seq(1:8)
inc_pr <- povlines/npr

pov_tbl <- bind_cols(HHSIZ = npr, povlines = povlines, povinc_pr = inc_pr)
rm(npr_extra, extrainc, povlines, npr, inc_pr)

grpvars <- pl.grpvars %>% 
  left_join((incomevals %>% select(INCOM, inc_hi, inc_lo)), by = "INCOM") %>% 
  mutate(inc_hi_pr = inc_hi/HHSIZ,
         inc_lo_pr = inc_lo/HHSIZ) %>%
  left_join(pov_tbl, by = "HHSIZ") %>%
  mutate(inc_lo_thresh = inc_lo_pr - povinc_pr,
         inc_hi_thresh = inc_hi_pr - povinc_pr) %>% 
  
  mutate(pov_lvl = 
           
           case_when(
             # low
             (INCOM == "$0 to $9,999" | 
                (INCOM == "$10,000 to $24,999" & HHSIZ > 2) | 
                (INCOM == "$25,000 to $34,999" & HHSIZ > 5)) ~ "low",
             #medium
             ((INCOM == "$10,000 to $24,999" & HHSIZ <= 2) | 
                (INCOM == "$25,000 to $34,999" & HHSIZ <= 5) | 
                (inc_lo >= 35000 & inc_lo < 50000)) ~ "low-med",
             #medium-high
             (inc_lo >=50000 & inc_lo < 100000) ~ "med-high",
             
             # high
             (inc_lo >= 100000 ~ "high")),
         
         # as ordered factor
         pov_lvl = ordered(pov_lvl, levels = c(NA, "low", "low-med", "med-high", "high")),
         
         # Do Child dummy (under 16)
         
         AGE = as.numeric(AGE),
         Und16 = AGE < 16
  ) 

write_rds(grpvars, here("data", "grouping-variables.rds"))



