# TTR histograms


library(tidyverse); library(here)

pr_dat <- read_rds(here::here("data","pr-dat_for-lm.rds")) %>% ungroup()


pr_dat %>% ggplot(mapping = aes(x = ttr)) + geom_histogram() +
  facet_wrap(facets = vars(namedcluster),scales = "free") + 
  labs(title="Distribution of TTR by Cluster")

ggsave(here::here("figs","ttr-hists-by-cluster.png"))














