AGI_accession = c()
Annotation = c()
ProteinType = c()
NumberOfDomains = c()

for (i in gene) {
  AramemHTML = read_html(paste0('https://aramemnon.botanik.uni-koeln.de/seq_view.ep?search=',i))
  Result <- AramemHTML %>% html_nodes('p')
  ResultText <- gsub('[\t\n]', '', html_text(Result[grep("headtopbox", Result)]))
  if (grepl("protein result(s)", ResultText,  fixed = TRUE) == 1) {
    AGI_Output <- AramemHTML %>% html_nodes('tr') %>% html_nodes('ul') %>% html_nodes('span')
    AGI_accession[i] <- gsub("[\t\n]", "", html_text(AGI_Output[1]))
    Annotation_Output <- AramemHTML %>%  html_nodes(".specT")
    Annotation [i] <-  gsub("[\t\n]", "", html_text(Annotation_Output[1]))
    DetermineProteinType <- AramemHTML %>%  html_nodes(".sideTS") %>%  html_children() %>%  html_children() %>% html_attrs()
    if (DetermineProteinType[[2]][["src"]] == "./Gifs/T10.gif"|DetermineProteinType[[2]][["src"]] == "./Gifs/T01.gif"){
      ProteinType[i] = 'membrane protein'
    } else{
      ProteinType[i] = 'soluble or peripheral protein'
    }
    if (ProteinType[i] == 'membrane protein'){
      DomainSearch <- AramemHTML %>%  html_nodes(".sideTS") %>% html_element("a") %>% html_attr("href")
      DomainSearch <- str_split(DomainSearch[1], "\" ")
      DomainSearch <- unlist(str_extract_all(DomainSearch[[1]][1],"\\(?[0-9]+\\)?"))
      DomainSearchNextPage <- read_html(paste0('https://aramemnon.botanik.uni-koeln.de/tm_sub.ep?GeneID=', DomainSearch[1], '&ModelID=0'))
      BBProtein <- DomainSearchNextPage %>% html_element('table') %>% html_nodes("div")
      BBProtein <- gsub('[\t\n]', '', html_text(BBProtein[grep("Beta barrel TM protein predictions", BBProtein)]))
      if (length(BBProtein) == 0) {
        DomainSearchNextPage <- DomainSearchNextPage %>% html_element('table') %>% html_nodes(xpath = '//*[@id="map0"]/area')
        DomainSearchNextPage <- str_split(grep("TmConsens consensus prediction", DomainSearchNextPage, value = TRUE), "\" ")
        DomainSearchNextPage <- unlist(str_extract_all(DomainSearchNextPage[[1]][5],"\\(?[0-9]+\\)?"))
        Coordinate1 <- DomainSearchNextPage[3]
        Coordinate2 <- DomainSearchNextPage[5]
        DomainSearchFinalPage <- read_html(paste0('https://aramemnon.botanik.uni-koeln.de/tm_sub2.ep?GeneID=', DomainSearch[1], '&ModelID=', Coordinate1, '&MethodID=', Coordinate2))
        DomainSearchFinalPage <- DomainSearchFinalPage %>% html_element('table') %>% html_nodes(".sideT")
        NumberOfDomains[i] <- max(as.numeric(grep('^-?[0-9.]+$', html_text(DomainSearchFinalPage), val = T)))
        if (NumberOfDomains[i] == '-Inf') {
          NumberOfDomains[i] = 0
        } else {
          NumberOfDomains[i]
        }
      } else{NumberOfDomains[i] = 'Beta-barrel'}}
    else{
      NumberOfDomains[i] = '0'
    }
  } else {
    AGI_accession[i] = 'please check AGI input'
    Annotation[i] = ''
    ProteinType[i] = ''
    NumberOfDomains[i] = ''
  }
}

output1 <- data.frame(AGI_accession, Annotation, ProteinType, NumberOfDomains)
output1$Annotation <- sapply(output1$Annotation, function(x) ifelse(grepl('\\s{2}', x)==TRUE, substr(x, 1, str_locate(x, "\\s{2}")[1, 'start']-1), x))
return(output1)