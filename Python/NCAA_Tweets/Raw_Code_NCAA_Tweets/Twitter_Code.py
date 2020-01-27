'''
Read in JSON formatted data from a twitter file. This will be in a format that
is structured with lines of data representing one type of unit, for example, one tweet for
Twitter. Program will contain the data as lists of json
structures, which are just python dictionaries and lists. Your program may also contain
pandas dataframes for processed data.
The program will do some processing to collect data from some of the fields that will
answer one or more questions.
Twitter data is collected from the 2017 march madness campaign.
'''
import pymongo
client = pymongo.MongoClient('localhost',27017)
#list the databases defined
client.database_names()

db = client.bball
db.collection_names()
coll=db.bbcoll
docs = coll.find()

# convert the document cursor to a list of documents
doclist = [tweet for tweet in docs]
print('Number of tweets imported: ', len(doclist))

# show difference from print
# print(doclist[:1])
#Look through this to point out field names.


print('\nQuestion01:\nWhat is the average friend count of each user that posted?')
newlist = [] # create a new list

for tweet in doclist:
	a = tweet['user']['friends_count']
	newlist.append(a) # place tweet count into list
	
# What is the average friend count of each user that posted
count = len(newlist) # number of friend counts in vector
avgf_cnt = sum(newlist) / count # averge friend count of each user
## answer is 1974.9615
print('Average friend count of each user that posted: ', avgf_cnt)

# What's the difference between a tweet from the most and least followed user?
print("\nQuestion02:\nWhat's the difference between a tweet from the most and least followed user?")
follower_list = [] # create a new list

for tweet in doclist:
	c = tweet['user']['followers_count']
	follower_list.append(c) # place follower count into list

max_fol = max(follower_list)
min_fol = min(follower_list)

print('Max Follower User Name:', doclist[follower_list.index(max_fol)]['user']['name'])
print('Max Follower Text:', doclist[follower_list.index(max_fol)]['text'])
print('Number of Followers: ', max_fol)
print('\nMin Follower User Name:',doclist[follower_list.index(min_fol)]['user']['name'])
print('Min Follower Text:', doclist[follower_list.index(min_fol)]['text'])
print('Number of Followers: ', min_fol)

# NNEEEDDD TTTOOO REEEEEEEEEEERRRRRRRRRRRRUUUUUUUUUUNNNNNNNNN
# They cheer for no one. Both sides are neutral (further explain).

# What time zones are the tweets from?
print('\nQuestion03: What time zones are the tweets from?')
timez_list = [] # create a new list

for tweet in doclist:
	b = tweet['user']['time_zone']
	timez_list.append(b) # place tweet location into list

	
import pandas as pd
from collections import Counter
letter_counts = Counter(timez_list)
df = pd.DataFrame.from_dict(letter_counts, orient='index')
df.plot(kind='bar')
print('Time Zone Freq. List:\n', df)

# df produces a frequency distribution of all time zones in list
# df also tells you which time zone is the most popular

# Which time zone gets the most retweets
print('\nQuestion04: Which time zone gets the most retweets?')

import numpy as np

# Create list of retweets
retweet_list = [] # create a new list

for tweet in doclist:
	d = tweet['retweet_count']
	retweet_list.append(d) # place retweet count into list
	
df2 = pd.DataFrame({'time_zone':timez_list, 'retweet':retweet_list})
print('Time zone by retweet count:\n', df2.groupby('time_zone')['retweet'].sum())
# Eastern time reigns surpreme with the most retweets. This is probably why
# games are catered to eastern time zones and not western.

# How many twitter users have their geo location enabled?
print('\nQuestion05: How many twitter users have their geo location on?')
# Create list of users that have geo location turned on
geo_list = [] # create a new list
d = 0 # counter for True statements
for tweet in doclist:
	e = tweet['user']['geo_enabled']
	geo_list.append(e) # place count into list
	if e == True:
		d = d + 1
print('There are' ,d, 'users out of', len(geo_list), 'that have their location enabled')
print(100*(d/len(geo_list)), 'Percent of people want their location tracked.') 

# There are 2088 users out of 4000 that want their location tracked to be used 
# by data meddlers like me!!! =) I am forever grateful!! 