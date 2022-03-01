# Installing libraries
library(tidyverse)
install.packages("ggfortify")
library(ggfortify)

# Data taken from: https://www.kaggle.com/corrieaar/apartment-rental-offers-in-germany/version/6
# Importing data
data <- read_csv("C://Users//ivkot//Downloads//archive//immo_data.csv")
# for mac
data <- read.csv("/Users/ivankotik/Documents/shape_files/immo_data.csv")

# Checking for berlin
table(data$regio1)

# Extracting Berlin
data %>% filter(regio1 == "Berlin") -> data_berlin
rm(data)

# Deleting columns that would not be used
data_berlin$telekomTvOffer <- NULL
data_berlin$telekomHybridUploadSpeed <- NULL
data_berlin$telekomUploadSpeed <- NULL
data_berlin$picturecount <- NULL
data_berlin$pricetrend <- NULL
data_berlin$scoutId <- NULL
data_berlin$noParkSpaces <- NULL
data_berlin$firingTypes <- NULL
data_berlin$geo_bln <- NULL
data_berlin$geo_krs <- NULL
data_berlin$petsAllowed <- NULL
data_berlin$street <- NULL
data_berlin$thermalChar <- NULL
data_berlin$livingSpaceRange <- NULL
data_berlin$baseRentRange <- NULL
data_berlin$yearConstructedRange <- NULL
data_berlin$noRoomsRange <- NULL
data_berlin$energyEfficiencyClass <- NULL
data_berlin$lastRefurbish <- NULL
data_berlin$electricityBasePrice <- NULL
data_berlin$electricityKwhPrice <- NULL

# Moving around the columns
data_berlin <- relocate(data_berlin, regio2, regio3, geo_plz, streetPlain, houseNumber, .after = regio1)
data_berlin <- relocate(data_berlin, totalRent, baseRent, serviceCharge, heatingCosts, .after = houseNumber)
data_berlin <- relocate(data_berlin, livingSpace, noRooms, hasKitchen, balcony, facilities, description, typeOfFlat, garden, interiorQual, condition, cellar,  .after = heatingType)
data_berlin <- relocate(data_berlin, lift,  .after = numberOfFloors)
data_berlin <- relocate(data_berlin, yearConstructed,  .after = cellar)

# Checking the "facilities" column for more useful characteristics
# Guest WC's
str_extract(data_berlin$facilities, "([zZ]wei.{0,4}B.d)|(ste.WC)")
sort(str_extract(data_berlin$facilities, "([zZ]wei.{0,4}B.d)|(ste.WC)"))  # all good
data_berlin$extrawc <- as.integer(sub("([zZ]wei.{0,4}B.d)|(ste.WC)", 1, (str_extract(data_berlin$facilities, "([zZ]wei.{0,4}B.d)|(ste.WC)"))))
data_berlin <- relocate(data_berlin, extrawc, .after = hasKitchen)

# Dishwashing machines
sort(str_extract(data_berlin$facilities, "Geschirrsp.lmaschine"))
data_berlin$geschirrsp <- as.integer(sub("Geschirrsp.lmaschine", 1, (str_extract(data_berlin$facilities, "Geschirrsp.lmaschine"))))

# Washing machines
sort(str_extract(data_berlin$facilities, "Waschmaschine"))
data_berlin$washingm <- as.integer(sub("Waschmaschine", 1, (str_extract(data_berlin$facilities, "Waschmaschine"))))

# Sorting data
data_berlin <- relocate(data_berlin, geschirrsp, washingm, .after = balcony)
data_berlin <- relocate(data_berlin, description, facilities, .after = date)

# Delete descriptions
data_berlin$description <- NULL
data_berlin$facilities <- NULL

# Replacing NA's with FALSE
data_berlin$hasKitchen <- as.logical(replace_na(data_berlin$hasKitchen, 0))
data_berlin$extrawc <- as.logical(replace_na(data_berlin$extrawc, 0))
data_berlin$balcony <- as.logical(replace_na(data_berlin$balcony, 0))
data_berlin$geschirrsp <- as.logical(replace_na(data_berlin$geschirrsp, 0))
data_berlin$washingm <- as.logical(replace_na(data_berlin$washingm, 0))
data_berlin$garden <- as.logical(replace_na(data_berlin$garden, 0))
data_berlin$cellar <- as.logical(replace_na(data_berlin$cellar, 0))
data_berlin$lift <- as.logical(replace_na(data_berlin$lift, 0))
data_berlin$heatingCosts <- replace_na(data_berlin$heatingCosts, 0)

