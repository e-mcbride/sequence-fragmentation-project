# Minutes spent in each state: prepping for travel time ratio

library(tidyverse); library(here)

seq_samp <- readr::read_rds(here::here("data", "sample-seq-05000.rds"))

min_by_state <- seq_samp %>% 
  as_tibble(rownames = "pid") %>% 
  mutate(pid = as.numeric(pid)) %>% 
  gather(-pid, key = "time", value = "place") %>% 
  group_by(pid, place) %>% 
  count(name = "minutes") %>% 
  ungroup() %>% 
  spread(key= place, value = "minutes", fill = 0) %>% 
  rename(min_H = "H", min_O = "O", min_S = "S", min_T = "T", min_W = "W") %>% 
  mutate(min_outside_home = min_O + min_S + min_W + min_T,
         ttr = min_T/min_outside_home)


min_by_state %>% write_rds(here::here("data", "min-by-state.rds"))















