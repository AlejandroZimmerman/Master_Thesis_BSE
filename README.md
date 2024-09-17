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
vessel_example <- get_vessel_info(query = "imo = '8733445'", 
                search_type = "advanced", 
                dataset = "all", 
                key = key)

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
          confidences = "4",
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


### Map Visualization API

Using this function of the gwfr library we can access to the raster data
but it is not possible to plot the actual map.

``` {r}
region_json = '{"geojson":{"type":"Polygon","coordinates":[[[-76.11328125,-26.273714024406416],[-76.201171875,-26.980828590472093],[-76.376953125,-27.527758206861883],[-76.81640625,-28.30438068296276],[-77.255859375,-28.767659105691244],[-77.87109375,-29.152161283318918],[-78.486328125,-29.45873118535532],[-79.189453125,-29.61167011519739],[-79.892578125,-29.6880527498568],[-80.595703125,-29.61167011519739],[-81.5625,-29.382175075145277],[-82.177734375,-29.07537517955835],[-82.705078125,-28.6905876542507],[-83.232421875,-28.071980301779845],[-83.49609375,-27.683528083787756],[-83.759765625,-26.980828590472093],[-83.84765625,-26.35249785815401],[-83.759765625,-25.64152637306576],[-83.583984375,-25.16517336866393],[-83.232421875,-24.447149589730827],[-82.705078125,-23.966175871265037],[-82.177734375,-23.483400654325635],[-81.5625,-23.241346102386117],[-80.859375,-22.998851594142906],[-80.15625,-22.917922936146027],[-79.453125,-22.998851594142906],[-78.662109375,-23.1605633090483],[-78.134765625,-23.40276490540795],[-77.431640625,-23.885837699861995],[-76.9921875,-24.28702686537642],[-76.552734375,-24.846565348219727],[-76.2890625,-25.48295117535531],[-76.11328125,-26.273714024406416]]]}}'

map_info <- get_raster(
  spatial_resolution = "low",
  temporal_resolution = "yearly",
  group_by = "flag",
  date_range = "2021-01-01,2021-12-31",
  region = region_json,
  region_source = "user_json",
  key = key
)
print(map_info)
```
