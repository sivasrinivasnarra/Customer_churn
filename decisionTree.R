# Clear the workspace
rm(list=ls())
cat("\014")

# Use menu /Session/Set Working Directory/Choose Directory Or command below to set working directory
setwd("/Users/sivasrinivasnarra/Desktop/Academic/SPRING_2024/BAR/5.Classification")

# load in the data file into data.frame
cellco <- read.csv("cellco_full.csv", stringsAsFactors = FALSE)

# change gender, phone, lines, churn to factor
cellco$gender <- as.factor(cellco$gender)
cellco$phone <- as.factor(cellco$phone)
cellco$lines <- as.factor(cellco$lines)
cellco$churn <- as.factor(cellco$churn)


# now we will split the data into testing and training data sets
# we will first randomly select 2/3 of the rows
set.seed(345) # for reproducible results
train <- sample(1:nrow(cellco), nrow(cellco)*(2/3)) # replace=FALSE by default

# Use the train index set to split the dataset
#  churn.train for building the model
#  churn.test for testing the model
churn.train <- cellco[train,]   # 6,666 rows
churn.test <- cellco[-train,]   # the other 3,334 rows

# Classification Tree with rpart
# Important! Comment the following line after installing rpart.
# install.packages('rpart')
library(rpart)

# grow tree 
fit <- rpart( churn~ ., # formula, all predictors will be considered in splitting
            data=churn.train, # dataframe used
            method="class",  # treat churn as a categorical variable, default
            control=rpart.control(xval=10, minsplit=50), # xval: num of cross validation for gini estimation # minsplit=1000: stop splitting if node has 1000 or fewer obs
            parms=list(split="gini"))  # criterial for splitting: gini default, entropy if set parms=list(split="information")


fit  # display basic results

# plot tree using built-in function
plot(fit, uniform=TRUE,  # space out the tree evenly
     branch=0.5,         # make elbow type branches
     main="Classification Tree for Churn Prediction",   # title
     margin=0.1)         # leave space so it all fits
text(fit,  use.n=TRUE,   # show numbers for each class
     all=TRUE,           # show data for internal nodes as well
     fancy=FALSE,            # draw ovals and boxes
     pretty=TRUE,           # show split details
     cex=0.8)            # compress fonts to 80%


# plot a prettier tree using rpart.plot
# Important! Comment the following line after installing rpart.plot
#install.packages('rpart.plot')
library(rpart.plot)
prp(fit, type = 1, extra = 1, under = TRUE, split.font = 1, varlen = -10, main="Classification Tree for Churn Prediction")    
# type can be any values from 0, 1, 2, ...,5, corresponding to different formats
# extra can be any value from 0, 1, 2,..., 11, corresponding to different texts to be displayed
rpart.plot(fit, type = 1, extra = 1, main="Classification Tree for  Prediction")  
rpart.plot(fit, type = 1, extra = 4, main="Classification Tree for Churn Prediction")  # show proportion of classes at each node
rpart.plot(fit, type = 3, extra = 5, main="Classification Tree for Churn Prediction")  # show proportion of classes at each node


# extract the vector of predicted class for each observation in chur.train
churn.pred <- predict(fit, churn.train, type="class")
# extract the actual class of each observation in chur.train
churn.actual <- churn.train$churn

# now build the "confusion matrix"
# which is the contingency matrix of predicted vs actual
# use this order: predicted then actual
confusion.matrix <- table(churn.pred, churn.actual)  
confusion.matrix
addmargins(confusion.matrix)
pt <- prop.table(confusion.matrix)  
pt
#accuracy
pt[1,1] + pt[2,2]   # 0.7365737

# calculate TPR, TNR, FPR, FNR (2 -> calculate w.r.t column)
prop.table(confusion.matrix, 2)

#now let us use the hold out data in churn.test
churn.pred <- predict(fit, churn.test, type="class")
churn.actual <- churn.test$churn
confusion.matrix <- table(churn.pred, churn.actual)
confusion.matrix
addmargins(confusion.matrix)
pt <- prop.table(confusion.matrix)
pt

#accuracy
pt[1,1] + pt[2,2]   # 0.714757

