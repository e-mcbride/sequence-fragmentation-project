
couple_ids <- alldata %>% 
  filter(str_detect(string = RELAT, pattern = "Spouse/Partner")) %>% 
  .$SAMPN

couple_ids_unq <- alldata %>% 
  filter(str_detect(string = RELAT, pattern = "Spouse/Partner")) %>% 
  .$SAMPN %>% 
  unique

length(couple_ids) - length(couple_ids_unq)

# compare the two, find out who the weird ones are and look at their data
id_repeats<-couple_ids[duplicated(couple_ids)]

pr_repeats <-alldata %>% filter(SAMPN %in% id_repeats)

pr_repeats$RELAT %>% unique

age_pr1 <- alldata %>% filter(PERNO == 1) %>% select(SAMPN, age_pr1 = AGE)

xyz <- chts$PERSON %>% 
  left_join(age_pr1, by = c("SAMPN")) %>% 
  mutate(tf       = (as.numeric(AGE)<=18 & str_detect(string = RELAT, pattern = "Spouse/Partner")),
         newrelat = if_else(tf,
                            true = "Child/Daughter/Son/Adopted child/Stepchild/Son-in-law/Daughter-in-law",
                            false = RELAT)) %>% 
  select(SAMPN, PERNO, RELAT, AGE, GEND, age_pr1, tf, newrelat) %>% 
  mutate(agedif = as.numeric(age_pr1) - as.numeric(AGE))



zzz <- xyz  %>% 
  # select(SAMPN, PERNO, RELAT, AGE, age_pr1, agedif) %>% 
  filter(str_detect(string = newrelat, pattern = "Spouse/Partner")) %>% 
  filter(agedif > 30)

xyz_ids <- xyz %>% 
  filter(str_detect(string = newrelat, pattern = "Spouse/Partner")) %>% 
  .$SAMPN
xyz_repeats<-xyz_ids[duplicated(xyz_ids)]

xyzpr_repeats <-xyz %>% filter(SAMPN %in% xyz_repeats)

wtf <- xyzpr_repeats %>% 
  # filter(!tf) %>% 
  # filter(agedif > 25) %>%
  filter(PERNO == 1 | str_detect(string = newrelat, pattern = "Spouse/Partner"))


################
# this is the test for the duplicated stuff
#####
id_repeats<-couple_ids[duplicated(couple_ids)]
# 36
# 15
# 12

pr_repeats <-alldata %>% filter(SAMPN %in% id_repeats) %>% 
  select(source, SAMPN, PERNO, RELAT, AGE, GEND, agedif)
# 137
# 58
# 45
