# This will be the eventual MAKEFILE-type thing with `source()` for each part of the code



#####
# Next, run the other stuff
#####




source(here("R","run-sequence-analysis.R")) 

#####
rmarkdown::render(here("README.Rmd"))
## I'm not really sure why this is being created, tbh
file_delete("README.html")
