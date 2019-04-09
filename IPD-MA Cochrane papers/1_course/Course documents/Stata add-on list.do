* Please run this do file 
* Select 'Tools' from the toolbar, and select 'Execute (do)' 

ssc install metan, replace
ssc install metaan, replace
ssc install stmixed, replace
ssc install stpm2, replace
ssc install rcsgen, replace
ssc install ipdmetan, replace
ssc install moremata, replace
ssc install metareg, replace
ssc install ipdforest, replace
ssc install metabias, replace
ssc install sencode

net install gr0033_1, replace force from(http://www.stata-journal.com/software/sj9-2)

net install network, replace force from(http://fmwww.bc.edu/repec/bocode/n)
net install mvmeta, replace force from(http://fmwww.bc.edu/repec/bocode/m)

net install network
ssc install mvmeta 

* replaced http://www.mrc-bsu.cam.ac.uk/IW_Stata/meta (as original source) with 

* mvmeta
* https://ideas.repec.org/c/boc/bocode/s456970.html
* http://fmwww.bc.edu/repec/bocode/m/

* network
* https://ideas.repec.org/c/boc/bocode/s458319.html
* http://fmwww.bc.edu/repec/bocode/n/
