# Agglomerative Nesting (agnes)
library(tidyverse);library(here)
library(cluster)

pl.om <- read_rds(here("data", "sequences-optimal-matching.rds"))


clusterward <- cluster::agnes(pl.om, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2, rotate=TRUE)