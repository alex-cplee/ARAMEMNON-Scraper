output1 <- data.frame(
  matrix(ncol = 4,
         nrow = 0, 
         dimnames=list(NULL, c("AGI_accession", "Annotation", "ProteinType", "NumberOfDomains"))
  )
)

for (i in gene) {
  AramemHTML = read_html(paste0('https://aramemnon.botanik.uni-koeln.de/seq_view.ep?search=',i))
  Result <- AramemHTML %>% html_nodes('p')
  ResultText <- gsub('[\t\n]', '', html_text(Result[grep("headtopbox", Result)]))
  if (grepl("protein result(s)", ResultText,  fixed = TRUE) == 1) {
    AGI_Output <- AramemHTML %>% html_nodes('tr') %>% html_nodes('ul') %>% html_nodes('span')
    AGI_accession <- gsub("[\t\n]", "", html_text(AGI_Output[1]))
    Annotation_Output <- AramemHTML %>%  html_nodes(".specT")
    Annotation <-  gsub("[\t\n]", "", html_text(Annotation_Output[1]))
    DetermineProteinType <- AramemHTML %>%  html_nodes(".sideTS") %>%  html_children() %>%  html_children() %>% html_attrs()
    if (DetermineProteinType[[2]][["src"]] == "./Gifs/T10.gif"|DetermineProteinType[[2]][["src"]] == "./Gifs/T01.gif"){
      ProteinType = 'membrane protein'
    } else{
      ProteinType = 'soluble or peripheral protein'
    }
    if (ProteinType == 'membrane protein'){
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
        NumberOfDomains <- max(as.numeric(grep('^-?[0-9.]+$', html_text(DomainSearchFinalPage), val = T)))
        if (NumberOfDomains == '-Inf') {
          NumberOfDomains = 0
        } else {
          NumberOfDomains
        }
      } else{NumberOfDomains = 'Beta-barrel'}}
    else{
      NumberOfDomains = '0'
    }
  } else {
    AGI_accession = 'please check AGI input'
    Annotation = ''
    ProteinType = ''
    NumberOfDomains = ''
  }
  Annotation <- ifelse(grepl('\\s{2}', Annotation)==TRUE, 
                          substr(Annotation, 1, str_locate(Annotation, "\\s{2}")[1, 'start']-1), 
                          Annotation)
  output1 <- rbind(output1, setNames(as.list(c(AGI_accession, Annotation, ProteinType, NumberOfDomains)), names(output1)))
}

return(output1)
