#####
# Attaching the LPA LU group variable to CHTS home locations 
#####
library(tidyverse); library(here)
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


CHTS_LUgrp <- LU_home@data %>% select(source, SAMPN, GEOID, LPAgrp) %>% 
  mutate(LPAgrpfac = factor(LPAgrp, levels = c(4,3,2,1), labels = c("urban", "suburban", "exurban", "rural")))


CHTS_LUgrp %>% readr::write_rds(here::here("data", "lpa-LU-grps_chts-srbi-nust.rds"))
