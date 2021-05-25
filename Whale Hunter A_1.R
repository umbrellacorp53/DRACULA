#LIBRARIES---------------------------------------------------------------------
library(httr)
library(rlist)
library(jsonlite)
library(dplyr)
library(anytime)

#VARIABLES --------------------------------------------------------------------
drc_address <- "0xb78B3320493a4EFaa1028130C5Ba26f0B6085Ef8"
api_key <- "G6NT89FAW872R3KGJD8EU9YD9FEYDBNX78"
acct_piece <- "api?module=account&action=tokentx"
contr_piece <- "&contractaddress="
wall_line <- "&address="
start <- "&startblock="
end <- "&endblock="
full_api <- "&apikey=G6NT89FAW872R3KGJD8EU9YD9FEYDBNX78"
growin_boi <- data.frame()

#CAPTURE-ADDRESSES-------------------------------------------------------------
holders <- read.csv(file = '/Documents/Dracula Whale Hunter/DRC_holders2.csv',
                    colClasses = "character")

#TXT-PROGRESS-BAR-INIT---------------------------------------------------------
n_iter <- 150L # Number of iterations of the loop

# Initializes the progress bar
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = n_iter, # Maximum value of the progress bar
                     style = 3,    # style (also available style = 1, style = 2)
                     width = 50,   # Bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar


#ITERATE-ADDRESSES-------------------------------------------------------------
for(i in 1:n_iter){
block_calc <- i * 10000L
block_calc

start_block <- 10990000L + block_calc

end_block <- start_block + 10000L

start_string <- toString(start_block)
end_string <- toString(end_block)

#API-URL-JIGSAW----------------------------------------------------------------
  API_jigsaw <- paste(acct_piece, contr_piece, drc_address,
                      start, start_block, end, end_block, full_api, sep="")
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
big_boi$result.value <- substr(big_boi$result.value,1,nchar
                               (big_boi$result.value)-18)

big_boi$result.value[big_boi$result.value==""]<-"0"
big_boi$result.value <- as.integer(big_boi$result.value)
big_boi$result.timeStamp <- anytime(as.integer(big_boi$result.timeStamp))
holders$Balance.in.DRC <- sub('\\..*', '', holders$Balance.in.DRC)
holders$Balance.in.DRC <- as.integer(holders$Balance.in.DRC)
#IMPORTANT-NOTE----------------------------------------------------------------
##  ##   ##      #####   #####     ##    #####    ##
##  ##           ##  ##  ##  ##   ####   ##  ##   ##
######   ##      ######  ######  ##  ##  ##  ##   ##
######   ##      ##  ##  ##  #   ######  ##  ##   ##
##  ##   ##      ##  ##  ##  ##  ##  ##  ##  ##
##  ##   ##      #####   ##  ##  ##  ##  #####    ##
