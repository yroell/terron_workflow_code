setwd(output_folder)

messages = paste0("start of round ", round_num, "\n", "there are 8 main steps in the code")
print_messages(log_file, messages)

# list all tiff files in round folder
rasters = list.files(path = variables[[i]][1], pattern = "*.tif$")

# list all clustered tiff files in round folder
out_rasters = list.files(path = output_folder, pattern = paste0("^rd_", round_num-1, ".*?_clustered.tif$"))

# read all tiff files in round folder
messages = "reading tiffs (step 1 of 8)"
print_messages(log_file, messages)
raster_stack = list()
for (num in 1:length(rasters)) {
  rast_lyr = raster(paste(variables[[i]][1], rasters[num], sep = "/"))
  raster_stack[[num]] = rast_lyr
}

# read all clustered tiff files in output folder
messages = "reading clustered tiffs (step 2 of 8)"
print_messages(log_file, messages)
rast_tmp = list()
rast_sim = grep(paste0("rd_", round_num-1), out_rasters)
for (num in 1:length(grep(paste0("rd_", round_num-1), out_rasters))) {
  rast_lyr = raster(paste(output_folder, out_rasters[rast_sim[num]], sep = "/"))
  rast_tmp[[num]] = rast_lyr + 10^(round_num-1) * num
}
output_stack = merge(stack(rast_tmp))

# get points to extract rasters to
messages = "preparing points (step 3 of 8)"
print_messages(log_file, messages)
rast = raster()
extent(rast) = extent(raster_stack[[1]])
proj4string(rast) = CRS(proj4string(raster_stack[[1]]))
res(rast) = resolution[[i]][1]
rast_res = resample(raster_stack[[1]], rast)
rast_pts = rasterToPoints(rast_res, spatial = TRUE)
xy_coords = coordinates(rast_pts)

# create data frame with coordinates and extracted info
messages = "extracting points (step 4 of 8)"
print_messages(log_file, messages)
pts_data = data.frame(xy_coords)
ex_variables = extract(output_stack, rast_pts)
pts_data = cbind(pts_data, ex_variables)
for (num in 1:length(raster_stack)) {
  ex_variables = extract(raster_stack[[num]], rast_pts)
  pts_data = cbind(pts_data, ex_variables)
}

# clean up data frame to get column names and remove NAs
messages = "cleaning dataframe (step 5 of 8)"
print_messages(log_file, messages)
colnames(pts_data) = c("x", "y", paste0("cluster_", round_num-1), rasters)
pts_na = remove.na(pts_data)
pts = pts_na$x

# get all clusters from previous round to subset with
messages = "counting clusters from previous step (step 6 of 8)"
print_messages(log_file, messages)
clust_col = grep("cluster*", colnames(pts))
df_clust = pts[, c(1:2,clust_col)]
var_count_all = as.data.frame(plyr::count(df_clust[,-c(1,2)]))
var_count = as.data.frame(var_count_all[,1])

