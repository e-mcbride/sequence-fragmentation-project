# Optimal Matching (OM) 
library(tidyverse);library(here)
library(TraMineR)

seq_samp05 <- readr::read_rds(here::here("data","sample-seq-05000.rds"))


couts <- TraMineR::seqsubm(seq_samp05, method = "TRATE")#, with.missing = TRUE) # took about 60 seconds
round(couts, 2)
#      H->  O-> S->  T-> W->
# H-> 0.00 2.00   2 1.99   2
# O-> 2.00 0.00   2 1.98   2
# S-> 2.00 2.00   0 2.00   2
# T-> 1.99 1.98   2 0.00   2
# W-> 2.00 2.00   2 2.00   0


pl_om <- TraMineR::seqdist(seq_samp05, method = "OM", indel = 3, sm = couts)#, with.missing = TRUE)
# with 5000 households (12704 people), it took 1.135 days (about 27 hrs)

write_rds(pl_om, here("data", "sequences-optimal-matching.rds"))


