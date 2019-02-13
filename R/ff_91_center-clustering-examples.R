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

