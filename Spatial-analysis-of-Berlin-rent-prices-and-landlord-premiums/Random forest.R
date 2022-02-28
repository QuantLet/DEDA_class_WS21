# Using the previously collected data
data_berlin %>% select(price, heatingType, noRooms, hasKitchen, extrawc, balcony, typeOfFlat, garden, cellar,
                              yearConstructed, newlyConst, floor, numberOfFloors, lift) -> forest_data
forest_data %>% filter(yearConstructed != 0) -> forest_data


# installing packages
install.packages("randomForest")
library(randomForest)
install.packages("caTools")
library(caTools)

# checking for NA's
sum(is.na(forest_data))
dim(forest_data)
# getting rid of the NA's
for(i in 1:14){
  forest_data[, i] <-  replace_na(forest_data[, i], 0)
}
# factoring the character columns
# getting rid of the factors "0" (NA's)
forest_data %>% filter(typeOfFlat != 0) -> forest_data
forest_data %>% filter(heatingType != 0) -> forest_data
levels(factor(forest_data$typeOfFlat))
forest_data$typeOfFlat <- factor(forest_data$typeOfFlat)
levels(factor(forest_data$heatingType))
forest_data$heatingType <- factor(forest_data$heatingType)
forest_data$hasKitchen <- factor(forest_data$hasKitchen)
forest_data$extrawc <- factor(forest_data$extrawc)
forest_data$balcony <- factor(forest_data$balcony)
forest_data$garden <- factor(forest_data$garden)
forest_data$cellar <- factor(forest_data$cellar)
forest_data$newlyConst <- factor(forest_data$newlyConst)
forest_data$lift <- factor(forest_data$lift)
summary(forest_data)

# sampelling for training
sample <-  sample.split(forest_data$lift, SplitRatio = .75)
sample <-  sample.split(forest_data$price)
train <-  subset(forest_data, sample == TRUE)
test  <-  subset(forest_data, sample == FALSE)
dim(train)
dim(test)

rf <- randomForest(price ~ ., data = train)
rf

pred <- predict(rf, newdata=test[-1])
pred

cm <- table(test[,1], pred)
cm
