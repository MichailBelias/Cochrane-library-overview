library(easyPubMed)
library(dplyr)
library(kableExtra)
library(readxl)
library(xlsx)
library(parallel)
library(foreach)
library(doParallel)


IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")
# Query pubmed and fetch many results
my_query <- c(paste(IPD_MA$EntrezUID[1], "[uid]",sep = ""),
              paste(" OR ",IPD_MA$EntrezUID[2:4137], "[uid]",sep = ""))


for (h in 1: 21){
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
max_chars = -1, getAuthors = FALSE, getKeywords = T))
final_df <- rbind(final_df, intermidiate)

}
# Final time: record
t.stop <- Sys.time()

#How long did it take?
print(t.stop - t.start)

}


rm(list =ls()[! ls() %in% c("IPD_MA","final_df")])

# Show an excerpt of the results
final_df[,c("pmid", "year", "abstract")]  %>%
  head() %>% kable() %>% kable_styling(bootstrap_options = 'striped')



names(IPD_MA)[which(names(IPD_MA) == "...24")] = "keywords"

for(i in 1:4137){
  print(i)
  if(IPD_MA[i,]$EntrezUID %in%  final_df$pmid){
  IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$Journal = final_df[ final_df$pmid == IPD_MA[i,]$EntrezUID,]$journal
  IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$doi = final_df[ final_df$pmid == IPD_MA[i,]$EntrezUID,]$doi
  IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$Abstract = final_df[ final_df$pmid == IPD_MA[i,]$EntrezUID,]$abstract
  IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$keywords = final_df[ final_df$pmid == IPD_MA[i,]$EntrezUID,]$keywords
  }else{
    IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$doi = NA
    IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$Abstract = NA
    IPD_MA[IPD_MA$EntrezUID == IPD_MA[i,]$EntrezUID,]$keywords = NA
  }
  
}

write.xlsx2(x = IPD_MA, file = "IPD-MA Cochrane papers/temp.xlsx")

IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")


Abstracts = list()


for(i in 1:4137){
  
  Abstracts[[i]] = unlist(strsplit(IPD_MA[i,]$Abstract, "(?<=[[:punct:]])\\s(?=[A-Z])", perl=T))
  
}


names(Abstracts) = paste( "Total sentences: ",sapply(Abstracts, length ))


Abstracts[[1]][1]

lapply(Abstracts, function(x) length(x))

Check =  matrix(NA, nrow = 4137 , ncol = 5 ,dimnames = list(1:4137, c("trial", "randomised", "randomised clinical", "randomised controlled", "RCT")) )
for(i in 1:4137){
  
  Check[i,] = c("trial", "randomised", "randomised clinical", "randomised controlled", "RCT") %in% unlist(strsplit(IPD_MA[i,]$Abstract, split = " "))

}
Check = as_data_frame(Check)
head(Check)
Any_TRUE =  apply(Check, MARGIN = 1, any)
Check$Any_TRUE = Any_TRUE
# If interested in specific information,
# you can subset the dataframe and save the
# desired columns/features
RCTs = IPD_MA[which(Any_TRUE),c("PMID", "Abstract")] 



### Check if Cohort Trials are included

Check =  matrix(NA, nrow = 4137 , ncol = 1 ,dimnames = list(1:4137, c("RCT")) )

for(i in 1:4137){
  
  Check[i,] = c("Children") %in% unlist(strsplit(IPD_MA[i,]$Abstract, split = " "))
  
}

IPD_MA[which(Check),]$Abstract
Children = IPD_MA[which(Check),c("PMID", "Journal", "Title of trial","General Medical Field", "Abstract")]
IPD_MA[which(Check),c("PMID", "Abstract")] %>%
  kable() %>% kable_styling(bootstrap_options = 'striped')

