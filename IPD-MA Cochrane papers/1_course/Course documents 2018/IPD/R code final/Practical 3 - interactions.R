## Practical 3 - IPD meta-analysis of a continuous outcome: interest in 
# treatment-covariate interaction.

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 3")


# First, let's install/load some packages
library(meta)
library(metafor)
library('lme4')

## There are 10 trials of hypertension treatment, aiming to lower systolic 
# blood pressure (SBP) with a total of 27903 patients - very large, thus
# increasing power to detect genuine modifiers of treatment effect.

## Non-IPD approach: meta-regression
##
  
## Load the dataset "SBP_summary"
library(readxl)
SBP_summ <- read_excel("SBP_summary.xls")
View(SBP_summ)

# This contains the treatment effect estimates and their standard errors 
# for each study. This is the same aggregate data you analysed in practical 1b
# in the 2nd stage of the two-stage IPD meta-analysis. This is based on 
# simulated data, so please only use for educational purposes.
# Recall we have here the study treatment effect estimates either from
# ancova, change score, or final score analyses.

## You will see that the proportion male in each study is also available in the 
# dataset (prop_male). Without IPD, researchers may look across studies to see 
# if the proportion male (prop_male) is associated with the treatment effect. 
# They could only do this by using meta-regression. Let us do this.

## Let us do a meta-regression of the ancova treatment effect estimates.
SBP_summ$varancova <- SBP_summ$seancova*SBP_summ$seancova

meta.reg <- rma.uni(ancova, varancova, mods = prop_male, data = SBP_summ, 
                    method = "REML", knha=TRUE)
meta.reg

## Q1: Write down the model. What does the result suggest about the association 
# between the proportion male in the study and the treatment effect?

## LEARNING POINT:  the result is what I refer to as an 'across-trials 
# association'. It explains between-study variation. The estimate of tau-squared
# is smaller when prop_male is included, than when it is excluded. Check this 
# by fitting the following:
ancova.reml <- rma.uni(ancova, varancova, data = SBP_summ, method = "REML",
                       knha=TRUE)
ancova.reml

## Q2: How does the tau-squared estimate obtained compare to the previous 
# model in Q1?

## One-stage IPD approach 
##
  
## With IPD, we can observe patient-level interactions more clearly.
# In other words, we can explain patient-level variation (residual variance), 
# rather than study-level variation (tau-squared).

## Use the 'SBP' data again (the full IPD) and create a dummy variable 
# for each trial.
SBP <- read_excel("SBP.xls")
head(SBP, n=10)
View(SBP)

SBP$trialdummy.f <- factor(SBP$trialdummy)
is.factor(SBP$trialdummy.f)

## Let us fit a one-stage ANCOVA IPD random effects model, with separate 
# intercept for each study, now with an interaction term. There are diferent 
# ways to specify the interaction term.

## Note that for simplicity (initially) we do not allow for separate baseline adjustment terms
# in each trial, and this is not ideal. But please do not focus on 
# this issue for now; just focus on the interaction.
model.int <- lmer(sbpl ~ sbpi + treat*sex + trialdummy.f - 1 + 
                    (treat -1 | trialdummy), data = SBP)
summary(model.int)

## Q3: Write down the model. What is the conclusion about the difference in 
# treatment effect for males and females? Is the conclusion different from
# the meta-regression?
  
## LEARNING POINTS: Also consider here the magnitude of the interaction estimate, 
# in terms of clinical relevance - do not just focus on the p-value.

## Separation of within-trial and across-trial interactions
##
  
## The one-stage analysis could be misleading, because our specification of the 
# interaction can explain both within-study and between-study variation. We can 
# already see the huge difference between the across-trial interaction from 
# the meta-regression and the pooled interaction from the model above. However,
# in the one-stage model above, the across-trial interaction 
# (i.e. meta-regression result) is still contributing to the pooled interaction,
# as we have not separated out the ecological bias.

# In the lectures, we discussed the need to separate out interactions by
# centering covariates. Let us calculate a new sex variable, centred by the 
# proportion male in each study.

# You can see the proportion male using:
tab <- table(SBP$trialdummy, SBP$sex)
tab
p.tab <- prop.table(tab, margin = 1)
p.tab
dframe <- data.frame(values = rownames(tab), prop = p.tab[,2],
                     count = tab[,2])
dframe

## Now create the centred sex variable:
SBP$sex.cent <- SBP$sex - 0.7
SBP$sex.cent <- ifelse(SBP$trialdummy == 2, SBP$sex - 0.35, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 3, SBP$sex - 0.24, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 4, SBP$sex - 0.55, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 5, SBP$sex - 0.59, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 6, SBP$sex - 0.42, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 7, SBP$sex - 0.43, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 8, SBP$sex - 0.26, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 9, SBP$sex - 0.64, SBP$sex.cent)
SBP$sex.cent <- ifelse(SBP$trialdummy == 10, SBP$sex - 0.33, SBP$sex.cent)

