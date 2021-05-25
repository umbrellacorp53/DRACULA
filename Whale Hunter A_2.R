#LIBRARIES---------------------------------------------------------------------
library(httr)
library(rlist)
library(jsonlite)
library(dplyr)
library(anytime)
library(igraph)

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
m_growin_boi <- data.frame()

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




####
####
#GET-HISTORICAL-DRC-PRICE------------------------------------------------------

#TXT-PROGRESS-BAR-INIT
n_iter <- 3L # Number of iterations of the loop
# Initializes the progress bar
 pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                      max = n_iter, # Maximum value of the progress bar
                      style = 3,    # style (also available style = 1, style = 2)
                      width = 50,   # Bar width. Defaults to getOption("width")
                      char = "=")   # Character used to create the bar
 
 for(i in 1:n_iter){
#SEND-URL-STORE-IN-DATA-VAR----------------------------------------------------
  epoch_calc <- i * 7000000L
  
  begin <- 1594979420L + epoch_calc
  
  end <- begin + 7000000L
    
#API-URL-JIGSAW-COINGECKO------------------------------------------------------
  g_url <- paste("https://api.coingecko.com/api/v3/coins/ethereum/",
                            "contract/0xb78b3320493a4efaa1028130c5ba26f0b6085ef8/",
                            "market_chart/range?vs_currency=usd&from=",
                            begin,"&to=",end, sep="")
  m_data <- fromJSON(g_url)
  market_data <- as.data.frame(m_data)
  essential_m_data <- select(market_data, 
                              prices.1, 
                              prices.2, 
                              market_caps.2, 
                              total_volumes.2)
  
  
#COMBINE CURRENT-DATA-FRAME-TO-GROWTH------------------------------------------  
  m_big_boi <- rbind(m_growin_boi, essential_m_data)
  
#FLUSH-VALUES-UPDATE-MASTER-DF-------------------------------------------------  
  m_growin_boi <- m_big_boi
  Sys.sleep(0.205)
  setTxtProgressBar(pb, i)
}

close(pb)
m_big_boi$prices.1 <- as.integer(m_big_boi$prices.1 / 1000)
m_big_boi$prices.1 <- anytime(as.integer(m_big_boi$prices.1))
m_big_boi$prices.2 <- round(m_big_boi$prices.2, digits = 6)


#IMPORTANT-NOTE----------------------------------------------------------------

#i love u (note from GF). Love you too Winter.




my_first_network <- graph(edges=c(big_boi$result.from, big_boi$result.to), directed=FALSE)











