* PRACTICAL 1(b) - Two-stage IPD meta-analysis of a continuous outcome 

* Open the 'SBP' data.
* This is simulated (not real!) data, based on real hypertension trials 
* discussed in the lectures. There are 10 trials of hypertension treatment, 
* aiming to lower systolic blood pressure (SBP) and a total of 27903 patients  
* PLEASE ONLY USE THIS DATA FOR EDUCATIONAL PURPOSES 


*** Exploration of the data
***
* Compare the baseline SBP (SBPi) across treatment (treat = 1) and control 
* groups (treat = 0) at the individual study level 

table trialdummy treat, contents(mean sbpi )

* Q1: What do you notice about some trials in terms of baseline balance 
* in the initial SBP value in each group?


* For just trial 1, under the following 3 types of analysis, compare effect 
* of treatment (i.e. treatment group - placebo) on:
* (i) Final SBP (the "sbpl" variable), under an ANCOVA model, adjusting for 
* initial SBP (the "sbpi" variable);
* (ii) Final SBP (the "sbpl" variable), under an ANOVA model (i.e. no baseline
* SBP adjustment in this model);
* (iii) Change in SBP (the "diff" variable), under an ANOVA model.

* ANCOVA *
reg sbpl sbpi treat if trialdummy == 1
* FINAL SCORE*
reg sbpl treat if trialdummy == 1
* CHANGE SCORE*
reg diff treat if trialdummy == 1

* Q2: How do the effect estimates compare? Which has the smaller standard 
* errors? Which method is more reliable?

* LEARNING POINT: Please see the following reference for more on why ANCOVA 
* is preferred: Vickers AJ, Altman DG. Statistics notes: Analysing controlled 
* trials with baseline and follow up measurements. BMJ 2001; 323: 1123-1124.


*** Two-stage IPD meta-analysis of the 10 trials
***

* We could use ipdmetan to do the first and second stages together.
* But for learning purposes now, we want you to understand the aggregate data
* going into the second stage

* Open the file 'SBP summary' 
* This already contains the treatment effect estimates and their standard
* errors for each hypertension study (to save you time).
* Treatment effect estimates are given based on ANCOVA, change score
* and final score.

* Perform a random effects meta-analysis of the ANCOVA results for each study, 
* using DL estimation. NB. This automatically allows a separate residual 
* variance and baseline response (i.e. mean placebo response) in each study, 
* as the treatment effect was estimated separately for each study.

admetan ancova seancova, re


* To improve display of the forest plot, try this:

admetan ancova seancova, re(dl) study(trial) md ///
	forestplot(xtitle(Mean difference (treatment - placebo)) xlabel(-20(5)5))


* Q3: Based on the results, does hypertension treatment appear effective?

* Q4: Based on the results, is there between-study heterogeneity in the 
* treatment effect?

* Generally we prefer using REML estimation.

admetan ancova seancova, re(reml) study(trial) md ///
	forestplot(xtitle(Mean difference (treatment - placebo)) xlabel(-20(5)5))


* This gives tau-squared = 7.4, but the DL method gave tau-squared = 3.3
* This difference is quite scary! There is ongoing work to resolve
* which is the best method. Therefore it is best to be transparent, and report 
* a primary analysis estimation choice in the protocol, and the impact of other 
* estimation methods in the report too.

* Let us also include the Hartung-Knapp confidence interval

admetan ancova seancova, re(reml, hksj) study(trial) md ///
	forestplot(xtitle(Mean difference (treatment - placebo)) xlabel(-20(5)5))

* the 95% CI is suitable wider, as it accounts for uncertainty in tau-squared

* Finally, now let us repeat the DL two-stage analysis, and additionally
* calculate a 95% prediction interval.
admetan ancova seancova, re rfdist study(trial) md ///
	forestplot(xtitle(Mean difference (treatment - placebo)) xlabel(-20(5)5))


* Q5: What does the 95% prediction interval tell us about the potential 
* treatment effect in a new study population?

* LEARNING POINT: In comparison to Practical 1(a), the prediction interval 
* here is more helpful. We have 10 studies, so less uncertainty in our 
* heterogeneity estimate. And all the studies show effect of treatment in the 
* same direction, despite the considerable heterogeneity. This helps us 
* summarise the distribution of effectiveness of anti-hypertension treatment.

* NB. When REML is used instead of DL, the upper and lower bounds of the 
* prediction interval are wider (due to the larger tau-squared), but still both
* fall well below zero.

* Lastly, let us use ipdmetan to do the first stage and second stage together
* Open the 'SBP' dataset again

ipdmetan, re rfdist study(trialdummy) md ///
forestplot(xtitle(Mean difference (treatment - placebo)) ///
xlabel(-20(5)5)): reg sbpl treat sbpi

* So very easy and quick!

* In your own time after the course, if desired you could use the 'SBP summary'  
* data to investigate how a meta-analysis of final scores, or a meta-analysis 
* of changes scores, differs to the meta-analysis of ancova estimates.
