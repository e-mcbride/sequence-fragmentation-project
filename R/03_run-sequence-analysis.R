
library(TraMineR); library(tidyverse); library(here)

places_mod <- readr::read_rds(here("data","modified_pldat.rds"))

slosb.labels <- seqstatl(places_mod$place_type)

# Translates the data into the necessary sequence format (STS) 
slosb.sts <- seqformat(data = places_mod, var = c("pid", "arr_time3_add1", "dep_time3_add1", "pltype"), id = "pid", begin = "arr_time3_add1", end = "dep_time3_add1", status = "pltype", from = "SPELL", to = "STS", process = FALSE)


# Creates the state sequence object
slosb.seq240 <- seqdef(data = slosb.sts,
                       process = FALSE,
                       xtstep = 240,
                       labels = slosb.labels,
                       covar = c("activity_type", "GEND", "AGE","HHSIZ","HHWRK", "HHVEH", "RESTY", "INCOM"))

# Writes the sequence object to file
slosb.seq240 %>% write_rds(here("data","slosb_seq240.rds"))

