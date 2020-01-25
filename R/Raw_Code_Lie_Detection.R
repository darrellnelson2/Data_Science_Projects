# change this file location to suit your machine
file_loc <- "C:\\Users\\Darrell\\Desktop\\Syracuse\\Spring_19\\IST_707_Data_Analytics\\Week09\\HW08\\deception_data_converted_final23.csv"
# change TRUE to FALSE if you have no column headings in the CSV
x <- read.csv(file_loc, header = TRUE)
require(tm)
corp <- Corpus(DataframeSource(x))
dtm <- DocumentTermMatrix(corp)

(getTransformations())
(ndocs<-length(corp))

# ignore extremely rare words i.e. terms that appear in less then 1% of the documents
minTermFreq <- ndocs * 0.000
# ignore overly common words i.e. terms that appear in more than 50% of the documents
maxTermFreq <- ndocs * 100000
STOPS <-stopwords('english')
# Very happy to note that the stop words in the ISO english are all conventional. It should not
# remove any of the flavorful dialect of old English (King's English)

Clean_dtm <- DocumentTermMatrix(corp,
                              control = list(
                                stopwords = TRUE,
                                wordLengths=c(3, 15),
                                removePunctuation = T,
                                removeNumbers = T,
                                tolower=T,
                                stemming = T,
                                remove_separators = T,
                                stopwords = STOPS,
                                bounds = list(global = c(minTermFreq, maxTermFreq))
                              ))

## Have a look

DTM_mat <- as.matrix(dtm)
(DTM_mat[1:5,1:5])

# Using clean corpus
CleanDTM_mat <- as.matrix(Clean_dtm)



# Create Lie Classification dataset
NEW_DF_LIE <- data.frame(LIE,DTM_mat)
CLEAN_NEW_DF_LIE <- data.frame(LIE, CleanDTM_mat) # using cleaned dataset

# Create Customer Sentiment dataset
NEW_DF_Sentiment <- data.frame(SENT, DTM_mat)
CLEAN_NEW_DF_Sentiment <- data.frame(SENT, CleanDTM_mat) # using cleaned dataset

require(e1071)
#### e1071
## formula is label ~ x1 + x2 + .  NOTE that label ~. is "use all to create model"
NB_e1071<-naiveBayes(LIE~., data=NEW_DF_LIE, na.action = na.pass)
NB_e1071_Pred <- predict(NB_e1071, NEW_DF_LIE, type = "class")
NB_e1071table <- table(NB_e1071_Pred, LIE)

## For cleaned dataset
NBc_e1071<-naiveBayes(LIE~., data=CLEAN_NEW_DF_LIE, na.action = na.pass)
NBc_e1071_Pred <- predict(NBc_e1071, CLEAN_NEW_DF_LIE, type = "class")
(NBc_e1071table <- table(NBc_e1071_Pred, LIE))

# Build Accuracy Function
modelacc <- function(table) {
  correctpred <- list()
  
  for (n in 1:nrow(table)){
    correctpred[n] <- table[n,n]
  }
  correctpred <- unlist(correctpred)
  ans_acc <- sum(correctpred) / sum(table)
  return(ans_acc)
}

# Output Accuracy for lie detection
modelacc(NB_e1071table)
# Output Precision and Recall based on fake reviews
precision(NB_e1071table)
recall(NB_e1071table)

ans_rev <- function(table){
  a2 <- c(modelacc(table), precision(table), recall(table), precision(table, relevant = 't'), recall(table, relevant = 't'))
  return(a2)
}

# Answers for sentiment analysis
ans_rev2 <- function(table){
  a2 <- c(modelacc(table), precision(table), recall(table), precision(table, relevant = 'p'), recall(table, relevant = 'p'))
  return(a2)
}
NBSent_e1071<-naiveBayes(SENT~., data=NEW_DF_Sentiment, na.action = na.pass)
NBSent_e1071_Pred <- predict(NBSent_e1071, NEW_DF_Sentiment, type = "class")
(NBSenttable <- table(NBSent_e1071_Pred, SENT))


## For cleaned dataset on sentiment
NBSentc_e1071<-naiveBayes(SENT~., data=CLEAN_NEW_DF_Sentiment, na.action = na.pass)
NBSentc_e1071_Pred <- predict(NBSentc_e1071, CLEAN_NEW_DF_Sentiment, type = "class")
(NBSentc_e1071table <- table(NBSentc_e1071_Pred, SENT))
# Output Accuracy
modelacc(NBSenttable)
# Output Precision and Recall based on fake reviews
precision(NBSenttable)
recall(NBSenttable)

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

SVM_lie <- svm(LIE~., data=NEW_DF_LIE, 
                 kernel="polynomial", cost=100, 
                 scale=FALSE)

## polynomial kernel for clean data 
SVMc_lie <- svm(LIE~., data=CLEAN_NEW_DF_LIE, 
               kernel="polynomial", cost=10000, 
               scale=FALSE)