## Specify a new within-trial interaction with treatment for this variable
SBP$ws.interaction <- SBP$treat*SBP$sex.cent

## Now specify the proportion male in each study 
# (the same for each patient in a trial)
SBP$sex.mean <- 0.7
SBP$sex.mean <- ifelse(SBP$trialdummy == 2, 0.35, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 3, 0.24, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 4, 0.55, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 5, 0.59, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 6, 0.42, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 7, 0.43, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 8, 0.26, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 9, 0.64, SBP$sex.mean)
SBP$sex.mean <- ifelse(SBP$trialdummy == 10, 0.33, SBP$sex.mean)

## Specify a new across-trial interaction with treatment for this variable.
SBP$acr.interaction <- SBP$treat*SBP$sex.mean

## Let us now fit an IPD meta-analysis model, with the across-trial interaction
# and the within-trial interaction (the ecological bias removed by centering).
mod.int.within.across <- lmer(sbpl ~ sbpi + trialdummy.f + sbpi + sex + treat
                 + ws.interaction + acr.interaction - 1 
                 + (treat -1 | trialdummy), data = SBP)
summary(mod.int.within.across)

## Q4: What are the updated conclusions about the difference in treatment effect 
# between males and females?
  
## Q5 What was the previously hidden influence of the across-trial interaction 
# in the previous one-stage IPD model? 
# HINT: Compare how the interaction estimates differ.

## LEARNING POINT:  The across-trial interaction will have more impact in 
# situations where the variation in patient values within each trial is low
# but the across trial variation is large. For an extreme example, consider
# there are 5 trials, each of which is done in either males or females only.  
# Then there is no within-level interaction observed in each trial. So the 
# across-trial interaction will then dominate entirely.

## One may also consider putting a random effect on the within-study interaction term in 
# the model.
mod.int.rand.interaction <- lmer(sbpl ~ sbpi + trialdummy.f + sbpi + sex + treat
                 + ws.interaction + acr.interaction - 1 
                 + (treat + ws.interaction - 1 || trialdummy), data = SBP)
summary(mod.int.rand.interaction)

## Q6:  Is there heterogeneity in the within-trial interaction estimate?

## Two-stage IPD approach
##

## For a two-stage analysis of interactions, we will use the dataset
# "SBP_summ_interact".
summ_interact <- read_excel("SBP_summ_interact.xls")
View(summ_interact)

## Try the following: 
## (i) fixed effect model to pool interaction estimates in the 2nd stage
## and (ii) random effects model using DL estimator to pool interactions
meta.int.dl <- metagen(est, se_est, trial, data = summ_interact,
                       sm = "MD", comb.fixed = TRUE)
meta.int.dl
## You get both fixed-effect and random-effects (DL) meta-analysis results
# by default with metagen even if you specify the fixed option.

## (iii) random effects model using REML estimator to pool interactions
meta.int.reml <- metagen(est, se_est, trial, data = summ_interact,
                   sm = "MD", comb.random = TRUE, method.tau = "REML")
meta.int.reml

## Q7: How do conclusions about the difference in treatment effect between males
# and females differ in the two-stage analysis and the one-stage analysis
# that separates the within- and across-trial interactions?
  
## LEARNING POINT: The findings are not identical, though close.
# For example, in the random effects REML approach the two-stage gives
# 0.87 (-0.44, 2.19) and the one-stage gives 0.76 (-0.90 to 2.42).
# What is the reason? This is a situation where the two-stage and one-stage 
# models are making different assumptions. The two-stage allows for 
# different residual variances and adjustment terms, but our one-stage 
# model did not. This leads to differences in the final meta-analysis results.

# Can we address this? Let us return to our one-stage model and allow for separate residual variances 
# Also allow for separate baseline adjustment terms and separate treatment effects per study, using random effects
# also put a random effect on the ws_interaction
ipd_onestage_results<-lme(sbpl~ 0 + trialdummy.f + sbpi*trialdummy.f + sex*trialdummy.f + treat + ws.interaction +
                            acr.interaction, random=list(trialdummy=~0+treat, trialdummy=~0+ws.interaction), 
                          weights=varIdent(form=~1|trialdummy), control = ctrl, data = SBP, na.action = na.omit, method = "REML")
summary(ipd_onestage_results)
intervals(ipd_onestage_results, which = "fixed")
# This gives a within-study interaction of 0.87, 95% CI: -0.44 to 2.19
# Hence identical to the 2-stage approach
