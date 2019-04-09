## Practical 1b : two-stage IPD meta-analysis 
##    with a continuous outcome

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 1")

# Necessary packages
library(meta)
library(metafor)

## Import the dataset "SBP"
library(readxl)
SBP <- read_excel("SBP.xls")
View(SBP)

## This is simulated (not real!) data, based on real hypertension trials 
# discussed in the lectures. There are 10 trials of hypertension treatment, 
# aiming to lower systolic blood pressure (SBP) and a total of 27903 patients  
# PLEASE ONLY USE THIS DATA FOR EDUCATIONAL PURPOSES 

## Exploration of the data
# Compare the baseline SBP (SBPi) across treatment (treat = 1) and control 
# groups (treat = 0) at the individual study level 
mean(subset(SBP, trialdummy == 1 & treat == 1)$sbpi)
mean(subset(SBP, trialdummy == 1 & treat == 0)$sbpi)

mean(subset(SBP, trialdummy == 2 & treat == 1)$sbpi)
mean(subset(SBP, trialdummy == 2 & treat == 0)$sbpi)

mean(subset(SBP, trialdummy == 3 & treat == 1)$sbpi)
mean(subset(SBP, trialdummy == 3 & treat == 0)$sbpi)

mean(subset(SBP, trialdummy == 4 & treat == 1)$sbpi)
mean(subset(SBP, trialdummy == 4 & treat == 0)$sbpi)

mean(subset(SBP, trialdummy == 5 & treat == 1)$sbpi)
mean(subset(SBP, trialdummy == 5 & treat == 0)$sbpi)

mean(subset(SBP, trialdummy == 6 & treat == 1)$sbpi)
mean(subset(SBP, trialdummy == 6 & treat == 0)$sbpi)

...

## Q1: What do you notice about some trials in terms of baseline balance 
# in the initial SBP value in each group?
  
## For just trial 1, under the following 3 types of analysis, compare effect 
# of treatment (i.e. treatment group - placebo) on:
# (i) Final SBP (the "sbpl" variable), under an ANCOVA model, adjusting for 
# initial SBP (the "sbpi" variable);
# (ii) Final SBP (the "sbpl" variable), under an ANOVA model (i.e. no baseline
# SBP adjustment in this model);
# (iii) Change in SBP (the "diff" variable), under an ANOVA model.

# ANCOVA
ancova <- glm(sbpl ~ sbpi + treat, subset(SBP, trialdummy==1), 
           family = gaussian(link = "identity"))
summary(ancova)
# Final score
final <- glm(sbpl ~ treat, subset(SBP, trialdummy==1), 
           family = gaussian(link = "identity"))
summary(final)
# Change score
change <- glm(diff ~ treat, subset(SBP, trialdummy==1), 
           family = gaussian(link = "identity"))
summary(change)

## Q2: How do the effect estimates compare? Which has the smaller standard 
# errors? Which method is more reliable?
  
## LEARNING POINT: Please see the following reference for more on why ANCOVA 
# is preferred: Vickers AJ, Altman DG. Statistics notes: Analysing controlled 
# trials with baseline and follow up measurements. BMJ 2001; 323: 1123-1124.

### Two-stage IPD meta-analysis of the 10 trials
###
  
# There is no equivalent in R for the "ipdmetan" package in Stata to do the
# first and second stages together. But for learning purposes now, we want 
# you to understand the aggregate data going into the second stage.

## Load the file 'SBP_summary'
SBP_summary <- read_excel("SBP_summary.xls")
View(SBP_summary)

## This already contains the treatment effect estimates and their standard
# errors for each hypertension study (to save you time).
# Treatment effect estimates are given based on ANCOVA, change score
# and final score.

# Perform a random effects meta-analysis of the ANCOVA results for each study, 
# using DL estimation. NB. This automatically allows a separate residual 
# variance and baseline response (i.e. mean placebo response) in each study, 
# as the treatment effect was estimated separately for each study.

## Now let's apply a random effects meta-analysis with methods of moments
# estimation (DerSimonian and Laird).
rand.dl <- metagen(ancova, seancova, trial, data = SBP_summary,
                       sm = "MD", method.tau = "DL")
rand.dl

## To produce a forest plot:
forest.ran.dl <- forest(rand.dl, comb.fixed = FALSE,
                     label.left = "Favours experimental",
                     label.right = "Favours control",
                     col.label.right = "green", 
                     col.label.left = "red",
                     prediction = FALSE,
                     leftlabs = c("trial", "ancova", "seancova"))

## Q3: Based on the results, does hypertension treatment appear effective?
  
## Q4: Based on the results, is there between-study heterogeneity in the 
# treatment effect?
  
# Generally we prefer using REML estimation.
rand.reml <- metagen(ancova, seancova, trial, data = SBP_summary,
                       sm = "MD", method.tau = "REML")
rand.reml

## This gives tau-squared = 7.4, but the DL method gave tau-squared = 3.3
# This difference is quite scary! There is ongoing work to resolve
# which is the best method. Therefore it is best to be transparent, and report 
# a primary analysis estimation choice in the protocol, and the impact of other 
# estimation methods in the report too.

# Let us also include the Hartung-Knapp confidence interval
meta.ran.reml.hk <- metagen(ancova, seancova, trial, data = SBP_summary,
                            sm = "MD", method.tau = "REML", hakn = TRUE)
meta.ran.reml.hk

## The 95% CI is suitable wider, as it accounts for uncertainty in tau-squared.

# Finally, now let us repeat the DL two-stage analysis, and additionally
# calculate a 95% prediction interval.
rand.dl.pred <- metagen(ancova, seancova, trial, data = SBP_summary,
                            sm = "MD", method.tau = "DL", prediction = TRUE)
rand.dl.pred

## Q5: What does the 95% prediction interval tell us about the potential 
# treatment effect in a new study population?
  
## LEARNING POINT: In comparison to Practical 1(a), the prediction interval 
# here is more helpful. We have 10 studies, so less uncertainty in our 
# heterogeneity estimate. And all the studies show effect of treatment in the 
# same direction, despite the considerable heterogeneity. This helps us 
# summarise the distribution of effectiveness of anti-hypertension treatment.

## NB. When REML is used instead of DL, the upper and lower bounds of the 
# prediction interval are wider (due to the larger tau-squared), but still both
# fall well below zero.
