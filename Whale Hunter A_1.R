#LIBRARIES---------------------------------------------------------------------
library(httr)
library(rlist)
library(jsonlite)
library(dplyr)
library(bit64)

#VARIABLES --------------------------------------------------------------------
drc_address <- "0xb78B3320493a4EFaa1028130C5Ba26f0B6085Ef8"
api_key <- "G6NT89FAW872R3KGJD8EU9YD9FEYDBNX78"
acct_piece <- "api?module=account&action=tokentx"
contr_piece <- "&contractaddress="
wall_line <- "&address="
blocks_sort <- "&startblock=0&endblock=999999999&sort=asc"
full_api <- "&apikey=G6NT89FAW872R3KGJD8EU9YD9FEYDBNX78"
growin_boi <- data.frame()

#CAPTURE-ADDRESSES-------------------------------------------------------------
holders <- read.csv(file = '/Documents/Dracula Whale Hunter/DRC_holders.csv',
                    colClasses = "character")

#TXT-PROGRESS-BAR-INIT---------------------------------------------------------
n_iter <- 2617 # Number of iterations of the loop

# Initializes the progress bar
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = n_iter, # Maximum value of the progress bar
                     style = 3,    # style (also available style = 1, style = 2)
                     width = 50,   # Bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar


#ITERATE-ADDRESSES-------------------------------------------------------------
for(i in 1:n_iter){
  address_x <- holders[i,"HolderAddress"]
#API-URL-JIGSAW----------------------------------------------------------------
  API_jigsaw <- paste(acct_piece, contr_piece, drc_address,
                      wall_line, address_x, blocks_sort, full_api, sep="")
  
#SEND-URL-STORE-IN-DATA-VAR----------------------------------------------------
  url <- modify_url("http://api.etherscan.io/", path = API_jigsaw)
  data <- fromJSON(url)
  ether_data <- as.data.frame(data)
#TRIM-DATA---------------------------------------------------------------------
  essential_columns <- select(ether_data, 
                              result.timeStamp, 
                              result.to, 
                              result.from, 
                              result.value,
                              result.hash)
#COMBINE CURRENT-DATA-FRAME-TO-GROWTH------------------------------------------  
  big_boi <- rbind(growin_boi, essential_columns)
  
#FLUSH-VALUES-UPDATE-MASTER-DF-------------------------------------------------  
  rm(address_x)
  growin_boi <- big_boi
  rm(essential_columns)
  rm(ether_data)
  rm(data)
  
#SLEEP-TIMER-------------------------------------------------------------------  
  Sys.sleep(0.205) # DELAY TO PREVENT DATA LOSS. API LIMIT = 5 CALLS/SEC.
  
#SET-PROGRESS-BAR-TO-CURRENT-STATE---------------------------------------------
  setTxtProgressBar(pb, i)
  
}
#CLOSE-PROGRESS-BAR------------------------------------------------------------
close(pb)

#CONVERT-COLUMN-DATA-----------------------------------------------------------
big_boi$result.value <-bit64::as.integer64(big_boi$result.value)


#IMPORTANT-NOTE----------------------------------------------------------------
##  ##   ##      #####   #####     ##    #####    ##
##  ##           ##  ##  ##  ##   ####   ##  ##   ##
######   ##      ######  ######  ##  ##  ##  ##   ##
######   ##      ##  ##  ##  #   ######  ##  ##   ##
##  ##   ##      ##  ##  ##  ##  ##  ##  ##  ##
##  ##   ##      #####   ##  ##  ##  ##  #####    ##