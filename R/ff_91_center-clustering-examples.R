source('R/ff_01_center-clustering-functions.R')

# Examples ####

# load business establishments data for all of CA, including XY in CA Teale-Albers (crs=3310)
estabs_data <- read_rds('data/nets_locs_retent.rds') 

# run default dbscan on this data at eps=200m, minPts=5 (gives you a dbscan_fast object)
dbscan_default_result <- dbscan(select(estabs_data, X, Y), 
                                eps = 200, minPts = 5, borderPoints = F)
# look at cluster size, note 0 ~ "Not in cluster"
tibble(clust = dbscan_default_result$cluster) %>% count(clust, sort = T)

# attach a cluster # to the estabs data using the functions in this script
estabs_data_cl <- estabs_data %>% 
  mutate(clust = dbscan_clust(select(., X, Y), 
                              eps = 200, minPts = 5))


# save clustered data for use with match_nearest fxns
nets_clust_ex <- estabs_data_cl %>% 
  select(DunsNumber, NAICS2, place_id, X, Y, clust) %>% 
  filter(!is.na(clust)) %>% 
  write_rds('data/nets_locs_retent_clust.rds')

# test a range of eps (neighbor distances)
db_tuning_results <- dbscan_tuning(estabs_data, eps=seq(50,400, 50), minPts = 5, 
                                   id_col = place_id, x_col = X, y_col = Y) 

# what's % of points in cluster for each eps tested?
db_tuning_results_summary <- db_tuning_results %>% 
  group_by(eps) %>% 
  summarise(n_clusts = max(clust, na.rm=T),
            pct_in_clust = mean(!is.na(clust)))

db_tuning_results_summary %>% 
  ggplot(aes(x=eps, y=pct_in_clust, label=n_clusts)) + 
  geom_label() +
  scale_x_continuous('eps ~ maximum neighbor distance', limits=c(0,450), expand=c(0,0)) +
  scale_y_continuous('Share of Businesses in a Cluster', limits=c(0,0.9), expand=c(0,0), 
                     labels=function(p) scales::percent(p,accuracy=1)) + 
  ggtitle('Cluster Tuning Results and Number of Clusters')


# Examples for nearest neighbor and adding clust to other datasets ####
source('R/ff_02_match-nearest-functions.R')

# generate comparison points ... randomly offset ~ 0-50 m in either direction from a subset of other points
# these should all be in same cluster as original point
samp_points <- nets_clust_ex %>% 
  sample_n(10000) %>%
  transmute(newid = paste0('r_', 10000+row_number()),
            orig_clust = clust,
            X = X + runif(n(), -50, 50),
            Y = Y + runif(n(), -50, 50))

# run nearest neighbor comp
samp_points_with_nn <- samp_points %>% 
  bind_cols(nearest_neighbor(select(nets_clust_ex, X, Y), select(., X, Y)))

samp_points_with_clust <- samp_points %>% 
  mutate(clust  = nearest_cluster(., nets_clust_ex, X, Y, clust, eps=200))

samp_points_with_clust %>% count(clust == orig_clust) 

# generate comparison points ... randomly offset ~ 0-1000 m in either direction from a subset of other points
# some of these will be in no cluster, some will be in same, some will be in different
samp_points_km <- nets_clust_ex %>% 
  sample_n(10000) %>%
  transmute(newid = paste0('r_', 10000+row_number()),
            orig_clust = clust,
            X = X + runif(n(), -1000, 1000),
            Y = Y + runif(n(), -1000, 1000))

samp_points_with_clust_km <- samp_points_km %>% 
  mutate(clust  = nearest_cluster(., nets_clust_ex, X, Y, clust, eps=200))
samp_points_with_clust_km %>% count(clust == orig_clust) 
