library(tidyverse); 
library(TraMineR); 
library(summarytools)

# code for Fragmentaion report section 6
# July 16-17 2019

# just checking Elissa's data
# read clusters
clusters = read_rds('cluster-ward_5000samp.rds')
View(clusters)
# place sequences

places = read_rds('place_sequence.rds')
View(places)


# read grpvars and find how many households we have
alldata = read_rds('grpvars_ent-tur-com.rds')
View(alldata)
hist(alldata$C)

HH <- alldata %>% group_by(SAMPN) %>%
  summarize( N = n())
dfSummary(HH)

# use the dummy variable Elissa gave to me all good!

alldata$worker <- ifelse(alldata$EMPLY == 'Yes' , 1, 0)
alldata$worker <- ifelse(is.na(alldata$worker), 0, alldata$worker)
summary(as.factor(alldata$worker))

summary(alldata$AgeGrp)

alldata$adult <- ifelse(alldata$AgeGrp == 'Age19-24'  |
                          alldata$AgeGrp == 'Age25-34' |
                            alldata$AgeGrp == 'Age35-44' |
                             alldata$AgeGrp == 'Age45-54' |
                               alldata$AgeGrp == 'Age55-65' |
                                 alldata$AgeGrp == 'Age65+' , 1, 0)
alldata$adult <- ifelse(is.na(alldata$adult), 0, alldata$adult)
summary(alldata$adult)

ctable(alldata$adult, alldata$worker)

alldata$male <- ifelse(alldata$GEND == 'MALE' , 1, 0)
alldata$male <- ifelse(is.na(alldata$male), 0, alldata$male)
alldata$female <- ifelse(alldata$male != 1,  1, 0)

ctable(alldata$male, alldata$female)

alldata$maleadultworker =  alldata$male * alldata$worker * alldata$adult 
alldata$femaleadultworker =  alldata$female * alldata$worker * alldata$adult 
summary(as.factor(alldata$maleadultworker))
summary(as.factor(alldata$femaleadultworker))

summary(as.factor(alldata$HHSIZ))

alldata$menC <- alldata$male * alldata$C
alldata$femaleC <- alldata$female * alldata$C

alldata$manadult <- alldata$male * alldata$adult
#ctable(alldata$manadult, alldata$adult)
alldata$femaleadult <- alldata$female * alldata$adult
#ctable(alldata$femaleadult, alldata$adult)


smalldata <- alldata %>%  select(SAMPN, manadult, adult, maleadultworker, femaleadult, femaleadultworker, C, menC, femaleC)
#View(couples)


houshold <- smalldata %>% group_by(SAMPN) %>%
  summarize(men = sum(manadult),
            women = sum(femaleadult),
            adults = sum(adult),
            workmen = sum(maleadultworker),
            workwomen = sum(femaleadultworker),
            adults = sum(adult),
            manC = sum(menC),
            womanC = sum(femaleC), N = n())

View(houshold)
dfSummary(houshold)
# adult couples with or without children these are household with 1 adult woman and 1 adult man

couples <- houshold %>% filter (women == 1 & men == 1)
dfSummary(couples)



# Just household size 2

wrkcouples <- couples %>% filter (N == 2)

# both working no kids

wrkcouples <- wrkcouples %>% filter(workmen ==1 & workwomen == 1) 
dfSummary(wrkcouples)


#hist(wrkcouples$manC, col='blue', xlim=c(0, 0.5)))
#hist(wrkcouples$womanC, col=rgb(1,0,0,0.3), add=T)

p1 <- hist(wrkcouples$manC,plot=FALSE)
p2 <- hist(wrkcouples$womanC,plot=FALSE)
plot(0,0,type="n",xlim=c(0,0.50),ylim=c(0,1500),xlab="Complexity Values",ylab="freq",main="Complexity of Men vs Women both working no children in 4895 households")
plot(p1,col="blue",density=10,angle=135,add=TRUE)
plot(p2,col="red",density=10,angle=45,add=TRUE)

dfSummary(wrkcouples)

# woman does not work no kids
wrkcouplesb <- couples %>% filter (N == 2)
wrkcouplesb <- wrkcouplesb %>% filter(workmen ==1 & workwomen == 0) 
dfSummary(wrkcouplesb)

p1 <- hist(wrkcouplesb$manC,plot=FALSE)
p2 <- hist(wrkcouplesb$womanC,plot=FALSE)
plot(0,0,type="n",xlim=c(0,0.50),ylim=c(0,1500),xlab="Complexity Values",ylab="freq",main="Complexity of Men vs Women, Man working no children in 2844 households")
plot(p1,col=rgb(0,0,1, 0.5),density=10,angle=135,add=TRUE)
plot(p2,col="red",density=10,angle=45,add=TRUE)

# man does not work no kids
wrkcouplesc <- couples %>% filter (N == 2)
wrkcouplesc <- wrkcouplesc %>% filter(workmen ==0 & workwomen == 1) 
dfSummary(wrkcouplesc)

p1 <- hist(wrkcouplesc$manC,plot=FALSE)
p2 <- hist(wrkcouplesc$womanC,plot=FALSE)
plot(0,0,type="n",xlim=c(0,0.50),ylim=c(0,1500),xlab="Complexity Values",ylab="freq",main="Complexity of Men vs Women, Woman working no children in 2142 households")
plot(p1,col=rgb(0,0,1, 0.5),density=10,angle=135,add=TRUE)
plot(p2,col="red",density=10,angle=45,add=TRUE)

# both working with kids household size greater than 2

family <- couples %>% filter (N > 2)
dfSummary(family)
wrkfamily <- family %>% filter(workmen ==1 & workwomen == 1) 
dfSummary(wrkfamily)

p1 <- hist(wrkfamily$manC,plot=FALSE)
p2 <- hist(wrkfamily$womanC,plot=FALSE)
plot(0,0,type="n",xlim=c(0,0.50),ylim=c(0,1500),xlab="Complexity Values",ylab="freq",main="Complexity of Men vs Women both working with children 4306 households")
plot(p1,col=rgb(0,0,1, 0.5),density=10,angle=135,add=TRUE)
plot(p2,col="red",density=10,angle=45,add=TRUE)


# man  working and woman does not work with kids

family <- couples %>% filter (N > 2)
dfSummary(family)
wrkfamilyb <- family %>% filter(workmen ==1 & workwomen == 0) 
dfSummary(wrkfamilyb)

p1 <- hist(wrkfamilyb$manC,plot=FALSE)
p2 <- hist(wrkfamilyb$womanC,plot=FALSE)
plot(0,0,type="n",xlim=c(0,0.50),ylim=c(0,1500),xlab="Complexity Values",ylab="freq",main="Complexity of Men vs Women, Man only working with children 2811 households")
plot(p1,col=rgb(0,0,1, 0.5),density=10,angle=135,add=TRUE)
plot(p2,col="red",density=10,angle=45,add=TRUE)


# man not working and woman  works with kids

family <- couples %>% filter (N > 2)
dfSummary(family)
wrkfamilyc <- family %>% filter(workmen ==0 & workwomen == 1) 
dfSummary(wrkfamilyc)

p1 <- hist(wrkfamilyc$manC,plot=FALSE)
p2 <- hist(wrkfamilyc$womanC,plot=FALSE)
plot(0,0,type="n",xlim=c(0,0.50),ylim=c(0,500),xlab="Complexity Values",ylab="freq",main="Complexity of Men vs Women, Woman only working with children 624 households")
plot(p1,col=rgb(0,0,1, 0.5),density=10,angle=135,add=TRUE)
plot(p2,col="red",density=10,angle=45,add=TRUE)






