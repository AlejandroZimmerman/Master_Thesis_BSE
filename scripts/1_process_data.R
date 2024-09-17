### FIRST STEP FOR PROCESSING THE DATA, GET ALL THE PORT VISITS OF EVERY VESSEL OF EVERY FLAG
# Import libraries and packages
library(sf)
library(dplyr)
library(gfwr)
library("ggplot2")
library(openxlsx)
library(arrow)
key <- gfw_auth()


### Download the data corresponding to the british vessels and the flags that landed in the UK.
# Create the list with all the different flags to inlcude in the loop
flags <- c("GBR", "FRA", "BEL", "ESP", "NOR", "DEU", 'SWE', 'IRL', 'DNK','NLD')


#Example:
# example <- get_vessel_info(
#   query = "flag = 'NLD'", 
#   search_type = "advanced", 
#   dataset = "all",
#   key = key
# )


### Create a loop that downloads the data for each flag.
# Build a list to store the id and the flag and finally drop the first dataframe generated to clean the memory

id_list <- list()
flags_list <- list()

for (i in flags) {
  temp <- get_vessel_info(
    query = paste0("flag = '", i, "'"), 
    search_type = "advanced", 
    dataset = "all",
    key = key
  )
  
  # Store vessel IDs and flags in a data frame
  temp_df <- data.frame(id = unlist(temp$id), flag = i)
  
  # Append to id_list
  id_list <- c(id_list, temp_df$id)
  
  # Append to flags_list
  flags_list <- c(flags_list, list(temp_df))
  
  # Remove temp dataframe
  rm(temp, temp_df)
}

# Combine all flag-vessel pairs into a single data frame
final_df <- do.call(rbind, flags_list)


#dplyr::count(example, geartype, sort = TRUE)


#####################
#### PORT VISITS ####
#####################

# Get the PORT VISITS for the vessels
# Determine the number of chunks
num_chunks <- ceiling(nrow(final_df) / 400)

# Initialize a list to store the events data
events_list <- list()

# Loop through each chunk
for (i in 1:num_chunks) {
  print(i)
  # Determine the range of indices for the current chunk
  start_index <- (i - 1) * 400 + 1
  end_index <- min(i * 400, nrow(final_df))
  
  # Get the vessel IDs for the current chunk
  vessel_ids <- paste0(final_df$id[start_index:end_index], collapse = ",")
  
  # Retrieve events for the current chunk of vessel IDs
  events <- get_event(event_type = "port_visit",
                      vessel = vessel_ids,
                      start_date = "2019-01-01",
                      end_date = "2022-01-01",
                      key = key)
  
  # Append the events data to the list
  events_list[[i]] <- events
}

# Combine all events data into a single dataframe
all_events <- do.call(rbind, events_list)

### Export the dataset

# Determine the number of observations in the dataset
num_obs <- nrow(all_events)

# Calculate the number of observations per file
obs_per_file <- ceiling(num_obs / 5)

# Split the dataset into five parts
split_events <- split(all_events, rep(1:5, each = obs_per_file, length.out = num_obs))

# Export each part to an Excel file
for (i in 1:5) {
  # Define the file name
  file_name <- paste0("unfiltered_events_part", i, ".xlsx")
  
  # Export the subset of data to Excel
  write.xlsx(split_events[[i]], file_name)
}



