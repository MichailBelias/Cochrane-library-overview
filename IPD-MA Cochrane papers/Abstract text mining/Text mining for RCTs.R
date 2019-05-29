#### Full text 
## with this 
library(easyPubMed)
library(dplyr)
library(kableExtra)
library(readxl)
library(xlsx)
library(parallel)
library(foreach)
library(doParallel)

IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/6. Data/New search in Pubmed.xlsx", sheet= 1)


#IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")
IPD_MA[IPD_MA == "NA"] <- NA
# Get Abstract in a list
Abstracts = list()


for(i in 1:1538){
  
  Abstracts[[i]] = unlist(strsplit(IPD_MA[i,]$Abstract, "(?<=\\.)\\s(?=[A-Z])", perl=T))
  
}

### Find phrases such as randomised clinical trials , cohort studies, etc
check =  grep("randomised clinical | randomised controlled | prospective | case-controls | case-reports | RCT | randomised control | placebo | cohort studies | observational studies| randomized clinical | randomized controlled | RCT | randomized control | placebo ",
              lapply(Abstracts, tolower))

Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 1538, ncol = 1)); colnames(Keyword_in_Abs_DF) = "Search in Abstracts"

for ( i in check){
temp = vector()
temp = grep("randomised clinical | randomised controlled | prospective | case-controls | case-reports | RCT | randomised control | placebo | cohort studies | observational studies| randomized clinical | randomized controlled | RCT | randomized control | placebo ",
            lapply(Abstracts[[i]], tolower),value = F)
print(temp)
  
if (!is.na(any(temp))){
    Keyword_in_Abs_DF[i,] = paste(Abstracts[[i]][temp], collapse = " ")
  }else{
    Keyword_in_Abs_DF[i,] = NA
  }
  
  if(is.na(IPD_MA[i,]$`Type of studies included`)){
    IPD_MA[i,]$`Type of studies included` = Keyword_in_Abs_DF[i,]
    print("Extra")
  }
}

table(is.na(Keyword_in_Abs_DF))

keywords = c("assess", "assessed", "examine","examined", "evaluate", "establish", "explore","purpose", 
             "provide", "investigate","investigated" , "goal", "understand", "aim", "aimed",
             "identify", "determine", "predict", "conduct","conducted", "aimed")

Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 1538, ncol = 1))
colnames(Keyword_in_Abs_DF) = "Search in Abstracts"

for ( i in 1:1538){
  temp = vector()
  for ( j in 1: length( Abstracts[[i]])){
    temp[j] = any(keywords %in% unlist(strsplit(Abstracts[[i]][j], split =  " ") ))
  }
  
  if (any(temp)){
    Keyword_in_Abs_DF[i,] = paste(Abstracts[[i]][which(temp)], collapse = " ")
  }else{
    Keyword_in_Abs_DF[i,] = NA
  }
  
  if(is.na(IPD_MA[i,]$Goal)){
    IPD_MA[i,]$Goal = Keyword_in_Abs_DF[i,]
  }
}

table(is.na(Keyword_in_Abs_DF))


IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/6. Data/New search in Pubmed.xlsx", sheet= 1)


#IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")
IPD_MA[IPD_MA == "NA"] <- NA
# Get Abstract in a list
Abstracts = list()

for(i in 1:1538){
  
  Abstracts[[i]] = unlist(strsplit(IPD_MA[i,]$Abstract, "(?<=\\.)\\s(?=[A-Z])", perl=T))
  
}

### Find phrases diagnostic studies, etc
check =  grep("diagnostic", lapply(Abstracts, tolower))

Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 4137, ncol = 1)); colnames(Keyword_in_Abs_DF) = "Search in Abstracts"

for ( i in check){
  temp = vector()
  temp = grep("diagnostic", 
              lapply(Abstracts[[i]], tolower),value = F)
  print(temp)
  
  if (!is.na(any(temp))){
    Keyword_in_Abs_DF[i,] = paste(Abstracts[[i]][temp], collapse = " ")
  }else{
    Keyword_in_Abs_DF[i,] = NA
  }
  
  if(is.na(IPD_MA[i,]$`IPD meta-analysis Review Guidelines Methodological`)){
    IPD_MA[i,]$`IPD meta-analysis Review Guidelines Methodological`= Keyword_in_Abs_DF[i,]
    print("Extra")
  }
}


IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/6. Data/New search in Pubmed.xlsx", sheet= 1)


#IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")
IPD_MA[IPD_MA == "NA"] <- NA
# Get Abstract in a list
Abstracts = list()

for(i in 1:1538){
  
  Abstracts[[i]] = unlist(strsplit(IPD_MA[i,]$Abstract, "(?<=\\.)\\s(?=[A-Z])", perl=T))
  
}

### Find phrases "We included xxx trials and xxx participants"
check =  grep("randomised clinical | randomised controlled | prospective | case-controls | case-reports | RCT | randomised control | placebo | cohort studies | observational studies| randomized clinical | randomized controlled | RCT | randomized control | placebo ",
              lapply(Abstracts, tolower))

Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 1538, ncol = 1)); colnames(Keyword_in_Abs_DF) = "Search in Abstracts"

for ( i in check){
  temp = vector()
  temp = grep("randomised clinical | randomised controlled | prospective | case-controls | case-reports | RCT | randomised control | placebo | cohort studies | observational studies| randomized clinical | randomized controlled | RCT | randomized control | placebo ",
              lapply(Abstracts[[i]], tolower),value = F)
  print(temp)
  
  if (!is.na(any(temp))){
    Keyword_in_Abs_DF[i,] = paste(Abstracts[[i]][temp], collapse = " ")
  }else{
    Keyword_in_Abs_DF[i,] = NA
  }
  
  if(is.na(IPD_MA[i,]$`Type of studies included`)){
    IPD_MA[i,]$`Type of studies included` = Keyword_in_Abs_DF[i,]
    print("Extra")
  }
}

# Query pubmed and fetch many results
c(paste(IPD_MA$EntrezUID[1], "[uid]",sep = ""),
              paste(" OR ",IPD_MA$EntrezUID[2:300], "[uid]",sep = ""))


write.xlsx(IPD_MA , "IPD-MA Cochrane papers/6. Data/IPD_test.xlsx", showNA = F)



