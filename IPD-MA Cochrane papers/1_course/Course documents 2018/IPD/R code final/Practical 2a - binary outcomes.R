## Practical 2a : one-stage IPD meta-analysis 
##    with a binary outcome

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 2")

# First, let's install/load some packages
install.packages("lme4")
library(lme4)

## Import the dataset "eryt"
library(readxl)
eryt <- read_excel("eryt.xls")
View(eryt)

## This is re-created IPD, based on the summary 2 by 2 data for the 3 DVT 
# studies discussed in the lecture 3.
# 3 IPD studies: patients either have or do not have a deep vein thrombosis 
# (DVT). 'eryt' is Erythema : redness of the skin, caused by hyperemia of the
# capillaries in the lower layers of the skin. 

## Research question is the same question as practical la: 
# Does presence of 'eryt' increase the risk of having a DVT?
# NB. please only use the data for educational purposes 
  
## One-stage analysis ignoring clustering *
one.ignore <- glm(dvt ~ eryt, data = eryt, 
           family = binomial(link = "logit"))
summary(one.ignore)
exp(one.ignore$coefficients)

## Q1(a): Write down the model being fitted here
## Q1(b): Based on the results, what is the conclusion about eryt: 
# is it a risk factor? *
  
## One-stage fixed effect IPD meta-analysis that does account for clustering

## We will need a separate intercept per study. Thus, first let us create a dummy
# variable for each study (=1 if in that study, and 0 otherwise)
eryt$study1 <- ifelse(eryt$studyid == 1, 1, 0)
eryt$study2 <- ifelse(eryt$studyid == 2, 1, 0)
eryt$study3 <- ifelse(eryt$studyid == 3, 1, 0)

## Use ML to fit the one-stage fixed effect meta-analysis 
# let's first use a stratified intercept approach
# i.e. estimate a separate intercept per study
one.strat <- glm(dvt ~ eryt + study1 + study2 + study3 -1, data = eryt, 
           family = binomial(link = "logit"))
summary(one.strat)
exp(one.strat$coefficients)

## Q2: write down the new model. Based on the results, what is the new 
# conclusion about eryt: is it a risk factor?
  
## Q3: compare your results to those when ignoring clustering from Q1(b). 
# How are they different? Can you explain why? 
# (hint: consider the prevalence of DVT in the three studies)
dvt.prev <- table(eryt$studyid, eryt$dvt)
dvt.prev

## One-stage random effects IPD meta-analysis that does account for clustering

## Let's now extend the previous analysis to allow for potential
# between-study heterogeneity in the effect of eryt 
# Use ML to fit the following random effects model
one.strat.rand <- glmer(dvt ~ eryt + study1 + study2 + study3 + (eryt -1 | studyid) -1, data = eryt, 
               family = binomial)
summary(one.strat.rand)

## Q4: Write down the model. Based on the results, is there evidence of 
# between-study heterogeneity in the effect of eryt? *
  
## Q5: Compare the pooled OR from the random effects and fixed effect models 
# - can you explain why they are identical?
  
## Q6: How do meta-analysis results compare with those from the two-stage
# approach using the same estimation method of ML?
# From two-stage r-e analysis using ML:
# OR = 1.351 95% CI (1.029 to 1.773), I2-hat=0.

## LEARNING NOTE FOR DISCUSSION FROM PRACTICAL 1: there are few studies here, 
# and so the choice of estimation method for tau has a big impact in the 
# two-stage analysis. ML estimates are potentially downwardly biased, and so 
# the ML estimates from one-stage approach, or two-stage with ML estimation 
# in the second stage may be producing too small taus; therefore we may be 
# obtaining too narrow CIs for the pooled effect using ML here.

## So should we be using the two-stage approach with REML (or DL) to improve 
# estimation, rather than one-stage with ML? 
# Given the studies are reasonably sized, and there are no zero events, 
# it is plausible to believe the log odds ratio are approx. normally distributed
# from each study.
# Therefore, the exact binomial approach in the one-stage analysis may not
# be needed, and two-stage with REML (and Hartung-Knapp) may be preferable.

## One way to reduce bias in ML estimates of tau-squared is to reduce the
# number of parameters in the model.
# We could do this by using a random (rather than stratified) intercept.
one.randint.rand <- glmer(dvt ~  eryt + (1 + eryt || studyid) , data = eryt, 
               family = binomial)
summary(one.randint.rand)
## We need to use the double bar notation above to specify uncorrelated random 
# effects (uncorrelated intercept and slope).

## This now identifies potential heterogeneity (though not as much as REML in 2-stage)
# tau-squared is 0.020 (REMl gave 0.15).

## LEARNING POINT - estimation of between-study variances is a complex issue.
# For binary outcomes, we want to use a 1-stage to model exact likelihood,
# but with ML estimation, we have problems of poor estimation.
# Therefore, a 2-stage (approximate) approach using REML may actually do better.
# One could adopt a Bayesian 1-stage approach, to account for full uncertainty 
# and maintain exact modelling, but this requires prior distributions.

## KEY MESSAGE: Sensitivity analyses to the choice of estimation method may be
# important. Doing both 1-stage and 2-stage is highly sensible, and then 
# try to understand the reasons for any differences.
