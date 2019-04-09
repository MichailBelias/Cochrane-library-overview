* PRACTICAL 1(c) - Two-stage IPD meta-analysis of RCTs with a survival outcome *

* We have so far looked at a binary outcome and then a continuous outcome.

* Open the dataset 'survivalIPD', which contains 15 simulated hypertension 
* trials with a time-to-event outcome (death). 
* 'stime' gives the patients time  to death or end of follow-up.
* treat = 1 when the patient had hypertension treatment.

* REF: Crowther, M. J. (2014) STMIXED: Stata module to fit multilevel
* mixed effects parametric survival models.

* So, the question is: does hypertension treatment reduce the mortality rate?

* Declare the data to be survival data *
stset stime, failure(event==1)

*** Two-stage meta-analysis using the 'ipdmetan' module
***

* Let us apply ipdmetan to the survival data here, with a Cox model in each 
* trial separately (first stage) and then a random effects meta-analysis 
* of the treatment effect estimates (second stage).

* random-effects model using DL estimator *
ipdmetan, study(trial) re hr : stcox treat 

* random-effects model using ML estimator *
ipdmetan, study(trial) re(ml) hr : stcox treat

* random-effects model using REML estimator *
ipdmetan, study(trial) re(reml) hr : stcox treat 

* Easy! All done in a few seconds thanks to ipdmetan.

* (N.B. if you see the error "an error occurred when ipdmetan executed stcox"
* then you probably haven't run the "stset" command given above.



* Q1: How does the estimate of tau change when using DL, ML and REML?

* Q2: Based on the REML analysis, is hypertension treatment effective?

* LEARNING POINT: A great feature of ipdmetan compared to other modules is the 
* wide variety of estimation methods available. We just used REML, DL and ML
* but there are a number of others.

* Furthermore, as seen in 1(a) and 1(b), it also includes the 
* Hartung-Knapp-Sidik-Jonkman approach to nflate the CI of pooled estimates 
* after DL or REML estimation. 

* REF: Hartung J and Knapp G (2001) On tests of the overall treatment effect 
* in meta-analysis with normally distributed responses. SiM 20(12).

* The random effects model using DL estimator
* with Hartung-Knapp-Sidik-Jonkman CI for pooled estimate:
ipdmetan, study(trial) re(hksj) hr : stcox treat
* and with REML
ipdmetan, study(trial) re(reml, hksj) hr : stcox treat


* Q3: How have the CIs for the pooled estimates changed compared to the previous 
* model with REML estimation? Have your conclusions changed?


* N.B. "ipdmetan" calls "admetan" to run the second stage of the two-stage 
* process. When we run "admetan" alone, on aggregate data, we are simply 
* running this second stage directly.

