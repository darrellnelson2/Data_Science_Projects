# Creator: Darrell Nelson II
# IST 707 HW 03

## Load appropriate libraries

require(plyr)
require(dplyr)
require(arules)

## Load bank data-set

bd = read.csv("C:/Users/Darrell/Desktop/Syracuse/Spring_19/IST_707_Data_Analytics/Week03/bankdata_csv_all.csv")
str(bd)

# id column provides no use in our dataframe; remove id column
newbd <- bd[ , -1]


## The first step is to convert all numeric variables to nominal, because AR mining can 
# only analyze nominal data (whether an item occurs in a transaction or not).

## Then the first step of conversion: discretization and numeric-to-nominal transformation. 

### Discretize age by customized bin
# View age feature
hist(newbd$age)
# The histogram partitions the ages into 6 distinct groups: adolescents (0-20), young adults (20-30),
# thirties, fourties, fifties, sixties, and seventies. While this is a good initial guess does it
# provide enough granularity into the younger sector? For instance, did parents open up personal equity
# plans (PEP) for their children? On further inspection of PEPs we can tell that the dataset only contains
# customers that our 18 and over.
newbd[newbd$age < 18 , ]
head(newbd[newbd$age < 20 , ])
# This is because PEPs are investment plans introduced in the U.K. that only allowed people 
# over the age of 18 to participate. With this we can appropriately discretize the ages as 
# teens, twenties, thirties, fourties, fifties, sixties, and 70+
newbd[newbd$age > 69 , ]
# On further inspection there are no 70+ customers in our data-set. Therefore, we can appropriately cut
# off our labeling after sixties.

newbd$age <- cut(newbd$age, breaks = c(0,20,30,40,50,60, Inf),labels=c("teens","20s","30s","40s","50s","60s"))


### Discretize income by equal-width bin
# View income feature
hist(newbd$income)
# Based off the histogram the min and max income are between $5,000 and $65,000
# We can verify by:
newbd[newbd$income < 5000 , ] #minimum income
newbd[newbd$income > 65000 , ] #maximum income

# Going to https://www.gov.uk/income-tax-rates shows us the different tax brackets
# in the UK. The tax bracket distinctions is the same method followed here to determine
# the size and of bins
# min_income <- min(bd$income)
# max_income <- max(bd$income)
# bins = 3 
# width=(max_income - min_income)/bins;

newbd$income = cut(newbd$income, breaks = c(0, 12500, 50000, Inf), labels = c("Poor", "Middle", "Affluent"))


### Convert numeric to nominal for "children"

newbd$children=factor(newbd$children)
str(newbd)

## After converting all features into nominal values 
## the second step of conversion is changing all binary outputs "YES" to "[variable_name]=YES
## in order to improve readability of the AR mining output."

newbd$married=dplyr::recode(newbd$married, YES="married=YES", NO="married=NO")
newbd$car=dplyr::recode(newbd$car, YES="car=YES", NO="car=NO")
newbd$save_act=dplyr::recode(newbd$save_act, YES="save_act=YES", NO="save_act=NO")
newbd$current_act=dplyr::recode(newbd$current_act, YES="current_act=YES", NO="current_act=NO")
newbd$mortgage=dplyr::recode(newbd$mortgage, YES="mortgage=YES", NO="mortgage=NO")
newbd$pep=dplyr::recode(newbd$pep, YES="pep=YES", NO="pep=NO")

# Visualize the data
plot(newbd$pep)

## Now load the transformed data into the apriori algorithm
# Based off of these defintions, it is assumed that the rarest and most valuable rules
# will be ones with a lift greater than 1. A lift of this magnitude represents a strong overlap/
# association between the LHS and RHS of the item-set. First pruning the dataset for strongly
# correlated rules, then filtering for most confident rules, and lastly the ones with the highest
# support should provide the strongest rules out of this dataset.

## Since the algorithm doesn't allow for filtering by lift initially, a high confidence and 
# low support are the initial parameters to bring in a large sum of rules
# Minimum number of items in the rule must be 3. R does not allow you to go over 10 items in an
# itemset to avoid running out of memory(Ref. https://www.rdocumentation.org/packages/arules/versions/1.6-3/topics/apriori)
# This wide scope allows for 843,180 rules to be generated and properly filterd based on the 
# business objective
myRules = apriori(newbd, parameter = list(supp = 0.001, conf = 0.9, minlen = 3))

# Sort rules by lift then confidence
sorted_rules<-sort(myRules, by=c("lift","confidence"), decreasing=TRUE)

# Show the top 30 rules, with only 3 sig figs
options(digits=3)
inspect(sorted_rules[1:30])


## While these rules have the highest lift; on closer inspection the support on these rules 
# is exceptionally small. Of these 30 rules the "count" of transactions that support
# this rule is never higher than 2. In a dataframe of 600 transactions, a rule based
# off 2 transactions is not significant enough to rely upon.
# ***INSERT EXAMPLE of one random rule****

## Since lift is an artifact of confidence; let's filter our rules by lift and support
# to provide rules based off a larger sample of the data
# Sort rules by lift then support
sorted_rules2<-sort(myRules, by=c("lift","support"), decreasing=TRUE)

# Show the top 30 rules, with only 3 sig figs
options(digits=3)
inspect(sorted_rules2[1:30])

# A high lift cannot be the initial parameter searched for. High lift automatically searches
# (...INSERT EXPLANATION HERE)

## Look at support then lift
sorted_rules3<-sort(myRules, by=c("support", "lift"), decreasing=TRUE)

# Show the top 30 rules, with only 3 sig figs
options(digits=3)
inspect(sorted_rules3[1:30])

## New hierarchy
# Confidence, support , and then lift

## Look at support then lift
sorted_rules4<-sort(myRules, by=c("confidence", "support", "lift"), decreasing=TRUE)

# Show the top 30 rules, with only 3 sig figs
options(digits=3)
inspect(sorted_rules4[1:30])

# Not as good
## Look at support then lift
sorted_rules5<-sort(myRules, by=c("support", "lift", "confidence" ), decreasing=TRUE)

# Show the top 30 rules, with only 3 sig figs
options(digits=3)
inspect(sorted_rules5[1:30])

# Heirarchy set!!


## Now that the heirarchy has been developed strong rules can are created focusing on the 
# desired right-hand side output (RHS) which is PEP or more succintly rather or not a 
# particular person will purchase a PEP

yesPEPrules<-apriori(data=newbd, parameter=list(supp=0.001,conf = 0.9, minlen=3), 
               appearance = list(default="lhs",rhs="pep=pep=YES"),
               control = list(verbose=F))

# Sort rules
yesPEPrules_sort <-sort(yesPEPrules, decreasing=TRUE,by=c("support", "lift", "confidence" ))

# Show the top 30 rules, with only 3 sig figs
options(digits=3)
inspect(yesPEPrules_sort[1:30])


# It appears that less is more. Even thou the algorithm has generated rules of up to 10-items
# it appears that rules of around 4-6 items yield the best rules. 
# Also, it appears that middle income parents with 1 child are extremely likely to take out 
# a PEP. The single child middle income combo accounts for 113 out of 600 transactions (~18%).
# Which is a small enough subgroup in the data to confidently say there is a nice correlation
# between both sides of this rule.
 
# View most interesting rules
inspect(yesPEPrules_sort[c(1,4,18,26,30)])

 