setwd(output_folder)

messages = paste0("start of 1st round", "\n", "there are 5 main steps in the code")
print_messages(log_file, messages)

# list all tiff files in first round folder
rasters = list.files(path = variables[[i]][1], pattern = "*.tif$")

# read all tiff files in first round folder
messages = "reading tiffs (step 1 of 5)"
print_messages(log_file, messages)
raster_stack = list()
for (num in 1:length(rasters)) {
  rast_lyr = raster(paste(variables[[i]][1], rasters[num], sep = "/"))
  raster_stack[[num]] = rast_lyr
}

# get points to extract rasters to
messages = "preparing points (step 2 of 5)"
print_messages(log_file, messages)
rast = raster()
extent(rast) = extent(raster_stack[[1]])
proj4string(rast) = CRS(proj4string(raster_stack[[1]]))
res(rast) = resolution[[i]][1]
rast_res = resample(raster_stack[[1]], rast)
rast_pts = rasterToPoints(rast_res, spatial = TRUE)
xy_coords = coordinates(rast_pts)

# create data frame with coordinates and extracted info
messages = "extracting points (step 3 of 5)"
print_messages(log_file, messages)
pts_data = data.frame(xy_coords)
for (num in 1:length(raster_stack)) {
  ex_variables = extract(raster_stack[[num]], rast_pts)
  pts_data = cbind(pts_data, ex_variables)
}

# clean up data frame to get column names and remove NAs
messages = "cleaning dataframe (step 4 of 5)"
print_messages(log_file, messages)
colnames(pts_data) = c("x", "y", rasters)
pts_na = remove.na(pts_data)
pts = pts_na$x

messages = "clustering data (step 5 of 5)"
print_messages(log_file, messages)
if (elbow[[i]][1] == TRUE) {
  
  # get cluster number by elbow method
  number_of_clusters = optimal_cluster(pts[,3:ncol(pts)], max_clust[[i]][1])
  messages = paste0("optimal number of clusters: ", number_of_clusters)
  print_messages(log_file, messages)
  
  # cluster the points depending on if fuzzy is TRUE or FALSE
  if (fuzzy[[i]][1] == TRUE) {
    
    # cluster with optimal fuzzy method if opt is TRUE or FALSE
    if (opt[[i]][1] == TRUE) {
      c_pts = fuzme_iteration(pts[,3:ncol(pts)], number_of_clusters, opt_runs[[i]][1])
      df = cbind(pts, c_pts$terron, c_pts$highclass)
      colnames(df) = c(colnames(pts), paste("cluster", i, sep = "_"), "membership")
      rast_output = rasterize(df[,1:2],rast,df[,ncol(df)-1])
      member_output = rasterize(df[,1:2],rast,df[,ncol(df)])
      writeRaster(rast_output, paste("rd", round_num, "clustered.tif", sep = "_"))
      writeRaster(member_output, paste("rd", round_num, "membership.tif", sep = "_"))
    } else {
      c_pts = cmeans(pts[,3:ncol(pts)], centers = number_of_clusters, iter.max = 100)
      df = cbind(pts, c_pts$cluster, apply(c_pts$membership, 1, max))
      colnames(df) = c(colnames(pts), paste("cluster", i, sep = "_"), "membership")
      rast_output = rasterize(df[,1:2],rast,df[,ncol(df)-1])
      member_output = rasterize(df[,1:2],rast,df[,ncol(df)])
      writeRaster(rast_output, paste("rd", round_num, "clustered.tif", sep = "_"))
      writeRaster(member_output, paste("rd", round_num, "membership.tif", sep = "_"))
    }
    
  } else {
    k_pts = kmeans(pts[,3:ncol(pts)], centers = number_of_clusters, iter.max = 100)
    df = cbind(pts, k_pts$cluster)
    colnames(df) = c(colnames(pts), paste("cluster", i, sep = "_"))
    rast_output = rasterize(df[,1:2],rast,df[,ncol(df)])
    writeRaster(rast_output, paste("rd", round_num, "clustered.tif", sep = "_"))
  }
  
} else {
  
  # cluster the points depending on if fuzzy is TRUE or FALSE
  if (fuzzy[[i]][1] == TRUE) {
    
    # cluster with optimal fuzzy method if opt is TRUE or FALSE
    if (opt[[i]][1] == TRUE) {
      c_pts = fuzme_iteration(pts[,3:ncol(pts)], clust_num[[i]][1], opt_runs[[i]][1])
      df = cbind(pts, c_pts$terron, c_pts$highclass)
      colnames(df) = c(colnames(pts), paste("cluster", i, sep = "_"), "membership")
      rast_output = rasterize(df[,1:2],rast,df[,ncol(df)-1])
      member_output = rasterize(df[,1:2],rast,df[,ncol(df)])
      writeRaster(rast_output, paste("rd", round_num, "clustered.tif", sep = "_"))
      writeRaster(member_output, paste("rd", round_num, "membership.tif", sep = "_"))
    } else {
      c_pts = cmeans(pts[,3:ncol(pts)], clust_num[[i]][1], iter.max = 100)
      df = cbind(pts, c_pts$cluster, apply(c_pts$membership, 1, max))
      colnames(df) = c(colnames(pts), paste("cluster", i, sep = "_"), "membership")
      rast_output = rasterize(df[,1:2],rast,df[,ncol(df)-1])
      member_output = rasterize(df[,1:2],rast,df[,ncol(df)])
      writeRaster(rast_output, paste("rd", round_num, "clustered.tif", sep = "_"))
      writeRaster(member_output, paste("rd", round_num, "membership.tif", sep = "_"))
    }
    
  } else {
    k_pts = kmeans(pts[,3:ncol(pts)], clust_num[[i]][1], iter.max = 100)
    df = cbind(pts, k_pts$cluster)
    colnames(df) = c(colnames(pts), paste("cluster", i, sep = "_"))
    rast_output = rasterize(df[,1:2],rast,df[,ncol(df)])
    writeRaster(rast_output, paste("rd", round_num, "clustered.tif", sep = "_"))
  }
}
  
  # save final df as csv for future analysis
  write.csv(df, paste("rd", round_num, "clustered.csv", sep = "_"))
  
  messages = paste0("output saved as:", paste("rd", round_num, "clustered", sep = "_"))
  print_messages(log_file, messages)
  
  round_num = round_num + 1
  messages = "end of round 1"
  print_messages(log_file, messages)