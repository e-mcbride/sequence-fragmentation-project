# 04_02 Building socioeconomic status grouping variables

library(tidyverse); library(here)


chts <- read_rds(here("data-raw","chts_all_2019-06-18.rds"))
places <- read_rds(here("data","modified_pldat.rds"))

# pulling variables of interest from person data that were not already joined to the place data
chts_sel <- chts$PERSON %>%
  mutate(pid = as.numeric(str_c(SAMPN, PERNO))) %>%
  select(source, pid, SAMPN, PERNO, HISP, RACE, NTVTY, DISAB, DTYPE, GEND, AGE,EMPLY,STUDE,LIC,EDUCA)




##### 
# household level
#####


Agegrp_count <- chts_sel %>%
  mutate(AGE = as.numeric(AGE)) %>% 
  mutate(AgeGrp = case_when(AGE < 4 ~ "Und04",
                            AGE >= 4 & AGE < 16 ~ "Age04-15",
                            AGE >= 16 & AGE < 19 ~ "Age16-18",
                            AGE >= 19 ~ "Age19+")) %>%
  
  group_by(SAMPN) %>% 
  summarise(Und04 = sum(AGE < 4, na.rm=T),
            Age04_15 = sum(AGE >= 4 & AGE < 16, na.rm=T),
            Age16_18 = sum(AGE >= 16 & AGE < 19,na.rm=T))

hh <- chts$HOUSEHOLD
hhvars <- hh %>% 
  select(SAMPN, HHSIZ, HHWRK, HHVEH, RESTY, INCOM,DOW) %>% 
  # filter(DOW == "hursday") %>% 
  mutate(DOW = case_when(DOW == "hursday" ~ "Thursday", 
                          TRUE             ~ DOW),
         DOW = factor(DOW, 
                      levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>% 
  left_join(Agegrp_count, by = "SAMPN")

#####
# Income variables
#####

# first: building numeric versions of income values
incomevals <- hhvars %>% 
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
npr_extra = c(1,2,3,4,5,6,7,8)-1
extrainc = npr_extra * 3960
povlines = extrainc + 11170
npr = seq(1:8)
inc_pr = povlines/npr

pov_tbl <- bind_cols(HHSIZ = npr, povlines = povlines, povinc_pr = inc_pr)
rm(npr_extra, extrainc, povlines, npr, inc_pr)

# NEXT: joining the income calculations to the other grouping variables
#' below we get the amount of money available per person in the household 
#' we then join the table with the poverty levels per person to the table
#' we subtract the min/max income ranges from the poverty level for that hh size
#' If we see a negative value for at least `inc_lo_thresh`, this gives us a rough idea of whether they are close to the poverty line. 
#' If both are negative, they are clearly below it. These numbers




grpvars <- chts_sel %>% 
  left_join(hhvars, by = "SAMPN") %>% 
  left_join(incomevals, by = "INCOM") %>% 
  mutate(inc_hi_pr = inc_hi/HHSIZ,
         inc_lo_pr = inc_lo/HHSIZ) %>%
  
  left_join(pov_tbl, by = "HHSIZ") %>%
  mutate(inc_lo_thresh = inc_lo_pr - povinc_pr,
         inc_hi_thresh = inc_hi_pr - povinc_pr) %>% 
  
  mutate(pov_lvl = case_when(
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
    Und16 = AGE < 16) %>% 
  
  # children variable
  mutate(AgeGrp = case_when(AGE < 4 ~              "Age00-03",
                            AGE >= 4 & AGE < 16 ~  "Age04-15",
                            AGE >= 16 & AGE < 19 ~ "Age16-18",
                            AGE >= 19 & AGE < 25 ~ "Age19-24", 
                            AGE >= 25 & AGE < 35 ~ "Age25-34",
                            AGE >= 35 & AGE < 45 ~ "Age35-44",
                            AGE >= 45 & AGE < 55 ~ "Age45-54",
                            AGE >= 55 & AGE < 65 ~ "Age55-65",
                            AGE >= 65 ~            "Age65+"     )) %>%
  
  mutate(AgeGrp = factor(AgeGrp, levels = c("Age00-03",
                                            "Age04-15",
                                            "Age16-18",
                                            "Age19-24",
                                            "Age25-34",
                                            "Age35-44",
                                            "Age45-54",
                                            "Age55-65",
                                            "Age65+")))



#####
# children

# 
# Agegrp_count <- grp_en_tu %>% 
#   mutate(AgeGrp = 
#            case_when(
#              AGE < 4 ~ "Und04",
#              AGE >= 4 & AGE < 16 ~ "Age04-15",
#              AGE >= 16 & AGE < 19 ~ "Age16-18",
#              AGE >= 19 ~ "Age19+"
#              #preschool age
#            )) %>%
#   # Und04 = AGE< 4,
#   # Age04_15 = AGE >= 4 & AGE < 16,
#   #     Age16_18 = AGE >= 16 & AGE < 19,
#   #     AGE >= 19 ~ "Age19+")
#   
#   group_by(SAMPN) %>% 
#   summarise(
#     Und04 = sum(AGE < 4, na.rm=T),
#     Age04_15 = sum(AGE >= 4 & AGE < 16, na.rm=T),
#     Age16_18 = sum(AGE >= 16 & AGE < 19,na.rm=T))

#####

#####
# Attaching land use 
#####
# CHTS_LUgrp <- read_rds(here::here("data-raw","LPA_bgGrps.rds"))

# CHTS_LUgrp <- CHTS_LUgrp %>% mutate(LPAgrpfac = factor(LPAgrp, levels = c(4,3,2,1), labels = c("urban", "suburban", "exurban", "rural")))
# 
# 
# grp_en_tu <- grp_en_tu %>% 
#   select(-LPAgrp, -GEOID, -LPAgrpfac) %>% 
#   left_join(CHTS_LUgrp, by = "SAMPN")


write_rds(grpvars, here("data", "grouping-variables.rds"))



