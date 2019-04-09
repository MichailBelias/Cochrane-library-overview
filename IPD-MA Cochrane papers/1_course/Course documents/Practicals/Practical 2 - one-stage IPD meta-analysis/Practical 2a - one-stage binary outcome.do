* Practical 2(a): ONE-STAGE IPD META-ANALYSIS OF A BINARY OUTCOME *

* syntax works in Stata 12 and above ... for Stata 13 & 14 users, you may want 
* to update the code post-course, for example xtmelogit is meqrlogit

* open the 'eryt' dataset *

* this is re-created IPD, based on the summary 2 by 2 data for the 3 DVT 
* studies discussed in the lecture 3 
* 3 IPD studies: patients either have or do not have a deep vein thrombosis 
* (DVT). 'eryt' is Erythema : redness of the skin, caused by hyperemia of the
* capillaries in the lower layers of the skin. 

* Research question is the same question as practical la: 
* Does presence of 'eryt' increase the risk of having a DVT?
* NB please only use the data for educational purposes *
 
* One-stage analysis ignoring clustering *

logistic dvt eryt 

* Q1(a): Write down the model being fitted here
* Q1(b): Based on the results, what is the conclusion about eryt: 
* is it a risk factor? *

* One-stage fixed effect IPD meta-analysis that does account for clustering

* We will need a separate intercept per study. Thus, first let us create a dummy
* variable for each study (=1 if in that study, and 0 otherwise)
tabulate studyid, gen(study)

* use ML to fit the one-stage fixed effect meta-analysis *

logistic dvt eryt study1 study2 study3, nocons

* Q2: write down the new model. Based on the results, what is the new *
* conclusion about eryt: is it a risk factor? *

* Q3: compare your results to those when ignoring clustering from Q1(b). 
* How are they different? Can you explain why? *
* (hint: consider the prevalence of DVT in the three studies) *

tabulate studyid dvt, row 

* One-stage random effects IPD meta-analysis that does account for clustering

* Let us now extend the previous analysis to allow for potential
* between-study heterogeneity in the effect of eryt 

* Use ML to fit the following random effects model

meqrlogit dvt eryt study1 study2 study3, nocons || studyid: eryt, nocons 
* to get the OR, use the following
meqrlogit dvt eryt study1 study2 study3, nocons || studyid: eryt, nocons or

* Q4: Write down the model. Based on the results, is there evidence of 
* between-study heterogeneity in the effect of eryt? *

* Q5: Compare the pooled OR from the random effects and fixed effect models 
* - can you explain why they are identical?

* Q6: How do meta-analysis results compare with those from the two-stage
* approach using the same estimation method of ML?

* HINT: run the following to get the two-stage results

ipdmetan, study(studyid) re(ml) or rfdist: logistic dvt eryt 


* LEARNING NOTE FOR DISCUSSION FROM PRACTICAL 1: there are few studies here, 
* and so the choice of estimation method for tau has a big impact in the 
* two-stage analysis. ML estimates are potentially downwardly biased, and so 
* the ML estimates from one-stage approach, or two-stage with ML estimation 
* in the second stage may be producing too small taus; therefore we may be 
* obtaining too narrow CIs for the pooled effect using ML here.

* So should we be using the two-stage approach with REML (or DL) to improve 
* estimation, rather than one-stage with ML? 
* Given the studies are reasonably sized, and there are no zero events, 
* it is plausible to believe the log odds ratio are approx. normally distributed
* from each study.
* Therefore, the exact binomial approach in the one-stage analysis may not
* be needed, and two-stage with REML may be preferable

ipdmetan, study(studyid) re(reml) or rfdist: logistic dvt eryt 

* One way to reduce bias in ML estimates of tau-squared is to reduce the
* number of parameters in the model

 * We could do this by using a random (rather than stratified) intercept

meqrlogit dvt eryt , || studyid: eryt, or var
* This now identifies potential heterogeneity (though not as much as REML)

* In short - this is a complicated issue
* Ideally a one-stage analysis with a REML-type estimator (to deal with 
* downward bias in the tau estimation) would be my preferred option
* - this is possible using pseudo-linear transformations of the y response
* e.g. use GLIMMIX in SAS.
* But this is advanced theory of generalised linear mixed model, and there are
* other reasons why one-stage ML using quadrature is preferred
* 
* KEY MESSAGE AGAIN: Try to pre-specify your analysis plan in a protocol 

* There are many other options too:
* One could adopt a Bayesian approach, to account for full uncertainty 
* and maintain exact binomial modelling, but this requires prior distributions.


