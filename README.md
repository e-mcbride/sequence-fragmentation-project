
<!-- README.md is generated from README.Rmd. Please edit that file -->
sequence-fragmentation-project
==============================

GeoTrans project looking at fragmentation using sequence analysis

[Integrating git and Github into an R project](https://happygitwithr.com/)

Principles I will be using can be found in the article [Project-oriented workflow.](https://www.tidyverse.org/articles/2017/12/workflow-vs-script/)

My goals for this reorganization of the project are for it to...

-   Flow well
-   Have an organizational scheme
-   Have each script be one piece (break down the workflow into small pieces that are each in their own script)

TIPS FOR MYSELF (directly from that article ["project-oriented workflow".](https://www.tidyverse.org/articles/2017/12/workflow-vs-script/) )

1.  Isolate code that creates an object that takes a long time to create in its own script.
2.  Write the object to file as `.rds`
3.  Scripts developed downstream can just reload the object

I will also be using something relatively new to me: the `here` package. This makes relative path structures much more flexible and is meant to be used within an R project. More info on that can be found [here.](https://github.com/jennybc/here_here)

Eventual goals:

-   Bring Adam's scripts that built the objects I am using into the project.
