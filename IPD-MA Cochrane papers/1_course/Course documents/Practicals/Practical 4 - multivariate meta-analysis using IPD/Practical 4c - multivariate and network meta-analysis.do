* Practical 4(c): Advanced multivariate & network meta-analysis

* To finish, let us consider two advanced examples: One with four outcomes 
* and then a network meta-analysis.


*** Four outcomes multivariate meta-analysis
***

* Open the file 'SBP DBP Stroke CVD'.
* This gives the treatment effect estimates, variances and within-study 
* correlations for each of these four outcomes from the 10 hypertension trials
* It is taken from:
* Riley RD, et al. Multivariate meta-analysis using individual participant 
* data. J Res Syn Methods 2015; 6: 157–174. doi: 10.1002/jrsm.1129.

* You should see the results for trial 1 are very close those you calculated
* in Practical 4a as the IPD you used was very similar to that for trial 1 here.

* Each Y in the dataset gives a treatment effect estimate.
* Y1 relates to SBP, y2 is DBP, Y5 is CVD, and Y6 is stroke.
* Y1 and Y2 are mean difference estimates; Y5 and Y6 are log HR estimates.
* Each V relates to a variance or a covariance.
* eg. V11 is the variance of Y1.
* eg. V15 is the covariance between Y1 and Y5.

* Let us apply a 4-outcome multivariate meta-analysis:
mvmeta Y V, wt

* To get results for 5 and 6 as HRs (rather than logHRs), we need to use eform:
mvmeta Y V, eform wt

* Q1: Is the treatment beneficial for each of these outcomes on average?

* Q2: What is the BoS value for each outcome in this analysis? Explain why it 
* is so much smaller than observed in the fibrinogen example.

* A great advantage of these multivariate results is joint inferences.
* For example, let us work out the mean treatment effect on pulse pressure (PP),
* which is the difference in SBP and DBP. High PP is associated with increased
* risk of poor outcomes, so we want the treatment to reduce this.
* The pooled treatment effect on PP 
* = the pooled treatment effect on SBP - the pooled treatment effect on DBP.
* Post estimation, we can derive this using:
mvmeta Y V, wt
lincom Y1 - Y2

* Q3: Does the treatment reduce PP more than control on average across studies?

* [NB: This calculation for PP appropriately accounts for the large positive
* correlation of the pooled estimates for SBP and DBP; recall from lectures
* this correlation is ignored when doing univariate meta-analysis.]

* Next, go into the data spreadsheet and manually replace the value of V12 
* for the last trial (make it a .). By doing this, we now have a situation 
* where the within-study correlation is unknown in the last trial. This is a 
* common problem when IPD is unavailable.

* Q4: If we run mvmeta again now, what happens?
mvmeta Y V, 

* There are many suggested approaches for dealing with this problem.
* We don't have time to cover this here, but please see details here:
* Riley RD.  Multivariate meta-analysis: the effect of ignoring 
* within-study correlation. JRSS (A) 2009; 172: 789-811.  
* The easiest option is to impute a value; e.g. we could assume the 
* missing correlation is the mean of the available correlations (about 0.59).

* [LEARNING POINT: When we have IPD, we can derive the within-study correlations
* ourselves as in Practical 4(a), and so avoid the issue of missing values.]

*** Network meta-analysis using the multivariate meta-analysis framework
***

* To finish, let's get a flavour of a network meta-analysis that utilises the 
* multivariate modelling framework.

* Open the dataset 'thromb'.
* This is the example used in the lecture. A network meta-analysis of 28 trials 
* to compare eight thrombolytic treatments after acute myocardial infarction: 
* outcome is mortality by 30-35 days.

* Please see:
* White IR et al. Consistency and inconsistency in network meta-analysis: 
* model estimation using multivariate meta-regression. 
* Res Synth Method. 2012;3: :111-25.
 
* In the data you will see that each study has two or more treatment groups, 
* denoted by A to H, and for each group we have r and n.
* r is the number of events and n is the number of individuals.

* The package 'network' will convert this data into the correct format
* to implement mvmeta.  As the outcome data is binary and we are not interested
* in covariates, we essentially have the IPD here for each study. Thus, we can 
* work out estimates, variances & within-study correlations directly.

* Even better: 'network' will automatically derive log odds ratios for each 
* treatment contrast in each study, plus their variances and their 
* within-study correlations. If a contrast is missing, it gives a arbitrary 
* value with large variance and all associated correlations set to zero
* (data augmentation).

* Install the package if you do not have it already:
net install network, from("http://www.mrc-bsu.cam.ac.uk/IW_Stata/meta")

* Generate the logor estimates, & their variances and within-study correlations.
network setup r n, studyvar(study) trtvar(treat)

* Look at the updated dataset, and see how it now fits the mvmeta data format.

* Let us use treatment A as the reference treatment, and therefore we have
* _y_B the logOR for B versus A, and _y_C the logOR for C versus A, etc.
* Under the consistency asumption, 'network' can now call mvmeta to fit the 
* network meta-analysis and give us pooled estimates and BoS and weights, etc.
network meta consistency, wt

* Q5: Check you understand the results presented. For example, what is the
* treatment effect for B versus A?  And for C versus A?

* The above command is actually equivalent to:
mvmeta _y _S  , bscovariance(exch 0.5) longparm suppress(uv mm) wt ///
vars(_y_B _y_C _y_D _y_E _y_F _y_G _y_H)

* Q6: What assumptions were made about the between-study variances & covariances
* when fitting this model?  Why do you think this was done?

* Q7: If I do the following, what am I now estimating?
lincom [_y_B]_cons - [_y_C]_cons

* For those interested, here is the command for obtaining a network plot:
network forest, group(type) xtitle(odds ratio and 95% CI) ///
title(Thrombolytics network) contrastopt(mlabsize(small)) trtc ///
diamond eform xlabel(0.5 1 2 3 5) col(study)

* Lastly, we can test for inconsistency in the network by using the i option.
* This now fits a 'design by treatment inconsistency model'.
* This allows a global test for inconsistency, and to examine differences
* betweeen direct and indirect evidence for each pair.
network meta inconsistency, wt
 
* We see that the test for overall inconsistency gives p= 0.38 and thus there
* is no strong evidence of inconsistency.
