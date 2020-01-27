# Darrell Nelson II
# IST 707 HW 04


# Upload/install all required libraries
# Analyze the formatted .csv first

library(tm)
library(stringr)
library(wordcloud)
library(slam)
library(quanteda)
## Note - this includes SnowballC
library(SnowballC)
library(arules)
## ONCE: install.packages("wordcloud")
library(wordcloud)
##ONCE: install.packages('proxy')
library(proxy)
library(cluster)
library(stringi)
library(proxy)
library(Matrix)
library(tidytext) # convert DTM to DF
library(plyr) ## for adply
library(ggplot2)
library(factoextra) # for fviz
library(mclust) # for Mclust EM clustering

# Set working directory
setwd("C:\\Users\\Darrell\\Desktop\\Syracuse\\Spring_19\\IST_707_Data_Analytics\\Week04\\HW04")

## Next, load in the documents (the corpus)
FedCorpus <- Corpus(DirSource("fedPapers"))
(getTransformations())
(ndocs<-length(FedCorpus))
## There are 85 documents in total:
# 11 papers are disputed as being Alexander Hamilton or James Madison
# 51 papers were authored by Alexander Hamilton
# 3 papers coauthored by Alexander Hamilton and James Madison
# 5 papers were authored by John Jay
# 15 papers were authored by James Madison
# There's a much larger sample size of Hamilton's work than Madison's. It'll be interesting to 
# see if the larger sample size skews the results towards Hamilton. But, also a resonable 
# point can be made that if Hamilton was the more advent writor than he could have wrote or at
# least had a lot of influence on the disputed papers even if Madison wrote them. They have worked
# together on 3 papers and I believe that where these 3 papers are classified (e.g. Hamilton, Madison,
# etc.) will be very telling to see which author had more stylistic influence over the other.
# As they've worked together it's quite possible the more adept writer "rubbed off" on the other. 
# If that's true, another compelling method to solve this mystery would be to put the federalist papers 
# in chronological order and see if the style/word choice of Hamilton gets closer to Madison's over time
# or vice versa. 

##The following will show you that you read in all the documents
(summary(FedCorpus))
(meta(FedCorpus[[1]]))
(meta(FedCorpus[[1]],5))

## No bounds on word frequency. It is best to see which author liked to use what type of 
# buzz words in their papers. Since all of these papers are intended to influence the
# voters to ratify the Constitution, it'll be interesting which analogies and turn of phrases
# are specific to a certain author.

# ignore extremely rare words i.e. terms that appear in less then 1% of the documents
minTermFreq <- ndocs * 0.000
# ignore overly common words i.e. terms that appear in more than 50% of the documents
maxTermFreq <- ndocs * 100000
STOPS <-stopwords('english')
# Very happy to note that the stop words in the ISO english are all conventional. It should not
# remove any of the flavorful dialect of old English (King's English)

