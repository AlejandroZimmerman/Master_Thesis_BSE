library(sf)
library(dplyr)
library(gfwr)
library("ggplot2")
library(openxlsx)
library(arrow)
key <- gfw_auth()

# Import the list of IDs
#id_list <- read.csv("C:\\Users\\alezi\\OneDrive\\Escritorio\\Master_Thesis\\data_out\\unique_id_vessels.csv")
id_list <- read.csv("C:\\Users\\alezi\\OneDrive\\Escritorio\\Master_Thesis\\data_out\\unique_ids.csv")

##################################
####### Tonnage and Lenght #######
##################################
# Determine the number of chunks
num_chunks <- ceiling(nrow(id_list) / 10)
# Initialize a list to store the events data
vessel_infos_list <- list()
# Initialize an empty dataframe to store the results
final_df <- data.frame(id = character(), lengthM = numeric(), tonnageGt = numeric())

# Loop through each chunk
for (i in 1:num_chunks) {
  print(paste("Processing chunk", i, "of", num_chunks))
  
  # Determine the range of indices for the current chunk
  start_index <- (i - 1) * 10 + 1
  end_index <- min(i * 10, nrow(id_list))
  
  # Loop through each vessel ID in the current chunk
  vessel_ids <- id_list$id_vessel[start_index:end_index]
  # Retrieve vessel information for the current ID
  vessel_info <- get_vessel_info(ids = vessel_ids,
                                 search_type = "id",
                                 key = key)
  # Extract relevant information and bind it to the final dataframe
  registry_info <- vessel_info$registryInfo
  temp_df <- data.frame(id = registry_info$id,
                        lengthM = registry_info$lengthM,
                        tonnageGt = registry_info$tonnageGt)
  final_df <- bind_rows(final_df, temp_df)
}

# Save the result to a CSV file if needed
write.csv(final_df, "C:\\Users\\alezi\\OneDrive\\Escritorio\\Master_Thesis\\data_out\\vessel_id_leng_ton.csv", row.names = FALSE)

######################################################################
# Other one without chunks#


final_df <- data.frame(id = character(), lengthM = numeric(), tonnageGt = numeric())
# Loop through each vessel ID in id_list
# Loop through each vessel ID in id_list
for (i in 1:nrow(id_list)) {
  # Print progress message at every 50th iteration
  if (i %% 50 == 0) {
    print(paste("Processing vessel", i, "of", nrow(id_list)))
  }
  
  # Retrieve the current vessel ID
  vessel_id <- id_list$id_vessel[i]
  
  # Retrieve vessel information for the current ID
  vessel_info <- get_vessel_info(ids = c(vessel_id),
                                 search_type = "id",
                                 key = key)
  
  # Extract relevant information and bind it to the final dataframe
  
  registry_info <- vessel_info$registryInfo
  self_rep_info <- vessel_info$selfReportedInfo
  
  temp_df <- data.frame(id = self_rep_info$id,
                        lengthM = registry_info$lengthM,
                        tonnageGt = registry_info$tonnageGt)
  final_df <- bind_rows(final_df, temp_df)
}



# Drop duplicates based on 'id' column
final_df_2 <- final_df %>% distinct(id, .keep_all = TRUE)
# Save the result to a CSV file if needed
write.csv(final_df_2, "C:\\Users\\alezi\\OneDrive\\Escritorio\\Master_Thesis\\data_out\\vessel_id_leng_ton.csv", row.names = FALSE)



b <-get_vessel_info(ids = "2bf16f8e4-40e0-b6a2-1859-df04aa31107f",
                search_type = 'id',
                key = key)

# Initialize final dataframe
final_df <- data.frame(id = character(), lengthM = numeric(), tonnageGt = numeric(), stringsAsFactors = FALSE)

# Loop through each vessel ID in id_list
for (i in 1800:nrow(id_list)) {
  # Print progress message at every 50th iteration
  if (i %% 50 == 0) {
    print(paste("Processing vessel", i, "of", nrow(id_list)))
  }
  
  # Retrieve the current vessel ID
  vessel_id <- id_list$id_vessel[i]
  
  # Retrieve vessel information for the current ID
  vessel_info <- get_vessel_info(ids = c(vessel_id), search_type = "id", key = key)
  
  # Check if vessel_info contains the expected data
  if (!is.null(vessel_info$registryInfo) && !is.null(vessel_info$selfReportedInfo)) {
    registry_info <- vessel_info$registryInfo
    self_rep_info <- vessel_info$selfReportedInfo
    
    # Check if the required fields are not NULL and not empty
    if (!is.null(registry_info$lengthM) && !is.null(registry_info$tonnageGt) && !is.null(self_rep_info$id) &&
        length(registry_info$lengthM) > 0 && length(registry_info$tonnageGt) > 0 && length(self_rep_info$id) > 0) {
      temp_df <- data.frame(id = self_rep_info$id,
                            lengthM = registry_info$lengthM,
                            tonnageGt = registry_info$tonnageGt,
                            stringsAsFactors = FALSE)
      final_df <- bind_rows(final_df, temp_df)
    } else {
      print(paste("Missing or empty data for vessel", vessel_id))
    }
  } else {
    print(paste("No registry or self-reported info for vessel", vessel_id))
  }
}
