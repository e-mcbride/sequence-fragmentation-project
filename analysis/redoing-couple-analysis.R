library(tidyverse); library(here)

chts <- read_rds("data-raw/chts_all_2019-06-18.rds")
grpvars <- read_rds(here::here('results','grpvars_ent-tur-com.rds'))

age_pr1 <- chts$PERSON %>% 
  mutate(AGE = as.numeric(AGE)) %>% 
  filter(PERNO == 1) %>% 
  select(SAMPN, age_pr1 = AGE)



pr_rel <- chts$PERSON %>% 
  select(SAMPN, PERNO, AGE, RELAT) %>% 
  left_join(age_pr1, by = c("SAMPN")) %>% 
  mutate(AGE = as.numeric(AGE), 
         agedif = age_pr1 - AGE
         ) %>% 
  # count of how many are called "spouse" in each family
  group_by(SAMPN) %>% 
  mutate(n_partners = sum(RELAT == "Spouse/Partner")) %>% 
  ungroup() %>% 
  
  #' first one: if the age of someone called a spouse/partner is under 18, then call them a child
  mutate(RELAT = if_else(AGE <=18 & str_detect(string = RELAT, pattern = "Spouse/Partner"),
         true = "Child/Daughter/Son/Adopted child/Stepchild/Son-in-law/Daughter-in-law",
         false = RELAT)) %>%
  
  #' second one: if there are more than one partners and perno 1 is 25 years older than one of the partners, 
  #' then make that partner into 
  
  mutate(RELAT = if_else((n_partners > 1) &
                           (str_detect(string = RELAT, pattern = "Spouse/Partner")) &
                           (agedif > 25),
                         true = "Child/Daughter/Son/Adopted child/Stepchild/Son-in-law/Daughter-in-law",
                         false = RELAT)) %>%
  
  #' next: if the difference between perno1 and another person is less than -25, then call them parent
  mutate(RELAT = if_else(condition = str_detect(string = RELAT, pattern = "Spouse/Partner") & (agedif < -25),
                         true = "Parent/Parent in-law/Step-Parent",
                         false = RELAT)) %>%
  select(-AGE)

#' if str_detect(string = RELAT, pattern = "Spouse/Partner") & (agedif > 25)
#' then make RELAT = "Child/Daughter/Son/Adopted child/Stepchild/Son-in-law/Daughter-in-law"
#' else: make RELAT = RELAT
#' 
#' 3. maybe something like if the age difference is higher than some negative number, then make it parents
#' sampn's that have that going on: 1898032, 1408289, 1965896



alldata <- grpvars %>% left_join(pr_rel, by = c("SAMPN", "PERNO"))

couple_ids <- alldata %>% 
  filter(str_detect(string = RELAT, pattern = "Spouse/Partner")) %>% 
  .$SAMPN

couple_ids_unq <- alldata %>% 
  filter(str_detect(string = RELAT, pattern = "Spouse/Partner")) %>% 
  .$SAMPN %>% 
  unique

length(couple_ids) - length(couple_ids_unq)

################################################################################
# dummy variables
################################################################################
alldata$worker <- ifelse(alldata$EMPLY == 'Yes' , 1, 0)
alldata$worker <- ifelse(is.na(alldata$worker), 0, alldata$worker)


alldata$adult <- ifelse(alldata$AgeGrp == 'Age19-24'  |
                          alldata$AgeGrp == 'Age25-34' |
                          alldata$AgeGrp == 'Age35-44' |
                          alldata$AgeGrp == 'Age45-54' |
                          alldata$AgeGrp == 'Age55-65' |
                          alldata$AgeGrp == 'Age65+' , 1, 0)
alldata$adult <- ifelse(is.na(alldata$adult), 0, alldata$adult)


alldata$male <- ifelse(alldata$GEND == 'MALE' , 1, 0)
alldata$male <- ifelse(is.na(alldata$male), 0, alldata$male)
alldata$female <- ifelse(alldata$male != 1,  1, 0)



alldata$manadultworker =  alldata$male * alldata$worker * alldata$adult 
alldata$womadultworker =  alldata$female * alldata$worker * alldata$adult 

alldata$menC <- alldata$male * alldata$C
# alldata$femaleC <- alldata$female * alldata$C
alldata$womC <- alldata$female * alldata$C

alldata$manadult <- alldata$male * alldata$adult

# alldata$femaleadult <- alldata$female * alldata$adult
alldata$womadult <- alldata$female * alldata$adult
#####

#####
smalldata <- alldata %>%  
  select(SAMPN, PERNO, adult, worker ,manadult, manadultworker, womadult, womadultworker, C, menC, womC)

################################################################################
# hh summary, adult couples with or without children
################################################################################

household <- smalldata %>% 
  group_by(SAMPN) %>%
  summarize(N = n(),
            men = sum(manadult),
            women = sum(womadult),
            adults = sum(adult),
            workers = sum(worker),
            workmen = sum(manadultworker),
            workwomen = sum(womadultworker),
            adults = sum(adult),
            manC = sum(menC),
            womanC = sum(womC))

couples <- household %>% filter(SAMPN %in% couple_ids_unq)

# couplez <- household %>% filter (women == 1 & men == 1)


################################################################################
# function to create the histograms
################################################################################
hist_men_v_women <- function(df, menvar, womenvar, main, 
                             type="n",xlim=c(0,0.50),ylim=c(0,1500),xlab="Complexity Values", ylab="freq"){
  
  mhist <- hist(df[[menvar]], plot = FALSE)
  whist <- hist(df[[womenvar]], plot = FALSE)
  
  plot(0,0,type=type,xlim=xlim,ylim=ylim,xlab=xlab, ylab=ylab,main=main,
       family = "serif", cex = 0.2)
  plot(mhist,col=rgb(0,0,1,0.3),add=TRUE)
  plot(whist,col=rgb(1,0,0,0.3),add=TRUE)
  
  legend(x = "topright",
         legend = c("Men", "Women"), 
         col   = c(rgb(0,0,1,0.3), rgb(1,0,0,0.3)),
         pt.cex=2, 
         pch=15)
}

################################################################################
# No children, Both working
################################################################################
wrkcouples <- couples %>% filter((N == 2)& (workers == 2))

man_woman <- couples %>% filter(women == 1 & men == 1)
other_relat <- couples %>% filter(!(women == 1 & men == 1))

MW_wrk <- man_woman %>% filter((N == 2)& (workers == 2))

# other_wrk <- other_relat %>% filter((N == 2)& (workers == 2))

MW_wrk %>% 
  hist_men_v_women(menvar = "manC", womenvar = "womanC", 
                   main = paste0("Complexity of Men vs Women, both working, no children in ", nrow(MW_wrk)," households"))

wrkcouples %>% 
  hist_men_v_women(menvar = "manC", womenvar = "womanC", 
                   main = paste0("Complexity of Men vs Women, both working, no children in ", nrow(MW_wrk)," households"))


# other_wrk %>% 
#   hist_men_v_women(menvar = "manC", womenvar = "womanC", 
#                    main = paste0("Complexity of Men vs Women, both working, no children in ", nrow(MW_wrk)," households"),
#                    ylim = c(0,500))


################################################################################
# adult couples with or without children
################################################################################













