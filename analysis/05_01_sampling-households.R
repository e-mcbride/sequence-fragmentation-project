# sampling

library(tidyverse)

#' 1. get the final result that goes into the sequence analysis (b/c it contains the final sample used)
pl_seq <- read_rds(here::here("results","place_sequence.rds")) %>% 
  as_tibble(rownames = "pid") %>% 
  mutate(pid = as.numeric(pid))

#' 2. Pull out the unique household ID's from it
hhids <- pl_seq %>% 
  transmute(SAMPN = str_sub(pid, end = -2)) %>% 
  distinct 

#' 3. Pick a random sample from it
hhid_samp <- hhids %>% 
  sample_n(size = 15000, replace = FALSE) %>% 
  .$SAMPN

#' 4. write the sample list
hhid_samp %>% readr::write_rds(here("data","sample-hhids-15000.rds"))




