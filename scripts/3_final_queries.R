### WORK WITH THE LIST OF IDs that we are interested in
# Import libraries and packages
library(sf)
library(dplyr)
library(gfwr)
library("ggplot2")
library(openxlsx)
library(arrow)
key <- gfw_auth()

# Import the list of IDs
id_list <- read.csv("C:\\Users\\alezi\\OneDrive\\Escritorio\\Master_Thesis\\data_out\\unique_id_vessels.csv")

# Create a loop that goes over the list of IDs and use the get_vessel_info function
#temp <- get_vessel_info(
  #query = "id = 'ee4409ed9-9530-1a82-524d-6cb8d2ed40f3'", 
  #search_type = "advanced", 
  #dataset = "all",
  #key = key
#)

#########################
####### Gear Type #######
#########################
# Determine the number of chunks
num_chunks <- ceiling(nrow(id_list) / 400)
# Initialize a list to store the events data
vessel_infos_list <- list()

# Loop through each chunk
for (i in 1:num_chunks) {
  print(paste("Processing chunk", i, "of", num_chunks))
  
  # Determine the range of indices for the current chunk
  start_index <- (i - 1) * 400 + 1
  end_index <- min(i * 400, nrow(id_list))
  
  # Loop through each vessel ID in the current chunk
  vessel_ids <- paste0(id_list$id_vessel[start_index:end_index], collapse = ",")
  # Retrieve vessel information for the current ID
  vessel_info <- get_vessel_info(
    query = vessel_ids ,
    search_type = "id",
    dataset = "all",
    key = key
  )
  # Append the events data to the list
  vessel_infos_list[[i]] <- vessel_info
}
# Combine all vessel info data into a single dataframe
all_vessel_infos <- do.call(rbind, vessel_infos_list)
# Keep only 'id' and 'geartype' columns
all_vessel_infos <- all_vessel_infos[, c('id', 'geartype')]

# Save the result to a CSV file if needed
write.csv(all_vessel_infos, "C:\\Users\\alezi\\OneDrive\\Escritorio\\Master_Thesis\\data_out\\vessel_id_geartype.csv", row.names = FALSE)



# Create a loop that goes over the list of IDs and, with the get_event_info function, get all the port
# visits in the years 2018, 2019, 2020, 2021 and 2022.

##########################
###### Port Visits #######
##########################

# Determine the number of chunks
num_chunks <- ceiling(nrow(id_list) / 400)
# Initialize a list to store the events data
total_port_visits <- list()

# Loop through each chunk
for (i in 1:num_chunks) {
  print(i)
  # Determine the range of indices for the current chunk
  start_index <- (i - 1) * 400 + 1
  end_index <- min(i * 400, nrow(id_list))
  
  # Get the vessel IDs for the current chunk
  vessel_ids <- paste0(id_list$id_vessel[start_index:end_index], collapse = ",")
  
  # Retrieve events for the current chunk of vessel IDs
  events <- get_event(event_type = "port_visit",
                      vessel = vessel_ids,
                      start_date = "2018-01-01",
                      end_date = "2022-12-31",
                      key = key)
  
  # Append the events data to the list
  total_port_visits[[i]] <- events
}

# Combine all events data into a single dataframe
all_events <- do.call(rbind, total_port_visits)

# Export
file_name <- paste0("final_port_visits.xlsx")

# Export the subset of data to Excel
write.xlsx(all_events, file_name)

##########################
##### Fishing Events #####
##########################

# Determine the number of chunks
num_chunks <- ceiling(nrow(id_list) / 400)
# Initialize a list to store the events data
total_fish_events <- list()

# Loop through each chunk
for (i in 1:num_chunks) {
  print(i)
  # Determine the range of indices for the current chunk
  start_index <- (i - 1) * 400 + 1
  end_index <- min(i * 400, nrow(id_list))
  
  # Get the vessel IDs for the current chunk
  vessel_ids <- paste0(id_list$id_vessel[start_index:end_index], collapse = ",")
  
  # Retrieve events for the current chunk of vessel IDs
  events <- get_event(event_type = "fishing",
                      vessel = vessel_ids,
                      start_date = "2018-01-01",
                      end_date = "2022-12-31",
                      key = key)
  
  # Append the events data to the list
  total_fish_events[[i]] <- events
}

# Combine all events data into a single dataframe
all_events <- do.call(rbind, total_fish_events)


###################################
###### Previous Port Visits #######
###################################
# This code get the port visits in the previous periods
# to study if there exists an anticipation effect.

# Determine the number of chunks
num_chunks <- ceiling(nrow(id_list) / 400)
# Initialize a list to store the events data
total_port_visits <- list()

# Loop through each chunk
for (i in 1:num_chunks) {
  print(i)
  # Determine the range of indices for the current chunk
  start_index <- (i - 1) * 400 + 1
  end_index <- min(i * 400, nrow(id_list))
  
  # Get the vessel IDs for the current chunk
  vessel_ids <- paste0(id_list$id_vessel[start_index:end_index], collapse = ",")
  
  # Retrieve events for the current chunk of vessel IDs
  events <- get_event(event_type = "port_visit",
                      vessel = vessel_ids,
                      start_date = "2015-12-31",
                      end_date = "2018-12-31",
                      key = key)
  
  # Append the events data to the list
  total_port_visits[[i]] <- events
}

# Combine all events data into a single dataframe
all_events <- do.call(rbind, total_port_visits)

# Export
file_name <- paste0("previous_port_visits.xlsx")

# Export the subset of data to Excel
write.xlsx(all_events, file_name)


##########################
### Export the dataset ###
##########################


# Determine the number of observations in the dataset
num_obs <- nrow(all_events)

# Calculate the number of observations per file
obs_per_file <- ceiling(num_obs / 2)

# Split the dataset into five parts
split_events <- split(all_events, rep(1:2, each = obs_per_file, length.out = num_obs))

# Export each part to an Excel file
for (i in 1:2) {
  # Define the file name
  file_name <- paste0("final_fishing_part", i, ".xlsx")
  
  # Export the subset of data to Excel
  write.xlsx(split_events[[i]], file_name)
}