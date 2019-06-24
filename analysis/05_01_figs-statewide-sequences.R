# 05_01 Visualizations: Getting the overall pattern statewide
library(tidyverse)
library(here)

pl_seq <- read_rds(here::here("results","place_sequence.rds")) %>% 
  as_tibble(rownames = "pid") %>% 
  mutate(pid = as.numeric(pid))


hhids <- pl_seq %>% transmute(SAMPN = str_sub(pid, end = -2)) %>% 
  distinct 

hhid_samp <- hhids %>% 
  sample_n(size = 15000, replace = FALSE) %>% 
  .$SAMPN

seq_samp <- pl_seq %>% 
  mutate(SAMPN = str_sub(pid, end = -2)) %>%
  filter(SAMPN %in% hhid_samp) %>% 
  select(-SAMPN)

#' Make data "long" so ggplot likes it
#' this also includes adding the better time names

timetable <- tibble(times = colnames(pl_seq %>% select(-pid)), mins = c(seq(from=1, to=1440, by=1)))


seq_long <- seq_samp %>%
  # left_join(cluster.id, by = "pid") %>%
  gather(key = "times", value = "state",  -pid) %>%
  left_join(timetable, by = ("times"))
# %>%
# mutate(minute =  as.numeric(minute)) %>%
# arrange(pid, time)


##' 4. Make x axis labels (times)
timelabs <- c(seq(3,21,3) %>% str_pad(width = 2,side = "left", pad = "0") %>% paste0(":00"), "00:00", "02:59")


#' MAKE FIGURE w/ `ggplot2`

seq_long %>% 
  #filter(cluster == "School Day") %>% 
  ggplot(aes(x = mins, fill =state)) + 
  geom_area(stat="bin", binwidth = 1, position = "fill") +
  scale_x_continuous('Time of Day', 
                     breaks=seq(1,1620, by = 180), 
                     minor_breaks = seq(1,1441, by = 60),
                     labels = timelabs) +
  scale_y_continuous(name = "Frequency")+
  scale_fill_brewer(palette = "Accent", name = "State", 
                    labels = c("Home", "Other", "School", "Travel", "Work")) +
  # facet_wrap(vars(cluster_count), scales = "free_x",dir="v") +
  #facet_wrap(cluster~count, scales = "free_x",dir="v") +
  theme_bw() + 
  
  theme(
    text = element_text(size=8),
    axis.text = element_text(size=7),
    legend.text = element_text(size=7),
    #strip.background = , 
    strip.text = element_text(size=8),
    panel.spacing.x = unit(0.28, "cm"),
    panel.border = element_rect(size = 0.4),
    axis.ticks = element_line(size = 0.4)
  )

ggsave(here("figs","statewide-sequences.png"), units = "in", width = 6.4, height = 5.2)


