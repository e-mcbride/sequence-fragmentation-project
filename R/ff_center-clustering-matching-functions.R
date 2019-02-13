library(tidyverse)
library(dbscan)

estabs_data <- read_rds('data/nets_locs_retent.rds')


# function that takes point idseps, minPts and provides a data frame with cols
# point_id, eps, minPts, cluster, point coordinates
# this plays nicely with map_dfr
dbscan_to_df = function(x_ids, x_locs, eps, minPts, keep_xs = F) {
  db_obj = dbscan(x_locs, eps, minPts)
  dbdf = data_frame(pointid = x_ids,
                    eps = eps, 
                    minPts = minPts, 
                    clust = db_obj$cluster)
  if (keep_xs) bind_cols(dbdf, x_locs) else dbdf
}

# mostly just a wrapper around dbscan::dbscan ... gets used inside dbscan_tuning but also easy to use inside mutate
# main difference: can set "noise" points outside of clusters to NA or leave as 0
dbscan_clust <- function(coords, eps, minPts = 5, borderPoints = FALSE, .non_clust_NA = TRUE) {
  
  clust_results <- dbscan::dbscan(x = coords, eps = eps, minPts = minPts, borderPoints = borderPoints) %>% pluck('cluster')
  if (.non_clust_NA) if_else(clust_results != 0, clust_results, NA_integer_)
  else clust_results
  
}


# function to make single tuning df (mostly will just let this be called insode dbscan_tuning)
# output tibble will be [ids, (X), (Y), eps, minPts, clust#]
make_dbscan_df <- function(eps, minPts, coords, keepers,
                           borderPoints = FALSE, .non_clust_NA = TRUE) {
  
  keepers %>% 
    mutate(eps = eps,
           minPts = minPts,
           clust = dbscan_clust(coords = coords, eps = eps, minPts = minPts, 
                                    borderPoints = borderPoints, .non_clust_NA = .non_clust_NA))
  
}


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
  pmap_dfr(params, make_dbscan_df, 
           coords = coords, keepers = keepers,
           borderPoints = borderPoints, .non_clust_NA = .non_clust_NA, .drop_coords = .drop_coords)
  
}

#dbscan_to_df_m(estabs_data, 200, 5)



