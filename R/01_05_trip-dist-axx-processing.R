library(tidyverse); library(here)

chts_rel <- readr::read_rds(here("data", "chts-all-tables_slo-sb.rds"))

# load table linking place number to road segment id
place_seg_links <- read_rds(here("data", "slo_sb_place2segid.rds"))

place_seg_links %<>% 
  mutate(loc_id = paste(SAMPN,PERNO,PLANO, sep='_')) %>%
  select(loc_id, seg_id)

# get segment id for current location, previous location, and next location to segment

locations_rel <- chts_rel$PLACE %>%
  left_join(home_locs, by='SAMPN') %>%
  left_join(school_work_locs, by=c('SAMPN','PERNO')) %>%
  left_join(school_work_activities, by=c('SAMPN','PERNO','PLANO'))


trip_seg_ids <- locations_rel %>% 
  select(SAMPN,PERNO,PLANO) %>%
  mutate(loc_id = paste(SAMPN,PERNO,PLANO, sep='_')) %>%
  group_by(SAMPN,PERNO) %>%
  mutate(prev_loc_id = lag(loc_id),
         next_loc_id = lead(loc_id)) %>%
  left_join(place_seg_links, by=c('prev_loc_id'='loc_id')) %>% rename(prev_seg_id = seg_id) %>%
  left_join(place_seg_links, by='loc_id') %>% rename(cur_seg_id = seg_id) %>%
  left_join(place_seg_links, by=c('next_loc_id'='loc_id')) %>% rename(next_seg_id = seg_id)
 

# Load the distance matrix for all pairs of seg_ids that appear in CHTS for these counties and calculate 3 relevant distances for each place (prev->current, current->next, prev->next).
# Because we're pulling values from a matrix rather than performing a join, this must be performed using row-wise

 
# load distance matrix of segment ids
dists_for_travel <- read_rds(here('data', 'slo_sb_dists4travel.rds'))
dists_ids <- rownames(dists_for_travel) # this'll work as long as it's a square matrix

# NA-safe function for pulling distances from dists_for_travel matrix
# because this process is done on a row-by-row basis, 
# no need to worry about functions that don't work with vectors
pull_distance_from_mat <- function(from_id, to_id, dist_mat=dists_for_travel, ok_ids=dists_ids) {
  if (all(c(from_id,to_id) %in% ok_ids)) return(dist_mat[from_id, to_id])
  else return(NA)
}

# pull all relevant distances
trip_seg_lengths <- trip_seg_ids %>%
  rowwise() %>%
  mutate(dist_m_prev2cur  = pull_distance_from_mat(prev_seg_id, cur_seg_id),
         dist_m_cur2next  = pull_distance_from_mat(cur_seg_id, next_seg_id),
         dist_m_prev2next = pull_distance_from_mat(prev_seg_id, next_seg_id)) %>%
  ungroup() %>%
  mutate(dist_m_out_of_way = dist_m_prev2cur + dist_m_cur2next - dist_m_prev2next) %>%
  select(SAMPN,PERNO,PLANO,cur_seg_id,dist_m_prev2cur:dist_m_out_of_way)
 


### Join Accessibilities
 
accessibilities <- readr::read_rds('slo_sb_segidAccess_pow10km.rds')
trip_dist_axx <- trip_seg_lengths %>% left_join(accessibilities, by=c('cur_seg_id'='seg_id'))
 

trip_dist_axx %>% readr::write_rds(here("data", "trip-dist-axx_places.rds"))
