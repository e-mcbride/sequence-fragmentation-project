library(tidyverse); library(here)
# library(TraMineR)

# Figure: Daily Sequences by Cluster 

#####
#' Figure 1: sequence plots divided by type
#####

pl_seq <- readr::read_rds(here("data","sample-seq-05000.rds"))
alldata <- readr::read_rds(here::here("data","pr-dat_for-lm.rds"))

#' PREP DATA for making Figure 1 with ggplot.

##' 1. Rename the columns for the minute of the day (avoids issues created by a previous mistake with column naming)
colnames(pl_seq) <- seq(1,1440) #paste0("y", seq(1,1440))

##' 2. Extracting cluster ids by pid from `alldata`
cluster_id <- alldata %>%
  select(pid, namedcluster) %>%
  group_by(namedcluster) %>% 
  mutate(n_clust = n()) %>%
  ungroup() %>%
  mutate(cluster_count = paste0(namedcluster, " (n=", n_clust,")"))  %>%
  select(-n_clust)

##' 3. Join the cluster ids to the sequences by pid. Make data "long" so ggplot likes it
seq_clust_long <- pl_seq %>% as_tibble(rownames = "pid") %>% 
  mutate(pid = as.numeric(pid)) %>%
  left_join(cluster_id, by = "pid") %>%
  gather(key = "minute", value = "state",  -pid,-namedcluster, -cluster_count) %>%
  mutate(minute =  as.numeric(minute)) %>%
  arrange(pid, minute)

##' 4. Make x axis labels (times)
# timelabs <- c(seq(3,21,3) %>% str_pad(width = 2,side = "left", pad = "0") %>% paste0(":00"), "00:00", "02:59") # 9 labels

timelabs <- c(seq(3,23,4) %>% str_pad(width = 2,side = "left", pad = "0") %>% paste0(":00"), "02:59") # 7 labels
# timelabs

# timelabs5 <- c(seq(3,24,6) %>% str_pad(width = 2,side = "left", pad = "0") %>% paste0(":00"), "02:59")
# timelabs5

#' MAKE FIGURE w/ `ggplot2`
seq_clust_gg <- seq_clust_long %>% 
  # filter(namedcluster == "School Day" | namedcluster =="Traveling") %>%
  ggplot(aes(x = minute, fill =state)) 

seq_clust_gg + geom_area(stat="bin", binwidth = 1, position = "fill") +
  scale_x_continuous('Time of Day', 
                     # breaks=seq(1,1620, by = 180), # 9 labels
                     breaks=seq(1,1620, by = 240), # 7 labels
                     minor_breaks = seq(1,1441, by = 60),
                     labels = timelabs) +
  scale_y_continuous(name = "Frequency")+
  # scale_fill_brewer(palette = "Accent", name = "State",
  #                   labels = c("Home", "Other", "School", "Travel", "Work")) +
  scale_fill_brewer(palette = "Accent", name = "State") +
  facet_wrap(vars(cluster_count), scales = "free_x",dir="v") +
  #facet_wrap(cluster~count, scales = "free_x",dir="v") +
  theme_bw() + 
  theme(
    text = element_text(size=8),
    axis.text = element_text(size=6.5),
    legend.text = element_text(size=7),
    strip.text = element_text(size=8),
    panel.spacing.x = unit(0.28, "cm"),
    panel.border = element_rect(size = 0.2),
    axis.ticks = element_line(size = 0.4)
  )

ggsave(here::here("figs","09-cluster-daily-sequences.png"), units = "in", width = 6.5)#, height = 5.2)



