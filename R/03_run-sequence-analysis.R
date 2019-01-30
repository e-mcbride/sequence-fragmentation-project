
library(TraMineR); library(tidyverse); library(here)

places_mod <- readr::read_rds(here("data","modified_pldat.rds"))

slosb.labels <- seqstatl(places_mod$place_type)

slosb.sts <- seqformat(data = places_mod, var = c("pid", "arr_time3_add1", "dep_time3_add1", "pltype"), id = "pid", begin = "arr_time3_add1", end = "dep_time3_add1", status = "pltype", from = "SPELL", to = "STS", process = FALSE)



slosb.seq240 <- seqdef(data = places_mod,
                       var = c("pid", "arr_time3_add1", "dep_time3_add1", "pltype"),
                       id="pid", begin="arr_time3_add1", end="dep_time3_add1", status="pltype", 
                       from="SPELL", to="STS",
                       process = FALSE, 
                       xtstep = 240)
                       #labels = slosb.labels)#,covar = c("activity_type", "GEND", "AGE","HHSIZ","HHWRK", "HHVEH", "RESTY", "INCOM"))#,informat = "SPELL", , 

slosb.seq240 %>% write_rds(here("data","slosb_seq240.rds"))

