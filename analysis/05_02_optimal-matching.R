# Optimal Matching (OM) 
library(tidyverse);library(here)
library(TraMineR)

seq_samp05 <- readr::read_rds(here("data","seq-samp-05000.rds"))


couts <- TraMineR::seqsubm(seq_samp05, method = "TRATE", with.missing = TRUE) # took about 60 seconds
round(couts, 2)
#      H->  O-> S->  T->  W-> *->
# H-> 0.00 2.00   2 1.98 2.00   2
# O-> 2.00 0.00   2 1.96 2.00   2
# S-> 2.00 2.00   0 2.00 2.00   2
# T-> 1.98 1.96   2 0.00 1.99   2
# W-> 2.00 2.00   2 1.99 0.00   2
# *-> 2.00 2.00   2 2.00 2.00   0

gc()

pl_om <- TraMineR::seqdist(seq_samp05, method = "OM", indel = 3, sm = couts, with.missing = TRUE)

write_rds(pl_om, here("data", "sequences-optimal-matching.rds"))


