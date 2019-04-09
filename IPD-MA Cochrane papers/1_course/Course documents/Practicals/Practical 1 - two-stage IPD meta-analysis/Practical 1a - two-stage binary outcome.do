* Practical 1(a):  TWO-STAGE IPD META-ANALYSIS OF A BINARY OUTCOME *

* open the 'eryt' dataset *

* 3 IPD studies: patients either have or do not have a deep vein thrombosis 
* (DVT). 'eryt' is Erythema : redness of the skin, caused by hyperemia of the
* capillaries in the lower layers of the skin. 

* Research question:  Does presence of 'eryt' increase the risk of having a DVT?

* So 3 observational studies
* NB please only use the data for educational purposes *
 
* Let us now do a two-stage IPD meta-analysis

* First-stage is to generate the aggregate data in each study *
* So we must calculate the log odds ratio estimates and their standard errors
* in each study separately, using a logistic regression in each study *

* First let us create a dummy variable for each study *
* (=1 if in that study, and 0 otherwise)
tabulate studyid, gen(study)

* We can obtain the logOR results for each study using the 'by' prefix

bysort studyid: logistic dvt eryt , coef

* We must now transfer across the logOR ('coef') estimates 
* and standard errors for each study to form a new dataset

* We already did this for you to save time *

* Open the dataset 'eryt summary'

* This contains 3 variables: studyid, logor, and se
* These are study number, the log odds ratio estimate and its standard error

* We can now pool the aggregate data using a fixed effect or random effects model *

* NB You might need to install relevant meta-analysis packages *
ssc install ipdmetan
* (this contains admetan within it )
* a related but older package is metan
ssc install metan

* We will also need an additional package called "moremata"
ssc install moremata

* Now let us apply a random effects meta-analysis to the aggregate data *
* There are many estimation options; first let's use ML estimation *

admetan logor se, re(ml)
* now with the exp option to provide an OR rather than logOR
admetan logor se, re(ml) or


* now let's apply a random effects meta-analysis with methods of moments
* estimation (DerSimonian and Laird) *
admetan logor se, re
admetan logor se, re or


* finally, let us use REML estimation *
admetan logor se, re(reml) or



* Q1: What do you notice about the between-study variance estimate 
* (tau-squared) when using ML, DL, and REML? 
* What impact does this have on the pooled OR and its 95% CI? *

* LEARNING NOTE FOR DISCUSSION: there are few studies here, and so the choice
* of estimation method for tau has a big impact in the two-stage analysis 
* - quite scary actually!
* ML estimates are potentially downwardly biased, and so the ML estimates 
* may be producing too small taus; therefore we may be obtaining too 
* narrow CIs for the pooled effect using ML here.

* KEY MESSAGE: Try to pre-specify your analysis plan in a protocol* 

* Could use ML estimation with profile likelihood to account for uncertainty 
* in tau estimate, as follows :

admetan logor se, re(pl) or

* There is also the Hartung-Knapp method. We will return to this later

* All the above estimation methods focus on obtaining a pooled (summary) effect

* Following random effects meta-analyses, Higgins et al argue that a 
* prediction interval is the most complete summary of the data
* let us calculate an approximate 95% prediction interval for the odds ratio 
* following DL estimation, using the 'rfdist' option *

* odds ratio scale *
admetan logor se, re or rfdist
admetan logor se, re or rfdist forestplot(xlabel(0.5 1 2 4, force) xtitle(OR))

* Q2: What do you make of the prediction interval? Why is it so wide?

* LEARNING NOTE: with 3 studies, it really is not sensible to calculate a 
* prediction interval. I suggest it is best when there are 7 or more studies *


* Finally, we actually do not need calculate the study-specific aggregate data
* ourselves, because ipdmetan will do this for us
* ipdmetan does the first stage and the second stage all in one go

* open the 'eryt' dataset again *
* Let us do a two-stage IPD random effects meta-analysis with DL estimation
* Everything before the colon defines the meta-analysis (Second stage), and
* everything after the colon specifies the model to use within each study

ipdmetan, study(studyid) re or rfdist: logistic dvt eryt 

* You should find identical results to when you used admetan with the eryt 
* summary data.
