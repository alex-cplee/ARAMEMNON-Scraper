# ARAMEMNON Scraper

### Description
This is a R-based app for scraping gene annotation and transmembrane domain information of a large number of plant genes from [ARAMEMNON](http://aramemnon.uni-koeln.de/). To run this app in your computer, you will need to have R installed with the required libraries (see below). '[ARAMEMScraper_app.R](https://github.com/alex-cplee/data-projects/blob/main/1%20Aramemnon%20Scraper/ARAMEMScraper_app.R)' is the core of the app (run this script in R!) and '[ScraperScript.R](https://github.com/alex-cplee/data-projects/blob/main/1%20Aramemnon%20Scraper/ScraperScript.R)' contains the source of scraping function, so you will need to put both of these files in the same folder in order to run the app properly in your local environment. Be aware that when you are querying a large number of genes (>100) it will take some time to return a complete list of results. This tool works for model plant <i>Arabidopsis thaliana</i> as well as nine crop plants in the [latest version of ARAMEMNON](http://aramemnon.uni-koeln.de/proj_view.ep?id=annot) (version 8 in November 2021): 

You can read more about how the source works and what the output/result can be used for in 'workbook.Rmd'. Example dataset is given in Excel file (Suba4-2021-11-8_1-11.xlsx) and example outputs are also included as txt files.

I created this app for the common good. But if you are looking for the original citation, here it is:

___
[Schwacke R, Schneider A, Van Der Graaff E, Fischer K, Catoni E, Desimone M, Frommer WB, Flügge UI, Kunze R. (2003)
ARAMEMNON, a Novel Database for Arabidopsis Integral Membrane Proteins. <i>Plant Physiol.</i> <b>131</b>: 16-26.](https://academic.oup.com/plphys/article/131/1/16/6114365)
___

All credit goes to them for making the database public, so cite their paper if you are using this app for your research. If you really want to acknowledge me for making this app, just send me an email and say thank you, or if you are in Australia, a pack of Tim Tam would do :)

### How to run/install
No issue has been found so far when the code is run in RStudio version 1.4.1717 and R version 4.1.0 (2021-05-18).

1. Download the following and put them into the same folder:
  + [ARAMEMScraper_app.R](https://github.com/alex-cplee/data-projects/blob/main/1%20Aramemnon%20Scraper/ARAMEMScraper_app.R)
  + [ScraperScript.R](https://github.com/alex-cplee/data-projects/blob/main/1%20Aramemnon%20Scraper/ScraperScript.R)
2. Run [ARAMEMScraper_app.R](https://github.com/alex-cplee/data-projects/blob/main/1%20Aramemnon%20Scraper/ARAMEMScraper_app.R) in R Gui or RStudio. A browser is then open that looks like this:
<img src="/../main/Graphics/Scraper_open.png"></img>
3. Either enter accession IDs into the text field or upload a text file containing all the gene IDs of interest.
4. Press the submit button. Wait until the result table is generated on the right (see below). Waiting time depends on the number of ID you submit for each job. Do not close the browser while you are waiting!
<img src="/../main/Graphics/Scraper_results.png"></img>

Required libraries include:
```javascript
library(shinybusy)
library(shiny)
library(stringr)
library(rvest)
library(tidyr)
```

To install these libraries, use the following command:
```javascript
install.packages("xxx") #single library

install.packages("xxx", "yyy", "zzz") #if you are installing multiple packages
```
where xxx (yyy and zzz) is the name of the library, such as shiny.

### Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

### Authors
[**Dr Chun Pong Lee**](https://scholar.google.com.au/citations?user=cxreV4YAAAAJ&hl=en) is the primary author & [**Professor Harvey Millar**](https://research-repository.uwa.edu.au/en/persons/harvey-millar) is the supervisor.

Affiliation: [ARC Centre of Excellence in Plant Energy Biology](http://www.plantenergy.edu.au/)
