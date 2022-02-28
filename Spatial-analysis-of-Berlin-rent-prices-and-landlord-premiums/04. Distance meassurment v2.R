# Load packages
install.packages("sf")
library(sf)
install.packages("tidyverse")
library(tidyverse)
library(units)
library(jcolors)
options(scipen=999)

# Import data
model <- read.csv("/Users/ivankotik/Documents/DEDA_project/files and graphs/data after modelling.csv")
geocoding <- read.csv("/Users/ivankotik/Documents/DEDA_project/files and graphs/coordinates_osm_v2.csv")
polygon <- read_sf("/Users/ivankotik/Documents/DEDA_project/files and graphs/polygon.shp")
multipolygon <- read_sf("/Users/ivankotik/Documents/DEDA_project/files and graphs/multipolygon.shp")
berlin <- read_sf("/Users/ivankotik/Documents/DEDA_project/files and graphs/berlin.shp")


### Data cleaning
# Deleting an empty row
geocoding <- geocoding[-1, ]

# Changing column names
geocoding <- rename(geocoding, "fulladress" = "query")

# Get the full adress
model$fulladress <- paste(model$regio1, model$geo_plz, model$streetPlain, model$houseNumber)

# Deleting a useless column
model$X <- NULL

# Joining the tables
left_join(model, geocoding, by = "fulladress") -> apartments
distinct(apartments) -> apartments

# Leaving only correct coordinates
apartments[is.na(apartments[, 32]) == FALSE, ] -> apartments_clean

# Creating the SF object out of
st_as_sf(apartments_clean, coords = c("lon", "lat"), crs = "WGS84") -> apartments_clean_points
rm(apartments_clean)
rm(apartments)


