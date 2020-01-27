# HW06: naïve Bayes and decision tree for handwriting recognition
# Darrell Nelson II

## Recall that Decision Trees can only split nominally
## This means that any quantitative (numerical) variables
## will have to be discretized/binned or removed
## numerical ordinal data or data with too many categories
## should also be consolidated.
## GOAL
## The goal is to create decision tree from the training data
## that tries to classify handwritten numbers into their correct category. 
## Then, we will use the testing data to see how well
## the Decision Tree works.

# Set working directory and import data
setwd("C:\\Users\\Darrell\\Desktop\\Syracuse\\Spring_19\\IST_707_Data_Analytics\\Week07\\HW06")
Digit_Train <- read.csv("Kaggle-digit-train-sample-small-1400.csv", na.string=c(""))

# View imported data
head(Digit_Train, n=5)
str(Digit_Train)
summary(Digit_Train)

# Can't see much let's look at max to view highest number in dataset
max(Digit_Train)

# How many data points are that high?
length(which(Digit_Train > 250))

# How many data points are that low
length(which(Digit_Train == 0))
# So there's a lot of empty cells in here

# What's the frequency of numbers in the training set
hist(Digit_Train$label)
# We can see that the number of 0s in this dataset is approx. 3 times as large as any other
# number. Will this affect our analysis? Check the histogram for the testing set to see if 
# it matches

## change "label" to a factor
Digit_Train$label=factor(Digit_Train$label)

# Import Testing data
Digit_Test <- read.csv("Kaggle-digit-test-sample1000.csv", na.string=c(""))


## Remove "label" from testing data
Digit_Test <- Digit_Test[  , -1]
str(Digit_Test)


######################################### BUILD Decision Trees ----------------------------
#install.packages("rpart")
#install.packages('rattle')
#install.packages('rpart.plot')
#install.packages('RColorBrewer')
#install.packages("Cairo")
#install.packages("CORElearn")
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(Cairo)

fit <- rpart(Digit_Train$label ~ ., data = Digit_Train, method="class") # decision tree created
summary(fit)
predicted= predict(fit,Digit_Test, type="class")
(head(predicted,n=10))

table(predicted)
# sum(table(predicted))
fancyRpartPlot(fit)
fancyRpartPlot(fit,cex=0.3) # adjust output size

# Validate model through training accuracy
predicted_train = predict(fit, Digit_Train, type = "class")
DT_table <- table(predicted_train, Digit_Train$label)

c <- list()
for (l in 1:nrow(DT_table)){
  c[l] <- sum(DT_table[l,])
}

sums_DT <- unlist(c)
pred_acc_DT <- list()
correctlist_DT <- list()

for (p in 1:length(sums_DT)){
  pred_acc_DT[p] <-  DT_table[p,p] / sums_DT[p]
  correctlist_DT[p] <- DT_table[p,p]
}
# How accurate were we at predicting each number?
data.frame(pred_acc_DT)
a <- data.frame(pred_acc_DT)
colnames(a) <- c(0:9)
View(a)
# How accurate were we at predicting ALL the numbers (overall)
DT <- sum(unlist(correctlist_DT)) / sum(DT_table)

########################################################################################
## Reduce the tree size
fit2 <- rpart(Digit_Train$label ~ ., data = Digit_Train,
              method="class", 
              control=rpart.control(minbucket=70, cp=0))

predicted2 = predict(fit2, Digit_Test, type = "class")
head(predicted2, n=10)
table(predicted2)
fancyRpartPlot(fit2, cex=0.3)

# Validate model through training accuracy
predicted2_train = predict(fit2, Digit_Train, type = "class")
DT2_table <- table(predicted2_train, Digit_Train$label)

d <- list()
for (m in 1:nrow(DT2_table)){
  d[m] <- sum(DT2_table[m,])
}

sums_DT2 <- unlist(d)
pred_acc_DT2 <- list()
correctlist_DT2 <- list()

for (q in 1:length(sums_DT2)){
  pred_acc_DT2[q] <-  DT2_table[q,q] / sums_DT2[q]
  correctlist_DT2[q] <- DT2_table[q,q]
}
# How accurate were we at predicting each number?
data.frame(pred_acc_DT2)
w <- data.frame(pred_acc_DT2)
colnames(w) <- c(0:9)
View(w)

# How accurate were we at predicting ALL the numbers (overall)
DT_pruned <- sum(unlist(correctlist_DT2)) / sum(DT2_table)

#####################################################################################
## Naive Bayes model
###########
#install.packages("e1071")
#install.packages("naivebayes")
library(e1071)
library(naivebayes)


###############################################################
#############  Create k-folds for k-fold validation ###########
###############################################################


# Number of observations
N <- nrow(Digit_Train)
# Number of desired splits
kfolds <- 3
# Generate indices of holdout observations
# Note if N is not a multiple of folds you will get a warning, but is OK.
holdout <- split(sample(1:N), 1:kfolds)


