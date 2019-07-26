library(tidyverse); 
library(TraMineR); 
library(here)
library(summarytools)

# code for Fragmentaion report section 6
# July 16-17 2019

# just checking Elissa's data
# read clusters
clusters <- read_rds(here::here('data','cluster-ward_5000samp.rds'))

# place sequences

places <- read_rds(here::here('results', 'place_sequence.rds'))



# read grpvars and find how many households we have
alldata <- read_rds(here::here('results','grpvars_ent-tur-com.rds'))

# hist(alldata$C)

HH <- alldata %>% group_by(SAMPN) %>%
  summarize( N = n())
# dfSummary(HH)


################################################################################
# Building dummy variables
################################################################################
# use the dummy variable Elissa gave to me all good!

alldata$worker <- ifelse(alldata$EMPLY == 'Yes' , 1, 0)
alldata$worker <- ifelse(is.na(alldata$worker), 0, alldata$worker)
# summary(as.factor(alldata$worker))

# summary(alldata$AgeGrp)

alldata$adult <- ifelse(alldata$AgeGrp == 'Age19-24'  |
                          alldata$AgeGrp == 'Age25-34' |
                            alldata$AgeGrp == 'Age35-44' |
                             alldata$AgeGrp == 'Age45-54' |
                               alldata$AgeGrp == 'Age55-65' |
                                 alldata$AgeGrp == 'Age65+' , 1, 0)
alldata$adult <- ifelse(is.na(alldata$adult), 0, alldata$adult)
# summary(alldata$adult)

# ctable(alldata$adult, alldata$worker)

alldata$male <- ifelse(alldata$GEND == 'MALE' , 1, 0)
alldata$male <- ifelse(is.na(alldata$male), 0, alldata$male)
alldata$female <- ifelse(alldata$male != 1,  1, 0)

# ctable(alldata$male, alldata$female)

alldata$maleadultworker =  alldata$male * alldata$worker * alldata$adult 
alldata$femaleadultworker =  alldata$female * alldata$worker * alldata$adult 
# summary(as.factor(alldata$maleadultworker))
# summary(as.factor(alldata$femaleadultworker))

summary(as.factor(alldata$HHSIZ))

alldata$menC <- alldata$male * alldata$C
# alldata$femaleC <- alldata$female * alldata$C
alldata$womC <- alldata$female * alldata$C

alldata$manadult <- alldata$male * alldata$adult

# alldata$femaleadult <- alldata$female * alldata$adult
alldata$womadult <- alldata$female * alldata$adult


smalldata <- alldata %>%  
  select(SAMPN, manadult, adult, maleadultworker, femaleadult, femaleadultworker, C, menC, femaleC)



houshold <- smalldata %>% group_by(SAMPN) %>%
  summarize(men = sum(manadult),
            women = sum(femaleadult),
            adults = sum(adult),
            workmen = sum(maleadultworker),
            workwomen = sum(femaleadultworker),
            adults = sum(adult),
            manC = sum(menC),
            womanC = sum(femaleC), N = n())

# View(houshold)
# dfSummary(houshold)

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
# adult couples with or without children these are household with 1 adult woman and 1 adult man
################################################################################
couples <- houshold %>% filter (women == 1 & men == 1)
# dfSummary(couples)


################################################################################
# Just household size 2, both working
################################################################################
wrkcouples <- couples %>% filter (N == 2) %>% 
  # both working no kids
  filter(workmen ==1 & workwomen == 1) 
# dfSummary(wrkcouples)

png(here::here("figs", "hist-wrkcouples.png"),width = 6, height = 5.14, units = "in", res = 300, pointsize = 9)
wrkcouples %>% hist_men_v_women(menvar = "manC", womenvar = "womanC", 
                                main = "Complexity of Men vs Women both working no children in 4895 households")
dev.off()

################################################################################
# woman does not work no kids
################################################################################
wrkcouplesb <- couples %>% filter (N == 2) %>% 
  filter(workmen ==1 & workwomen == 0) 
# dfSummary(wrkcouplesb)
png(here::here("figs", "hist-wrkcouplesb.png"),width = 6, height = 5.14, units = "in", res = 300, pointsize = 9)
wrkcouplesb %>%  hist_men_v_women(menvar = "manC", womenvar = "womanC", 
                                  main = "Complexity of Men vs Women, Man working no children in 2844 households")
dev.off()

################################################################################
# man does not work no kids
################################################################################
wrkcouplesc <- couples %>% filter (N == 2) %>% 
  filter(workmen ==0 & workwomen == 1) 
# dfSummary(wrkcouplesc)
png(here::here("figs", "hist-wrkcouplesc.png"),width = 6, height = 5.14, units = "in", res = 300, pointsize = 9)
wrkcouplesc %>%  hist_men_v_women(menvar = "manC", womenvar = "womanC", 
                                  main = "Complexity of Men vs Women, Woman working no children in 2142 households")
dev.off()

################################################################################
# both working with kids household size greater than 2
################################################################################
family <- couples %>% filter (N > 2)
# dfSummary(family)
wrkfamily <- family %>% filter(workmen ==1 & workwomen == 1) 
# dfSummary(wrkfamily)
png(here::here("figs", "hist-wrkfamily.png"),width = 6, height = 5.14, units = "in", res = 300, pointsize = 9)
wrkfamily %>% hist_men_v_women(menvar = "manC", womenvar = "womanC",
                               main = "Complexity of Men vs Women both working with children 4306 households")
dev.off()

################################################################################
# man  working and woman does not work with kids
################################################################################
wrkfamilyb <- family %>% filter(workmen ==1 & workwomen == 0) 
# dfSummary(wrkfamilyb)
png(here::here("figs", "hist-wrkfamilyb.png"),width = 6, height = 5.14, units = "in", res = 300, pointsize = 9)
wrkfamilyb %>% hist_men_v_women(menvar = "manC", womenvar = "womanC", 
                                main = "Complexity of Men vs Women, Man only working with children 2811 households")
dev.off()

################################################################################
# man not working and woman works with kids
################################################################################
wrkfamilyc <- family %>% filter(workmen ==0 & workwomen == 1) 
# dfSummary(wrkfamilyc)
png(here::here("figs", "hist-wrkfamilyc.png"),width = 6, height = 5.14, units = "in", res = 300, pointsize = 9)
wrkfamilyc %>% hist_men_v_women(menvar = "manC", womenvar = "womanC",
                                main = "Complexity of Men vs Women, Woman only working with children 624 households",
                                ylim = c(0,500))
dev.off()






