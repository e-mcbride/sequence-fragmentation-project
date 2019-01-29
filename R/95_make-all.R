# This will be the eventual MAKEFILE-type thing with `source()` for each part of the code

## Make vector of the counties you want. 
## I kind of want to have some big parameters like this out here instead of internal to scripts so I can run stuff from out here.

library(here); library(fs)

if (!dir_exists(here("data"))) {
  dir_create(here("data"))
}

if (!dir_exists(here("figs"))) {
  dir_create(here("figs"))
}

source(here("R/01_extract-all-chts-tables_slo-sb.R"))


rmarkdown::render(here("README.Rmd"))
## I'm not really sure why this is being created, tbh
file_delete("README.html")
