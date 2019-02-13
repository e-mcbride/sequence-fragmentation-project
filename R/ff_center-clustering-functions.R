library(tidyverse)
library(dbscan)

#estabs_data <- read_rds('data/nets_locs_retent.rds')


# mostly just a wrapper around dbscan::dbscan ... gets used inside dbscan_tuning but also easy to use inside mutate
# main difference from default: can set "noise" points outside of clusters to NA or leave as 0
# coords: data frame or matrix of coordinates, probably 2-columns, one row per point you want to cluster
# eps: neighbor-distance in meters (200ish works well in most of CA, probably vary eps for experiments)
# minPts: minimum number of neighbors for cluster status (5 is min by rule of thumb and works well for CA)
# borderPoints: should non-dense points be added to a cluster within eps (will assign randomly if a point borders multiple clusters)
dbscan_clust <- function(coords, eps, minPts = 5, borderPoints = FALSE, .non_clust_NA = TRUE) {
  
  clust_results <- dbscan::dbscan(x = coords, eps = eps, minPts = minPts, borderPoints = borderPoints) %>% pluck('cluster')
  if (.non_clust_NA) if_else(clust_results != 0, clust_results, NA_integer_)
  else clust_results
  
}


# function to make single tuning df (mostly will just let this be called insode dbscan_tuning)
# output tibble will be [ids, (X), (Y), eps, minPts, clust#]
make_dbscan_df <- function(eps, minPts, coords, keepers,
                           borderPoints = FALSE, .non_clust_NA = TRUE) {
  
  # running clust first really seems to matter for some reason
  clust = dbscan_clust(coords = coords, eps = eps, minPts = minPts, 
                       borderPoints = borderPoints, .non_clust_NA = .non_clust_NA)
  
  keepers %>% 
    mutate(eps = eps,
           minPts = minPts,
           clust = clust)
  
}

# t1 <- make_dbscan_df(200, 5, select(estabs_data, X, Y), select(estabs_data, place_id)) %>% summarise(mean(!is.na(clust)))

# provide eps as vector of neighbor-distance in meters (200ish works well in most of CA, probably vary eps for experiments)
# provide minPts as (vector of) minimum number of neighbors for cluster status (5 is min by rule of thumb and works well for CA)
# provide id_col as unquoted variable name PRESENT in data
# ... if id_col is NOT provided, coords will be included in output by default
# provide either x_col and y_col as unquoted variable names OR coords_cols as character vector (defaults to coords_cols = c('X','Y'))
dbscan_tuning <- function(data, eps, minPts=5, 
                          id_col, x_col, y_col, coords_cols = c('X','Y'), 
                          borderPoints = FALSE, .non_clust_NA = TRUE, .drop_coords = TRUE) {
  
  # if coord variables are not provided as unquoted names, default to using coords_cols character vector
  if (missing(x_col) | missing(y_col)) coords <- select(data, one_of(coords_cols))
  else {
    x_col <- enquo(x_col)
    y_col <- enquo(y_col)
    coords <- select(data, !!x_col, !!y_col) 
  }
  
  # if id_col is not provided, keep coords in output regardless of .drop_coords setting
  if (missing(id_col)) {
    keepers = coords
  } else {
    id_col = enquo(id_col)
    keepers <- select(data, !!id_col)
    if (!.drop_coords) keepers <- bind_cols(keepers, coords)
  }
  
  # enumerate all combinations of eps/minPts parameters
  params <- expand.grid(eps, minPts)
  
  # run dbscan for all params, output result as single tibble
  pmap_dfr(params, 
           ~ make_dbscan_df(..1, ..2, 
                            coords = coords, keepers = keepers,
                            borderPoints = borderPoints, .non_clust_NA = .non_clust_NA))
  
}

# t2 <- dbscan_tuning(estabs_data, eps=c(100,150,200), minPts = 5, id_col = place_id, x_col = X, y_col = Y) %>% group_by(eps) %>% summarize(mean(!is.na(clust)))
# t3 <- dbscan_tuning(estabs_data, eps=c(100,150,200), minPts = 5, id_col = place_id, x_col = X, y_col = Y, borderPoints = T) %>% group_by(eps) %>% summarize(mean(!is.na(clust)))


