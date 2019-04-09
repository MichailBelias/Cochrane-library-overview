* PRACTICAL 4(a): Deriving within-study correlations

* Multivariate meta-analysis usually requires within-study correlations.
* Thus we begin by considering how to estimate these using IPD.

* We need to derive within-study correlations for each pair of outcomes in
* every trial available to us. For simplicity, in this practical we just focus 
* on deriving within-study correlations in a single trial. But in reality, we 
* would need to repeat this process for all trials.

*** Derivation of within-study correlation between SBP and DBP treatment effect 
*** estimates.
***

* Open the dataset 'Trial 1'
* This is one of the 10 simulated hypertension trials from the lectures.
* Again, please only use this for educational purposes.

* We have 1530 patients in either a treatment or control group.
* We are interested in both the treatment effect on SBP and DBP.
* We can easily obtain the treatment effect and its standard error
* for both SBP and DBP by fitting ANCOVA models.
reg sbpl sbpi treat
reg dbpl dbpi treat

* Q1: Does the treatment appear to be effective in this trial for SBP and DBP?


* To enable a bivariate meta-analysis of DBP and SBP, we need to go further
* and also obtain the within-study correlation between the treatment effect
* estimates for SBP and DBP.
* Let us firstly do this via a joint regression model
* We are going to fit this in Stata using 'seemingly unrelated regression'
* This fits an ANCOVA model for each of SBP and DBP, accounting for 
* correlation in their residuals as shown in the lecture notes.
sureg (sbpl = sbpi treat) (dbpl = dbpi treat), corr

* Q2: Compare the treatment effect estimates to those obtained in Q1
*  - are they different and if so, why?

* Q3: What is the correlation in the residuals for SBP and DBP?
* - what does this tell you?


* [LEARNING POINT: The large correlation in the residuals is the patient-level
* correlation. Clearly it is high here, as expected as SBP and DBP are 
* correlated in a patient. This patient-level correlation is why there will be
* a within-study correlation in the treatment effect estimates for SBP and DBP]


* To work out the within-study correlation between SBP and DBP effect estimates
* we need the variance-covariance matrix of the parameter estimates.

matrix list e(V)

* Q4: what is the:
* -  within-study COVARIANCE between the SBP & DBP treatment effect estimates?
* -  within-study CORRELATION between the SBP & DBP treatment effect estimates?
 

* Now, let us rather estimate the within-study correlation (covariance) 
* using the bootstrap approach, and compare with the value just obtained.

* Let us define a program 'myprog' where we run an ANCOVA for SBP and then DBP.
* Each time we save the treatment effect estimates.
capture program drop myprog
prog def myprog, rclass
	regress sbpl sbpi treat
	return scalar sbptreat = _b[treat]
	regress dbpl dbpi treat
	return scalar dbptreat = _b[treat]
end


* When you run the program you will want to save the estimates to use later.
* Therefore, it makes sense to choose where Stata stores this data, rather than 
* using the default location. In a location of your choice, for example your own
* work folder, create and name a new folder, let's say "IPD course". Now copy
* the whole location from the top of the windows explorer window and paste it 
* within the inverted commas below: 
cd ""
*** Mine looks like this: 
	** cd "C:\Users\pre03\Google Drive\IPD course\Course 2017\Practicals"

* We then apply the bootstrap to our data 2000 times and run our program each
* time, saving the treatment effect estimates for SBP and DBP each time. 
bootstrap b_treat_sbp=r(sbptreat) b_treat_dbp=r(dbptreat), ///
	saving(boot, replace) rep(2000) seed(231): myprog

* Thus, we now have a big dataset of 2000 estimates for each of SBP and DBP.
* If we work out their correlation it is our within-study correlation.
use boot, clear
corr b_treat_dbp b_treat_sbp

* Q5: How does this correlation compare with the one from Q4?


* [LEARNING POINT: The bootstrap correlation and the correlation from the joint
* model should usually be very similar. However, the bootstrap approach is more
* general and important when we have mixed outcomes, such as an effect from a
* logistic model and an effect from a Cox regression.]



*** Derivation of within-study correlation between fully and partially
*** adjusted results
***

* Now let us work out a within-study correlation for a pair of 
* partially and fully adjusted results

* Open the dataset 'Trial 1' again.
* Let's say we want to examine whether smoking is a prognostic factor for stroke
* after adjusting for age and sex and treatment.

* Let us see whether the partially adjusted hazard ratio estimate for smoking
* (only adjusted for treatment) has a high within-study correlation
* with the fully adjusted hazard ratio (adjusted for age, treatment and sex).

* First we define our survival outcome
stset dl_st, failure(st==1)

* Now we define our program of two Cox models
* (one partially and one fully adjusted) 
prog def myprog2, rclass
	stcox smk treat
	return scalar partially = _b[smk]
	stcox smk treat age sex
	return scalar fully = _b[smk]
end

* Now we run 2000 bootstraps.
bootstrap b_partially_smk=r(partially) b_fully_smk=r(fully), ///
	saving(boot2, replace) rep(2000) seed(231): myprog2

* NB Some bootstraps don't give estimates, due to low or no events so you will 
* get a red cross in the output.


* Now work out the correlation.
use boot2, clear
corr b_partially_smk b_fully_smk

* Q6: What is the within-study correlation?