# Create factors frm the 0/1 T/F columns and character vectors with groups
data_berlin$heatingType <- factor(data_berlin$heatingType)
data_berlin$hasKitchen <- factor(data_berlin$hasKitchen)
data_berlin$extrawc <- factor(data_berlin$extrawc)
data_berlin$balcony <- factor(data_berlin$balcony)
data_berlin$geschirrsp <- factor(data_berlin$geschirrsp)
data_berlin$washingm <- factor(data_berlin$washingm)
data_berlin$typeOfFlat <- factor(data_berlin$typeOfFlat)
data_berlin$garden <- factor(data_berlin$garden)
data_berlin$interiorQual <- factor(data_berlin$interiorQual)
data_berlin$condition <- factor(data_berlin$condition)
data_berlin$cellar <- factor(data_berlin$cellar)
data_berlin$newlyConst <- factor(data_berlin$newlyConst)
data_berlin$lift <- factor(data_berlin$lift)


table(data_berlin$floor)  # 80 and 83 floor looks suspisious, deleting it
data_berlin %>% filter(floor < 27) -> data_berlin

table(data_berlin$noRooms)  # 1.1, 2.1, 2.2, 99.5 looks suspisious
data_berlin[data_berlin[, "noRooms"] == 1.1, "noRooms"] <- 1
data_berlin[data_berlin[, "noRooms"] == 2.1, "noRooms"] <- 2
data_berlin[data_berlin[, "noRooms"] == 2.2, "noRooms"] <- 2
data_berlin %>% filter(noRooms != 99.5) -> data_berlin

# ===========================================================
# Checking whether heatingTypes have a influence on the price
ggplot(data_berlin[data_berlin[, "totalRent"]<5000, ], aes(x = livingSpace, y = totalRent, color = heatingType))+
  geom_point()+
  labs(title = "HEATING TYPE", color = "TYPES", x = "Living Space, m^2", y = "Total Rent, EUR")+
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
ggsave("heatingtypewithoutlines.png", dpi = 320, scale = 1)

ggplot(data_berlin[data_berlin[, "totalRent"]<5000, ], aes(x = livingSpace, y = totalRent, color = heatingType))+
  geom_point(size = 0.75, alpha = 0.2)+
  geom_smooth(se = FALSE, method = lm, size = 0.7)+
  labs(title = "HEATING TYPE", color = "TYPES", x = "Living Space, m^2", y = "Total Rent, EUR")+
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
  }  # based on the graps it can be seen that there is no heavy difference between the types
ggsave("heatingtypewithlines.png", dpi = 320, scale = 1)

# ===========================================================
# Making the model
# Calculating price
data_berlin$price <- data_berlin$baseRent + data_berlin$serviceCharge + data_berlin$heatingCosts
data_berlin <- relocate(data_berlin, price, .after = houseNumber)
data_berlin_model <- data_berlin[, c(7, 12:30)]
data_berlin_model_withnames <- data_berlin[, c(1:7, 12:30)]
data_berlin_model %>% filter(is.na(price) == FALSE) -> data_berlin_model
data_berlin_model_withnames %>% filter(is.na(price) == FALSE) -> data_berlin_model_withnames

# Including everyting
data_berlin_model_alltime <- data_berlin_model[, 1:19]
summary(lm(price ~ ., data = data_berlin_model_alltime))
model_1 <- lm(price ~ ., data = data_berlin_model_alltime)

# Initial filtering of parameterts
summary(lm(price ~ livingSpace + hasKitchen + floor + numberOfFloors + lift, data = data_berlin_model))
model_2 <- lm(price ~ livingSpace + hasKitchen + floor + numberOfFloors + lift, data = data_berlin_model)
autoplot(model_1)

# Getting read of the externalities
ggplot(data_berlin_model, aes(x = price))+
  geom_density()
quantile(data_berlin_model$price, 0.9)  # cutoff at 2400
data_berlin_model %>% filter(price <= 2400) -> data_berlin_model_filter
data_berlin_model_withnames %>% filter(price <= 2400) -> data_berlin_model_withnames

# modelling
model_2_2 <- lm(price ~ livingSpace + hasKitchen + floor + numberOfFloors + lift, data = data_berlin_model_filter)
summary(model_2_2)  # deleting number of floors due to insignificance
model_2_2 <- lm(price ~ livingSpace + hasKitchen + floor + lift, data = data_berlin_model_filter)
summary(model_2_2)  # deleting floors due to insignificance
model_2_2 <- lm(price ~ livingSpace + hasKitchen + lift, data = data_berlin_model_filter)
summary(model_2_2)  # deleting floors due to insignificance
autoplot(model_2_2)

model_2_3 <- lm(log(price) ~ livingSpace + hasKitchen + lift, data = data_berlin_model_filter)
summary(model_2_3)
autoplot(model_2_3)

data_berlin_model_filter$model2_2 <- model_2_2$fitted.values
data_berlin_model_withnames$model2_2 <- model_2_2$fitted.values
data_berlin_model_filter$model2_3 <- model_2_3$fitted.values
data_berlin_model_withnames$model2_3 <- model_2_3$fitted.values

ggplot(data = data_berlin_model_filter)+
  geom_point(aes(x = livingSpace, y = price, color = lift))
write.csv(data_berlin_model_withnames, "/Users/ivankotik/Documents/DEDA_project/miscellaneous/data after modelling.csv")
