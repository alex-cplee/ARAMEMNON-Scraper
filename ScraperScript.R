AMNSearch <- function(i) {
  AramemHTML = read_html(paste0('https://aramemnon.botanik.uni-koeln.de/seq_view.ep?search=',i))
  Result <- AramemHTML %>% html_nodes('p')
  ResultText <- gsub('[\t\n]', '', html_text(Result[grep("headtopbox", Result)]))
  
  #Scraping initial result page provided that the results are valid
  if (grepl("protein result(s)", ResultText,  fixed = TRUE) == 1) {
    AGI_Output <- AramemHTML %>% html_nodes('tr') %>% html_nodes('ul') %>% html_nodes('span')
    AGI_accession <- gsub("[\t\n]", "", html_text(AGI_Output[1]))
    Annotation_Output <- AramemHTML %>%  html_nodes(".specT")
    Annotation <-  gsub("[\t\n]", "", html_text(Annotation_Output[1]))
    DetermineProteinType <- AramemHTML %>%  html_nodes(".sideTS") %>%  html_children() %>%  html_children() %>% html_attrs()
    
    # In Aramemnon results page, there is a little icon in one of the columns for each protein to indicate whether it is a membrane protein or soluble protein
    # We leverage the information from the icon to determine the membrane character of each protein. 
    if (DetermineProteinType[[2]][["src"]] == "./Gifs/T10.gif"|DetermineProteinType[[2]][["src"]] == "./Gifs/T01.gif"){
      ProteinType = 'membrane protein'
    } else{
      ProteinType = 'soluble or peripheral protein'
    }
    
    # If the protein is determined as membrane-bound, proceed to search for the number of transmembrane domains
    if (ProteinType == 'membrane protein'){
      DomainSearch <- AramemHTML %>%  html_nodes(".sideTS") %>% html_element("a") %>% html_attr("href")
      DomainSearch <- str_split(DomainSearch[1], "\" ")
      DomainSearch <- unlist(str_extract_all(DomainSearch[[1]][1],"\\(?[0-9]+\\)?"))
      DomainSearchNextPage <- read_html(paste0('https://aramemnon.botanik.uni-koeln.de/tm_sub.ep?GeneID=', DomainSearch[1], '&ModelID=0'))
      
      #need a special case for b-barrel proteins in the next two lines
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
        
        # For some reason ARAMEMNON classifies certain proteins as membrane proteins without a predicted transmembrane domain. 
        # Each of these proteins have a '-INF' value because there is no membrane domain table in the last HTML link. 
        # This step converts all '-INF' values to 0. 
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
  return(c(AGI_accession, Annotation, ProteinType, NumberOfDomains))
}