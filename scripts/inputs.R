if (running == "main") {
  ##### set inputs #####
  
  # number of rounds
  rounds = 2
  
  # list of rasters for each round
  variables = list("D:\\Yannik\\terron\\national\\norm_vars",
		   "D:\\Yannik\\terron\\regional\\norm_vars")
  
  # resolution for each round
  resolution = list(304, 30.4)
  
  # number of clusters for each round, not used if elbow = TRUE
  clust_num = list(1, 9)
  
  # clustering method for each round
  fuzzy = list(TRUE, FALSE)
  
  # output folder
  output_folder = "D:\\Yannik\\terron\\output\\test"
  
  # if number of clusters should be picked automatically or fuzzy optimized, change inputs below
  # WARNING: increases time to complete code drastically, if elbow or opt = TRUE
  
  # pick optimal cluster number by elbow method for each round
  elbow = list(TRUE)
  
  # max clusters to test in elbow method, only applies if elbow = TRUE
  max_clust = list(12)
  
  # optimize fuzzy if picked for each round
  opt = list(TRUE)
  
  # number of runs for optimizing fuzzy
  opt_runs = list(5)
  
  # set seed if interested
  seed = 123
  set.seed(seed)
  
  # manual cleaning after each round
  clean_each = FALSE
  start_round = 1
}

if (running == "windows") {
  ##### set inputs #####
  
  # number of rounds
  rounds = as.integer(winDialogString("How many levels of terrons do you want? (please insert a number)", ""))
  
  
  # list of rasters for each round
  variables = list()
  for (i in 1:rounds) {
    variables[i] = winDialogString(paste0("What is the path to the folder containing the variables for round ", i, "?"), "")
  }
  
  
  # resolution for each round
  resolution = list()
  for (i in 1:rounds) {
    resolution[i] = as.numeric(winDialogString(paste0("What is the resolution for round ", i, 
                                                      "? (please insert a number"), ""))
  }
  
  
  # pick optimal cluster number by elbow method for each round
  elbow = list()
  for (i in 1:rounds) {
    elbow[i] = as.logical(winDialogString(paste0("Should the elbow method be used to determine the number of clusters for round ", i,
                                                 "? (TRUE or FALSE)"), ""))
  }
  
  # number of clusters for each round, not used if elbow = TRUE
  clust_num = list()
  # max clusters to test in elbow method, only applies if elbow = TRUE
  max_clust = list()
  
  i = 1
  for (n in elbow) {
    if (n == TRUE) {
      clust_num[i] = 2
      max_clust[i] = as.numeric(winDialogString(paste0("What is the maximum number of clusters to test in elbow method for round ", i,
                                                       "? (please insert a number)"), ""))
    }
    if (n == FALSE) {
      clust_num[i] = as.numeric(winDialogString(paste0("What is the number of clusters for round ", i,
                                                       "? (please insert a number)"), ""))
      max_clust[i] = 2
    }
    i = i + 1
  }
  
  
  # clustering method for each round
  fuzzy = list()
  for (i in 1:rounds) {
    fuzzy[i] = as.logical(winDialogString(paste0("Should fuzzy c-means be used for round ", i,
                                                 "? (TRUE or FALSE)"), ""))
  }
  
  # optimize fuzzy if picked for each round
  opt = list()
  # number of runs for optimizing fuzzy
  opt_runs = list()
  
  i = 1
  for (n in fuzzy) {
    if (n == TRUE) {
      opt[i] = as.logical(winDialogString(paste0("Should fuzzy c-means be optimized for round ", i,
                                                 "? (TRUE or FALSE)"), ""))
      if (opt[i] == TRUE) {
        opt_runs[i] = as.numeric(winDialogString(paste0("What is the number of runs for optimizing the clustering output for round ", i,
                                                        "? (please insert a number)"), "5"))
      }
      if (opt[i] == FALSE) {
        opt_runs[i] = 1
      }
    }
    if (n == FALSE) {
      opt[i] = FALSE
      opt_runs[i] = 2
    }
    i = i + 1
  }
  
  
  # output folder
  output_folder = winDialogString("What is the path to the output folder?", "")
  
  # manual cleaning after each round
  clean_each = as.logical(winDialogString(paste0("Should terrons be cleaned at the end of the round? (TRUE or FALSE; TRUE stops the code after this round)"), ""))
  if (clean_each == TRUE) {
    start_round = as.numeric(winDialogString(paste0("What round should the code restart on if cleaning is applied? (please insert a number)"), ""))
  } else {
    start_round = 1
  }
  
  # seed set
  seed = 123
  set.seed(seed)
  
  # WARNING: if number of clusters should be picked automatically or fuzzy optimized,
  # computation time drastically increases, if elbow or opt = TRUE
  # cleaning manually takes time and care to make sure the code runs properly again
}


##### create logfile and record inputs #####

log_file = file(paste0(output_folder, "\\logfile.txt"), open = "a")
messages = paste0("inputs for this run at ", Sys.time(), "\n",
                  "scripts folder is set to ", scripts_wd, "\n",
                  "number of rounds = ", rounds, "\n",
                  "folder of variables for each round = ", paste0(unlist(variables), collapse = "   "), "\n",
                  "resolution for rounds = ", paste0(unlist(resolution), collapse = "   "), "\n",
                  "number of clusters for each round = ", paste0(unlist(clust_num), collapse = "   "), " (not used if elbow is TRUE)", "\n",
                  "clustering method for each round = ", paste0(unlist(fuzzy), collapse = "   "), " (TRUE = fuzzy c-means and FALSE = k-means)", "\n",
                  "output folder for everything = ", output_folder, "\n",
                  "elbow method for each round = ", paste0(unlist(elbow), collapse = "   "), " (TRUE = elbow method used and FALSE = manual cluster number used)", "\n",
                  "max number of clusters to test in elbow method = ", paste0(unlist(max_clust), collapse = "   "), "\n",
                  "optimize fuzzy clustering = ", paste0(unlist(opt), collapse = "   "), " (if fuzzy is TRUE)", "\n",
                  "number of times to optimize = ", paste0(unlist(opt_runs), collapse = "   "), " (if fuzzy is TRUE)", "\n",
                  "manual cleaning data after each round = ", clean_each, "\n",
                  "round to start on after manual cleaning each round = ", start_round, "\n",
                  "seed set to ", seed, "\n")
print_messages(log_file, messages)

