# Packages ----------------------------------------------------------------

rm(list=ls())
library(lsr)
library(dplyr)
library(rjson)
library(RSQLite)
library(stringr)
library(ggplot2)
library(Hmisc)

mean.na.rm <- function(x) { mean(x,na.rm=T) }
sum.na.rm <- function(x) { sum(x,na.rm=T) }
stderr <- function(x) sqrt(var(x)/length(x))

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

#Weird behavior! I got those wrong-lenght participants to be assigned a participant no of NA, which is something, anyway.
#Lost 6 people to this.
nrow(df.wide)
df.wide = df.wide[!is.na(df.wide$participant),]
nrow(df.wide)


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

#Analyze data!--------------------------------------------------

#For each participant, make a score, which is abs(mean(mannerchange)-mean(pathchange))

mannerScores = aggregate(df.long[df.long$stimcondition=="mannerchange",]$keypress, by=list(df.long[df.long$stimcondition=="mannerchange",]$participant, df.long[df.long$stimcondition=="mannerchange",]$condition), mean.na.rm)
names(mannerScores) = c("participant", "condition", "mannerscore")
pathScores = aggregate(df.long[df.long$stimcondition=="pathchange",]$keypress, by=list(df.long[df.long$stimcondition=="pathchange",]$participant, df.long[df.long$stimcondition=="pathchange",]$condition), mean.na.rm)
names(pathScores) = c("participant", "condition", "pathscore")

Scores = merge(mannerScores, pathScores, by=c("participant", "condition"))

Scores$diffscore = abs(Scores$mannerscore - Scores$pathscore)
with(Scores, tapply(diffscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
with(Scores, tapply(ILikeMannerscore, list(condition), stderr), drop=TRUE)

Scores$ILikeMannerscore = Scores$pathscore - Scores$mannerscore
with(Scores, tapply(ILikeMannerscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
with(Scores, tapply(ILikeMannerscore, list(condition),stderr), drop=TRUE)

#And let's do a dead simple t test on that

t.test(Scores[Scores$condition == "Noun",]$diffscore, Scores[Scores$condition == "Verb",]$diffscore)
cohensD(Scores[Scores$condition == "Noun",]$diffscore, Scores[Scores$condition == "Verb",]$diffscore)



#Graph data------------------------------------------------

##Summarize the data for graphing
data.summary.diffscores <- data.frame(
  condition=levels(Scores$condition),
  mean=with(Scores, tapply(diffscore, list(condition), mean, na.rm=TRUE), drop=TRUE),
  n=with(Scores, tapply(diffscore, list(condition), length)),
  se=with(Scores, tapply(ILikeMannerscore, list(condition), stderr), drop=TRUE)
)

# Precalculate margin of error for confidence interval
data.summary.diffscores$me <- qt(1-0.05/2, df=data.summary.diffscores$n)*data.summary.diffscores$se

# Use ggplot to draw the bar plot!
png('simpledax-barplot-se.png') # Write to PNG
ggplot(data.summary.diffscores, aes(x = condition, y = mean)) +  
  geom_bar(position = position_dodge(), stat="identity", fill="brown") + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=0.25) +
  ylim(0,6) +
  ylab("Abs(mean(manner) - mean(path))")+
  xlab("")+
  ggtitle("Rating of manner vs. path changes") + # plot title
  theme_bw() + # remove grey background (because Tufte said so)
  theme(panel.grid.major = element_blank()) # remove x and y major grid lines (because Tufte said so)
dev.off() # Close PNG

