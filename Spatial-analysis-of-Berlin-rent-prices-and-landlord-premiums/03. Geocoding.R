# install packages
install.packages("ggmap")
install.packages("tmaptools")
install.packages("RCurl")
install.packages("jsonlite")
install.packages("tidyverse")
install.packages("leaflet")
# load packages
library(ggmap)
library(tmaptools)
library(RCurl)
library(jsonlite)
library(tidyverse)
library(leaflet)

url_nominatim_search_api <- "https://nominatim.openstreetmap.org/search/"

test_adress <- "Berlin 10557 Heidestrasse 19"
test_adress2 <- "Berlin 12587 NA NA"

coords <- geocode_OSM("Berlin 10557 Heidestrasse 19", as.sf = TRUE)
coords2 <- geocode_OSM(test_adress2, as.sf = TRUE)

ggplot(data = berlin_countour)+
  geom_sf()+
  geom_sf(data = coords, color = "red")

berlin_countour

# reading the postalcodes
plz <- read_sf("C://Users//ivkot//Downloads//plz-5stellig.shp//plz-5stellig.shp")
plz %>% filter(str_detect(note, "Berlin")) -> plz
plz$midpoint <- st_centroid(plz$geometry)
ggplot(data = plz)+
  geom_sf()+
  geom_sf(data = plz$midpoint)  # everything works

# Creating an empty column for lacking adress (no need to geocode)
data_berlin$lacksfulladress <- NA

data_berlin[is.na(data_berlin[, 6]) == FALSE, 34] <-  "FALSE"
data_berlin[is.na(data_berlin[, 6]) == TRUE, 34] <- "TRUE"

data_berlin %>% filter(lacksfulladress == TRUE)
data_berlin %>% filter(lacksfulladress == FALSE)
data_berlin %>% filter(lacksfulladress == FALSE) %>% select(full_adress)

adresses_for_geo <- as.data.frame(data_berlin[is.na(data_berlin$streetPlain) == FALSE, 1])
adresses_for_geo <- unlist(adresses_for_geo)
adresses_for_geo[1:3]

# Back to geocoding
test_adress <- geocode_OSM(adresses_for_geo, as.sf = TRUE)

ggplot(data = berlin_countour)+
  geom_sf()+
  geom_sf(data = test_adress, color = "red")

coord_list <- test_adress[1, ]
coord_list[1, ] <- NA

length(adresses_for_geo)

for(i in 1:8856) {
  placeholderadress <- geocode_OSM(adresses_for_geo[i], as.sf = TRUE)
  coord_list <- bind_rows(coord_list, placeholderadress)
  print(Sys.time())
  Sys.sleep(1.5)
}

write_csv(coord_list, file = "C://Users//ivkot//Downloads//shape_files//coordinates_osm.csv")
savefile <- coord_list
write_csv(savefile[, c(1, 2, 3, 9)], file = "C://Users//ivkot//Downloads//shape_files//coordinates_osm_v2.csv")
write_csv(savefile[, c(4, 5, 6, 7, 8)], file = "C://Users//ivkot//Downloads//shape_files//coordinates_osm_rest(not needed).csv")
