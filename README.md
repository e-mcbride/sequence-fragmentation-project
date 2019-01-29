
<!-- README.md is generated from README.Rmd. Please edit that file -->
sequence-fragmentation-project
==============================

GeoTrans project looking at fragmentation using sequence analysis

Introduction to this project
----------------------------

[Integrating git and Github into an R project](https://happygitwithr.com/)

Principles I will be using can be found in the article [Project-oriented workflow.](https://www.tidyverse.org/articles/2017/12/workflow-vs-script/)

My goals for this reorganization of the project are for it to...

-   Flow well
-   Have an organizational scheme
-   Have each script be one piece (break down the workflow into small pieces that are each in their own script)
-   Bring over all necessary pieces from the old scripts to the new ones.

TIPS FOR MYSELF (directly from that article ["project-oriented workflow".](https://www.tidyverse.org/articles/2017/12/workflow-vs-script/) )

1.  Isolate code that creates an object that takes a long time to create in its own script.
2.  Write the object to file as `.rds`
3.  Scripts developed downstream can just reload the object

I will also be using something relatively new to me: the `here` package. This makes relative path structures much more flexible and is meant to be used within an R project. More info on that can be found [here.](https://github.com/jennybc/here_here)

Eventual goals:

-   Bring Adam's scripts that built the objects I am using into the project.

Project structure (folders, etc)
--------------------------------

-   `/R` contains scripts
-   `/figs` contains any figures built
-   `/data` contains the data files we will use and access. Right now, this includes those. However, I am ocnsidering moving the mid-stream files to their own folder.
-   `/results` contains any files that are a final result in themselves, but are not explicitly figures. This would include things like .csv's

Undecided if I will be uploading the folders `/data` and `/results` to GitHub. I need to learn what the best way to deal with data in projects is.

Notes
-----

I believe the order of the previous scripts is as follows:

1.  "ExtractActivitySequence\_SLOSB.Rmd"
2.  "FirstTraMineR\_Exploration.Rmd"
3.  "IATBR18analysis.Rmd"
4.  "TRB2019\_Regression\_etc.Rmd"
