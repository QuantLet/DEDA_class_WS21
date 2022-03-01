# installing the libraries
install.packages("sf")
library(sf)
install.packages("tidyverse")
library(tidyverse)
install.packages("maptiles")
library(maptiles)
install.packages("cartography")
library(cartography)
install.packages("geogrid")
library(geogrid)
install.packages("tmap")
library(tmap)
install.packages("geogrid")
library(geogrid)

# loading all the shape files
list.files("C://Users//ivkot//Downloads//shape_files")

# the points of interest multipolygons
a_ber_poi_multipolygon <- read_sf(dsn = "C://Users//ivkot//Downloads//shape_files//gis_osm_pois_a_free_1.shp")
# for mac
a_ber_poi_multipolygon <- read_sf(dsn = "/Users/ivankotik/Documents/shape_files/gis_osm_pois_a_free_1.shp")

# the points of interest polygons
a_ber_poi_polygon <- read_sf(dsn = "C://Users//ivkot//Downloads//shape_files//gis_osm_pois_free_1.shp")
# for mac
a_ber_poi_polygon <- read_sf(dsn = "/Users/ivankotik/Documents/shape_files/gis_osm_pois_free_1.shp")

# the landuse(parks) polygons
b_ber_landuse_multipolygon <- read_sf(dsn = "C://Users//ivkot//Downloads//shape_files//gis_osm_landuse_a_free_1.shp")
# for mac
b_ber_landuse_multipolygon <- read_sf(dsn = "/Users/ivankotik/Documents/shape_files/gis_osm_landuse_a_free_1.shp")

# the transport polygons
c_ber_transport_polygon <- read_sf(dsn = "C://Users//ivkot//Downloads//shape_files//gis_osm_transport_free_1.shp")
# for mac
c_ber_transport_polygon <- read_sf(dsn = "/Users/ivankotik/Documents/shape_files/gis_osm_transport_free_1.shp")

# the water objects multipolygons
d_ber_water_multipolygons <- read_sf(dsn = "C://Users//ivkot//Downloads//shape_files//gis_osm_water_a_free_1.shp")
# for mac
d_ber_water_multipolygons <- read_sf(dsn = "/Users/ivankotik/Documents/shape_files/gis_osm_water_a_free_1.shp")

# the Berlin city map
e_ber_map <- read_sf(dsn = "C://Users//ivkot//Downloads//shape_files//gis_osm_places_a_free_1.shp")
# for mac
e_ber_map <- read_sf(dsn = "/Users/ivankotik/Documents/shape_files/gis_osm_places_a_free_1.shp")
berlin_countour <- filter(e_ber_map, fclass == "suburb")
berlin_countour <- berlin_countour[, 5:6]
berlin_countour <- arrange(berlin_countour, name)
rm(e_ber_map)

# A documentation of the layers in this shape file is available here:
# http://download.geofabrik.de/osm-data-in-gis-formats-free.pdf


# cleaning data
# the a_ files
# picking out the right "codes" for items: 21xx, 22xx, 23xx, 25xx, 27(2+)x
a_ber_poi_polygon <- a_ber_poi_polygon %>% filter(((code >= 2100) & (code < 2400))|((code >= 2500) & (code < 2600))|((code >= 2720) & (code < 2800)))
a_ber_poi_multipolygon <- a_ber_poi_multipolygon %>% filter(((code >= 2100) & (code < 2400))|((code >= 2500) & (code < 2600))|((code >= 2700) & (code < 2800)))

# the b_ files
# picking out the right "codes" for items: 7201, 7202
b_ber_landuse_multipolygon <- b_ber_landuse_multipolygon %>% filter((code == 7201) | (code == 7202))

# the c_ files
# picking out the right "codes" for items: 5601, 5602, 5603, 5621, 5622
c_ber_transport_polygon <- c_ber_transport_polygon %>% filter((code == 5601) | (code == 5602) | (code == 5603) | (code == 5621) | (code == 5622))

# the c_ files
# picking out the right "codes" for items: 5601, 5602, 5603, 5621, 5622
d_ber_water_multipolygons <- d_ber_water_multipolygons %>% filter((code == 8200) | (code == 8202))


