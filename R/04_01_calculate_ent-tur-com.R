# 04_01 Calculating entropy and turbulence
library(tidyverse); library(TraMineR); library(here)
pl.seq <- read_rds(here("results","place_sequence.rds"))

## Sequence Entropy and Turbulence 
#' Combined, written to file, examined

pl.en_tu_com <- data.frame(seqient(pl.seq, norm = F, with.missing = T), 
                           seqST(pl.seq), 
                           seqici(pl.seq, with.missing = T)) %>% 
  rownames_to_column(var = "pid") %>% 
  separate(col = pid, into = c("SAMPN", "PERNO"),sep = -1, convert = T) %>% 
  mutate(pid = as.numeric(str_c(SAMPN, PERNO)))

write_csv(pl.en_tu_com, here("results", "ent-tur-com_place-seq.csv"))
write_rds(pl.en_tu_com, here("results", "ent-tur-com_place-seq.rds"))

