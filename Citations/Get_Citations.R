library(easyPubMed)
library(dplyr)
library(kableExtra)
library(readxl)
library(xlsx)
library(parallel)
library(foreach)
library(doParallel)


IPD.MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")

Pubmed_results =  readxl::read_xlsx("IPD-MA Cochrane papers/pubmed_result.xlsx")

# Query pubmed and fetch many results
my_query <- c(paste(Pubmed_results$EntrezUID[1], "[uid]",sep = ""),
              paste(" OR ",Pubmed_results$EntrezUID[2:4137], "[uid]",sep = ""))




for (h in 1: ceiling(length(my_query)/200)){
# Starting time: record
t.start <- Sys.time()
print(h)
l= (200*(h-1)+1)
u= 200*(h)

z= my_query[l:u][!is.na(my_query[l:u])]

my_query_mini = paste(z,collapse=" ")
!is.na(my_query_mini)
my_pubmed_ids <-  get_pubmed_ids(my_query_mini)

print("Fetching complete")

# Download by 1000-item batches
my_batches <- seq(from = 1, to = my_pubmed_ids$Count, by = 200)
my_abstracts_xml <- lapply(my_batches,  function(i) {
fetch_pubmed_data(my_pubmed_ids, retmax = 1000, retstart = i)  
})

print("download XMLs complete")

# Store Pubmed Records as elements of a list
all_xml <- list()
for(x in my_abstracts_xml) {
xx <- articles_to_list(x)
for(y in xx) {
all_xml[[(1 + length(all_xml))]] <- y
}  
}

print("download all XMLs")


# Perform operation (use lapply here, no further parameters)

if(h==1){
final_df <- do.call(rbind, lapply(all_xml, article_to_df, 
max_chars = -1, getAuthors = F, getKeywords = T))
}else{

intermidiate =  do.call(rbind, lapply(all_xml, article_to_df, 
max_chars = -1, getAuthors = F, getKeywords = T))
final_df <- rbind(final_df, intermidiate)

}
# Final time: record
t.stop <- Sys.time()

#How long did it take?
print(t.stop - t.start)

}


rm(list =ls()[! ls() %in% c("IPD.MA","IPD.MA","final_df", "Pubmed_results")])

# Show an excerpt of the results
final_df = final_df[,-which(names(final_df) %in% c("month", "day", "jabbrv","lastname" , "firstname", "address", "email"))]  

names(final_df)[1] =  "EntrezUID"

final_df[,1] = as.numeric(final_df[,1])
final_df = Pubmed_results %>% left_join(final_df, by = "EntrezUID")


IPD_MA =  as.data.frame(matrix(NA,nrow = dim(final_df)[1], ncol = dim(IPD.MA)[2], dimnames = list(1:dim(final_df)[1],colnames(IPD.MA))))

for (i in 1:dim(IPD_MA)[1]){
  print(paste( floor(i*100/dim(IPD_MA)[1]), "% is complete", sep = ""))
  
  if(final_df[i,]$EntrezUID  %in%  IPD.MA$EntrezUID){
    IPD_MA[i,] =  IPD.MA[which(IPD.MA$EntrezUID == final_df[i,]$EntrezUID),]
  }else{
    IPD_MA[i,]$PMID = final_df[i,]$EntrezUID
    IPD_MA[i,]$doi =  final_df[i,]$doi
    IPD_MA[i,]$`Title of trial` = final_df[i,]$title
    IPD_MA[i,]$Abstract = final_df[i,]$abstract
    IPD_MA[i,]$Year = final_df[i,]$year
    IPD_MA[i,]$Journal = final_df[i,]$journal
    IPD_MA[i,]$Keywords = final_df[i,]$keywords
    IPD_MA[i,]$Authors = final_df[i,]$Description
    IPD_MA[i,]$Hyperlink = paste("https://www.ncbi.nlm.nih.gov/", final_df[i,]$URL)
    }
  cat("\014") 
    
}
rm(i)

IPD_MA[IPD_MA == "NA"] <- NA
IPD_MA$...26  =  final_df$Details
names(IPD_MA)[26]  =  "Details"

# We  run one more the getPubMed for the articles that didn't download

NA_IPD = IPD_MA[which(is.na(IPD_MA$Journal)),]


# Query pubmed and fetch many results
my_query <- c(paste(NA_IPD$PMID[1], "[uid]",sep = ""),
              paste(" OR ",NA_IPD$PMID[2:dim(NA_IPD)[1]], "[uid]",sep = ""))

# Starting time: record
t.start <- Sys.time()


