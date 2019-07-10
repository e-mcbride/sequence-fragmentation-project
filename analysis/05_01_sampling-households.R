# sampling
# ALL COMMENTED OUT SO I DON'T ACCIDENTALLY OVERWRITE MY SAMPLE
#' 
#' library(tidyverse); library(here)
#' 
#' #' 1. get the final result that goes into the sequence analysis (b/c it contains the final sample used)
#' pl_seq <- read_rds(here::here("results","place_sequence.rds"))
#' 
#' pl_seq_tbl <- read_rds(here::here("results","place_sequence.rds")) %>% 
#'   as_tibble(rownames = "pid") %>% 
#'   mutate(pid = as.numeric(pid)) %>% 
#'   mutate(SAMPN = str_sub(pid, end = -2))
#' 
#' #' 2. Pull out the unique household ID's from it
#' hhids <- pl_seq_tbl %>% 
#'   select(SAMPN) %>% 
#'   distinct 
#' 
#' #####
#' # 15000 sample
#' #####
#' 
#' #' 3. Pick a random sample from it
#' hhid_samp15 <- hhids %>% 
#'   sample_n(size = 15000, replace = FALSE) %>% 
#'   .$SAMPN
#' 
#' pid_samp15 <- pl_seq_tbl %>%
#'   select(pid, SAMPN) %>% 
#'   distinct() %>% 
#'   filter(SAMPN %in% hhid_samp15) %>% 
#'   .$pid
#' 
#' #' 4. write the sample list
#' hhid_samp15 %>% readr::write_rds(here("data","sample-hhids-15000.rds"))
#' pid_samp15 %>% readr::write_rds(here("data","sample-pids-15000.rds"))
#' 
#' 
#' 
#' 
#' ##### 
#' # smaller sample
#' #####
#' 
#' #' 3. Pick a random sample from it
#' hhid_samp05 <- hhids %>% 
#'   sample_n(size = 5000, replace = FALSE) %>% 
#'   .$SAMPN
#' 
#' pid_samp05 <- pl_seq_tbl %>%
#'   select(pid, SAMPN) %>% 
#'   distinct() %>% 
#'   filter(SAMPN %in% hhid_samp05) %>% 
#'   .$pid
#' 
#' #' 4. write the sample list
#' hhid_samp05 %>% readr::write_rds(here("data","sample-hhids-05000.rds"))
#' pid_samp05 %>% readr::write_rds(here("data","sample-pids-05000.rds"))
#' 
#' 
#' #####
#' # keep it in the right format for traminer
#' #####
#' seq_samp15 <- pl_seq[which(rownames(pl_seq) %in% pid_samp15),]
#' 
#' seq_samp05 <- pl_seq[which(rownames(pl_seq) %in% pid_samp05),]
#' 
#' seq_samp15 %>% readr::write_rds(here("data","sample-seq-15000.rds"))
#' seq_samp05 %>% readr::write_rds(here("data","sample-seq-05000.rds"))

