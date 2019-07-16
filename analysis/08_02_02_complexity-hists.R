# Look at distribution of Complexity in each

library(tidyverse); library(here)

pr_dat <- read_rds(here::here("data","pr-dat_for-lm.rds")) %>% ungroup()


pr_dat %>% ggplot(mapping = aes(x = C)) + geom_histogram() +
  facet_wrap(facets = vars(namedcluster),scales = "free") + 
  labs(title="Distribution of Complexity by Cluster")

ggsave(here::here("figs","complexity-hists-by-cluster.png"))























