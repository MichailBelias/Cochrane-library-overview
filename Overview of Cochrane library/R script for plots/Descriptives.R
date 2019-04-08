library(readxl)
IPD_MA_Cochrane <- read_excel("~/Downloads/IPD-MA_Cochrane.xlsx", 
                              sheet = "Sheet2")
View(IPD_MA_Cochrane)



IPD_MA_Cochrane$Studies = as.numeric(IPD_MA_Cochrane$Studies)
IPD_MA_Cochrane$Participants= as.numeric(IPD_MA_Cochrane$Participants)




hist(IPD_MA_Cochrane$Studies, xlab = "Number of trials per meta-analysis", main = "Histogram of studies per meta-analysis" )
hist(IPD_MA_Cochrane$Participants, xlab = "Number of participants per meta-analysis", main = "Histogram of participants per meta-analysis")



