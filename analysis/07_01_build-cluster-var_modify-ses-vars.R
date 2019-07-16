# This is where we build the data with the desired number of clusters to examine

library(tidyverse);library(here)
# library(TraMineR)

# library(summarytools)


# grouping variables

grp_en_tu <- read_rds(here::here("results","grpvars_ent-tur-com.rds"))

#need to pull out the sample that was used in the clustering
# samp_ids <- readr::read_rds(here::here("data","sample-seq-05000.rds")) %>% rownames()
pid_samp05 <- readr::read_rds(here("data","sample-pids-05000.rds")) %>% enframe(name = NULL, value = "pid")
 # <- rownames(seq_samp05)


samp_grp <- pid_samp05 %>% left_join(grp_en_tu, by = "pid")


clusterward <- read_rds(here::here("data", "cluster-ward_5000samp.rds"))




# below is an outdated key for changing the names of the cluster labels which will be applied in `cluster <- `

# level_key <- list(`Type 1` = "Traveling", 
#                   `Type 2` = "Home Day",
#                   `Type 3` = "Work Day",
#                   `Type 4` = "School Day",
#                   `Type 5` = "Errands Day",
#                   `Type 6` = "Return Home")

cluster <- cutree(clusterward, k = 9) %>% 
  factor(labels=paste("Type", 1:9)) 

# %>% 
#   recode_factor(!!!level_key)


# 
level_key <- list(`Type 1` = "Home Day",
                  `Type 2` = "School Day",
                  `Type 3` = "Typical Work Day",
                  `Type 4` = "Errands Type 1",
                  `Type 5` = "Mostly Out of Home",
                  `Type 6` = "Errands Type 2",
                  `Type 7` = "Non-typical Work Day",
                  `Type 8` = "Leave Home",
                  `Type 9` = "Traveling")

alldata <- cbind(samp_grp, cluster) %>% mutate(namedcluster = recode_factor(cluster, !!!level_key))



#####
#' Below is where I tested the different number of clusters by changing everywhere it says `10` to change the number of clusters
#####
# cluster <- cutree(clusterward, k = 10) %>% 
#   factor(labels=paste("Type", 1:10)) 
# 
# 
# alldata10 <- cbind(samp_grp, cluster)



#####
# Adding the new variables
#####

alldata$worker <- ifelse(alldata$EMPLY == 'Yes' , 1, 0)
alldata$worker <- ifelse(is.na(alldata$worker), 0, alldata$worker)

alldata$student <- ifelse(alldata$STUDE == 'YES - Full Time' , 1, 0)
alldata$student <- ifelse(is.na(alldata$student), 0, alldata$student)

alldata$driver <- ifelse(alldata$LIC == 'YES' , 1, 0)
alldata$driver <- ifelse(is.na(alldata$driver), 0, alldata$driver)


alldata$graduate <- ifelse(alldata$EDUCA == 'Graduate degree (includes professional degree like MD, DDs, JD)', 1,0)
alldata$graduate <- ifelse(is.na(alldata$graduate), 0, alldata$graduate)

alldata$undergrad <- ifelse(alldata$EDUCA == 'Bachelor’s or undergraduate degree', 1,0)
alldata$undergrad <- ifelse(is.na(alldata$undergrad), 0, alldata$undergrad)


alldata$disability <- ifelse(alldata$DISAB == 'Yes' , 1, 0)
alldata$disability <- ifelse(is.na(alldata$disability), 0, alldata$disability)


alldata$senior <- ifelse(alldata$AgeGrp == 'Age65+' , 1, 0)
alldata$senior <- ifelse(is.na(alldata$senior), 0, alldata$senior)


alldata$seniordisabled = alldata$senior * alldata$disability

alldata$female <- ifelse(alldata$GEND == 'FEMALE' , 1, 0)
alldata$female <- ifelse(is.na(alldata$female), 0, alldata$female)


alldata$femaledisabled = alldata$female * alldata$disability


alldata$childbelow15 <- ifelse(alldata$AgeGrp == 'Age00-03'  |
                                 alldata$AgeGrp == 'Age04-15' , 1, 0)
alldata$childbelow15 <- ifelse(is.na(alldata$childbelow15), 0, alldata$childbelow15)



#driver with young children

alldata$driverWC4to15 = alldata$driver * alldata$Age04_15



# use Elissas poverty definition but create an order numerical variable

alldata$povlevel <- ifelse(alldata$pov_lvl == 'low' , 1,
                           ifelse(alldata$pov_lvl == 'low-med' , 2,
                                  ifelse(alldata$pov_lvl == 'med-high' , 3,
                                         ifelse(alldata$pov_lvl == 'high' , 4,  0))))
alldata$povlevel <- ifelse(is.na(alldata$povlevel), 0, alldata$povlevel)

#dfSummary(alldata$povlevel)                           
alldata$male <- ifelse(alldata$GEND == 'MALE' , 1, 0)
alldata$male <- ifelse(is.na(alldata$male), 0, alldata$male)


alldata$maleworker =  alldata$male * alldata$worker





#####

alldata %>% readr::write_rds(here::here("data","cluster_ses.rds"))












