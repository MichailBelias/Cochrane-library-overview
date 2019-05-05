library(xlsx)

IPD_MA = readxl::read_xlsx("IPD-MA Cochrane papers/IPD-MAs in General.xlsx", sheet = "Pub med IPD-MA articles")
IPD_MA[,c("PMID", "Abstract")] 

Check =  matrix(NA, nrow = 4137*2)
for(i in 1:4137){
  Check[2*i - 1] = IPD_MA[i,"PMID"] 
  Check[2*i] = IPD_MA[i,"Abstract"] 
}

Check =  as.data.frame(Check)
write.xlsx2(x = unlist(Check), file = "IPD-MA Cochrane papers/Abstacts.xlsx")


download.file(url = "IPD-MA Cochrane papers/paper.pdf", "https://sci-hub.tw/10.1176/appi.ajp.2017.17040472")



download.file(url = "https://sci-hub.tw/10.1176/appi.ajp.2017.17040472", 'IPD-MA Cochrane papers/paper.pdf', mode="wb")



for (i in 1:4137){
  
  url = paste("https://sci-hub.tw/", IPD_MA[i,]$doi, sep = "")
  name = paste(IPD_MA[i,]$`Title of trial`, paste(IPD_MA[i,]$Year, ".pdf",sep = ""), sep = " ")
  destination= "IPD-MA Cochrane papers/"
  download.file(url = url, paste(destination, name, sep = ""), mode="wb")
  
  }



rm(list =ls()[! ls() %in% c("IPD_MA","final_df")])

  

