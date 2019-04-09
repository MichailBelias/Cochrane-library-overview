## PRACTICAL 1(c) - Two-stage IPD meta-analysis of RCTs with a survival outcome *

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 1")

# We have so far looked at a binary outcome and then a continuous outcome.

# Open the dataset 'survivalIPD', which contains 15 simulated hypertension 
# trials with a time-to-event outcome (death).
library(readxl)
survIPD <- read_excel("SurvivalIPD.xls")
View(survIPD)

# 'stime' gives the patients time  to death or end of follow-up.
# treat = 1 when the patient had hypertension treatment.

# REF: Crowther, M. J. (2014) STMIXED: Stata module to fit multilevel
# mixed effects parametric survival models.

## So, the question is: does hypertension treatment reduce the mortality rate?

# First, let's install/load some packages
install.packages("survival")
install.packages("survminer")
library(survival)
library(survminer)
library(dplyr)
library(meta)

## Declare the data to be survival data *
surv_object <- Surv(survIPD$stime, survIPD$event)
surv_object 

## Two-stage meta-analysis
# As mentioned in the continuous outcomes practical 1b, there is no R equivalent
# of Stata's "ipdmetan" package. Therefore, for the first stage,
# we need to estimate the hazard ratios and their standard errors in each trial 
# separately with a Cox PH model.
# For example, here is the code to estimate the hazard ratio in the first trial:
fit_coxph1 <- coxph(surv_object ~ treat, data = survIPD, subset=(survIPD$trial == 1))
summary(fit_coxph1)
# Trial 2:
fit_coxph2 <- coxph(surv_object ~ treat, data = survIPD, subset=(survIPD$trial == 2))
summary(fit_coxph2)
# and so on for the 15 trials...

# Then we can save the log hazard ratios and their standard errors to use in 
# the second stage of a two-stage IPD meta-analysis.

## To save you time, we have created a dataset with the first stage estimates
summ_surv <- read_excel("surv_summary.xls")
View(summ_surv)

## Now, use a random-effect meta-analysis approach to synthesise the estimates
## First use a DL estimator
surv.ran.dl <- metagen(loghr, seloghr, trial, data = summ_surv,
                       sm = "hr", method.tau = "DL")
summary(surv.ran.dl)

# Next use an ML estimator
surv.ran.ml <- metagen(loghr, seloghr, trial, data = summ_surv,
                       sm = "hr", method.tau = "ML")
surv.ran.ml

# Next use a REML estimator
surv.ran.reml <- metagen(loghr, seloghr, trial, data = summ_surv,
                       sm = "hr", method.tau = "REML")
surv.ran.reml

## Q1: How does the estimate of tau change when using DL, ML and REML?

## Q2: Based on the REML analysis, is hypertension treatment effective?

## The random effects model using DL estimator
# with Hartung-Knapp-Sidik-Jonkman CI for pooled estimate:
surv.ran.dl.hksj <- metagen(loghr, seloghr, trial, data = summ_surv,
                       sm = "hr", method.tau = "DL", hakn = TRUE)
summary(surv.ran.dl.hksj)

# and with REML:
surv.ran.reml.hksj <- metagen(loghr, seloghr, trial, data = summ_surv,
                            sm = "hr", method.tau = "REML", hakn = TRUE)
summary(surv.ran.reml.hksj)

## Q3: How have the CIs for the pooled estimates changed compared to the previous 
# model with REML estimation? Have your conclusions changed?


