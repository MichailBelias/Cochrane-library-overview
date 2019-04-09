* Practical 3 - IPD meta-analysis of a continuous outcome: interest in 
* treatment-covariate interaction.

* There are 10 trials of hypertension treatment, aiming to lower systolic 
* blood pressure (SBP) with a total of 27903 patients - very large, thus
* increasing power to detect genuine modifiers of treatment effect.

*** Non-IPD approach: meta-regression
***

* Open the file 'SBP summary'

* This contains the treatment effect estimates and their standard errors 
* for each study. This is the same aggregate data you analysed in practical 1b
* in the 2nd stage of the two-stage IPD meta-analysis. This is based on 
* simulated data, so please only use for educational purposes.

* Recall we have here the study treatment effect estimates either from
* ancova, change score, or final score analyses.

* You will see that the proportion male in each study is also available in the 
* dataset (prop_male). Without IPD, researchers may look across studies to see 
* if the proportion male (prop_male) is associated with the treatment effect. 
* They could only do this by using meta-regression. Let us do this.

* If you do not have metareg, then install it
ssc install metareg

* The metareg command wants the standard errors after the comma, unlike admetan.
* We specify the estimates and the covariates, and then the standard errors
* and estimation method. Let us do a meta-regression of the ancova treatment
* effect estimates.
metareg ancova prop_male, wsse(seancova) reml graph

* Q1: Write down the model. What does the result suggest about the association 
* between the proportion male in the study and the treatment effect?

* LEARNING POINT:  the result is what I refer to as an 'across-trials 
* association'. It explains between-study variation. The estimate of tau-squared
* is smaller when prop_male is included, than when it is excluded. Check this 
* by fitting the following:
metareg ancova , wsse(seancova) reml

* Q2: How does the tau-squared estimate obtained compare to the previous 
* model in Q1?


*** One-stage IPD approach 
***

* With IPD, we can observe patient-level interactions more clearly.
* In other words, we can explain patient-level variation (residual variance), 
* rather than study-level variation (tau-squared).

* Open the 'SBP' data again (the full IPD) and create a dummy variable 
* for each trial.
tabulate trialdummy, gen(trial)

* Let us fit a one-stage ANCOVA IPD random effects model, with separate 
* intercept for each study, now with an interaction term. There are diferent 
* ways to specify the interaction term, but treat##sex is chosen here.

* Note that due to long convergence time we still do not allow for separate
* residuals or baseline adjustment terms in each trial, and this is not ideal
* R or SAS would  be much faster
* But please do not focus on this issue for now; just focus on the interaction.

mixed sbpl sbpi treat##sex trial1 trial2 trial3 trial4 trial5 trial6 trial7 ///
	trial8 trial9 trial10 , nocons || trialdummy: treat, nocons reml

* Q3: Write down the model. What is the conclusion about the difference in 
* treatment effect for males and females? Is the conclusion different from
* the meta-regression?

* LEARNING POINTS: Also consider here the magnitude of the interaction estimate, 
* in terms of clinical relevance - do not just focus on the p-value.

*** Separation of within-trial and across-trial interactions
***

* The one-stage analysis could be misleading, because our specification of the 
* interaction can explain both within-study and between-study variation. We can 
* already see the huge difference between the across-trial interaction from 
* the meta-regression and the pooled interaction from the model above. However,
* in the one-stage model above, the across-trial interaction 
* (i.e. meta-regression result) is still contributing to the pooled interaction,
* as we have not separated out the ecological bias.

* In the lectures, we discussed the need to separate out interactions by
* centering covariates. Let us calculate a new sex variable, centred by the 
* proportion male in each study.

* You can see the proportion male using:
bysort trialdummy: tab sex

* Now create the centred variable:
gen sex_cent = sex - 0.7 if trial1 ==1
replace sex_cent = sex - 0.35 if trial2 ==1
replace sex_cent = sex - 0.24 if trial3 ==1
replace sex_cent = sex - 0.55 if trial4 ==1
replace sex_cent = sex - 0.59 if trial5 ==1
replace sex_cent = sex - 0.42 if trial6 ==1
replace sex_cent = sex - 0.43 if trial7 ==1
replace sex_cent = sex - 0.26 if trial8 ==1
replace sex_cent = sex - 0.64 if trial9 ==1
replace sex_cent = sex - 0.33 if trial10 ==1

* Specify a new within-trial interaction with treatment for this variable
gen ws_interaction = treat*sex_cent

* Now specify the proportion male in each study (the same for each patient 
* in a trial)
gen sex_mean = 0.7 if trialdummy == 1
replace sex_mean = 0.35 if trialdummy == 2
replace sex_mean = 0.24 if trialdummy == 3
replace sex_mean = 0.55 if trialdummy == 4
replace sex_mean = 0.59 if trialdummy == 5
replace sex_mean = 0.42 if trialdummy == 6
replace sex_mean = 0.43 if trialdummy == 7
replace sex_mean = 0.26 if trialdummy == 8
replace sex_mean = 0.64 if trialdummy == 9
replace sex_mean = 0.33 if trialdummy == 10

