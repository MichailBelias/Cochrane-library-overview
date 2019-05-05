# This is a test code for extracting  the goal of the study 
# from the abstract



## Call the libraris

library(easyPubMed)
library(dplyr)
library(kableExtra)
library(readxl)
library(xlsx)
library(parallel)
library(foreach)
library(doParallel)
library(readxl)




keywords =  c("assess", "examine", "evaluate", "establish" ," provide", "investigate" , "goal")

Keyword_in_Abs = list()
Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 4137, ncol = 1))
colnames(Keyword_in_Abs_DF) = "Search in Abstracts"

for ( i in 1:4137){
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



# Now As a second step  
# We will search for the primary and secondary outcomes
# in the abstract

keywords =   c("primary", "secondary")

Keyword_in_Abs = list()
Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 4137, ncol = 1))

for ( i in 1:4137){
  temp = vector()
  for ( j in 1: length( Abstracts[[i]])){
    temp[j] = any(keywords %in% unlist(strsplit(Abstracts[[i]][j], split =  " ") ))
  }
  
  if (any(temp)){
    Keyword_in_Abs_DF[i,] = paste(Abstracts[[i]][which(temp)], collapse = " ")
  }else{
    Keyword_in_Abs_DF[i,] = NA
  }
  
  if(is.na(IPD_MA[i,]$`Type of primary outcome`)){
    IPD_MA[i,]$`Type of primary outcome` = Keyword_in_Abs_DF[i,]
  }
  
}

table(is.na(IPD_MA$`Type of primary outcome`))


# First we download the abstract
IPD_MA <- read_excel("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet =  "Pub med IPD-MA articles")
IPD_MA[IPD_MA == "NA"] <- NA
# write.xlsx(IPD_MA , "IPD-MA Cochrane papers/temp.xlsx")
# Query pubmed and fetch many results

Abstracts =  (strsplit(as.character(IPD_MA$Abstract), split =  "(?<=[[:punct:]])\\s(?=[A-Z])",  perl = T))

IPD_MA$Goal =  as.character(IPD_MA$Goal)
IPD_MA$`Type of primary outcome` =  as.character(IPD_MA$`Type of primary outcome`)
IPD_MA$`Type of studies
 included` =  as.character(IPD_MA$`Type of studies
 included`)


keywords =   c("randomised", "RCT" ,"RCTs")

Keyword_in_Abs = list()
Keyword_in_Abs_DF = data.frame(matrix(NA, nrow = 4137, ncol = 1))

for ( i in 1:4137){
  temp = vector()
  for ( j in 1: length( Abstracts[[i]])){
    temp[j] = any(keywords %in% unlist(strsplit(Abstracts[[i]][j], split =  " ") ))
  }
  
  if (any(temp)){
    Keyword_in_Abs_DF[i,] = paste(Abstracts[[i]][which(temp)], collapse = " ")
  }else{
    Keyword_in_Abs_DF[i,] = NA
  }
  
  if(is.na(IPD_MA[i,]$`Type of primary outcome`)){
    IPD_MA[i,]$`Type of studies
 included` = Keyword_in_Abs_DF[i,]
  }
  
}

table(is.na(Keyword_in_Abs_DF))



write.xlsx(IPD_MA , "IPD-MA Cochrane papers/temp.xlsx")

