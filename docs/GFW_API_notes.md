# Brief Description of the Datasets and Scripts


## GFW API's

The way of accessing to the GFW data is through queries to the different
API's that GFW provides. The API's are the following:

1.  Vessel API
2.  Events API
3.  Map Visualization API
4.  Insights API

The forth API is a new feature included in API Version 3. The objective
of the insights is to support risk-based decision-making, operational
planning, and other due diligence activities by making it easier for a
user to identify vessel characteristics that can indicate an increased
potential or opportunity for a vessel to engage in IUU (Illegal,
Unreported, or Unregulated) fishing. The Insights API is not yet
implemented in the gfwr library. Because the current version of gfwr
gives access to the API Version 2, we will focus on the first three
API's.

***NOTE:*** In this report we will use the gfwr library to display the
content of each dataset. This library that was built to interact with
the GFW API. The gfwr R package is a simple wrapper for the Global
Fishing Watch (GFW) APIs. It provides convenient functions to freely
pull GFW data directly into R in tidy formats. To see the whole
documentation of the gfwr library you can visit this
[link](https://github.com/GlobalFishingWatch/gfwr).

This code is used to authenticate the user with the GFW API.

``` {r}
# This is the library that was built to interact with the GFW API 
library(gfwr) 

# This is the function that will authenticate the user with the GFW API.
# To set the key you have to modify R.environ.txt
key <- gfw_auth() 
```

### Vessel API

The way of accessing to the Vessel API is through the function
`get_vessel_info()`. This function allows to search for vessels by name,
IMO, MMSI, or flag. The function returns a data frame with the
information of the vessels that match the search criteria. The following
code shows how to use the function `get_vessel_info` to search for the
vessel with the imo = 8733445.

``` {r}
vessel_example <- get_vessel_info(
#   query = "flag = 'NLD'", 
#   search_type = "advanced", 
#   dataset = "all",
#   key = key
# )

# Display the content of the dataset
colnames(vessel_example)
```

### Events API

The way of accessing to the Events API is through the function
`get_events()`. This function allows to search for events by vessel,
event_type or date. The function returns a data frame with the
information of the events that match the search criteria. The following
code shows how to use the function `get_events` to search for the events
of the vessel with the id = 224224000.

``` {r}
vessel_id <- get_vessel_info(query = 224224000, search_type = "basic", key = key)$id

event_example <- get_event(event_type = "port_visit",
          vessel = vessel_id,
          start_date = "2019-01-01",
          end_date = "2022-01-01",
          key = key)

colnames(event_example)
```

Using this function, we can filter by start and end date, event type,
flag (country), or multiple vessel IDs. For example, we can filter all the
USA-flagged vessels and search for events between `2020-01-01` and
`2020-02-01`.

```{r}
# Download the list of USA vessels
usa_trawlers <- get_vessel_info(
  query = "flag = 'USA' AND geartype = 'trawlers'",
  search_type = "advanced",
  dataset = "fishing_vessel",
  key = key
)

# Collapse vessel IDs into a comma-separated list to pass to the Events API
usa_trawler_ids <- paste0(usa_trawlers$id[1:100], collapse = ",")

# Get the events for the USA vessels
usa_events <- get_event(
  event_type = "fishing",
  vessel = usa_trawler_ids,
  start_date = "2020-01-01",
  end_date = "2020-02-01",
  key = key
)

# Show the first few rows of the events
head(usa_events)
```
