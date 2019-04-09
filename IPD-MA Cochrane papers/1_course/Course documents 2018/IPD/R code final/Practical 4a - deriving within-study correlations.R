## PRACTICAL 4(a): Deriving within-study correlations

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 4")

# First, let's install/load some packages
install.packages("nnet")
install.packages("mgcv")
install.packages("quantreg")
install.packages("systemfit")
library(systemfit)
library(boot)
library(survival)

## Multivariate meta-analysis usually requires within-study correlations.
# Thus we begin by considering how to estimate these using IPD.
# We need to derive within-study correlations for each pair of outcomes in
# every trial available to us. For simplicity, in this practical we just focus 
# on deriving within-study correlations in a single trial. But in reality, we 
# would need to repeat this process for all trials.

## Derivation of within-study correlation between SBP and DBP treatment effect 
# estimates.
##

## Load the dataset 'Trial 1'
library(readxl)
trial_1 <- read_excel("Trial_1.xls")
View(trial_1)
# This is one of the 10 simulated hypertension trials from the lectures.
# Again, please only use this for educational purposes.
# We have 1530 patients in either a treatment or control group.
# We are interested in both the treatment effect on SBP and DBP.
# We can easily obtain the treatment effect and its standard error
# for both SBP and DBP by fitting ANCOVA models.
ancova.sbp <- glm(sbpl ~ sbpi + treat, data = trial_1, 
           family = gaussian(link = "identity"))
summary(ancova.sbp)

ancova.dbp <- glm(dbpl ~ dbpi + treat, data = trial_1, 
           family = gaussian(link = "identity"))
summary(ancova.dbp)

## Q1: Does the treatment appear to be effective in this trial for SBP and DBP?

## To enable a bivariate meta-analysis of DBP and SBP, we need to go further
# and also obtain the within-study correlation between the treatment effect
# estimates for SBP and DBP.
# Let us firstly do this via a joint regression model.
# We are going to fit this in R using 'seemingly unrelated regression'
# This fits an ANCOVA model for each of SBP and DBP, accounting for 
# correlation in their residuals as shown in the lecture notes.
r1 <- sbpl ~ sbpi + treat
r2 <- dbpl ~ dbpi + treat
fitsur <- systemfit(list(sbpreg = r1, dbpreg = r2), data = trial_1,
                    method = "SUR")
## Q2: Compare the treatment effect estimates to those obtained in Q1
# - are they different and if so, why?

## Q3: What is the correlation in the residuals for SBP and DBP?
# - what does this tell you?
  
## LEARNING POINT: The large correlation in the residuals is the patient-level
# correlation. Clearly it is high here, as expected because SBP and DBP are 
# correlated in a patient. This patient-level correlation is why there will be
# a within-study correlation in the treatment effect estimates for SBP and DBP.

## To work out the within-study correlation between SBP and DBP effect estimates
# we need the variance-covariance matrix of the parameter estimates.
fitsur$coefCov

## Q4: what is the:
# -  within-study COVARIANCE between the SBP & DBP treatment effect estimates?
# -  within-study CORRELATION between the SBP & DBP treatment effect estimates?

# Hint: 
ws_corr<-0.344/sqrt(0.7228*0.2722)
ws_corr

## Now, let us rather estimate the within-study correlation (covariance) 
# using the bootstrap approach, and compare with the value just obtained.

## Define a function where we run an ANCOVA for SBP and then DBP.
# Each time we save the treatment effect estimates
bloodpress <- function(data, indices){
  trial_1 = data[indices, ]
  reg1 <- glm(sbpl ~ sbpi + treat, data = trial_1)
  treat.coef.1 <- coef(summary(reg1))["treat", "Estimate"]
  reg2 <- glm(dbpl ~ dbpi + treat, data = trial_1)
  treat.coef.2 <- coef(summary(reg2))["treat", "Estimate"]
  regress.coeffs <- c(treat.coef.1, treat.coef.2)
  return(regress.coeffs)
}

## Now apply the bootstrap to our data 2000 times using the function above.
# Set the seed for reproducibility.
set.seed(12345)
results <- boot(data = trial_1, statistic = bloodpress, R = 2000)
print(results)
View(results$t)

## If we work out the correlation between the treatment effect estimates
# for SBP and DBP, it is our within-study correlation.
corr1 <- cor(results$t[,1], results$t[,2], method = "pearson")
corr1

## Q5: How does this correlation compare with the one from Q4?

## [LEARNING POINT: The bootstrap correlation and the correlation from 
# the joint model should usually be very similar. However, the bootstrap 
# approach is more general and important when we have mixed outcomes,
# such as an effect from a logistic model and an effect from a 
# Cox regression.]

## Derivation of within-study correlation between fully and partially
# adjusted results
#
  
## Now let us work out a within-study correlation for a pair of 
# partially and fully adjusted results.

## Use the dataset 'trial_1' again.
## Let's say we want to examine whether smoking is a prognostic factor for
# stroke after adjusting for age and sex and treatment.

## Let us see whether the partially adjusted hazard ratio estimate for smoking
# (only adjusted for treatment) has a high within-study correlation
# with the fully adjusted hazard ratio (adjusted for age, treatment and sex).

## Set the data to be survival data 
surv_object <- Surv(trial_1$dl_st, trial_1$st)

## Now we define our program of two Cox models:
# one partially and one fully adjusted
fully_part <- function(data, indices){
  trial_1 = data[indices, ]
  fit.coxph1 <- coxph(surv_object ~ smk + treat, data = trial_1)
  smk.coef.1 <- coef(summary(fit.coxph1))["smk", "coef"]
  fit.coxph2 <- coxph(surv_object ~ smk + treat + age + sex, data = trial_1)
  smk.coef.2 <- coef(summary(fit.coxph2))["smk", "coef"]
  regress.coeffs <- c(smk.coef.1, smk.coef.2)
  return(regress.coeffs)
}

## Now apply the bootstrap to our data 2000 times using the function above.
# Set the seed for reproducibility.
set.seed(23456)
results2 <- boot(data = trial_1, statistic = fully_part, R = 2000)
print(results2)
View(results2$t)

## Now work out the correlation.
corr2 <- cor(results2$t[,1], results2$t[,2], method = "pearson")
corr2

## Q6: What is the within-study correlation?