messages = paste0("completing steps 7 and 8: ", nrow(var_count), " times")
print_messages(log_file, messages)
# make map for each previos cluster
for (j in 1:nrow(var_count)) {    
  
  # create logical statement for subsetting
  messages = paste0("creating logic statement and subsetting points (step 7 of 8) ", j, " time")
  print_messages(log_file, messages)
  row_info = var_count[j, ]
  raw_logical = paste0("cluster_", round_num-1, " == ", row_info)
  
  # get subset of data
  df_sub = subset(pts, eval(parse(text=raw_logical)))
  
  messages = paste0("clustering data (step 8 of 8) ", j, " time")
  print_messages(log_file, messages)
  if (elbow[[i]][1] == TRUE) {
    
    # get cluster number by elbow method
    number_of_clusters = optimal_cluster(df_sub[,4:ncol(pts)], max_clust[[i]][1])
    messages = paste0("optimal number of clusters: ", number_of_clusters)
    print_messages(log_file, messages)
    
    # cluster the points depending on if fuzzy is TRUE or FALSE
    if (fuzzy[[i]][1] == TRUE) {
      
      # cluster with optimal fuzzy method if opt is TRUE or FALSE
      if (opt[[i]][1] == TRUE) {
        c_pts = fuzme_iteration(df_sub[,4:ncol(df_sub)], number_of_clusters, opt_runs[[i]][1])
        df_rd = cbind(df_sub, c_pts$terron, c_pts$highclass)
        colnames(df_rd) = c(colnames(df_sub), "cluster", "membership")
        rast_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)-1])
        member_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)])
        writeRaster(rast_output, paste("rd", round_num, j, "clustered.tif", sep = "_"))
        writeRaster(member_output, paste("rd", round_num, j, "membership.tif", sep = "_"))
      } else {
        c_pts = cmeans(df_sub[,4:ncol(df_sub)], centers = number_of_clusters, iter.max = 100)
        df_rd = cbind(df_sub, c_pts$cluster, apply(c_pts$membership, 1, max))
        colnames(df_rd) = c(colnames(df_sub), "cluster", "membership")
        rast_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)-1])
        member_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)])
        writeRaster(rast_output, paste("rd", round_num, j, "clustered.tif", sep = "_"))
        writeRaster(member_output, paste("rd", round_num, j, "membership.tif", sep = "_"))
      }
      
    } else {
      k_pts = kmeans(df_sub[,4:ncol(df_sub)], centers = number_of_clusters, iter.max = 100)
      df_rd = cbind(df_sub, k_pts$cluster)
      colnames(df_rd) = c(colnames(df_sub), "cluster")
      rast_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)])
      writeRaster(rast_output, paste("rd", round_num, j, "clustered.tif", sep = "_"))
    }
    
  } else {
    
    # cluster the points depending on if fuzzy is TRUE or FALSE
    if (fuzzy[[i]][1] == TRUE) {
      
      # cluster with optimal fuzzy method if opt is TRUE or FALSE
      if (opt[[i]][1] == TRUE) {
        c_pts = fuzme_iteration(df_sub[,4:ncol(df_sub)], centers = clust_num[[i]][1], opt_runs[[i]][1])
        df_rd = cbind(df_sub, c_pts$terron, c_pts$highclass)
        colnames(df_rd) = c(colnames(df_sub), "cluster", "membership")
        rast_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)-1])
        member_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)])
        writeRaster(rast_output, paste("rd", round_num, j, "clustered.tif", sep = "_"))
        writeRaster(member_output, paste("rd", round_num, j, "membership.tif", sep = "_"))
      } else {
        c_pts = cmeans(df_sub[,4:ncol(df_sub)], centers = clust_num[[i]][1], iter.max = 100)
        df_rd = cbind(df_sub, c_pts$cluster, apply(c_pts$membership, 1, max))
        colnames(df_rd) = c(colnames(df_sub), "cluster", "membership")
        rast_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)-1])
        member_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)])
        writeRaster(rast_output, paste("rd", round_num, j, "clustered.tif", sep = "_"))
        writeRaster(member_output, paste("rd", round_num, j, "membership.tif", sep = "_"))
      }
      
    } else {
      k_pts = kmeans(df_sub[,4:ncol(df_sub)], centers = clust_num[[i]][1], iter.max = 100)
      df_rd = cbind(df_sub, k_pts$cluster)
      colnames(df_rd) = c(colnames(df_sub), "cluster")
      rast_output = rasterize(df_rd[,1:2],rast,df_rd[,ncol(df_rd)])
      writeRaster(rast_output, paste("rd", round_num, j, "clustered.tif", sep = "_"))
    }
  }
  
  # save final df as csv for future analysis
  write.csv(df_rd, paste("rd", round_num, j, "clustered.csv", sep = "_"))
  
  messages = paste0("output saved as: ", paste("rd", round_num, j, "clustered/membership", sep = "_"))
  print_messages(log_file, messages)
  
}

messages = paste0("end of round ", round_num)
print_messages(log_file, messages)
round_num = round_num + 1
