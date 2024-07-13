library(shinybusy)
library(shiny)

ui <- fluidPage(
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
                  uiOutput('filedata_ui'),
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
  output$textfield_ui <- renderUI({
    input$example 
    textAreaInput(inputId = "textin",
                  label = NULL,
                  width = '100%',
                  resize = 'vertical',
                  value = 'At4g01470\nMELO3C002183\nPotri.001G235300\nSolyc06g072130\nGSVIVG01025038001\nBradi2g07830\nGSMUA_Achr9T06260\nLOC_Os01g13130\nGRMZM2G146627')})
  observeEvent(input$resetText, {updateTextInput(session, 'textin', value = '')})
  output$filedata_ui <- renderUI({
    input$resetFile
    fileInput(inputId = "filedata",
              label = "Upload only a single text file containing AGI Accessions", 
              multiple = FALSE, 
              accept = c('.txt'))})
  observeEvent(input$go, {
    output$gene_list <- renderDataTable({
      #only reactive when the submit button is clicked
      isolate(
        if (isTruthy(input$filedata)){
          gene <<- list()
          gene <<- unlist(read.delim(input$filedata$datapath, header = FALSE))
          gene <<- unique(c(gene,str_split(str_replace_all(input$textin, ',', '\n'), "\n")[[1]]))
          gene <<- gene[gene != ""]
          source('ScraperScript.R')
          return(output1)
          }
        else if (input$textin == ""){
          df = data.frame(matrix(ncol = 4, nrow = 0))
          colnames(df) <- c('AGI_accession', 'Annotation', 'ProteinType', 'NumberOfDomains')
          return(df)
          }
        else {
          gene <<- list()
          gene <<- str_split(str_replace_all(input$textin, ',', '\n'), "\n")[[1]]
          source('ScraperScript.R')
          return(output1)}
        )
      }
    )
    output$Download <- downloadHandler(
      filename = function(){"results.csv"}, 
      content = function(fname){
        write.csv(output1, fname)})}
  )
}

shinyApp(ui = ui, server = server)