z= my_query[1:dim(NA_IPD)[1]][!is.na(my_query[1:dim(NA_IPD)[1]])]

my_query_mini = paste(z,collapse=" ")
!is.na(my_query_mini)
my_pubmed_ids <-  get_pubmed_ids(my_query_mini)

print("Fetching complete")

# Download by 1000-item batches
my_batches <- seq(from = 1, to = my_pubmed_ids$Count, by = dim(NA_IPD)[1])
my_abstracts_xml <- lapply(my_batches,  function(i) {
  fetch_pubmed_data(my_pubmed_ids, retmax = 1000, retstart = i)  
})

print("download XMLs complete")

# Store Pubmed Records as elements of a list
all_xml <- list()
for(x in my_abstracts_xml) {
  xx <- articles_to_list(x)
  for(y in xx) {
    all_xml[[(1 + length(all_xml))]] <- y
  }  
}

print("download all XMLs")


# Perform operation (use lapply here, no further parameters)

final_df2 <- do.call(rbind, lapply(all_xml, article_to_df, max_chars = -1, getAuthors = F, getKeywords = T))

# Final time: record
t.stop <- Sys.time()

#How long did it take?
print(t.stop - t.start)


rm(list =ls()[! ls() %in% c("IPD.MA","IPD.MA","final_df", "final_df2", "Pubmed_results", "IPD_MA")])



for(i in which(!is.na(as.numeric(IPD_MA$PMID)))){
  
  IPD_MA[i,]$EntrezUID = IPD_MA[i,]$PMID 
  IPD_MA[i,]$PMID =  paste("PMID :",IPD_MA[i,]$PMID )
  
  
}



names(final_df2)[1] =  "EntrezUID"

final_df2[,1] = as.numeric(final_df2[,1])

final_df2 = final_df2 %>%left_join( Pubmed_results, by = "EntrezUID")


for( i in 1:dim(final_df2)[1]){
  
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$EntrezUID 
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$doi =  final_df2[i,]$doi
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$`Title of trial` = final_df[i,]$title
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$Abstract = final_df2[i,]$abstract
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$Year = final_df2[i,]$year
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$Journal = final_df2[i,]$journal
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$Keywords = final_df2[i,]$keywords
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$Authors = final_df2[i,]$Description
  IPD_MA[IPD_MA$EntrezUID == final_df2[i,]$EntrezUID,]$Hyperlink = paste("https://www.ncbi.nlm.nih.gov", final_df2[i,]$URL,sep = "")
  
}



IPD_MA.final =  IPD_MA[,-c(28,29) ]


write.xlsx2(IPD_MA.final, "IPD-MA Cochrane papers/6. Data/IPD_test.xlsx")
rm(list =ls())
IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/6. Data/IPD_test.xlsx", sheet= 1)




Abstracts = list()


for(i in 1:4137){
  
  Abstracts[[i]] = unlist(strsplit(IPD.MA[i,]$Abstract, "(?<=[[:punct:]])\\s(?=[A-Z])", perl=T))
  
}


names(Abstracts) = paste( "Total sentences: ",sapply(Abstracts, length ))


Abstracts[[1]][1]

lapply(Abstracts, function(x) length(x))

Check =  matrix(NA, nrow = 4137 , ncol = 5 ,dimnames = list(1:4137, c("trial", "randomised", "randomised clinical", "randomised controlled", "RCT")) )
for(i in 1:4137){
  
  Check[i,] = c("trial", "randomised", "randomised clinical", "randomised controlled", "RCT") %in% unlist(strsplit(IPD.MA[i,]$Abstract, split = " "))

}
Check = as_data_frame(Check)
head(Check)
Any_TRUE =  apply(Check, MARGIN = 1, any)
Check$Any_TRUE = Any_TRUE
# If interested in specific information,
# you can subset the dataframe and save the
# desired columns/features
RCTs = IPD.MA[which(Any_TRUE),c("PMID", "Abstract")] 



### Check if Cohort Trials are included

Check =  matrix(NA, nrow = 4137 , ncol = 1 ,dimnames = list(1:4137, c("RCT")) )

for(i in 1:4137){
  
  Check[i,] = c("Children") %in% unlist(strsplit(IPD.MA[i,]$Abstract, split = " "))
  
}

IPD.MA[which(Check),]$Abstract
Children = IPD.MA[which(Check),c("PMID", "Journal", "Title of trial","General Medical Field", "Abstract")]
IPD.MA[which(Check),c("PMID", "Abstract")] %>%
  kable() %>% kable_styling(bootstrap_options = 'striped')

