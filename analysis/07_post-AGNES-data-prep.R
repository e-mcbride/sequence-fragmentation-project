# Putting together the rest of the variables for the regression model

library(tidyverse)

alldata <- readr::read_rds(here::here("data","alldata.rds"))




# Adding the new variables
alldata$worker <- ifelse(alldata$EMPLY == 'Yes' , 1, 0)
alldata$worker <- ifelse(is.na(alldata$worker), 0, alldata$worker)
#dfSummary(alldata$worker)
alldata$student <- ifelse(alldata$STUDE == 'YES - Full Time' , 1, 0)
alldata$student <- ifelse(is.na(alldata$student), 0, alldata$student)
#dfSummary(alldata$student)
alldata$driver <- ifelse(alldata$LIC == 'YES' , 1, 0)
alldata$driver <- ifelse(is.na(alldata$driver), 0, alldata$driver)
#dfSummary(alldata$driver)

alldata$graduate <- ifelse(alldata$EDUCA == 'Graduate degree (includes professional degree like MD, DDs, JD)', 1,0)
alldata$graduate <- ifelse(is.na(alldata$graduate), 0, alldata$graduate)
#dfSummary(alldata$graduate)                           
alldata$undergrad <- ifelse(alldata$EDUCA == 'Bachelor’s or undergraduate degree', 1,0)
alldata$undergrad <- ifelse(is.na(alldata$undergrad), 0, alldata$undergrad)
#dfSummary(alldata$undergrad)                           

alldata$disability <- ifelse(alldata$DISAB == 'Yes' , 1, 0)
alldata$disability <- ifelse(is.na(alldata$disability), 0, alldata$disability)
#dfSummary(alldata$disability)                           

alldata$senior <- ifelse(alldata$AgeGrp == 'Age65+' , 1, 0)
alldata$senior <- ifelse(is.na(alldata$senior), 0, alldata$senior)
#dfSummary(alldata$senior)                           

alldata$seniordisabled = alldata$senior * alldata$disability

alldata$female <- ifelse(alldata$GEND == 'FEMALE' , 1, 0)
alldata$female <- ifelse(is.na(alldata$female), 0, alldata$female)
#dfSummary(alldata$female)                           

alldata$femaledisabled = alldata$female * alldata$disability


alldata$childbelow15 <- ifelse(alldata$AgeGrp == 'Age00-03'  |
                                 alldata$AgeGrp == 'Age04-15' , 1, 0)
alldata$childbelow15 <- ifelse(is.na(alldata$childbelow15), 0, alldata$childbelow15)
#dfSummary(alldata$childbelow15)                           


#driver with young children

alldata$driverWC4to15 = alldata$driver * alldata$Age04_15



# use Elissas poverty definition but create an order numerical variable

alldata$povlevel <- ifelse(alldata$pov_lvl == 'low' , 1,
                           ifelse(alldata$pov_lvl == 'low-med' , 2,
                                  ifelse(alldata$pov_lvl == 'med-high' , 3,
                                         ifelse(alldata$pov_lvl == 'high' , 4,  0))))
alldata$povlevel <- ifelse(is.na(alldata$povlevel), 0, alldata$povlevel)

#dfSummary(alldata$povlevel)                           
alldata$male <- ifelse(alldata$GEND == 'MALE' , 1, 0)
alldata$male <- ifelse(is.na(alldata$male), 0, alldata$male)


alldata$maleworker =  alldata$male * alldata$worker


#####
# Attaching the LPA LU group variable to CHTS home locations 
#####

library(sf);library(sp)


LU_shp <- sf::read_sf(here::here("data-raw","LPA_bgGrps","LPA_bgGrps.shp"))
st_crs(LU_shp) <- "+proj=longlat +datum=NAD83 +no_defs"


chts <- readr::read_rds("data-raw/chts_all_2019-06-18.rds")

hhloc <- chts$HOUSEHOLD %>% select(source, SAMPN, HLAT, HLON)

homeloc_sf <- hhloc %>% 
  st_as_sf(agr = "identity", coords = c("HLON", "HLAT"), crs = ("+proj=longlat +datum=NAD83 +no_defs"))


homePts_sp <- as_Spatial(homeloc_sf)
LUPolys_sp <- as_Spatial(LU_shp)


# plot(LUPolys_sp)

library(spatialEco)
LU_home <- point.in.poly(homePts_sp, LUPolys_sp)
head(LU_home@data)


CHTS_LUgrp <- LU_home@data %>% select(source, SAMPN, GEOID, LPAgrp)


CHTS_LUgrp %>% readr::write_rds(here::here("data", "lpa-LU-grps_chts-srbi-nust.rds"))


#####

pr_dat <- alldata %>% 
  #below added on 2019-04-10. Could be moved elsewhere:
  mutate(pid, Age04_15, Und04, Und16 = Age04_15 + Und04) %>% 
  mutate(i = 1) %>% 
  spread(pov_lvl, i, fill = 0, sep = ".") %>% ungroup() %>% 
  left_join(CHTS_LUgrp, by = c("source", "SAMPN"))


summary (pr_dat$namedcluster)


pr_dat_dum <- pr_dat %>% 
  mutate(native = as.numeric(NTVTY == "Yes"),
         hispanic = as.numeric(HISP == "YES"),
         weekend = as.numeric(DOW == "Saturday" | DOW == "Sunday"),
         age00_03.d = as.numeric(Und04>0),
         age04_15.d = as.numeric(Age04_15>0), # flag for check
         age16_18.d = as.numeric(Age16_18>0)
  ) # %>% 
# mutate(i = 1) %>% 
# spread(pov_lvl, i, fill = 0, sep = ".") 
# age.grp.f = factor(AgeGrp, ordered = FALSE, exclude = "Unknown"))



pr_dat_dum %>% write_rds(here::here("data","pr-dat_for-lm.rds"))









