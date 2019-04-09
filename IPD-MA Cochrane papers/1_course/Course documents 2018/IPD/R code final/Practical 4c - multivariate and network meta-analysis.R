## Practical 4(c): Advanced multivariate & network meta-analysis

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 4")

## Install/load necessary packages
library(mvmeta)
library(foreign)
install.packages("multcomp")
library(multcomp)
install.packages("netmeta")
library(netmeta)

## To finish, let us consider two advanced examples: One with four outcomes 
# and then a network meta-analysis.

## Four outcomes multivariate meta-analysis
##

## Load the data 'SBP DBP Stroke CVD'.
library(readxl)
four.outcomes <- read_excel("four_outcomes.xls")
View(four.outcomes)

## This gives the treatment effect estimates, variances and within-study 
# correlations for each of these four outcomes from the 10 hypertension trials
# It is taken from:
# Riley RD, et al. Multivariate meta-analysis using individual participant 
# data. J Res Syn Methods 2015; 6: 157-174. doi: 10.1002/jrsm.1129.
# You should see the results for trial 1 are very close those you calculated
# in Practical 4a as the IPD you used was very similar to that for trial 1 here.
# Each Y in the dataset gives a treatment effect estimate.
# Y1 relates to SBP, y2 is DBP, Y5 is CVD, and Y6 is stroke.
# Y1 and Y2 are mean difference estimates; Y5 and Y6 are log HR estimates.
# Each V relates to a variance or a covariance.
# eg. V11 is the variance of Y1.
# eg. V15 is the covariance between Y1 and Y5.

## Let us apply a 4-outcome multivariate meta-analysis:
y <- as.matrix(four.outcomes[2:5])
S <- as.matrix(four.outcomes[6:15])
model.four.outcomes <- mvmeta(y, S)
print(summary(model.four.outcomes),digits=3)
## Note: the standard errors do not match those from Stata exactly because 
# R does not have the inflated standard error option. Ideally, we would
# want to use something like the Kenward-Roger ddf option.

## To get the results for 5 and 6 as HRs (rather than logHRs):
exp(model.four.outcomes$coefficients)

## Q1: Is the treatment beneficial for each of these outcomes on average?

## Q2 in the Stata practical is to determine the BoS value for each outcome.
# Unfortunately, we do not have the BoS built in to the R functions.

## A great advantage of these multivariate results is joint inferences.
# For example, let us work out the mean treatment effect on pulse pressure (PP),
# which is the difference in SBP and DBP. High PP is associated with increased
# risk of poor outcomes, so we want the treatment to reduce this.
# The pooled treatment effect on PP 
# = the pooled treatment effect on SBP - the pooled treatment effect on DBP.
# Post estimation, we can derive this using:
contr <- rbind("Y1 - Y2" = c(1, -1, 0, 0))
lincom <- glht(model.four.outcomes, linfct = contr)
lincom
confint(lincom)

## Q3: Does the treatment reduce PP more than control on average across studies?

## [NB: This calculation for PP appropriately accounts for the large positive
# correlation of the pooled estimates for SBP and DBP; recall from lectures
# this correlation is ignored when doing univariate meta-analysis.]

## Next, replace the value of V12 for the last trial (make it a .). 
# By doing this, we now have a situation where the within-study correlation 
# is unknown in the last trial. This is a common problem when IPD is unavailable.

S[10,2] <- NA
S
## Q4: If we run mvmeta again now, what happens?
model.four.outcomes <- mvmeta(y, S)

## There are many suggested approaches for dealing with this problem.
# We don't have time to cover this here, but please see details here:
# Riley RD.  Multivariate meta-analysis: the effect of ignoring 
# within-study correlation. JRSS (A) 2009; 172: 789-811.  
# The easiest option is to impute a value; e.g. we could assume the 
# missing correlation is the mean of the available correlations (about 0.59).

## [LEARNING POINT: When we have IPD, we can derive the within-study correlations
# ourselves as in Practical 4(a), and so avoid the issue of missing values.]

## Network meta-analysis using the multivariate meta-analysis framework
##

## To finish, let's get a flavour of a network meta-analysis that utilises the 
# multivariate modelling framework.

## Load the dataset 'thromb'.
thromb <- read_excel("thromb.xls")
View(thromb)

# This is the example used in the lecture. A network meta-analysis of 28 trials 
# to compare eight thrombolytic treatments after acute myocardial infarction: 
# outcome is mortality by 30-35 days.

# Please see:
# White IR et al. Consistency and inconsistency in network meta-analysis: 
# model estimation using multivariate meta-regression. 
# Res Synth Method. 2012;3: :111-25.

## In the data you will see that each study has two or more treatment groups, 
# denoted by A to H, and for each group we have r and n.
# r is the number of events and n is the number of individuals.

## First we need to prepare the data into the correct format for a network
# meta-analysis. As the outcome data is binary and we are not interested
# in covariates, we essentially have the IPD here for each study. Thus, we can 
# work out estimates, variances & within-study correlations directly.
# Even better, the "pairwise" function will convert the data for us.
net.data <- pairwise(treat, r, n, data = thromb, studlab = study, sm = "OR")
View(net.data)

## Let us use treatment A as the reference treatment.
## Under the consistency asumption, we can fit the network meta-analysis 
# and give us pooled estimates. There are many different ways to do this in R
# One approach is the approach of Rucker and Schwarzer, which uses graph theory, but is equivalent to ML estimation
net1 <- netmeta(TE, seTE,  treat1, treat2, sm = "OR", comb.random = TRUE, data=net.data)
net1

## Note: these results do not match those in Stata because ML rather than REML is used, and we do not have
# the inflation option to inflate the standard errors to account for uncertainty of variance estimates.
# But they are very similar

## If you just want to see the matrix with estimated overall treatment effects
treat.ests <- exp(net1$TE.random)
treat.ests
## To view the lower bounds of the 95% CI of the estimated overall effects
treat.ests.lower <- exp(net1$lower.random)
treat.ests.lower
## To view the upper bounds of the 95% CI of the estimated overall effects
treat.ests.upper <- exp(net1$upper.random)
treat.ests.upper

## Q5: Check you understand the results presented. For example, what is the
# treatment effect for B versus A?  And for C versus A?

## Q6: Notice that we only get one estimated between-study heterogeneity. tau^2 = 0;
# What assumptions were made about the between-study variances & covariances
# when fitting this model?  Why do you think this was done?


## Q7: What is the treatment effect estimate of B versus C?

## For those interested, we can plot the estimated overall treatment effects
# on a forest plot.
forest(net1)

## We can look at the p-value for the test of heterogeneity / inconsistency
# in the network
net1$pval.Q

# We can also rank treatments; netmeta gives the p score
# The P-score of treatment i can be interpreted as the mean extent of certainty that treatment i is better
# than another treatment. This interpretation is comparable to that of the Surface Under the Cumulative
# RAnking curve (SUCRA)
rank<-netrank(net1, small.values="good")
rank
# As mentioned in the lecture, treatment G has highest probability of being 1st
# But also high probability of being ranked last!
 # Highest mean rank (and thus SUCRA) is for treatments B and E


