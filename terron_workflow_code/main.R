# location of scripts folder
scripts_wd = "D:\\Yannik\\terron\\output\\test"

##### read in functions and libraries #####

setwd(paste0(scripts_wd, "\\scripts"))
# script for clustering functions
source("clustering_fun.R")


##### read in inputs #####

setwd(paste0(scripts_wd, "\\scripts"))
# script for inputs
source("inputs.R")


##### start terron code #####

# set working directory to output_folder
setwd(output_folder)

# determine round number to start on
if (clean_each == TRUE){
  round_num = start_round
} else {
  # initial round_num
  round_num = 1 
}

# start process for each round
for (i in round_num:rounds) {
  
  # if first round, start here; if not, go to else statement at line 107
  if (round_num == 1) {

    setwd("D:\\Yannik\\terron\\output\\test\\scripts")
    # script for round 1
    source("round1.R")
    
    if (clean_each == TRUE) {
      break
    }
    
  } else {
      
    setwd("D:\\Yannik\\terron\\output\\test\\scripts")
    # script for other rounds
    source("otherrounds.R")
    
    if (clean_each == TRUE) {
      break
    }
      
  }
}

close(log_file)