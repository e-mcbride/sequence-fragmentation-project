# This will be the eventual MAKEFILE-type thing with `source()` for each part of the code

## Make vector of the counties you want. 
#ffffffffff

library(here); library(fs)

if (!dir_exists(here("data"))) {
  dir_create(here("data"))
}

if (!dir_exists(here("figs"))) {
  dir_create(here("figs"))
}

# This section will put together the file `places_slo_sb.rds` used throughout the analysis
source(here("R/01_01_extract-all-chts-tables_slo-sb.R"))
source(here("R/01_02_classify-places-HWSO.R"))
source(here("R/01_03_time-in-min-since-3am.R"))
# source(here("R/01_04_activity-var-processing.R")) # BROKEN TIL I GET FILES FROM ADAM
# source(here("R/01_05_trip-dist-axx-processing.R")) # BROKEN TIL I GET FILES FROM ADAM
source(here("R/01_06_pr-hh-pl-vars.R"))

# WARNING: ONLY RUN THE FOLLOWING AFTER YOU HAVE FIXED 04 AND 05
# source(here("R/01_95_make-place-file.R")) 

source(here("R/02_modify-place-file.R"))
source(here("R/03_run-sequence-analysis.R"))

#####
rmarkdown::render(here("README.Rmd"))
## I'm not really sure why this is being created, tbh
file_delete("README.html")