#####  Run training and Testing for each of the k-folds
AllResults<-list()
AllLabels<-list()
for (k in 1:kfolds){
  
  Digit_Train_Test=Digit_Train[holdout[[k]], ]
  Digit_Train_Train=Digit_Train[-holdout[[k]], ]
  ## View the created Test and Train sets
  (head(Digit_Train_Train))
  (table(Digit_Train_Test$label))
  
  ## Make sure you take the labels out of the testing data
  (head(Digit_Train_Test))
  Digit_Train_Test_noLabel<-Digit_Train_Test[-c(1)]
  Digit_Train_Test_justLabel<-Digit_Train_Test$label
  (head(Digit_Train_Test_noLabel))
  
  
  #### e1071
  ## formula is label ~ x1 + x2 + .  NOTE that label ~. is "use all to create model"
  NB_e1071<-naiveBayes(label~., data=Digit_Train_Train, na.action = na.pass)
  NB_e1071_Pred <- predict(NB_e1071, Digit_Train_Test_noLabel)
  NB_e1071
  
  ## Accumulate results from each fold
  AllResults<- c(AllResults,NB_e1071_Pred)
  AllLabels<- c(AllLabels, Digit_Train_Test_justLabel)
  
}
### end crossvalidation -- present results for all folds   
NB_e1071_table <- table(unlist(AllResults),unlist(AllLabels))

b <- list()
for (j in 1:nrow(NB_e1071_table)){
  b[j] <- sum(NB_e1071_table[j,])
}

sums_NB <- unlist(b)
pred_acc_NB <- list()
correctlist_NB <- list()

for (o in 1:length(sums_NB)){
  pred_acc_NB[o] <-  NB_e1071_table[o,o] / sums_NB[o]
  correctlist_NB[o] <- NB_e1071_table[o,o]
}
# How accurate were we at predicting each number?
unlist(pred_acc_NB)
data.frame(pred_acc_NB)
x <- data.frame(pred_acc_NB)
colnames(x) <- c(0:9)
View(x)

# How accurate were we at predicting ALL the numbers (overall)
NBe1071 <- sum(unlist(correctlist_NB)) / sum(NB_e1071_table)

###########################################################################################





## using naivebayes package
## https://cran.r-project.org/web/packages/naivebayes/naivebayes.pdf

NB_object<- naive_bayes(label~., data=Digit_Train_Train)
NB_prediction<-predict(NB_object, Digit_Train_Test_noLabel, type = c("class"))
head(predict(NB_object, Digit_Train_Test_noLabel, type = "prob"))
NB_table <- table(NB_prediction,Digit_Train_Test_justLabel)

a <- list()
for (s in 1:nrow(NB_table)){
  a[s] <- sum(NB_table[s,])
}

sums <- unlist(a)
pred_acc <- list()
correctlist <- list()

for (n in 1:length(sums)){
  pred_acc[n] <-  NB_table[n,n] / sums[n]
  correctlist[n] <- NB_table[n,n]
}
# How accurate were we at predicting each number?
unlist(pred_acc)
data.frame(pred_acc)
y <- data.frame(pred_acc)
colnames(y) <- c(0:9)
View(y)

# How accurate were we at predicting ALL the numbers (overall)
NaiveB <- sum(unlist(correctlist)) / sum(NB_table)

##############################################################################################
##############################################################################################
## Support Vector Machines
require(tidyverse)
require(magrittr)
require(rpart)
require(rattle)
require(rpart.plot)
require(RColorBrewer)
require(Cairo)
require(forcats)
require(dplyr)
require(stringr)
require(e1071)
require(mlr)
require(caret)
require(naivebayes)

###################################
## polynomial kernel 

SVM_digit <- svm(label~., data=Digit_Train_Train, 
                          kernel="polynomial", cost=100, 
                          scale=FALSE)
print(SVM_digit)

## COnfusion Matrix for training data to check model

(SVM_digit_pred <- predict(SVM_digit, Digit_Train_Test_noLabel, type="class"))
SVM_table <- table(SVM_digit_pred, Digit_Train_Test_justLabel)

a1 <- list()
for (s1 in 1:nrow(SVM_table)){
  a1[s1] <- sum(SVM_table[s1,])
}

sums_svm <- unlist(a1)
pred_acc_svm <- list()
correctlist_svm <- list()

for (n in 1:length(sums_svm)){
  pred_acc_svm[n] <-  SVM_table[n,n] / sums_svm[n]
  correctlist_svm[n] <- SVM_table[n,n]
}
# How accurate were we at predicting each number?
unlist(pred_acc_svm)
data.frame(pred_acc_svm)
DF_SVM <- data.frame(pred_acc_svm)
colnames(DF_SVM) <- c(0:9)
View(DF_SVM)

# How accurate were we at predicting ALL the numbers (overall)
SVM_Poly <- sum(unlist(correctlist_svm)) / sum(SVM_table)


###################################
## linear kernel 

