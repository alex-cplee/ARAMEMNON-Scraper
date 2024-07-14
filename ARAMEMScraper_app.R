library(shinybusy)
library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  add_busy_spinner(spin = "fading-circle"),
  titlePanel(title = 'ARAMEMNON Scraper App'), 
  sidebarLayout(position = "left",
                sidebarPanel(
                  h4('Purpose:'),
                  p('This is a R-based web scraping tool for obtaining gene annotation and transmembrane domain information of a large number of genes from ARAMEMNON. Be aware that when you are querying >100 genes it will take some time to return a complete list of results.'),
                  p('Copy and paste your list of genes below:'),
                  uiOutput('textfield_ui'),
                  actionButton(inputId = 'resetText', label='Clear Text'),
                  actionButton(inputId = 'example', label='Example'),
                  p(''),
                  p('or Upload a list of genes as .txt below:'),
                  fileInput(inputId = "filedata",
                            label = "Upload only a single text file containing AGI Accessions", 
                            multiple = FALSE, 
                            accept = c('.txt')),
                  actionButton(inputId = 'go', label='Submit'),
                  actionButton(inputId = 'resetFile', label='Clear File')),
                mainPanel(
                  downloadButton(outputId = 'Download', label = 'Download'),
                  dataTableOutput('gene_list')
                ))
)

server <- function(input, output, session) {
  library(readxl)
  library(stringr)
  library(rvest)
  library(tidyr)
  library(pbapply)
  source('ScraperScript.R')
  
  # reset the output data frame in memory
  output1 <- c()

  # set variables to toggle on or off the file upload
  rv <- reactiveValues(
    data = NULL,
    clear = TRUE
  )
  
  # When there is a file in the upload section, trigger to include the file in the search
  observeEvent(input$filedata, {
    rv$clear <- FALSE
  })
  
  # When "Clear File" is clicked, clear the text in the upload dialogue and deactivate any file directory in memory from the search 
  observeEvent(input$resetFile, {
    rv$data <- NULL
    rv$clear <- TRUE
    reset('filedata')
  })
  
  # generate a list of plant accession examples 
  output$textfield_ui <- renderUI({
    input$example 
    textAreaInput(inputId = "textin",
                  label = NULL,
                  width = '100%',
                  resize = 'vertical',
                  value = 'At4g01470\nMELO3C002183\nPotri.001G235300\nSolyc06g072130\nGSVIVG01025038001\nBradi2g07830\nGSMUA_Achr9T06260\nLOC_Os01g13130\nGRMZM2G146627')})
  
  # clear the text upon clicking "Clear Text"
  observeEvent(input$resetText, {updateTextInput(session, 'textin', value = '')})
  
  observeEvent(input$go, {
    withProgress(message = "Your Aramemnon query is in progess...", value=0,{
      #the search function is only activated when the submit button is clicked at least once
      isolate(
        if (rv$clear == FALSE){
          # If there is a file being uploaded, include genes in the text-box and file in the search
          gene <<- list()
          gene <<- unlist(read.delim(input$filedata$datapath, header = FALSE)) |> suppressWarnings()
          gene <<- unique(c(gene,str_split(str_replace_all(input$textin, ',', '\n'), "\n")[[1]]))
          gene <<- gene[gene != ""]
          #calculate the progress of the search
          percentage <<- 0
          wranggling <- pblapply(gene, 
                               function(x) {
                                 Sys.sleep(0.05);
                                 percentage <<- percentage + 1/length(gene)*100
                                 incProgress(1/length(gene), detail = paste0("Progress: ",round(percentage,1)))
                                 AMNSearch(x)
                               })
          output1 <<- 
            setNames(
              as.data.frame(do.call(rbind, wranggling)), 
              c("AGI_accession", "Annotation", "ProteinType", "NumberOfDomains")
              )
          } 
        else if (input$textin == "" || is.na(input$textin)){
          # create an empty table if no genes are passed into the search
          percentage <<- 100
          output1 <<- data.frame(matrix(ncol = 4, nrow = 0))
          colnames(output1) <<- c('AGI_accession', 'Annotation', 'ProteinType', 'NumberOfDomains')
          } 
        else {
          # If there is no file being uploaded, include genes only in the text-box in the search
          gene <<- list()
          gene <<- str_split(str_replace_all(input$textin, ',', '\n'), "\n")[[1]]
          percentage <<- 0
          wranggling <- pblapply(gene, 
                                 function(x) {
                                   Sys.sleep(0.05);
                                   percentage <<- percentage + 1/length(gene)*100
                                   incProgress(1/length(gene), detail = paste0("Progress: ",round(percentage,2)))
                                   AMNSearch(x)
                                 })
          output1 <<- 
            setNames(
              as.data.frame(do.call(rbind, lapply(gene, AMNSearch))), 
              c("AGI_accession", "Annotation", "ProteinType", "NumberOfDomains")
            )
        }
        )
      })
  })
  
  observeEvent(input$go, {
    output$gene_list <- renderDataTable({
      #the rsult table only appears when the submit button is clicked at least once
      isolate(output1)
      })
  })
    
  # download function
    output$Download <- downloadHandler(
      filename = function(){"results.csv"}, 
      content = function(fname){
        write.csv(output1, fname)})
    }

shinyApp(ui = ui, server = server)