* Specify a new across-trial interaction with treatment for this variable.
gen acr_interaction = sex_mean*treat

* Let us now fit an IPD meta-analysis model, with the across-trial interaction
* and the within-trial interaction (the ecological bias removed by centering).
mixed sbpl trial1 trial2 trial3 trial4 trial5 trial6 trial7 trial8 trial9 ///
	trial10 sbpi sex treat ws_interaction acr_interaction , nocons ///
	|| trialdummy: treat, nocons reml

* Q4: What are the updated conclusions about the difference in treatment effect 
* between males and females?

* Q5 What was the previously hidden influence of the across-trial interaction 
* in the previous one-stage IPD model? 
* HINT: Compare how the interaction estimates differ.

* LEARNING POINT:  The across-trial interaction will have more impact in 
* situations where the variation in patient values within each trial is low
* but the across trial variation is large.  For an extreme example, consider
* there are 5 trials, each of which is done in either males or females only.  
* Then there is no within-level interaction observed in each trial. So the 
* across-trial interaction will then dominate entirely.

* One may also consider putting a random effect on the interaction term in 
* the model.
mixed sbpl trial1 trial2 trial3 trial4 trial5 trial6 trial7 trial8 trial9 ///
	trial10 sbpi sex treat ws_interaction acr_interaction , nocons ///
	|| trialdummy: treat ws_interaction, nocons reml

* Q6:  Is there heterogeneity in the within-trial interaction estimate?

* ADVANCED POINTERS:
* There are commands in Stata that allow you to perform forest plots after 
* a one-stage IPD meta-analysis automatically.
* Kontopantelis E and Reeves D. A short guide and a forest plot command 
* (ipdforest) for one-stage meta-analysis. The Stata Journal, 
* 2013 Oct; 13(3): 574-587.*
* We leave this for you to explore if desired.
* But note, we do not agree with the % weights given by this package
ssc install ipdforest

*** Two-stage IPD approach
***

* For a two-stage analysis of interactions, we can also utilise ipdmetan.
* (Fisher D. Two-stage individual participant data meta-analysis and generalised 
* forest plots.  Stata Journal 2015 15: 369–396.)
ssc install ipdmetan
ssc install moremata

* 'ipdmetan' allows us to do a two-stage IPD meta-analysis of the interactions.
* We can either use the 'interaction' option or the 'poolvar(x)' to tell
* Stata which parameter 'x' we want to pool.

* Try the following: 
* (i) fixed effect model to pool interaction estimates in the 2nd stage
ipdmetan, study(trialdummy) interaction keepall : mixed sbpl treat##sex sbpi

* (ii) random effects model using DL estimator to pool interactions
ipdmetan, study(trialdummy) interaction keepall re : mixed sbpl treat##sex sbpi
 
* (iii) random effects model using REML estimator to pool interactions
ipdmetan, study(trialdummy) interaction keepall re(reml) : mixed sbpl treat##sex sbpi


* Q7: How do conclusions about the difference in treatment effect between males
* and females differ in the two-stage analysis and the one-stage analysis
* that separates the within- and across-trial interactions?

* LEARNING POINT: The findings are not identical, though close.
* For example, in the random effects REML approach the two-stage gives
* 0.87 (-0.44, 2.19) and the one-stage gives 0.76 (-0.90 to 2.42).
* The reason? This is a situation where the two-stage and one-stage models are
* making different assumptions. The two-stage allows for different residual
* variances and adjustment terms, but (for computational time) our one-stage 
* model did not. This leads to differences in the final meta-analysis results.

* If the model assumptions were the same, we should get very similar results
* To show this, let us restrict the analysis to the first 3 studies
* We now create three adjustment terms for sex and sbpi, one for each trial.
gen sbpi_trial1 = sbpi*trial1
gen sbpi_trial2 = sbpi*trial2
gen sbpi_trial3 = sbpi*trial3

gen sex_trial1 = sex*trial1
gen sex_trial2 = sex*trial2
gen sex_trial3 = sex*trial3


* Let us fit our one-stage random effects analysis now with all 6 adjustment
* terms and three residual variances, one for each trial.
mixed sbpl trial1 trial2 trial3 sbpi_trial1 sbpi_trial2 sbpi_trial3 ///
	sex_trial1 sex_trial2 sex_trial3 treat ws_interaction acr_interaction ///
	if trial1 ==1 | trial2==1 |trial3==1 , nocons ///
	|| trialdummy: treat ws_interaction , nocons reml  ///
	residuals(ind, by(trialdummy)) technique(nr)

* The pooled interaction is now -1.86 (-5.21, 1.49).
* Tau-squared is close to zero for the within-study interactions.


* If we do the two-stage approach:
ipdmetan, study(trialdummy) interaction keepall re(reml) : ///
	mixed sbpl treat##sex sbpi if (trial1==1 | trial2==1 | trial3==1)

* We get -1.851 (-5.194, 1.491) and tau-squared is zero.
* Thus, one-stage and two-stage results are almost identical now.
* (Another example showing the greater ease of the two-stage approach) *