# subgrouping the df's
# poi polygon
a_ber_poi_polygon$group <- NA
a_ber_poi_polygon[((a_ber_poi_polygon$code == 2201) | (a_ber_poi_polygon$code == 2202) | (a_ber_poi_polygon$code == 2203)), 6] <- "entertainment"
a_ber_poi_polygon[(a_ber_poi_polygon$code == 2204), 6] <- "park"
a_ber_poi_polygon[(a_ber_poi_polygon$code == 2205), 6] <- "kids"
a_ber_poi_polygon[((a_ber_poi_polygon$code > 2205) & (a_ber_poi_polygon$code < 2300)), 6] <- "activities"
a_ber_poi_polygon[((a_ber_poi_polygon$code >= 2100) & (a_ber_poi_polygon$code < 2200)), 6] <- "health"
a_ber_poi_polygon[((a_ber_poi_polygon$code >= 2300) & (a_ber_poi_polygon$code < 2400)), 6] <- "catering"
a_ber_poi_polygon[((a_ber_poi_polygon$code >= 2500) & (a_ber_poi_polygon$code < 2600)), 6] <- "shopping"
a_ber_poi_polygon[((a_ber_poi_polygon$code >= 2700) & (a_ber_poi_polygon$code < 2800)), 6] <- "destinations"
table(a_ber_poi_polygon$group)

# poi multipolygon
a_ber_poi_multipolygon$group <- NA
a_ber_poi_multipolygon[((a_ber_poi_multipolygon$code == 2201) | (a_ber_poi_multipolygon$code == 2202) | (a_ber_poi_multipolygon$code == 2203)), 6] <- "entertainment"
a_ber_poi_multipolygon[(a_ber_poi_multipolygon$code == 2204), 6] <- "park"
a_ber_poi_multipolygon[(a_ber_poi_multipolygon$code == 2205), 6] <- "kids"
a_ber_poi_multipolygon[((a_ber_poi_multipolygon$code > 2205) & (a_ber_poi_multipolygon$code < 2300)), 6] <- "activities"
a_ber_poi_multipolygon[((a_ber_poi_multipolygon$code >= 2100) & (a_ber_poi_multipolygon$code < 2200)), 6] <- "health"
a_ber_poi_multipolygon[((a_ber_poi_multipolygon$code >= 2300) & (a_ber_poi_multipolygon$code < 2400)), 6] <- "catering"
a_ber_poi_multipolygon[((a_ber_poi_multipolygon$code >= 2500) & (a_ber_poi_multipolygon$code < 2600)), 6] <- "shopping"
a_ber_poi_multipolygon[((a_ber_poi_multipolygon$code >= 2700) & (a_ber_poi_multipolygon$code < 2800)), 6] <- "destinations"
table(a_ber_poi_multipolygon$group)

# landuse multipolygons
table(b_ber_landuse_multipolygon$fclass)
b_ber_landuse_multipolygon$group <- "park"

# transport polygons
table(c_ber_transport_polygon$fclass)
c_ber_transport_polygon$group <- "transport"

# water multipolygons
table(d_ber_water_multipolygons$fclass)
d_ber_water_multipolygons$group <- "water"


# creating an empty dataframe
berlin_counter <- data.frame(matrix(ncol = 0, nrow = nrow(berlin_countour)))
berlin_counter$bezirk <- berlin_countour$name

# checking the groups and assigning the count-value
# poi multipolygon counts (parks by area, rest by intersection)
table(a_ber_poi_multipolygon$group)
berlin_counter$activities <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "activities")), length)
berlin_counter$catering <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "catering")), length)
berlin_counter$destinations <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "destinations")), length)
berlin_counter$entertainment <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "entertainment")), length)
berlin_counter$health <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "health")), length)
berlin_counter$kids <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "kids")), length)
test <- data.frame(bezirk = st_intersection(filter(a_ber_poi_multipolygon, group == "park"), berlin_countour)$name.1,
                   area = st_area(st_intersection(filter(a_ber_poi_multipolygon, group == "park"), berlin_countour)))
  test2 <- aggregate(test$area, by = list(test$bezirk), FUN = sum)
  test2 <- rename(test2, bezirk = Group.1)
  berlin_counter <- left_join(berlin_counter, test2, by = "bezirk")
  berlin_counter <- rename(berlin_counter, park = x)