### Calaulating distance polygons
# Calculating the distance
apartments_clean_points %>% st_distance((polygon %>% filter(group == "catering"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$catering_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "activities"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$activities_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "destinations"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$destinations_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "entertainment"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$entertainment_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "health"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$health_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "kids"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$kids_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "shopping"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$shopping_p

apartments_clean_points %>% st_distance((polygon %>% filter(group == "transport"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$transport_p


### Calaulating distance multipolygons
# Calcualte the distance between the multipolygon and points for all the groups
apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "activities"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$activities_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "catering"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$catering_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "destinations"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$destinations_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "entertainment"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$entertainment_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "health"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$health_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "kids"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$kids_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "shopping"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$shopping_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "park"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$park_m

apartments_clean_points %>% st_distance((multipolygon %>% filter(group == "water"))) %>%
  + set_units(10, m) %>% `^`(-1) %>% apply(MARGIN = 1, FUN = sum) -> apartments_clean_points$water_m

# Combining the distances
apartments_clean_points$activities <- apartments_clean_points$activities_m + apartments_clean_points$activities_p
apartments_clean_points$catering <- apartments_clean_points$catering_m + apartments_clean_points$catering_p
apartments_clean_points$destinations <- apartments_clean_points$destinations_m + apartments_clean_points$destinations_p
apartments_clean_points$entertainment <- apartments_clean_points$entertainment_m + apartments_clean_points$entertainment_p
apartments_clean_points$health <- apartments_clean_points$health_m + apartments_clean_points$health_p
apartments_clean_points$kids <- apartments_clean_points$kids_m + apartments_clean_points$kids_p
apartments_clean_points$shopping <- apartments_clean_points$shopping_m + apartments_clean_points$shopping_p
apartments_clean_points$transport <- apartments_clean_points$transport_p
apartments_clean_points$park <- apartments_clean_points$park_m
apartments_clean_points$water <- apartments_clean_points$water_m

# Normalizing the data
apartments_clean_points$norm_activities <- (apartments_clean_points$activities - min(apartments_clean_points$activities))/
  (max(apartments_clean_points$activities) - min(apartments_clean_points$activities))

apartments_clean_points$norm_catering <- (apartments_clean_points$catering - min(apartments_clean_points$catering))/
  (max(apartments_clean_points$catering) - min(apartments_clean_points$catering))

apartments_clean_points$norm_destinations <- (apartments_clean_points$destinations - min(apartments_clean_points$destinations))/
  (max(apartments_clean_points$destinations) - min(apartments_clean_points$destinations))

apartments_clean_points$norm_entertainment <- (apartments_clean_points$entertainment - min(apartments_clean_points$entertainment))/
  (max(apartments_clean_points$entertainment) - min(apartments_clean_points$entertainment))

apartments_clean_points$norm_health <- (apartments_clean_points$health - min(apartments_clean_points$health))/
  (max(apartments_clean_points$health) - min(apartments_clean_points$health))

apartments_clean_points$norm_kids <- (apartments_clean_points$kids - min(apartments_clean_points$kids))/
  (max(apartments_clean_points$kids) - min(apartments_clean_points$kids))

apartments_clean_points$norm_shopping <- (apartments_clean_points$shopping - min(apartments_clean_points$shopping))/
  (max(apartments_clean_points$shopping) - min(apartments_clean_points$shopping))

apartments_clean_points$norm_transport <- (apartments_clean_points$transport - min(apartments_clean_points$transport))/
  (max(apartments_clean_points$transport) - min(apartments_clean_points$transport))

apartments_clean_points$norm_park <- (apartments_clean_points$park - min(apartments_clean_points$park))/
  (max(apartments_clean_points$park) - min(apartments_clean_points$park))

apartments_clean_points$norm_water <- (apartments_clean_points$water - min(apartments_clean_points$water))/
  (max(apartments_clean_points$water) - min(apartments_clean_points$water))

# Total score calculation
apartments_clean_points$norm_total <- apartments_clean_points$norm_activities + apartments_clean_points$norm_catering +
  apartments_clean_points$norm_destinations + apartments_clean_points$norm_entertainment + apartments_clean_points$norm_health +
  apartments_clean_points$norm_kids + apartments_clean_points$norm_shopping + apartments_clean_points$norm_transport +
  apartments_clean_points$norm_park + apartments_clean_points$norm_water

# Total score re-normalized
apartments_clean_points$norm_total_score <- (apartments_clean_points$norm_total - min(apartments_clean_points$norm_total))/
  (max(apartments_clean_points$norm_total) - min(apartments_clean_points$norm_total)) + 0.5


### The landlord premium model
# Calcualter the premium
apartments_clean_points$premium <- apartments_clean_points$price - (apartments_clean_points$norm_total_score *
  apartments_clean_points$model2_2)

b_shape <- st_union(berlin)

# Adding up the scores
apartments_clean_points$catering <- apartments_clean_points$catering_m + apartments_clean_points$catering_p

### PLOTS
# Plotting the results
{
ggplot()+
  geom_sf(data = berlin, alpha = 0.6)+
  geom_sf(data = apartments_clean_points, aes(color = norm_total_score), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
  labs(title = " TOTAL WEIGHT", color = "WEIGHT, w_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("weight_total.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin, alpha = 0.6)+
  geom_sf(data = apartments_clean_points, aes(color = catering), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
  labs(title = "TOTAL SCORE CATERING", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_catering.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin, alpha = 0.6)+
  geom_sf(data = apartments_clean_points, aes(color = activities), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
  labs(title = "TOTAL SCORE ACTIVITIES", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_activities.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = destinations), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
  labs(title = "TOTAL SCORE DESTINATIONS", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_destinations.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = entertainment), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE ENTERTAINMENT", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_entertainment.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = health), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE HEALTH", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_health.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = kids), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE KIDS", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_kids.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = shopping), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE SHOPPING", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_shopping.png", dpi = 320, scale = 1)

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = transport), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE TRANSPORT", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_transport.png", dpi = 320, scale = 1)
}

ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = park), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE PARKS", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_parks.png", dpi = 320, scale = 1)


ggplot()+
  geom_sf(data = berlin)+
  geom_sf(data = apartments_clean_points, aes(color = water), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
    labs(title = "TOTAL SCORE WATER", color = "SCORE, s_i")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("score_water.png", dpi = 320, scale = 1)


# Unfulfilled multipolygon idea
{
ggplot()+
  geom_sf(data = multipolygon)+
  geom_sf(data = st_buffer(apartments_clean_points[1:10,], set_units(2000, m)), color = "red", alpha = 0.5)+
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
      title = element_text(colour = "#cacaca"))
}
ggsave("buffers.png", dpi = 320, scale = 1)
}

# Premiums visualized
ggplot()+
  geom_sf(data = berlin, fill = "white", alpha = 0.5)+
  geom_sf(data = apartments_clean_points, aes(color = premium), size = 3, alpha = 0.8)+
  scale_color_jcolors_contin("pal4")+
  labs(title = "LANDLORD PREMIUM", color = "PREMIUM")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("Premiums.png", dpi = 320, scale = 1)

# Distribution of premium
summary(apartments_clean_points$premium)
mean(apartments_clean_points$premium)
sd(apartments_clean_points$premium)
ggplot()+
  geom_density(data = apartments_clean_points, aes(x = premium), color = "white")+
  annotate(geom="text", x=350, y=0.0012, label="mean = -71.71371", color="white")+
  annotate(geom="text", x=300, y=0.0013, label="sd = 258.6865", color="white")+
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
      title = element_text(colour = "#cacaca"))
  }
ggsave("Premiumsdist.png", dpi = 320, scale = 1)