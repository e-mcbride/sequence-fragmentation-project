library(tidyverse)

pr_dat <- read_rds(here::here("data","pr-dat_for-lm.rds")) %>% ungroup()


sumtable_clusters <- pr_dat %>% 
  # select(namedcluster, C, female, worker, student, disability, weekend, age00_03.d, age04_15.d, age16_18.d) %>% 
  select(namedcluster, C, ttr, female, worker, student, disability, weekend) %>% #, age00_03.d, age04_15.d, age16_18.d) %>%
  group_by(namedcluster) %>% 
  summarise_all(list(~mean(., na.rm = TRUE), ~sd(.,na.rm = TRUE)))

write_csv(sumtable_clusters, here::here("figs", "cluster-summary-table.csv"))

library(summarytools)
ctable(pr_dat$namedcluster, pr_dat$AgeGrp, prop = "n", totals = FALSE) 
ctable(pr_dat$namedcluster, pr_dat$DOW, prop = "n", totals = FALSE)


#Summary table that includes TTR attached. NOTE: NaN's have been removed from the means of TTR (only was affecting Home Day cluster)