svm2_digit <- svm(label~., data=Digit_Train_Train, 
                 kernel="linear", cost=100, 
                 scale=FALSE)
print(svm2_digit)

## COnfusion Matrix for training data to check model

(svm2_digit_pred <- predict(svm2_digit, Digit_Train_Test_noLabel, type="class"))
svm2_table <- table(svm2_digit_pred, Digit_Train_Test_justLabel)

a1 <- list()
for (s1 in 1:nrow(svm2_table)){
  a1[s1] <- sum(svm2_table[s1,])
}

sums_svm2 <- unlist(a1)
pred_acc_svm2 <- list()
correctlist_svm2 <- list()

for (n in 1:length(sums_svm2)){
  pred_acc_svm2[n] <-  svm2_table[n,n] / sums_svm2[n]
  correctlist_svm2[n] <- svm2_table[n,n]
}
# How accurate were we at predicting each number?
unlist(pred_acc_svm2)
data.frame(pred_acc_svm2)
DF_svm2 <- data.frame(pred_acc_svm2)
colnames(DF_svm2) <- c(0:9)
View(DF_svm2)

# How accurate were we at predicting ALL the numbers (overall)
SVM_linear <- sum(unlist(correctlist_svm2)) / sum(svm2_table)


#####################################################################
#############   kNN #################################################
#####################################################################

# get a guess for k
k_guess <- round(sqrt(nrow(Digit_Train_Train)))

kNN_digit_fit <- class::knn(train=Digit_Train_Train, test=Digit_Train_Train, 
                          cl=Digit_Train_Train$label, k = k_guess, prob=F)
print(kNN_digit_fit)
## Check the classification accuracy
(table(kNN_digit_fit, Digit_Train_Train$label))

## Model works well

## Let's test it on the test set now

kNN_digit_fit2 <- class::knn(train=Digit_Train_Train[-1], test=Digit_Train_Test_noLabel, 
                             cl=Digit_Train_Train$label, k = k_guess, prob=F)
print(kNN_digit_fit2)
## Check the classification accuracy
kNN_table <- (table(kNN_digit_fit2, Digit_Train_Test_justLabel))

a2 <- list()
for (s2 in 1:nrow(kNN_table)){
  a2[s2] <- sum(kNN_table[s2,])
}

sums_kNN <- unlist(a2)
pred_acc_kNN <- list()
correctlist_kNN <- list()

for (n in 1:length(sums_kNN)){
  pred_acc_kNN[n] <-  kNN_table[n,n] / sums_kNN[n]
  correctlist_kNN[n] <- kNN_table[n,n]
}
# How accurate were we at predicting each number?
unlist(pred_acc_kNN)
data.frame(pred_acc_kNN)
DF_kNN <- data.frame(pred_acc_kNN)
colnames(DF_kNN) <- c(0:9)
View(DF_kNN)

# How accurate were we at predicting ALL the numbers (overall)
kNN <- sum(unlist(correctlist_kNN)) / sum(kNN_table)

##############################################################################################
####################################  Random Forest ##########################################
##############################################################################################

require("randomForest")

rf_digit <- randomForest(label~., data=Digit_Train_Train, 
                             importance=TRUE, proximity = TRUE)
print(rf_digit)


(rf_digit_pred <- predict(rf_digit, Digit_Train_Test_noLabel, type="class"))
rf_table <- table(rf_digit_pred, Digit_Train_Test_justLabel)

a3 <- list()
for (s3 in 1:nrow(rf_table)){
  a3[s3] <- sum(rf_table[s3,])
}

sums_rf <- unlist(a3)
pred_acc_rf <- list()
correctlist_rf <- list()

for (n in 1:length(sums_rf)){
  pred_acc_rf[n] <-  rf_table[n,n] / sums_rf[n]
  correctlist_rf[n] <- rf_table[n,n]
}
# How accurate were we at predicting each number?
unlist(pred_acc_rf)
data.frame(pred_acc_rf)
DF_rf <- data.frame(pred_acc_rf)
colnames(DF_rf) <- c(0:9)
View(DF_rf)

# How accurate were we at predicting ALL the numbers (overall)
RF <- sum(unlist(correctlist_rf)) / sum(rf_table)

overall_acc <- c(DT, DT_pruned, NBe1071, NaiveB, SVM_Poly, SVM_linear, kNN, RF)
data.frame(overall_acc, row.names = c("DT", "DT_pruned", "NBe1071", "NaiveB", "SVM_Poly", "SVM_linear", "kNN", "RF"))


overall_acc_bynum <- cbind.data.frame(a,w,x,y,DF_SVM, DF_svm2, DF_kNN, DF_rf)
man2 <- data.frame((matrix(overall_acc_bynum, nrow = 10)))
colnames(man2) <- c("DT", "DT_pruned", "NBe1071", "NaiveB", "SVM_Poly", "SVM_linear", "kNN", "RF")
rownames(man2) <- c(0:9)

View(man2)
