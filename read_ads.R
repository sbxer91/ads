library(httr)
library(jsonlite)
library(dplyr)

uuid <- "7b8d31d9d2f2d73ffb2208614db599fa"

query_all <- "https://samples.adsbexchange.com/readsb-hist/2024/01/01/000000Z.json.gz"

all_aircraft <-  GET(query_all, add_headers("api-auth" = uuid)) %>% content(as="text") %>% fromJSON()

library(leaflet)

filtered_data <- all_aircraft$aircraft %>%
  filter(!is.na(lat) & !is.na(lon))  # Remove rows with missing coordinates

# Create the map
aircraft_map <- leaflet(data = filtered_data) %>%
  addTiles() %>%  # Add default map tiles
  addCircleMarkers(
    lng = ~lon, lat = ~lat,  # Longitude and latitude for marker positions
    radius = 2,              # Marker size
    color = "blue",          # Marker color
    popup = ~paste0(
      "<b>Flight:</b> ", flight, "<br>",
      "<b>Type:</b> ", type, "<br>",
      "<b>Altitude:</b> ", alt_baro, " ft<br>",
      "<b>Ground Speed:</b> ", gs, " knots<br>",
      "<b>Track:</b> ", track, "°<br>",
      "<b>Category:</b> ", category, "<br>",
      "<b>Seen:</b> ", seen, " seconds ago<br>"
    )  # Display detailed info in popup
  ) %>%
  setView(lng = mean(filtered_data$lon, na.rm = TRUE), 
          lat = mean(filtered_data$lat, na.rm = TRUE), 
          zoom = 5)  # Center the map based on the dataset

# Display the map
aircraft_map
