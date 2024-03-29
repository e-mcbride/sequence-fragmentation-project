library(tidyverse); library(TraMineR); library(here)

travel_dat <- readr::read_rds(here("data", "places_travel-added.rds"))
pl.labels <- seqstatl(travel_dat$place_type)


# function to get time of day labels for future graphs (added to `cnames` argument of `seqdef`)
min2TOD = function(dayminutes) {
  TOD = c()
  for (i in 1:length(dayminutes)) {
    add3 = (dayminutes[i]/60) + 3
    
    if(add3 < 24){
    tod_hr = (floor(add3)) %>% str_pad(width = 2, side = "left", pad = "0")
    } else {
      tod_hr = (floor(add3) - 24) %>% str_pad(width = 2, side = "left", pad = "0")
    }
    
    tod_min = ((add3 - floor(add3))*60) %>% round() %>% 
      str_pad(width = 2, side = "left", pad = "0")
    
    TOD[i] = tod_hr %>% str_c(tod_min, sep = ":")
  }
  return(TOD)
}


time <- min2TOD(seq(0,1439))


# bad.ids <- travel_dat %>%  mutate(timedif = dep_time3_add1 - arr_time3_add1) %>% 
#   filter(timedif<0) %>% 
#   .$pid
# 
# temp.traveldat <- travel_dat %>% filter(!(pid %in% bad.ids))# filter(!is.na(arr_time3_add1))


# Running sequence analysis:
pl.seq <- travel_dat %>% data.frame() %>% 
  seqdef(var = c("pid", "arr_time3_add1", "dep_time3_add1", "pltype"),
         informat = "SPELL", labels = pl.labels, process = FALSE, cnames = time, xtstep= 180)

print(pl.seq[10000:10015, ], format = "SPS")

print(pl.seq[1:15, ], format = "SPS")


write_rds(pl.seq, here("results","place_sequence.rds"))