SVM_sent <- svm(SENT~., data=NEW_DF_Sentiment, 
               kernel="polynomial", cost=100, 
               scale=FALSE)

## Sentiment: polynomial kernel for clean data 
SVMsentc <- svm(SENT~., data=CLEAN_NEW_DF_Sentiment, 
                kernel="polynomial", cost=10000, 
                scale=FALSE)

## COnfusion Matrix for training data to check model

(SVM_lie_pred <- predict(SVM_lie, NEW_DF_LIE, type="class"))
SVM_lie_table <- table(SVM_lie_pred, LIE)

# Confusion matrix for cleaned data
(SVMc_lie_pred <- predict(SVMc_lie, CLEAN_NEW_DF_LIE, type="class"))
(SVMc_lie_table <- table(SVMc_lie_pred, LIE))
# Output Accuracy, Precision,  and Recall
ans_rev(SVMc_lie_table)


(SVM_sent_pred <- predict(SVM_sent, NEW_DF_Sentiment, type="class"))
(SVM_sent_table <- table(SVM_sent_pred, SENT))

# Sentiment: Confusion matrix for cleaned data
(SVMSentc_pred <- predict(SVMsentc, CLEAN_NEW_DF_Sentiment, type="class"))
(SVMSentc_table <- table(SVMSentc_pred, SENT))
# Output Accuracy, Precision,  and Recall
ans_rev2(SVMSentc_table)



##########################################################################################
############################# Testing Model ##############################################
trainRatio <- .67; # ~2/3rds of the rows will be used for testing
set.seed(9) # Set Seed so that same sample can be reproduced in future also

# Split up the reviews into training and testing data
sample <- sample.int(n = nrow(CLEAN_NEW_DF_LIE), size = floor(trainRatio*nrow(CLEAN_NEW_DF_LIE)), replace = FALSE)

train_lie <- CLEAN_NEW_DF_LIE[sample, ]
test_lie <- CLEAN_NEW_DF_LIE[-sample, ]
train_sent <- CLEAN_NEW_DF_Sentiment[sample, ]
test_sent <- CLEAN_NEW_DF_Sentiment[-sample, ]

# train / test ratio
# Verify that this number is close to trainRatio
length(sample)/nrow(CLEAN_NEW_DF_LIE)

## For cleaned dataset NB
NBc_e1071<-naiveBayes(LIE~., data=train_lie, na.action = na.pass)
NBc_e1071_Pred <- predict(NBc_e1071, test_lie[ , -1], type = "class")
(NBc_e1071table <- table(NBc_e1071_Pred, test_lie$LIE))

NBSentc_e1071<-naiveBayes(SENT~., data=train_sent, na.action = na.pass)
NBSentc_e1071_Pred <- predict(NBSentc_e1071, test_sent[ , -1], type = "class")
(NBSentc_e1071table <- table(NBSentc_e1071_Pred, test_sent$SENT))

## SVM polynomial kernel for clean data 
SVMc_lie <- svm(LIE~., data=train_lie, 
                kernel="polynomial", cost=10000, 
                scale=FALSE)

(SVMc_lie_pred <- (predict(SVMc_lie, test_lie[, -1], type="class")))
SVMc_lie_table <- table(SVMc_lie_pred, test_lie$LIE)

## SVM polynomial kernel for clean data 
SVMc_sent <- svm(SENT~., data=train_sent, 
                kernel="polynomial", cost=10000, 
                scale=FALSE)

(SVMc_sent_pred <- (predict(SVMc_sent, test_sent[, -1], type="class")))
SVMc_sent_table <- table(SVMc_sent_pred, test_sent$SENT)

########################### Information Gain with Entropy ----------------------------
install.packages("CORElearn")

#https://cran.r-project.org/web/packages/CORElearn/CORElearn.pdf

#Method.CORElearn <- CORElearn::attrEval(CleanTrain$Survived ~ ., data=CleanTrain,  estimator = "InfGain")
#(Method.CORElearn)
#Method.CORElearn2 <- CORElearn::attrEval(CleanTrain$Survived ~ ., data=CleanTrain,  estimator = "Gini")
#(Method.CORElearn2)
Method.CORElearn3 <- CORElearn::attrEval(CLEAN_NEW_DF_LIE$LIE ~ ., data=CLEAN_NEW_DF_LIE,  estimator = "GainRatio")
(Method.CORElearn3)
bich <- sort(Method.CORElearn3, decreasing = TRUE)
head(bich, n=30)

Method.CORElearn3 <- CORElearn::attrEval(CLEAN_NEW_DF_Sentiment$SENT ~ ., data=CLEAN_NEW_DF_Sentiment,  estimator = "GainRatio")
(Method.CORElearn3)
bich <- sort(Method.CORElearn3, decreasing = TRUE)
head(bich, n=30)
