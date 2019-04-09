## Practical 2b : one-stage IPD meta-analysis 
##    of a continuous outcome

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 2")

# First, let's install/load some packages
library('lme4')
#install.packages('pbkrtest')
#library('pbkrtest')
install.packages('lmerTest')
library('lmerTest')

## Load the dataset "SBP"
library(readxl)
SBP <- read_excel("SBP.xls")
View(SBP)

## This is simulated data, based on the hypertension trials discussed in the 
# lectures. There are 10 trials of hypertension treatment, aiming to lower
# systolic blood pressure (SBP) and a total of 27903 patients - very large! 
# Please only use this data for educational purposes.

## One-stage IPD meta-analysis 
##

## We will use the ANCOVA approach to adjust for baseline blood pressure.

## First create a dummy variable for each study.
SBP$study1 <- ifelse(SBP$trialdummy == 1, 1, 0)
SBP$study2 <- ifelse(SBP$trialdummy == 2, 1, 0)
SBP$study3 <- ifelse(SBP$trialdummy == 3, 1, 0)
SBP$study4 <- ifelse(SBP$trialdummy == 4, 1, 0)
SBP$study5 <- ifelse(SBP$trialdummy == 5, 1, 0)
SBP$study6 <- ifelse(SBP$trialdummy == 6, 1, 0)
SBP$study7 <- ifelse(SBP$trialdummy == 7, 1, 0)
SBP$study8 <- ifelse(SBP$trialdummy == 8, 1, 0)
SBP$study9 <- ifelse(SBP$trialdummy == 9, 1, 0)
SBP$study10 <- ifelse(SBP$trialdummy == 10, 1, 0)

## Now fit, using ML, an ANCOVA IPD fixed effect meta-analysis model, with a
# separate intercept for each study.
ancova.strat <- glm(sbpl ~ sbpi + treat + study1 + study2 + study3 + study4
           + study5 + study6 + study7 + study8 + study9
           + study10 - 1, data = SBP, 
           family = gaussian(link = "identity"))
summary(ancova.strat)

## Q1: Write down the model. Based on the results, does hypertension 
# treatment appear effective?

## The trials were done in different populations with different
# anti-hypertensive drugs. Thus, let us allow for heterogeneity 
# in the treatment effect using a random effects ANCOVA model using REML,
# again with a separate intercept for each study.
ancova.strat.rand <- lmer(sbpl ~ sbpi + treat + study1 + study2 + study3 + study4
           + study5 + study6 + study7 + study8 + study9
           + study10 - 1 + (treat -1 | trialdummy), data = SBP)

summary(ancova.strat.rand)


## Q2: Write down the model. Based on the results is there between-study
# heterogeneity in treatment effect? Have conclusions about treatment
# effect changed?
  
## Q3: How do these results compare to your random effects two-stage results 
# with REML estimation?
  
## Note that the previous models were actually assuming the same effect 
# of the baseline SBPi in each study. Similarly, it assumed the same residual 
# variance for each study. This are strong assumptions and may not be necessary.

# We can't estimate a separate residual variance per study using the lme4 module
# try nlme (which contains lme)

install.packages('nlme')
library(nlme)

## It also helps to tell R that trialdummy is a factor variable

## Check the class of the trial variable
class(SBP$trialdummy)
## Change to factor 
SBP$trialdummy <-as.factor(SBP$trialdummy)

## This allows us to include trialdummy directly, and have separate intercept terms per study

## Random effects on baseline SBPi and treatment AND separate resid vars by using the 
# weights option; unlike Stata this works very quickly 
ipdresults1 <- lme(sbpl ~ 0 + trialdummy + sbpi + treat, random = ~ 0 + sbpi + treat | trialdummy, 
                 weights = varIdent(form = ~1 | trialdummy), control = ctrl, data = SBP, 
                 na.action = na.omit, method = "REML")
# (takes about 30 seconds)
summary(ipdresults1)


# This automatically including correlation of the 2 random effects - we can remove this
ipdresults2<-lme(sbpl~ 0+trialdummy+sbpi +treat , random=list(trialdummy=~0+sbpi, trialdummy=~0+treat),
                 weights=varIdent(form=~1|trialdummy), control = ctrl, data = SBP, na.action = na.omit, method = "REML")
summary(ipdresults2)

# We could also put separate  terms in for sbpi and avoid assuming they are random; takes 30 seconds
ipdresults3<-lme(sbpl~ 0+trialdummy+ trialdummy*sbpi + treat, random=~0+treat|trialdummy, 
                 weights=varIdent(form=~1|trialdummy), control = ctrl, data = SBP, na.action = na.omit, method="REML")
summary(ipdresults3)

# And we could also add a random effect on study intercepts etc. Lots of different permutations, but results for treatment effect are very stable

# Unfortunately the Kenward Roger option to inflate CIs does not work with lme, as far as we can tell

###