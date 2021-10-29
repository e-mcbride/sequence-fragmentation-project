# Agglomerative Nesting (agnes)
library(tidyverse);library(here)
library(cluster)

pl_om <- read_rds(here("data", "sequences-optimal-matching.rds"))


clusterward <- cluster::agnes(pl_om, diss = TRUE, method = "ward")
#start: 19:24 on 2019-06-25

clusterward %>% write_rds(here::here("data", "cluster-ward_5000samp.rds"))


plot(clusterward, which.plots = 2, rotate=TRUE)


