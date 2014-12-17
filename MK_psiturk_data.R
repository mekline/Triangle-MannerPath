# Packages ----------------------------------------------------------------

rm(list=ls())
library(lsr)
library(dplyr)
library(rjson)
library(RSQLite)
library(stringr)

# Read data ---------------------------------------------------------------

con = dbConnect(SQLite(),dbname = "participants.db");
df.complete = dbReadTable(con,"turkdemo") #change the name of the database here (mine was called "almost")
dbDisconnect(con)

#filter out incompletes (using dplyr methods)
df.complete = subset(df.complete,status %in% c(3,4)) 

#filter to a particular day (if I haven't set codeversions). OR together multiple days if needed
df.complete$currentVersion = str_detect(df.complete$beginhit, "2014-12-11")
df.complete = subset(df.complete, currentVersion %in% TRUE)


# Structure data ----------------------------------------------------------
#Note: Compile in wide form: 1 row/participant; each trial gets a series of column names, formatted XYFIELD_#
#Also, no extra underscores in the column names, this breaks wideToLong
#df.wide = data.frame(NULL)
df.wide = data.frame(matrix(nrow=nrow(df.complete),ncol=4))
colnames(df.wide) = c("participant","workerId","browser","beginhit") #will dynamically add columns from datastring below

for (i in 1:nrow(df.wide)){
  a = fromJSON(df.complete$datastring[i])
  #Note! Some badness is happening in finding these indices, need to fix this loop so it doesn't go beyond a's limit
  mylength = length(a$data)
  print(mylength)
  #Weird: Some of the people (~10) have the wrong number of blocks!  For now, just take the ones who are length 23, but what the hell!
  if (mylength == 23){
    df.wide$participant[i] = i
    df.wide$workerId[i] = a$workerId
    df.wide$browser[i] = df.complete$browser[i]
    df.wide$beginhit[i] = df.complete$beginhit[i]
    #cycle through all the trials, but only record where isTestTrial = 1
    for (j in 1:mylength){
      if(a$data[[j]]$trialdata$isTestTrial == "1"){
        df.wide[[paste("rt_",j, sep="")]][i] = a$data[[j]]$trialdata$rt
        df.wide[[paste("keypress_",j, sep="")]][i] = a$data[[j]]$trialdata$key_press
        df.wide[[paste("stimcondition_",j, sep="")]][i] = a$data[[j]]$trialdata$stimcondition
        df.wide[[paste("exposureManner_",j, sep="")]][i] = a$data[[j]]$trialdata$exposure_manner
        df.wide[[paste("exposurePath_",j, sep="")]][i] = a$data[[j]]$trialdata$exposure_path
        df.wide[[paste("exposureNumber_",j, sep="")]][i] = a$data[[j]]$trialdata$exposure_number
        df.wide[[paste("condition_",j, sep="")]][i] = a$data[[j]]$trialdata$condition_name
      } #Else just don't make any columns right now!!!
    }
  
    #And grab the info we need from the last 'trial' (feedback)
    if (is.null(a$data[[mylength-1]]$trialdata$Q0)){df.wide$feedback[i] = "none"
    }else{
      df.wide$feedback[i] = a$data[[mylength-1]]$trialdata$Q0
    }
  }
} #End of this participant
#Weird behavior!  If a cell is not assigned, R is filling it in with the values from the first row.  What?!  Anyway I made it stop but not sure how.  Explore this more.
#I got those wrong-lenght participants to be assigned a participant no of NA, which is something, anyway.




#Reformat into long form!
df.long = wideToLong(subset(df.wide,select=-feedback),within="trial")

#create factors
df.long = mutate(df.long, participant = as.numeric(participant),
          trial = as.numeric(as.character(trial)),
          rt = as.numeric(as.character(rt)),
          keypress = as.numeric(as.character(keypress))-48, #transform keycodes to numerals!
          stimcondition = factor(stimcondition,levels=c("mismatch","match", "mannerchange","pathchange")),
          exposureNumber = as.numeric(as.character(exposureNumber)),
          condition = factor(condition, levels=c("Noun","Verb")))

df.long = df.long[order(df.long$participant,df.long$trial),]