berlin_counter$shopping <- sapply(st_intersects(berlin_countour, filter(a_ber_poi_multipolygon, group == "shopping")), length)


# poi polygon count (done)
table(a_ber_poi_polygon$group)
berlin_counter$activities <- berlin_counter$activities + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "activities")), length)
berlin_counter$catering <- berlin_counter$catering + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "catering")), length)
berlin_counter$destinations <- berlin_counter$destinations + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "destinations")), length)
berlin_counter$entertainment <- berlin_counter$entertainment + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "entertainment")), length)
berlin_counter$health <- berlin_counter$health + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "health")), length)
berlin_counter$kids <- berlin_counter$kids + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "kids")), length)
berlin_counter$shopping <- berlin_counter$shopping + sapply(st_intersects(berlin_countour, filter(a_ber_poi_polygon, group == "shopping")), length)

# adding up more parks from landuse polygons by intersection (done)
table(b_ber_landuse_multipolygon$group)
test <- data.frame(bezirk = st_intersection(filter(b_ber_landuse_multipolygon, group == "park"), berlin_countour)$name.1,
                   area = st_area(st_intersection(filter(b_ber_landuse_multipolygon, group == "park"), berlin_countour)))
  test2 <- aggregate(test$area, by = list(test$bezirk), FUN = sum)
  test2 <- rename(test2, bezirk = Group.1)
  berlin_counter <- left_join(berlin_counter, test2, by = "bezirk")
  berlin_counter$park <- berlin_counter$park + berlin_counter$x
  berlin_counter$x <- NULL

# transport polygon count (done)
table(c_ber_transport_polygon$group)
berlin_counter$transport <- sapply(st_intersects(berlin_countour, filter(c_ber_transport_polygon, group == "transport")), length)

# water multipolygon count (done)
table(d_ber_water_multipolygons$group)
test <- data.frame(bezirk = st_intersection(d_ber_water_multipolygons, berlin_countour)$name.1,
                   area = st_area(st_intersection(d_ber_water_multipolygons, berlin_countour)))
test2 <- aggregate(test$area, by = list(test$bezirk), FUN = sum)
test2 <- rename(test2, bezirk = Group.1)
berlin_counter <- left_join(berlin_counter, test2, by = "bezirk")
berlin_counter <- rename(berlin_counter, water = x)
head(berlin_counter)
rm(test)
rm(test2)
# counter done

# combining the one file
x_berlin <- left_join(rename(berlin_countour, bezirk = name), berlin_counter, by = "bezirk")


# plots [in progress]
ggplot()+
  geom_sf(data = berlin_countour)+
  geom_sf(data = a_ber_poi_multipolygon[13354, 5], color = "red")+
  geom_sf(data = a_ber_poi_polygon[1,5], color = "blue")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#545454")
  )
  }
ggsave("temporary.png", dpi = 320, scale = 1)


ggplot()+
  geom_sf(data = berlin_countour)+
  geom_sf(data = c_ber_transport_polygon, aes(color = fclass), size = 0.5)+
  labs(title = "TRANSPORT", color = "TYPES")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }  # based
  ggsave("temporary3.png", dpi = 320, scale = 1)


# getting palettes
install.packages("devtools")
devtools::install_github("jaredhuling/jcolors")
library(jcolors)
display_all_jcolors()
display_all_jcolors_contin()

# entertainment plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = entertainment))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "ENTERTAINMENT OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }  # based
ggsave("entertainment.png", dpi = 320, scale = 1)

# activities plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = activities))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "ACTIVITIES OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("activities.png", dpi = 320, scale = 1)

# Shopping plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = shopping))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "SHOPPING OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("shopping.png", dpi = 320, scale = 1)

# catering plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = catering))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "CATERING OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("catering.png", dpi = 320, scale = 1)

# destinations plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = destinations))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "TOURISM/SIGHTSEEING OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("destinations.png", dpi = 320, scale = 1)

# health plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = health))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "HEALTH OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("health.png", dpi = 320, scale = 1)

