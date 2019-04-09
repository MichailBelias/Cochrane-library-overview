## Practical 1a : two-stage IPD meta-analysis 
##    with a binary outcome

# Set your working directory to a relevant location. For example, mine is:
setwd("C:/Work/IPD course/R datasets/Practical 1")

## Import the dataset "eryt"
library(readxl)
eryt <- read_excel("eryt.xls")
View(eryt)

## 3 IPD studies: patients either have or do not have a deep vein thrombosis 
# (DVT). 'eryt' is Erythema : redness of the skin, caused by hyperemia of the
# capillaries in the lower layers of the skin. 

# Research question:  Does presence of 'eryt' increase the risk of having a DVT?
  
# So 3 observational studies
# NB please only use the data for educational purposes
  
# Let's now do a two-stage IPD meta-analysis

# First-stage is to generate the aggregate data in each study.
# So we must calculate the log odds ratio estimates and their standard errors
# in each study separately, using a logistic regression in each study.
# Study 1
lr1 <- glm(dvt ~ eryt, subset(eryt, studyid==1), 
           family = binomial(link = "logit"))
summary(lr1)
exp(lr1$coefficients)

# Study 2
lr2 <- glm(dvt ~ eryt, subset(eryt, studyid==2), 
           family = binomial(link = "logit"))
summary(lr2)
exp(lr2$coefficients)

# Study 3
lr3 <- glm(dvt ~ eryt, subset(eryt, studyid==3), 
           family = binomial(link = "logit"))
summary(lr3)
exp(lr3$coefficients)

## We must now transfer across the logOR estimates 
# and standard errors for each study to form a new dataset.
# We already did this for you to save time.
  
## Import the dataset "eryt_summary"
# This contains 3 variables: studyid, logor, and se
# These are study number, the log odds ratio estimate and its standard error
eryt_summary <- read_excel("eryt_summary.xls")
View(eryt_summary)

## We can now pool the aggregate data using a fixed effect or random effects model
## Install packages "meta" and "metafor"
install.packages("meta")
install.packages("metafor")
library(meta)
library(metafor)

## Now let us apply a random effects meta-analysis to the aggregate data.
# There are many estimation options; first let's use ML estimation.
meta.ran.ml <- metagen(logor, se, studyid, data = eryt_summary,
                       sm = "OR", method.tau = "ML")
meta.ran.ml

## now let's apply a random effects meta-analysis with methods of moments
# estimation (DerSimonian and Laird)
meta.ran.dl <- metagen(logor, se, studyid, data = eryt_summary,
                       sm = "OR", method.tau = "DL")
meta.ran.dl

## finally let's use REML estimation
meta.ran.reml <- metagen(logor, se, studyid, data = eryt_summary,
                         sm = "OR", method.tau = "REML")
meta.ran.reml

## Q1: What do you notice about the between-study variance estimate 
# (tau-squared) when using ML, DL, and REML? 
# What impact does this have on the pooled OR and its 95% CI?

## LEARNING NOTE FOR DISCUSSION: there are few studies here, and so the choice
# of estimation method for tau has a big impact in the two-stage analysis.

## ML variance estimates are usually downwardly biased, and tau-squared is likely
# too small for the ML approach; this leads to overly narrow CIs 
# for the pooled effect using ML here.

## REML or DL is preferred

## Note that, we have not accounted for the uncertainty in the tau-squared 
# estimates when deriving our CIs.

## We might use the profile likelihood option to account for
# uncertainty in tau-squared when deriving the CIs. We can do that using metaplus
install.packages("metaplus")
library(metaplus)
result <- metaplus(logor, se, slab = studyid, data = eryt_summary)
summary(result)


## We recommend DL or REML with the Hartung-Knapp method for CI derivation
meta.ran.dl.hk <- metagen(logor, se, studyid, data = eryt_summary,
                       sm = "OR", method.tau = "DL", hakn = TRUE)
meta.ran.dl.hk

meta.ran.reml.hk <- metagen(logor, se, studyid, data = eryt_summary,
                          sm = "OR", method.tau = "REML", hakn = TRUE)
meta.ran.reml.hk

## All the above estimation methods focus on obtaining a pooled (summary) effect

# Following random effects meta-analyses, Higgins et al. argue that a 
# prediction interval is the most complete summary of the data
# Let's calculate an approximate 95% prediction interval for the odds ratio 
# following DL estimation:
meta.ran.dl.pred <- metagen(logor, se, studyid, data = eryt_summary,
                            sm = "OR", method.tau = "DL", prediction = TRUE)
meta.ran.dl.pred

## Q2: What do you make of the prediction interval? Why is it so wide?

## LEARNING NOTE: with 3 studies, it really is not sensible to calculate a 
# prediction interval. We suggest it is best when there are 7 or more studies.

## There is no equivalent package for David Fisher's Stata package, "ipdmetan",
# in R.

## Forest plots do not get produced automatically
# in the "meta" package in R. Here is some example
# code for how to do it using the random-effects
# meta-analysis with DL estimation and prediction
# interval.
for.ran.dl <- forest(meta.ran.dl.pred, comb.fixed = FALSE, label.left = "Favours control", 
                     label.right = "Favours experimental", col.label.right = "green", col.label.left = "red", prediction = TRUE,
                     xlim = c(0.01, 304.5), leftlabs = c("studyID", "logOR", "se"))




########################################################################
## It is possible to use other meta-analysis packages, such as "metafor"
# for most of this work. Some example code below:
install.packages("metafor")
library(metafor)
fix <- rma.uni(logor, se, data = eryt_summary, 
               method = "FE")
fix

ran.ml <- rma.uni(logor, se, data = eryt_summary, method = "ML",
                  measure = "OR")
ran.ml
## Now exponentiate the logOR
exp(ran.ml$beta) ## this OR is higher than that from Stata

ran.dl <- rma.uni(logor, se, data = eryt_summary, method = "DL",
                  measure = "OR")
ran.dl
exp(ran.dl$beta)

ran.reml <- rma.uni(logor, se, data = eryt_summary, method = "REML",
                  measure = "OR")
ran.reml
exp(ran.reml$beta)

## We recommend DL or REML with the Hartung-Knapp method for CI derivation
ran.dl.hk <- rma.uni(logor, se, data = eryt_summary, method = "DL",
                     knha = TRUE, measure = "OR")
ran.dl.hk
exp(ran.dl.hk$beta)

ran.reml.hk <- rma.uni(logor, se, data = eryt_summary, method = "REML",
                    knha = TRUE, measure = "OR")
ran.reml.hk
exp(ran.reml.hk$beta)

