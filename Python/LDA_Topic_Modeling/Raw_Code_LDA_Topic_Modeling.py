# -*- coding: utf-8 -*-
"""
Created on Tue Sep  3 03:54:15 2019

@author: Darrell
"""

## Change the working directory
import os
print(os.getcwd())  # Prints the current working directory

# change to appropriate directory
path = 'D:\Darrell\Desktop\Syracuse\Summer_19\IST_736_Text_Mining\Week08\HW08'
os.chdir(path)

print(os.getcwd())  # Prints the current working directory
###############################################################################
# %%

# Import text files
import os             
all_files = os.listdir("homework_8_data/110/110-f-d/")   # import txt file names
print(all_files)  # won't necessarily be sorted

def read_first_line(file):
    with open(file, 'rt') as fd:
        first_line = fd.readline()
    return first_line

output_strings = map(read_first_line, all_files)  # apply read first line function all text files
print(output_strings)

# %%

import os
import io

work_dir = "D:\Darrell\Desktop\Syracuse\Summer_19\IST_736_Text_Mining\Week08\HW08"
newlist = [] # empty list

for index in range(0, 50):
    name = all_files[index]
    path = os.path.join(work_dir, name)
    with io.open(path, mode="r", encoding="ISO-8859-1") as fd:
        content = fd.read()
        newlist.append(content)

#%%
###################################################
###
### Data Prep and Pre-processing
###
###################################################
#https://www.machinelearningplus.com/nlp/topic-modeling-gensim-python
#pip install -U gensim #installing gensim
import gensim
## IMPORTANT - you must install gensim first ##
## conda install -c anaconda gensim
from gensim.utils import simple_preprocess
from gensim.parsing.preprocessing import STOPWORDS
from nltk.stem import WordNetLemmatizer, SnowballStemmer

import numpy as np
np.random.seed(2018)

import nltk
#nltk.download('wordnet')
from nltk import PorterStemmer
from nltk.stem import PorterStemmer 
stemmer = PorterStemmer()

from nltk.tokenize import word_tokenize 
from nltk.stem.porter import *

#NOTES
##### Installing gensim caused my Spyder IDE no fail and no re-open
## I used two things and did a restart
## 1) in cmd (if PC)  psyder --reset
## 2) in cmd (if PC) conda upgrade qt

######################################
## function to perform lemmatize and stem preprocessing
############################################################
## Function 1
def lemmatize_stemming(text):
    return stemmer.stem(WordNetLemmatizer().lemmatize(text, pos='v'))

## Function 2
def preprocess(text):
    result = []
    for token in gensim.utils.simple_preprocess(text):
        if token not in gensim.parsing.preprocessing.STOPWORDS and len(token) > 3:
            result.append(lemmatize_stemming(token))
    return result

#Select a document to preview after preprocessing
doc_test = newlist[0]
print(doc_test)
print('original document: ')
words2 = []
for word in doc_test.split(' '):
    words2.append(word)
print(words2)
print('\n\n tokenized and lemmatized document: ')
print(preprocess(doc_test))

#%%

## Preprocess all the documents, saving the results as ‘processed_all_docs’
import pandas as pd
speeches = pd.DataFrame(newlist)
processed_all_docs = speeches[0].map(preprocess)
print(processed_all_docs[:1])


#%%

## Create a dictionary from ‘processed_docs’ containing the 
## number of times a word appears in the training set.

dictionary2 = gensim.corpora.Dictionary(processed_all_docs)

## Take a look ...you can set count to any number of items to see
## break will stop the loop when count gets to your determined value
count = 0
for k, v in dictionary2.iteritems():
    print(k, v)
    count += 1
    if count > 5:
        break

#%%
#######################
## For each document we create a dictionary reporting how many
##words and how many times those words appear. Save this to ‘bow_corpus’
##############################################################################
#### bow: Bag Of Words
bow_corpus = [dictionary2.doc2bow(doc) for doc in processed_all_docs]
print(bow_corpus[1:2])

#%%
#################################################################
### TF-IDF
#################################################################
##Create tf-idf model object using models.TfidfModel on ‘bow_corpus’ 
## and save it to ‘tfidf’, then apply transformation to the entire 
## corpus and call it ‘corpus_tfidf’. Finally we preview TF-IDF 
## scores for our first document.

from gensim import corpora, models

tfidf = models.TfidfModel(bow_corpus)
corpus_tfidf = tfidf[bow_corpus]
## pprint is pretty print
from pprint import pprint

for doc in corpus_tfidf:
    pprint(doc)
    ## the break will stop it after the first doc
    break

#%%

#############################################################
### Running LDA using Bag of Words
#################################################################
    
# ~ 12 minutes
lda_model = gensim.models.LdaMulticore(bow_corpus, num_topics=10, id2word=dictionary2, passes=10)
    
# Print the Keyword in the 10 topics
pprint(lda_model.print_topics())

#doc_lda = lda_model[bow_corpus]


# Compute Perplexity
perplx = lda_model.log_perplexity(bow_corpus)
print('\nPerplexity: ', perplx )  # a measure of how good the model is. lower the better.

# %%

# Save the pre-trained model
from gensim.test.utils import datapath

# Save model to disk.
temp_file = datapath("model")
lda_model.save(temp_file)

# Load a potentially pretrained model from disk.
lda = LdaModel.load(temp_file)