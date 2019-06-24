# sampling

library(tidyverse); library(here)

#' 1. get the final result that goes into the sequence analysis (b/c it contains the final sample used)
pl_seq <- read_rds(here::here("results","place_sequence.rds")) %>% 
  as_tibble(rownames = "pid") %>% 
  mutate(pid = as.numeric(pid)) %>% 
  mutate(SAMPN = str_sub(pid, end = -2))

#' 2. Pull out the unique household ID's from it
hhids <- pl_seq %>% 
  select(SAMPN) %>% 
  distinct 


#' 3. Pick a random sample from it
hhid_samp15 <- hhids %>% 
  sample_n(size = 15000, replace = FALSE) %>% 
  .$SAMPN

#' 4. write the sample list
hhid_samp15 %>% readr::write_rds(here("data","sample-hhids-15000.rds"))




##### 
# smaller sample
#####

#' 3. Pick a random sample from it
hhid_samp05 <- hhids %>% 
  sample_n(size = 5000, replace = FALSE) %>% 
  .$SAMPN

#' 4. write the sample list
hhid_samp05 %>% readr::write_rds(here("data","sample-hhids-05000.rds"))


# pl_seq <- read_rds(here("results","place_sequence.rds"))

seq_samp15 <- pl_seq %>% 
  filter(SAMPN %in% hhid_samp15) %>% 
  select(-SAMPN) %>% 
  column_to_rownames(var = "pid")

seq_samp15 %>% readr::write_rds(here("data","seq-samp-15000.rds"))


seq_samp05 <- pl_seq %>% 
  filter(SAMPN %in% hhid_samp05) %>% 
  select(-SAMPN) %>% 
  column_to_rownames(var = "pid")

seq_samp05 %>% readr::write_rds(here("data","seq-samp-05000.rds"))



