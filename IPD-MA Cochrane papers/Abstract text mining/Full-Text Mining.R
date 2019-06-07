install.packages("pdftools")
library(pdftools)

setwd("IPD-MA Cochrane papers/7. sample of IPD-MAs/")
files <- list.files(pattern = "pdf$")


opinions <- lapply(files, pdf_text)



install.packages("tm")
library(tm)


corp <- Corpus(URISource(files),
               readerControl = list(reader = readPDF))


opinions.tdm <- TermDocumentMatrix(corp, 
                                   control = 
                                     list(removePunctuation = TRUE,
                                          stopwords = TRUE,
                                          tolower = TRUE,
                                          stemming = TRUE,
                                          removeNumbers = TRUE,
                                          bounds = list(global = c(3, Inf)))) 


inspect(opinions.tdm[1:10,]) 




library(dplyr)
library(janeaustenr)
library(tidytext)



