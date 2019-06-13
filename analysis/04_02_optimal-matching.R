# Optimal Matching (OM) 
library(tidyverse);library(here)
library(TraMineR)

pl.seq <- read_rds(here("results","place_sequence.rds"))

couts <- TraMineR::seqsubm(pl.seq, method = "TRATE")
round(couts, 2)

pl.om <- TraMineR::seqdist(pl.seq, method = "OM", indel = 3, sm = couts)


write_rds(pl.om, here("data", "sequences-optimal-matching.rds"))


