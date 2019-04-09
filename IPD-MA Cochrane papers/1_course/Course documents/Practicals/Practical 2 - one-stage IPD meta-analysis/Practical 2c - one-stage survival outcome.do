* PRACTICAL 2(c) - One-stage IPD meta-analysis of RCTs with a survival outcome *

* We have so far looked at a binary outcome and then a continuous outcome

* Open the dataset 'survivalIPD', which contains 15 simulated hypertension 
* trials with a time-to-event outcome (death). 
* 'stime' gives the patients time  to death or end of follow-up.
* treat = 1 when the patient had hypertension treatment.

* REF: Crowther, M. J. (2014) STMIXED: Stata module to fit multilevel
* mixed effects parametric survival models.

* So, as in practical 1c, the question is:
* Does hypertension treatment reduce the mortality rate?

* declare the data to be survival data
stset stime, failure(event==1)

* generate a dummy variable for each trial
tab trial, gen(trialvar)

*** One-stage fixed effect approach
***

* Fit the naive fixed effect model ignoring clustering
stcox treat

* Q1: Write down the fitted model. Is hypertension treatment effective?

* Now fit the following fixed effect model that accounts for clustering:

stcox treat trialvar1-trialvar15

* Q2: Write down the model. What does the model assume about the baseline
* hazard functions of the trials?

* Q3: Why is trial15 'omitted' from the results?

* Q4: Do the results still suggest hypertension treatment remains effective?

* Though not usually recommended, one can assume the baseline hazards are
* proportional to each other (as above) AND that they come from 
* a shared distribution
stcox treat , shared(trial)

* But there is no need to be so restrictive. To allow a completely separate
* baseline hazard shape in each trial, we can fit:
stcox treat, strata(trial)

* In this example, the results are very similar to the previous models though

*** One-stage random effects approach
***

* The above models all assumed the treatment effect was fixed.
* To fit a random effect on the treatment effect is difficult for survival
* models; software is only recently becoming available to do this. *
* In Stata, random effects for covariates are more easily obtained using 
* parametric survival models, which assume a particular distribution for the
* baseline hazard. Though this is quite specialist, consider the following use 
* of 'stmixed' written by Crowther. This module allows many approaches, such as
* Weibull or flexible parametric survival models. The latter models the
* baseline hazard using restricted cubic splines. But for today, we just focus 
* on the treatment effect estimate and the amount of heterogeneity.

* Note that 'stmixed' uses maximum likelihood estimation, so heterogeneity 
* estimates may still be downwardly biased. See Crowther M, Look MP, Riley RD.
* Multilevel mixed effects parametric survival models using adaptive 
* Gauss-Hermite quadrature: with application to recurrent events and
* IPD meta-analysis. Stat Med 2014 33(22):3844-58.

* install the package
net install stpm2, replace force from(http://www.homepages.ucl.ac.uk/~ucakjpr/stata)
ssc install stmixed,  
ssc install rcsgen,  

* Let us fit our one-stage IPD random effects meta-analysis model.
* Assume trial baseline hazards are proportional, and model the shape of the
* baseline hazard using a Weibull distribution (other options could be chosen). 
* Allow the treatment effect to be random across studies.
stmixed trialvar1-trialvar15 treat, nocons || trial: treat , nocons ///
distribution(weibull) gh(10)

* The following fits a flexible parametric model:
stmixed trialvar1-trialvar15 treat, nocons || trial: treat , nocons ///
distribution(fpm) df(3) gh(10)

* Q5: Is there heterogeneity in the treatment effect? How does the estimate 
* of tau compare to that from the previous two-stage model using ML?

* Hint: The two-stage model can be obtained using:

* random-effects model using ML estimator *
ipdmetan, study(trial) re(ml) hr : stcox treat

* Q6: Is hypertension treatment still effective according to the results?
