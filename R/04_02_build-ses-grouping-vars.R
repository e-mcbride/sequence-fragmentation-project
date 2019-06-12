# 04_02 Building socioeconomic status grouping variables

library(tidyverse); library(TraMineR); library(here)


chts <- read_rds(here("data-raw","chts_all_2019-05-22.rds"))
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


#####
# Income variables
#####

# first: building numeric versions of income values
incomevals <- pl.grpvars %>% 
  select(INCOM) %>% 
  unique() %>% 
  mutate(renameinc = str_remove_all(INCOM,c("\\$|\\,| or more"))) %>%
  #split
  tidyr::separate(col = renameinc, into = c("inc_lo", "inc_hi"), sep = " to ", remove = TRUE) %>%
  mutate(inc_lo = as.numeric(inc_lo),
         inc_hi = as.numeric(inc_hi)) %>%
  arrange(inc_lo)

# NEXT: using the US poverty lines for 2012 to determine poverty levels
#
##' the poverty line is not one number. It takes household size into account.
##' In 2012 the poverty line had a baseline of $11,170 for a hh of 1 person. 
##' Added $3,960 to this number for each additional person in hh.
##' Below are calculations of these thresholds.


pov_tbl <- seq(1:12) %>% enframe(name = NULL) %>% 

  rename(HHSIZ=value) %>% 
  mutate(npr_extra = HHSIZ-1,
         extrainc = npr_extra * 3960,
         povlines = extrainc + 11170, 
         povinc_pr = povlines/HHSIZ) # see notes above for basis of these calculations


# NEXT: joining the income calculations to the other grouping variables
#' below we get the amount of money available per person in the household 
#' we then join the table with the poverty levels per person to the table
#' we subtract the min/max income ranges from the poverty level for that hh size
#' If we see a negative value for at least `inc_lo_thresh`, this gives us a rough idea of whether they are close to the poverty line. 
#' If both are negative, they are clearly below it. These numbers

grpvars <- pl.grpvars %>% 
  left_join(incomevals, by = "INCOM") %>% 
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
#####
# making edits to incom calcs
#####
hh <- chts$HOUSEHOLD

inc.test <- hh %>% 
  select(SAMPN, HHSIZ, HHWRK, INCOM) %>% 
  left_join(incomevals, by = "INCOM") %>% 
  mutate(inc_hi_pr = inc_hi/HHSIZ,
         inc_lo_pr = inc_lo/HHSIZ) %>%
  left_join(pov_tbl, by = "HHSIZ") %>%
  mutate(inc_lo_thresh = inc_lo_pr - povinc_pr,
         inc_hi_thresh = inc_hi_pr - povinc_pr)

inc.test$inc_hi_thresh %>% 
  hist()
  #quantile(na.rm = TRUE)

aa <- inc.test %>% 
  #filter((!inc_lo_thresh<=0))
  filter((inc_hi_thresh<=0)) %>%
  filter(inc_lo_thresh<0 & inc_hi_thresh<1000) #INCOM == "$25,000 to $34,999" & HHSIZ > 5))


  
zz <- inc.test %>% 
  mutate(pov_lvl =
           
           case_when(
             # low
                ((inc_hi_thresh<=0) |
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


bb <- inc.test %>% filter((INCOM == "$0 to $9,999" | 
          (INCOM == "$10,000 to $24,999" & HHSIZ > 2) | 
          (INCOM == "$25,000 to $34,999" & HHSIZ > 5)))

# (INCOM == "$0 to $9,999" | 
#     (INCOM == "$10,000 to $24,999" & HHSIZ > 2) | 
#     (INCOM == "$25,000 to $34,999" & HHSIZ > 5)) ~ "low",
# #medium
# ((INCOM == "$10,000 to $24,999" & HHSIZ <= 2) | 
#    (INCOM == "$25,000 to $34,999" & HHSIZ <= 5) | 
#    (inc_lo >= 35000 & inc_lo < 50000)) ~ "low-med",
# #medium-high
# (inc_lo >=50000 & inc_lo < 100000) ~ "med-high",
# 
# # high
# (inc_lo >= 100000 ~ "high"))

write_rds(grpvars, here("data", "grouping-variables.rds"))



