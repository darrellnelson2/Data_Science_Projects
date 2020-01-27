'''
  This program shell reads email data for the spam classification problem.
  The input to the program is the path to the Email directory "corpus" and a limit number.
  The program reads the first limit number of ham emails and the first limit number of spam.
  It creates an "emaildocs" variable with a list of emails consisting of a pair
    with the list of tokenized words from the email and the label either spam or ham.
  It prints a few example emails.
  Your task is to generate features sets and train and test a classifier.

  Usage:  python classifySPAM.py  <corpus directory path> <limit number>
'''
# open python and nltk packages needed for processing
import os
import sys
import random
import nltk
from nltk.corpus import stopwords

# Create bigrams
from nltk.collocations import *
bigram_measures = nltk.collocations.BigramAssocMeasures()



# define a feature definition function here
def bigram_document_features(document, word_features, bigram_features):
  document_words = set(document)
  document_bigrams = nltk.bigrams(document)
  features = {}
  for word in word_features:
    features['V_{}'.format(word)] = (word in document_words)
  for bigram in bigram_features:
    features['B_{}_{}'.format(bigram[0], bigram[1])] = (bigram in document_bigrams)    
  return features

# function to read spam and ham files, train and test a classifier 
def processspamham(dirPath,limitStr):
  # convert the limit argument from a string to an int
  limit = int(limitStr)
  
  # start lists for spam and ham email texts
  hamtexts = []
  spamtexts = []
  os.chdir(dirPath)
  # process all files in directory that end in .txt up to the limit
  #    assuming that the emails are sufficiently randomized
  for file in os.listdir("./spam"):
    if (file.endswith(".txt")) and (len(spamtexts) < limit):
      # open file for reading and read entire file into a string
      f = open("./spam/"+file, 'r', encoding="latin-1")
      spamtexts.append (f.read())
      f.close()
  for file in os.listdir("./ham"):
    if (file.endswith(".txt")) and (len(hamtexts) < limit):
      # open file for reading and read entire file into a string
      f = open("./ham/"+file, 'r', encoding="latin-1")
      hamtexts.append (f.read())
      f.close()
  
  # print number emails read
  print ("Number of spam files:",len(spamtexts))
  print ("Number of ham files:",len(hamtexts))
  print
  
  # create list of mixed spam and ham email documents as (list of words, label)
  emaildocs = []
  # add all the spam
  for spam in spamtexts:
    tokens = nltk.word_tokenize(spam)
    emaildocs.append((tokens, 'spam'))
  # add all the regular emails
  for ham in hamtexts:
    tokens = nltk.word_tokenize(ham)
    emaildocs.append((tokens, 'ham'))
  
  # randomize the list
  random.shuffle(emaildocs)
  
  # print a few token lists
  for email in emaildocs[:4]:
    print (email)
    print
  
  # possibly filter tokens

  # # continue as usual to get all words and create word features
  all_words_list = [word for (sent,cat) in emaildocs for word in sent]
  all_words = nltk.FreqDist(all_words_list)
  word_items = all_words.most_common(1500)
  word_features = [word for (word, freq) in word_items]
  
  # create the first 50 words; do NOT filter by stopwords when doing bigrams
  finder = BigramCollocationFinder.from_words(word_items)

  # Define the top 500 bigrams using the chi squared measure
  bigram_features = finder.nbest(bigram_measures.chi_sq, 1000)



  # # feature sets from a feature definition function
  featuresets = [(bigram_document_features(d, word_features, bigram_features), c) for (d,c) in emaildocs]
  print(len(featuresets))

  # # train classifier and show performance in cross-validation
  #train_set, test_set = featuresets[1000:], featuresets[:1000]
  train_set, test_set = featuresets[round(0.8*len(featuresets)):], featuresets[:round(0.8*len(featuresets))]
  classifier = nltk.NaiveBayesClassifier.train(train_set)
  #print(nltk.classify.accuracy(classifier, test_set))
  num_folds = 10
  def cross_validation_accuracy(num_folds, featuresets):
    subset_size = int(len(featuresets)/num_folds)
    print('Each fold size: ', subset_size)
    accuracy_list = []
    # iterate over the folds
    for i in range(num_folds):
      test_this_round = featuresets[i*subset_size:][:subset_size]
      train_this_round = featuresets[:i*subset_size]+featuresets[(i+1)*subset_size:]
      # train using train_this_round
      classifier = nltk.NaiveBayesClassifier.train(train_this_round)
      # evaluate against test_this_round and save accuracy
      accuracy_this_round = nltk.classify.accuracy(classifier, test_this_round)
      print (i, accuracy_this_round)
      accuracy_list.append(accuracy_this_round)
    # find mean accuracy over all rounds
    print ('Cross validation mean accuracy: ', sum(accuracy_list) / num_folds)
  cross_validation_accuracy(num_folds, featuresets)
  

  #compute the gold list and the predicted list
  goldlist = []
  predictedlist = []
  for (features, label) in test_set:
    goldlist.append(label)
    predictedlist.append(classifier.classify(features))


  # Create and print out confusion matrix
  cm = nltk.ConfusionMatrix(goldlist, predictedlist)
  print(cm.pretty_format(sort_by_count=True, show_percents=True, truncate=9))
  
  # Output:  prints precision, recall and F1 for each label
  def eval_measures(gold, predicted):
    # get a list of labels
    labels = list(set(gold))
    # these lists have values for each label 
    recall_list = []
    precision_list = []
    F1_list = []
    for lab in labels:
      # for each label, compare gold and predicted lists and compute values
      TP = FP = FN = TN = 0
      for i, val in enumerate(gold):
        if val == lab and predicted[i] == lab:  TP += 1
        if val == lab and predicted[i] != lab:  FN += 1
        if val != lab and predicted[i] == lab:  FP += 1
        if val != lab and predicted[i] != lab:  TN += 1
      # use these to compute recall, precision, F1
      recall = TP / (TP + FP)
      precision = TP / (TP + FN)
      recall_list.append(recall)
      precision_list.append(precision)
      F1_list.append( 2 * (recall * precision) / (recall + precision))
	  
    # the evaluation measures in a table with one row per label
    print('\tPrecision\tRecall\t\tF1')
    # print measures for each label
    for i, lab in enumerate(labels):
      print(lab, '\t', "{:10.3f}".format(precision_list[i]), \
        "{:10.3f}".format(recall_list[i]), "{:10.3f}".format(F1_list[i]))

  # Now we can call this function on our data.
  print(eval_measures(goldlist, predictedlist))



	



"""
commandline interface takes a directory name with ham and spam subdirectories
   and a limit to the number of emails read each of ham and spam
It then processes the files and trains a spam detection classifier.

"""
if __name__ == '__main__':
   if (len(sys.argv) != 3):
       print ('usage: python classifySPAM.py <corpus-dir> <limit>')
       sys.exit(0)
   processspamham(sys.argv[1], sys.argv[2])
        
