library(tidyverse)

# this requires the package RANN


# function to grab single nearest neighbor, output as a tibble
nearest_neighbor <- function(match_points, targ_points) {
  nn_obj <- RANN::nn2(match_points, targ_points)
  tibble(nn_index = nn_obj$nn.idx[,1], 
         nn_dist  = nn_obj$nn.dists[,1])
}


# function to grab nearest cluster IFF cluster is within range (probs run within mutate)
# this is bad form, BUT coordinate column names HAVE TO MATCH between the two datasets, give them as unquoted variable names
nearest_cluster <- function(data, clustered_points, eps, 
                            x_col, y_col, clust_col) {

  # capture column names
  x_col <- enquo(x_col)
  y_col <- enquo(y_col)
  clust_col <- enquo(clust_col)
  
  
  nns <- nearest_neighbor(select(clustered_points, !!x_col, !!y_col), 
                          select(data, !!x_col, !!y_col))
  
  # if distance is not provided, set distance to max distance
  if(missing(eps)) eps <- max(nns$nn_dist) + 1
  
  clustered_points %>% 
    select(!!clust_col) %>% 
    slice(nns$nn_index) %>% 
    mutate(dists = nns$nn_dist,
           clust_out = if_else(dists <= eps, !!clust_col, NA_integer_)) %>% 
    .$clust_out
}