# kids plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = kids))+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "KIDS OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("kids.png", dpi = 320, scale = 1)

# park plot
xx_berlin <- x_berlin
xx_berlin$park <- as.integer(xx_berlin$park/(100*100))
options(scipen=999)

ggplot(data = xx_berlin)+
  geom_sf(aes(fill = park))+
  scale_fill_jcolors_contin(palette = "pal11")+
  labs(title = "PARK OBJECTS", fill = "PARKS, HEC.")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("parks.png", dpi = 320, scale = 1)

# transport plot
ggplot(data = x_berlin)+
  geom_sf(aes(fill = transport))+
  labs(fill = "transportation")+
  scale_fill_jcolors_contin("pal11")+
  labs(title = "TRANSPORT OBJECTS", fill = "QUANTITY")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("transport.png", dpi = 320, scale = 1)

# water plot
xx_berlin$water <- as.integer(xx_berlin$water/(100*100))

ggplot(data = xx_berlin)+
  geom_sf(aes(fill = water))+
  scale_fill_jcolors_contin(palette = "pal11")+
  labs(title = "WATER OBJECTS", fill = "WATER, HEC.")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("water.png", dpi = 320, scale = 1)
rm(xx_berlin)

# combining the distance files
x_distance_polygon <- bind_rows(a_ber_poi_polygon, c_ber_transport_polygon)
x_distance_multipolygon <- bind_rows(a_ber_poi_multipolygon, b_ber_landuse_multipolygon, d_ber_water_multipolygons)

x_distance_polygon[1, 5]
st_distance(x_distance_polygon, x_distance_polygon[1, 5])

# all dots plot
ggplot()+
  geom_sf(data = x_berlin, fill = NA)+
  geom_sf(data = x_distance_polygon, aes(color = group), size = 0.4, alpha = 0.85)+
  scale_color_jcolors("pal8")+
  labs(title = "ALL OBJECTS", color = "TYPE")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("alldots.png", dpi = 320, scale = 1)

# poi poly plot
ggplot()+
  geom_sf(data = x_berlin)+
  geom_sf(data = a_ber_poi_multipolygon, aes(fill = group))+
  labs(title = "ALL MULTIPOLYGON OBJECTS", fill = "TYPE")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("poipolyplot.png", dpi = 320, scale = 1)

# forest and water plot
ggplot()+
  geom_sf(data = x_berlin)+
  geom_sf(data = b_ber_landuse_multipolygon, fill = "lightgreen")+
  geom_sf(data = d_ber_water_multipolygons, fill = "lightblue")+
  labs(title = "ALL WATER AND PARK OBJECTS", fill = "OBJECT")+
  {theme(
    panel.background = element_rect(fill = "#222222",
                                  colour = "#222222",
                                  size = 0.1, linetype = "solid"),
    panel.grid.major = element_line(size = 0.1, linetype = 'solid',
                                  colour = "white"),
    panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                  colour = "#222222"),
    plot.background = element_rect(fill = "#222222"),
    legend.background = element_rect(fill = "#222222"),
    legend.title = element_text(colour = "#cacaca"),
    legend.text = element_text(colour = "#cacaca"),
    title = element_text(colour = "#cacaca")
  )
  }
ggsave("waterforestplot.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = x_distance_multipolygon)

write.csv2(x_berlin, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/x_berlin.csv")
write.table(x_berlin, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/x_berlin.csv", sep = "|")
write.csv2(x_distance_multipolygon, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/x_distance_multipolygon.csv")
write.table(x_distance_multipolygon, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/x_distance_multipolygon.csv", sep = "|")
write.csv2(x_distance_polygon, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/x_distance_polygon.csv")
write.table(x_distance_polygon, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/x_distance_polygon.csv", sep = "|")

write_sf(x_distance_polygon, "/Users/ivankotik/Documents/DEDA_project/files and graphs/polygon.shp")
write_sf(x_distance_multipolygon, "/Users/ivankotik/Documents/DEDA_project/files and graphs/multipolygon.shp")
write_sf(x_berlin, "/Users/ivankotik/Documents/DEDA_project/files and graphs/berlin.shp")
