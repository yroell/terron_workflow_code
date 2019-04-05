##### set inputs #####

# number of rounds
rounds = 2

# list of rasters for each round
variables = list("D:\\Yannik\\scratch\\variables_nat",
                 "D:\\Yannik\\scratch\\variables_reg")

# resolution for each round
resolution = list(304, 30.4)

# number of clusters for each round, not used if elbow = TRUE
clust_num = list(3, 9)

# clustering method for each round
fuzzy = list(TRUE, FALSE)

# output folder
output_folder = "D:\\Yannik\\scratch\\output"

# if number of clusters should be picked automatically or fuzzy optimized, change inputs below
# WARNING: increases time to complete code drastically, if elbow or opt = TRUE

# pick optimal cluster number by elbow method for each round
elbow = list(TRUE, FALSE)

# max clusters to test in elbow method, only applies if elbow = TRUE
max_clust = list(12, 12)

# optimize fuzzy if picked for each round
opt = list(TRUE, FALSE)

# number of runs for optimizing fuzzy
opt_runs = list(5, 5)

# set seed if interested
seed = 123
set.seed(seed)

# manual cleaning after each round
clean_each = FALSE
start_round = 3


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
