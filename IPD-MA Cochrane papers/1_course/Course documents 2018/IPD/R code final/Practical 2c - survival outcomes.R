## PRACTICAL 2(c) - One-stage IPD meta-analysis of RCTs with a survival outcome *

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 2")

# First, let's install/load some packages
library(survival)
library(survminer)
library(dplyr)
install.packages("coxme")
library(coxme)

## We have so far looked at a binary outcome and then a continuous outcome.

## Load the dataset 'survivalIPD', which contains 15 simulated hypertension
# trials with a time-to-event outcome (death)
library(readxl)
survIPD <- read_excel("SurvivalIPD.xls")
View(survIPD)
# 'stime' gives the patients time  to death or end of follow-up.
# treat = 1 when the patient had hypertension treatment.
# REF: Crowther, M. J. (2014) STMIXED: Stata module to fit multilevel
# mixed effects parametric survival models.

## So, as in practical 1c, the question is:
# Does hypertension treatment reduce the mortality rate?

## Declare the data to be survival data 
surv_object <- Surv(survIPD$stime, survIPD$event)
surv_object 

## Generate a dummy variable for each trial.
survIPD$trial1 <- ifelse(survIPD$trial == 1, 1, 0)
survIPD$trial2 <- ifelse(survIPD$trial == 2, 1, 0)
survIPD$trial3 <- ifelse(survIPD$trial == 3, 1, 0)
survIPD$trial4 <- ifelse(survIPD$trial == 4, 1, 0)
survIPD$trial5 <- ifelse(survIPD$trial == 5, 1, 0)
survIPD$trial6 <- ifelse(survIPD$trial == 6, 1, 0)
survIPD$trial7 <- ifelse(survIPD$trial == 7, 1, 0)
survIPD$trial8 <- ifelse(survIPD$trial == 8, 1, 0)
survIPD$trial9 <- ifelse(survIPD$trial == 9, 1, 0)
survIPD$trial10 <- ifelse(survIPD$trial == 10, 1, 0)
survIPD$trial11 <- ifelse(survIPD$trial == 11, 1, 0)
survIPD$trial12 <- ifelse(survIPD$trial == 12, 1, 0)
survIPD$trial13 <- ifelse(survIPD$trial == 13, 1, 0)
survIPD$trial14 <- ifelse(survIPD$trial == 14, 1, 0)
survIPD$trial15 <- ifelse(survIPD$trial == 15, 1, 0)

## Or define variable 'trial' to be a factor variable
survIPD$trial.f <- factor(survIPD$trial)
is.factor(survIPD$trial.f)

## One-stage fixed effect approach
##
  
## Fit the naive fixed effect model ignoring clustering
cox.naive <- coxph(surv_object ~ treat, data = survIPD, ties = c("breslow"))
cox.naive

## Q1: Write down the fitted model. Is hypertension treatment effective?
  
## Now fit the following fixed effect model that accounts for clustering:
cox.fix.clustered <- coxph(surv_object ~ treat + trial.f,
                           data = survIPD, ties = c("breslow"))
cox.fix.clustered

## Q2: Write down the model. What does the model assume about the baseline
# hazard functions of the trials?
  
## Q3: Why is trial1 'omitted' from the results?
  
## Q4: Do the results still suggest hypertension treatment remains effective?
  
## A stronger assumption is to assume the baseline hazards are
# proportional to each other (as above) AND that they come from 
# a shared distribution
cox.shared <- coxme(surv_object ~ treat + (1 | trial), data = survIPD, ties = c("breslow"))
cox.shared

## But there is no need to be so restrictive. To allow a completely separate
# baseline hazard shape in each trial, we can fit:
cox.strata <- coxph(surv_object ~ strata(trial.f) + treat,
                    data = survIPD, ties = c("breslow"))
cox.strata

## In this example, the results are very similar to the previous models though

## One-stage random effects approach
##

## The above models all assumed the treatment effect was fixed.
# To fit a random effect on the treatment effect is difficult for survival
# models; software is only recently becoming available to do this. 
# R is perhaps ahead of other software in this respect.

## Fit a model with fixed separate trial effects and a random treatment effect:
cox.rand.clustered <- coxme(surv_object ~ treat + (treat | trial) + trial.f,
                            data = survIPD, ties = c("breslow"))
cox.rand.clustered

## Q5: Is there heterogeneity in the treatment effect? How does the estimate 
# of tau compare to that from the previous two-stage model using ML?
# The two-stage model estimate of tau is 0.621.

## Q6: Is hypertension treatment still effective according to the results?
  
## Recall that ML estimates are downwardly biased, especially when there are
# large numbers of parameters and small number of studies. 
# So sensitivity analysis is helpful,  using a random intercept model 
# to reduce the number of parameters, rather than a stratified intercept model.

cox.rand.shared <- coxme(surv_object ~ treat + (1 + treat | trial),
                            data = survIPD, ties = c("breslow"))
cox.rand.shared

## The results are very similar to before.
## Parametric approaches are alternative approaches to random effects survival models
