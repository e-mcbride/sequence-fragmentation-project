library(tidyverse)

sumtable_clusters <- pr_dat %>% 
  # select(namedcluster, C, female, worker, student, disability, weekend, age00_03.d, age04_15.d, age16_18.d) %>% 
  select(namedcluster, C, female, worker, student, disability, weekend) %>% #, age00_03.d, age04_15.d, age16_18.d) %>%
  group_by(namedcluster) %>% 
  summarise_all(funs(mean, sd))

write_csv(sumtable_clusters, here::here("figs", "cluster-summary-table.csv"))

library(summarytools)
ctable(pr_dat$namedcluster, pr_dat$AgeGrp, prop = "n", totals = FALSE) 
ctable(pr_dat$namedcluster, pr_dat$DOW, prop = "n", totals = FALSE)
