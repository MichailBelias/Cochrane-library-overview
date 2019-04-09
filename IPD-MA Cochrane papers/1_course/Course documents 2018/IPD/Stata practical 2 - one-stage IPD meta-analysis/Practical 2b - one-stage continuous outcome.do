* PRACTICAL 2(b) - One-stage IPD meta-analysis of a continuous outcome 

* Open the SBP data.
* This is simulated data, based on the hypertension trials discussed in the 
* lectures. There are 10 trials of hypertension treatment, aiming to lower
* systolic blood pressure (SBP) and a total of 27903 patients - very large! 
* PLEASE ONLY USE THIS DATA FOR EDUCATIONAL PURPOSES 

*** One-stage IPD meta-analysis 
***

* We will use the ANCOVA approach to adjust for baseline blood pressure.

* First create a dummy variable for each study.

tabulate trialdummy, gen(trial)

* Now fit, using ML, an ANCOVA IPD fixed effect meta-analysis model, with a
* separate intercept for each study.

reg sbpl sbpi treat trial1 trial2 trial3 trial4 trial5 trial6 trial7 ///
trial8 trial9 trial10, nocons

* Q1: Write down the model. Based on the results, does hypertension 
* treatment appear effective?

* The trials were done in different populations with different
* anti-hypertensive drugs. Thus, let us allow for heterogeneity 
* in the treatment effect using a random effects ANCOVA model using REML,
* again with a separate intercept for each study.

xtmixed sbpl sbpi treat trial1 trial2 trial3 trial4 trial5 trial6 trial7 ///
trial8 trial9 trial10 , nocons || trialdummy: treat, nocons reml var

* Q2: Write down the model. Based on the results is there between-study
* heterogeneity in treatment effect? Have conclusions about treatment
* effect changed?

* Q3: How do these results compare to your random effects two-stage results 
* with REML estimation?

* Note that the previous models were actually assuming the same effect 
* of the baseline SBPi in each study. Similarly, it assumed the same residual 
* variance for each study. This are strong assumptions and may not be necessary.

* Let us try to specify separate residual variances in each study. The 
* 'residuals' option is used to do this:

xtmixed sbpl sbpi treat trial1 trial2 trial3 trial4 trial5 trial6 trial7 ///
trial8 trial9 trial10 , nocons  || trialdummy: treat, nocons reml ///
residuals(ind, by(trialdummy)) technique(nr) 

* Q4: What do you notice after about 30 seconds.

* LEARNING POINT:  More advanced one-stage model structures may lead to 
* convergence problems or be extremely slow. Hence why two-stage approaches 
* are often preferred. Stata seems particularly bad/slow here - SAS PROC Mixed 
* is very quick and the issue has been raised with Stata.
* This model will converge but may take over an hour. Leave this now and
* try it again at home if you wish.

* Stop it running by pressing the RED CROSS BUTTON on the main page.

* Interestingly, if you reduce the number of studies it is far easier to 
* converge. Try just using trials 1 to 3.

xtmixed sbpl sbpi treat trial1 trial2 trial3 if trial1 ==1 | ///
trial2==1 |trial3==1 , nocons  || trialdummy: treat, nocons reml ///
residuals(ind, by(trialdummy)) technique(nr)

* This converges within 10 seconds *
* Look at the results. We have a separate residual variance for each trial.
* Try now including a separate baseline adjustment term per trial.

gen sbpi_trial1 = sbpi*trial1
gen sbpi_trial2 = sbpi*trial2
gen sbpi_trial3 = sbpi*trial3
xtmixed sbpl sbpi_trial1 sbpi_trial2  sbpi_trial3 treat trial1 trial2 ///
trial3 if trial1 ==1 | trial2==1 |trial3==1 , nocons  || trialdummy: treat, ///
nocons reml residuals(ind, by(trialdummy)) technique(nr)

* This also converges very fast, though slightly slower due to the added 
* complexity. We now have 3 residual variances, 3 trial intercepts, and 
* 3 SBPi adjustment terms.
* Results are very similar had you used a random intercept and random sbpi

* Let us add the Kenward Roger option, to inflate confidence intervals
* to more fully account for uncertainty .
* This take a while to converge (2 mins).

mixed sbpl sbpi_trial1 sbpi_trial2  sbpi_trial3 treat trial1 trial2 ///
trial3 if trial1 ==1 | trial2==1 |trial3==1 , nocons  || trialdummy: treat, ///
nocons reml residuals(ind, by(trialdummy)) technique(nr) dfmethod(kroger)

* Notice that the CI is now much wider for the summary treatment effect
* Without KR correction: -10.74 (-15.88 to -5.59)
* With KR correction: -10.74 (-23.45 to 1.98)

* LEARNING POINT: The Kenward Roger correction is computationally intensive
* but important, to account for uncertainty

* Let us compare it a two-stage approach with Hartung-Knapp CI correction

ipdmetan , re(reml,hksj) ///
study(trialdummy) md : reg sbpl treat sbpi if trialdummy<4
 
* we obtain -10.74 (-22.03 to 0.56)
* so same estimate and similar CI (though not identical)


