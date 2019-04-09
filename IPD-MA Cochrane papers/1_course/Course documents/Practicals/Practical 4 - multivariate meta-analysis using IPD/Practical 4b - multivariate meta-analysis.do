* Practical 4(b): Getting to know mvmeta

* Now that we know how to derive within-study correlations from IPD,
* let us focus on applying multivariate meta-analysis using 'mvmeta'.

*** Fibrinogen
***

* Let us start by replicating the fibrinogen example.
* Recall this looked at the fully and partially adjusted HR for fibrinogen;
* 14 IPD studies gave the fully and partially adjusted results;
* 17 IPD studies only gave the partially adjusted result.

* We use the meta-analysis data as reported in here:
* The Fibrinogen Studies Collaboration. Systematically missing confounders 
* in individual participant data meta-analysis
* of observational cohort studies. Stat Med. 2009;28:1218-37.

* The authors used a Cox model to obtain fully and partially adjusted HRs.
* From the IPD, bootstraping was used to derive the within-study correlations 
* in those 14 studies that provided both (as we just did in practical 4a).

* Open the file 'fibrinogen'; here we have the data derived from the IPD.

* y1 is the fully adjusted logHR, se1 its standard error & v11 its variance
* y2 is the partially adjusted logHR, se2 its standard error & v22 its variance
* wscorr is the within-study correlation
* v12 is the within-study covariance

* To run a multivariate meta-analysis, we need to tell mvmeta the data;
* mvmeta wants to know the effect label (here, y) and the var-cov label (here v)
* It then automatically looks for the numbering after the label to define the
* outcome number and the entry of the var-cov matrix.

* Let us start with a univariate meta-analysis for the fully adjusted result.
* Let us use random effects and REML.
* Recall admetan can do this as follows:
admetan y1 se1, re(reml)


* mvmeta also allows this. First install mvmeta using the following link:
net install mvmeta, from("http://www.mrc-bsu.cam.ac.uk/IW_Stata/meta")

* Now use mvmeta to do the same univariate meta-analysis:
mvmeta y v, nounc vars(y1)

* Q1: Are the results for metaan and mvmeta the same? 
* [LEARNING POINT: the vars(y1) option tell mvmeta to just look at y1 outcome.]


* The 'nounc' option tells mvmeta to not inflate the variance of pooled 
* estimates; I  removed this to maintain compatability with metaan.
* But we should use it really, to account for uncertainty.
* Let us therefore do this:
mvmeta y v, vars(y1)

* Q2: Does accounting for additional uncertainty change conclusions?


* Did you spot that mvmeta issued a warning message that 17 studies 
* were removed from the analysis?

* Q3: Why were 17 studies dropped?



* Let us now do a bivariate meta-analysis, to include all 31 studies,
* and to borrow strength between the partially and fully adusted results.
mvmeta y v

* Q4: Compare the multivariate fully adjusted pooled estimate 
* with the univariate fully adjusted pooled estimate
* - what do we gain by using mvmeta?

* [It may be helpful to also compare the pooled HRs rather than log HRs]
mvmeta y v, eform vars(y1)
mvmeta y v, eform


* The extra gain from the multivariate meta-analysis is due to the 
* borrowing of strength. We can obtain the study weights and BoS statistics
* by including the 'wt' option:
mvmeta y v, eform wt

* Q5: What is BoS for the fully adjusted and the partially adjusted results?
*     - Why is BoS so much lower for the partially adjusted result?

* Q6: What was BoS in the univariate meta-analysis?
* HINT: run
 mvmeta y v, eform vars(y1) wt
 
* Also compare the weight of study 30 in the multivariate meta-analysis
* with its weight in the univariate meta-analysis toward the fully adjusted result


* Unfortunately, there is no automated forest plot using mvmeta yet.
* But it is relatively easy to use admetan and force in the mvmeta result.

* Firstly, to save the BoS data from mvmeta,
* you will need to install an additional package called "sencode"
* if you don't already have it.
ssc install sencode

* Now to begin. There are several parts to the process:

* 1. Save the multivariate weights and BoS statistics
preserve
	mvmeta y v, wt(details clear)
	keep if covariate==1
	keep id source scaled
	rename scaled wt
	reshape wide wt, i(id) j(source)
	rename (wt1 wt2 wt3) (borrowed direct total)
	label variable borrowed   "Multivariate weight (%)"
	label variable direct     "Multivariate BoS (%)"
	format borrowed direct %5.2f
	save multivariate
restore

* ... and save the multivariate pooled estimate
lincom y1
scalar multi_eff = r(estimate)
scalar multi_se = r(se)


* 2. Run the univariate analysis using admetan
* and save the dataset
admetan y1 se1, study(study) re(reml) nogr keepall keeporder ///
	saving(univariate)


* 3. Load and merge together the univariate and multivariate datasets
preserve
	use univariate, clear
	gen byte id = _STUDY
	merge 1:1 id using multivariate, nogen
	replace _LABELS = "Univariate meta-analysis: Overall" if _USE==5
	
	* Manipulate the dataset to create the forestplot:
	* Add multivariate pooled estimate
	gen expand = 2*(_USE==5)
	expand expand
	local N = _N
	replace _ES   = multi_eff in `N'
	replace _seES = multi_se  in `N'
	replace _LCI  = _ES - invnorm(.975)*_seES in `N'
	replace _UCI  = _ES + invnorm(.975)*_seES in `N'
	
	summ direct, meanonly
	replace _LABELS = "Multivariate meta-analysis: Overall (BoS = " + string(r(sum), "%4.1f") + "%)" in `N'
	
	gen univariate = cond(missing(_WT), 0, 100*_WT) if _USE<5
	label variable univariate "Univariate weight (%)"
	format univariate %5.2f
	format _LABELS %-5s
	
	* Finally, create forestplot
	forestplot, hr keepall nowt noinsuff lcols(univariate borrowed direct) xlabel(.75 1 1.25 1.5 2, force)
restore



* However, this is quite a complex sequence of commands.
* To simplify matters, I have done most of the work for you.
* Open the dataset 'Fibrinogen for plot'.
* The code below should give you a forest plot that allows
* you to display the univariate and multivariate results.

* N.B. we need to use metan for this, as admetan hasn't (yet) got
* some of the more obscure options used here.
* (as admetan aims for total flexibility rather than a selective list of options)

metan hrfully lowerhrfully upperhrfully , nowt effect(hazard ratio) ///
	first(1.31 1.22 1.42 Univariate meta-analysis:)  wgt( mvmetaweight) ///
	secondstats(BoS 53.3%) second(1.31 1.25 1.38 Multivariate meta-analysis:) ///
	astext(60) texts(100) olineopt(lwidth(none) lcolor(white)) nobox ///
	xtitle(hazard ratio, size(small)) xlab(0.75,1.25,1.5, 2) null(1) ///
	force lcols(Study uvmetaweight mvmetaweight  mvmetabos )
* NB The 'excluded' parts of the plot should be airbrushed out.

