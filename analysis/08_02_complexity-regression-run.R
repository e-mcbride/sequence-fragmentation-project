#


# First model (without the business establishments added since those will take some time to get together)

# library(censReg)
library(tidyverse); library(here)
library(stargazer)

#library(sf)

pr_dat <- read_rds(here::here("data","pr-dat_for-lm.rds")) %>% ungroup()



lm.fxn <- function(cluster.name) {
  lm(C ~ 
       disability + 
       # native + 
       # hispanic + 
       # pov_lvl + 
       pov_lvl.low +
       weekend +
       # DOW + # **change to weekday?
       # AgeGrp +
       childbelow15 +
       senior +
       # Und04 +
       # Age04_15 +
       # Age16_18 +
       age00_03.d +
       age04_15.d +
       age16_18.d +
       female + 
       worker + 
       student + 
       # driver +
       # HHSIZ + 
       HHVEH +
     LPAgrpfac,
     # avg_serv_ests_10km + 
     # max.kms.from.home,
     data = cluster.name)
  # %>% 
  #   summary()
}

#' below, we exclude "return home" and "traveling" because they are different from the others and the models should not be like dat for them.

linear <- pr_dat %>% 
  group_by(namedcluster) %>%
  nest() %>%
  # filter( != "Return Home" &  != "Traveling") %>%
  mutate(models = map(data, lm.fxn)) %>%
  mutate(tidymodel = map(models, broom::tidy))

#' copy results to paste directly into excel

linear %>% select(namedcluster, tidymodel) %>%
  unnest() %>% 
  select(namedcluster, term, estimate, statistic, p.value) %>%
  gather('stat','est', -namedcluster, -term) %>% 
  #unite(termstat, term, stat, sep='_') %>% 
  spread(namedcluster, est) %>% 
  clipr::write_clip()



######
# df <- pr_dat
# 
# lm(C ~ factor(DISAB) + NTVTY + HISP + pov_lvl +
#      DOW + AgeGrp +
#      # HHSIZ + HHVEH + female + DOW + worker + LPAgrpfac + avg_serv_ests_10km + 
#    max.kms.from.home, 
#    data = pr_dat) %>% 
#   summary()



# pr_dat %>% 
#   group_by() %>% 
#   
#   tobit.fxn() %>% 
#   summary
# #####

#####
#
#####
# x <- linear %>% transmute(summary = map(models, summary))
# 
# x$summary


#####
# models directly to stargazer
#####
lin.mods <- set_names(linear$models, nm = linear$namedcluster)

lin.mods %>% stargazer(type = "text",
                       dep.var.caption = "Cluster Type", 
                       digits = 2,
                       column.labels = names(.),
                       report = "vct*",
                       intercept.bottom = FALSE,
                       # notes = lmnotes,
                       single.row = TRUE,
                       align = TRUE,
                       model.numbers = FALSE,
                       out="figs/cluster-lms-lpalu.htm")

#####
# stuff that didnt work out
#####
# lin.mods <- linear %>% 
#   select(models)
# 
# %>%
#   stargazer(type = "text")#, 
#             dep.var.caption = "Complexity", 
#             out="figures/cluster-lms.htm")
# 
# names(linear)
# names(xyz)
# xyz <- linear$models
# 
# %>% 
#   select(models)
# write_csv(linear, here::here("figures", "lin-models-6.csv"))
