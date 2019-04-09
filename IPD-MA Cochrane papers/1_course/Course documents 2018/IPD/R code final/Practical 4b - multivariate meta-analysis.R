## Practical 4(b): Getting to know multivariate meta-analysis

# Set your working directory, for example mine is:
setwd("C:/Work/IPD course/R datasets/Practical 4")

## Install/load necessary packages
install.packages("mvmeta")
library(mvmeta)
library(meta)
library(metafor)

## Now that we know how to derive within-study correlations from IPD,
# let us focus on applying multivariate meta-analysis using 'mvmeta'.

## Fibrinogen
##
  
## Let us start by replicating the fibrinogen example.
# Recall this looked at the fully and partially adjusted HR for fibrinogen;
# 14 IPD studies gave the fully and partially adjusted results;
# 17 IPD studies only gave the partially adjusted result.

# We use the meta-analysis data as reported in here:
# The Fibrinogen Studies Collaboration. Systematically missing confounders 
# in individual participant data meta-analysis
# of observational cohort studies. Stat Med. 2009;28:1218-37.

## The authors used a Cox model to obtain fully and partially adjusted HRs.
# From the IPD, bootstraping was used to derive the within-study correlations 
# in those 14 studies that provided both (as we just did in practical 4a).

## Load the datafile 'fibrinogen'; here we have the data derived from the IPD.
library(readxl)
fibrin <- read_excel("fibrinogen.xls")
View(fibrin)

# y1 is the fully adjusted logHR, se1 its standard error & v11 its variance
# y2 is the partially adjusted logHR, se2 its standard error & v22 its variance
# wscorr is the within-study correlation
# v12 is the within-study covariance

## To run a multivariate meta-analysis, we need to tell mvmeta the data.

# Let us start with a univariate meta-analysis for the fully adjusted result.
# Let us use random effects and REML.
univ.y1.reml <- metagen(y1, se1, study, data = fibrin,
                     sm = "logHR", comb.random = TRUE, method.tau = "REML")
univ.y1.reml

## "mvmeta" package also does this.
univ.y1.reml2 <- mvmeta(y1, S = v11, data = fibrin, method = "reml")
summary(univ.y1.reml2)

## Q1: Are the results for metagen and mvmeta the same?

## Q2: The Stata practical discusses the additional uncertainty option in Stata's
# "mvmeta" - we do not have an equivalent in R.

## Did you notice that meta and mvmeta issued warning messages that
# 17 studies were removed from the analysis?

## Q3: Why were 17 studies dropped?

## Let us now do a bivariate meta-analysis, to include all 31 studies,
# and to borrow strength between the partially and fully adusted results.
# i.e. we now includes two outcomes.

## Load the data "fib.meta", which is set up in long format.
fib.mvmeta <- read_excel("mvmeta_data.xls")
View(fib.mvmeta)

## Before we can proceed with the model fitting, we need to construct the
# full (block-diagonal) variance-covariance for all studies from these two 
## variables. We can do this using the bldiag() function in one line of code:
V <- bldiag(lapply(split(fib.mvmeta[,c("v1i", "v2i")], fib.mvmeta$study), as.matrix))
V

biv.full.part <- rma.mv(yi, V, mods = ~ outcome - 1, random = ~ outcome | study, 
              struct="UN", data=fib.mvmeta, method="REML")
print(biv.full.part, digits=3)

## Learning point: If there are missing estimates, variances and covariances, R 
# excludes these studies from the analysis. In order to force inclusion of 
# the studies with missing data, and to borrow strength across all studies,
# we can replace the missing data such that those estimates contribute negligible
# weight in the analysis. We can do this by fixing the point estimates to zero,
# variances to 10000, and covariances to zero.

## Q4: Compare the multivariate fully adjusted pooled estimate 
# with the univariate fully adjusted pooled estimate
# - what do we gain by using mvmeta?

## The extra gain from the multivariate meta-analysis is due to the 
# borrowing of strength. Unfortunately we cannot obtain the study weights from mvmeta in R yet; we can in Stata

## Q5 and Q6 in Stata are to ask for BoS values, but we do not have a
# built in BoS function in R yet (unless anyone knows otherwise?)
