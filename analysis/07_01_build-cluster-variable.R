# This is where we build the data with the desired number of clusters to examine

library(tidyverse);library(here)
library(TraMineR)

library(summarytools)


# grouping variables

grp_en_tu <- read_rds(here::here("results","grpvars_ent-tur-com.rds"))

#need to pull out the sample that was used in the clustering
# samp_ids <- readr::read_rds(here::here("data","sample-seq-05000.rds")) %>% rownames()
pid_samp05 <- readr::read_rds(here("data","sample-pids-05000.rds")) %>% enframe(name = NULL, value = "pid")
 # <- rownames(seq_samp05)


samp_grp <- pid_samp05 %>% left_join(grp_en_tu, by = "pid")


clusterward <- read_rds(here::here("data", "cluster-ward_5000samp.rds"))




# below is an outdated key for changing the names of the cluster labels which will be applied in `cluster <- `

# level_key <- list(`Type 1` = "Traveling", 
#                   `Type 2` = "Home Day",
#                   `Type 3` = "Work Day",
#                   `Type 4` = "School Day",
#                   `Type 5` = "Errands Day",
#                   `Type 6` = "Return Home")

cluster <- cutree(clusterward, k = 9) %>% 
  factor(labels=paste("Type", 1:9)) 

# %>% 
#   recode_factor(!!!level_key)


# 
alldata <- cbind(samp_grp, cluster)

readr::write_rds(alldata, here::here("data","alldata.rds"))


#' Below is where I tested the different number of clusters by changing everywhere it says `10` to change the number of clusters
# 
# cluster <- cutree(clusterward, k = 10) %>% 
#   factor(labels=paste("Type", 1:10)) 
# 
# 
# alldata10 <- cbind(samp_grp, cluster)




















