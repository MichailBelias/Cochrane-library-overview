c("ketamine","quetiapine","Lithium","olanzapine","paroxetine","ssris","methylphenidate","paliperidone","amisulpride",
"Haloperidol","penfluridol","pimozide","chloropromazine","fluphenazine","levopromazine","perphenazine","clopenthixole",
"zuclopenthixol","loxapine","lurasidone","risperidone","ziprasidone","aripiprazole","cariprazine","asenapine","clozapine","sertraline","citalopram","fluoxetine","Escitalopram","trazodone","venlafaxine","bupropion","duloxetine","amitryptiline","mirtazapine","benzodiazepine","diazepam","alprazolam",
"lorazepam","midazolam","triazolam","bromazepam","carbamazepine","valproic","valproate")



library(readxl)
library(knitr)
library(dplyr)
library(ggpubr)
library(kableExtra)

IPD_MA <- read_xlsx("IPD-MA Cochrane papers/6. Data/New search in Pubmed.xlsx",  sheet = 1)
IPD_MA[IPD_MA == "NA"] <- NA
IPD_MA <- as.data.frame(IPD_MA)
download = IPD_MA%>%
  filter(`General Medical Field` !=  "Statistical") %>%
  filter(!is.na(`General Medical Field`))

for ( i in 210:dim(download)[1]){
  Sys.sleep(time = 1 )
  browseURL(paste("https://sci-hub.tw/",download$doi[i], sep = ""), browser = getOption("browser"), encodeIfNeeded = FALSE)
  print(download[i,]$`Title of trial`)
}

for ( i in 1:86){
  download.file(url = paste("https://sci-hub.tw/",IPD_MA$doi[i], sep = ""),
                destfile = paste("IPD-Overview papers/", IPD_MA$`Title of trial`[i], "pdf", sep = ""), mode = "w",
                cacheOK = TRUE, extra = getOption("download.file.extra"))
  print(i)
  
}