Fed_dtm <- DocumentTermMatrix(FedCorpus,
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

DTM_mat <- as.matrix(Fed_dtm)
(DTM_mat[1:13,1:5])

# Fed_dtm <- weightTfIdf(Fe_dtm, normalize = TRUE)
# Novels_dtm <- weightTfIdf(Novels_dtm, normalize = FALSE)

## Look at word freuqncies
(WordFreq <- colSums(as.matrix(Fed_dtm)))

head(WordFreq)
(length(WordFreq))
ord <- order(WordFreq)
(WordFreq[head(ord)]) # least used words in all documents
(WordFreq[tail(ord)]) # most used words in all documents

## Row Sums
(Row_Sum_Per_doc <- rowSums((as.matrix(Fed_dtm))))
max(Row_Sum_Per_doc)
which(Row_Sum_Per_doc == max(Row_Sum_Per_doc)) # Hamilton_fed_83 is the longest paper
min(Row_Sum_Per_doc)
mean(Row_Sum_Per_doc)
sd(Row_Sum_Per_doc)
plot(Row_Sum_Per_doc, xlab = "Paper Index", ylab = "Word Count") # need to normalize the data because there is an outlier (Hamilton_fed_83) 

## Create normalized version of Fed_dtm by hand! Explain why in paper (Look at 
# TextMining_NLP_Novels.R)
FedPapers_M <- as.matrix(Fed_dtm)
FedPapers_M_N1 <- apply(FedPapers_M, 1, function(i) round(i/sum(i),3))
## transpose
FedPapers_Matrix_Norm <- t(FedPapers_M_N1)
## Have a look at the original and the norm to make sure
(FedPapers_M[c(1:6),c(1000:1005)])
(FedPapers_Matrix_Norm[c(1:6),c(1000:1005)])

## Convert to matrix and view
Fed_dtm_matrix = as.matrix(Fed_dtm)
str(Fed_dtm_matrix)
(Fed_dtm_matrix[c(1:3),c(2:4)]) # Verify output looks good

## Convert to DF and view
Fed_DF <- as.data.frame(as.matrix(Fed_dtm))
str(Fed_DF)
(nrow(Fed_DF))  ## Each row is a Federalist Paper
## Fox DF format



wordcloud(colnames(Fed_dtm_matrix), Fed_dtm_matrix[1, ], max.words = 70, scale=c(2,.5)) # 
(head(sort(as.matrix(Fed_dtm)[1,], decreasing = TRUE), n=20))

wordcloud(colnames(Fed_dtm_matrix), Fed_dtm_matrix[12, ], max.words = 70, scale=c(2,.5)) # 
(head(sort(as.matrix(Fed_dtm)[12,], decreasing = TRUE), n=20))

wordcloud(colnames(Fed_dtm_matrix), Fed_dtm_matrix[71, ], max.words = 70, scale=c(2,.5)) # 
(head(sort(as.matrix(Fed_dtm)[71,], decreasing = TRUE), n=20))


############## Distance Measures ######################

m  <- Fed_dtm_matrix
m_norm <- FedPapers_Matrix_Norm

distMatrix_E <- dist(m, method="euclidean")
distMatrix_C <- dist(m, method="cosine")
distMatrix_C_norm <- dist(m_norm, method="cosine")

############# Clustering #############################
## Hierarchical

## Euclidean
groups_E <- hclust(distMatrix_E,method="ward.D")
plot(groups_E, cex=0.9, hang=-1)
rect.hclust(groups_E, k=4)

## Cosine Similarity
groups_C <- hclust(distMatrix_C,method="ward.D")
plot(groups_C, cex=0.9, hang=-1)
rect.hclust(groups_C, k=4)

## Cosine Similarity for Normalized Matrix
groups_C_n <- hclust(distMatrix_C_norm,method="ward.D")
plot(groups_C_n, cex=0.9, hang=-1)
rect.hclust(groups_C_n, k=4)

# Complete linkage HAC Cosine
hac_complete = hclust(distMatrix_C, method = "complete")
plot(hac_complete, cex=0.9, hang=-1)
rect.hclust(hac_complete, k=4)

# Complete linkage HAC Cosine Normalized
hac_complete_norm = hclust(distMatrix_C_norm, method = "complete")
plot(hac_complete_norm, cex=0.9, hang=-1)
rect.hclust(hac_complete_norm, k=4)

# Average linkage HAC Cosine Normalized
hac_avg_norm = hclust(distMatrix_C_norm, method = "average")
plot(hac_avg_norm, cex=0.9, hang=-1)
rect.hclust(hac_avg_norm, k=4)

# Centroid linkage HAC Cosine Normalized
hac_cen_norm = hclust(distMatrix_C_norm, method = "centroid")
plot(hac_cen_norm, cex=0.9, hang=-1)
rect.hclust(hac_cen_norm, k=4)

####################   k means clustering -----------------------------
X <- m_norm
## Remember that kmeans uses a matrix of ONLY NUMBERS
## We have this so we are OK.
## Pearson gives the best vis results!
distance1 <- get_dist(X,method = "manhattan")
fviz_dist(distance1, gradient = list(low = "red", mid = "white", high = "blue"))
distance2 <- get_dist(X,method = "pearson")
fviz_dist(distance2, gradient = list(low = "red", mid = "white", high = "blue"))
distance3 <- get_dist(X,method = "canberra")
fviz_dist(distance3, gradient = list(low = "red", mid = "white", high = "blue"))
distance4 <- get_dist(X,method = "spearman")
fviz_dist(distance4, gradient = list(low = "red", mid = "white", high = "blue"))


################# Expectation Maximization ---------
## When Clustering, there are many options. 
## I cannot run this as it requires more than 18 Gigs...
# 
# ClusFI <- Mclust(X)
# (ClusFI)
# summary(ClusFI)
# par(mar = rep(0.2, 0.4))
# plot(ClusFI, what = "classification")
