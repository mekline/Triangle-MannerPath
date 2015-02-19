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

con = dbConnect(SQLite(),dbname = "many-dax-jspsych-psiturk-experiment_1_13_15/participants.db");
df.complete = dbReadTable(con,"turkdemo") #change the name of the database here (mine was called "almost")
dbDisconnect(con)

#filter out incompletes (using dplyr methods)
df.complete = subset(df.complete,status %in% c(3,4)) 

nrow(df.complete) #includes alll subjects ever plus all debug attempts!
#filter to a particular day (if I haven't set codeversions). OR together multiple days if needed
df.complete$currentVersion1 = str_detect(df.complete$beginhit, "2015-01-13")
df.complete$currentVersion2 = str_detect(df.complete$beginhit, "2015-01-14")
df.complete$currentVersion3 = str_detect(df.complete$beginhit, "2015-01-15")
df.complete$currentVersion4 = str_detect(df.complete$beginhit, "2015-01-16")

#Run 1, 1/13/15-1/15/15
#df.complete = df.complete[df.complete$currentVersion1 == TRUE | df.complete$currentVersion2 == TRUE |df.complete$currentVersion3 == TRUE,]

#Run 2, 1/16/15
df.complete = df.complete[df.complete$currentVersion4 == TRUE,]

nrow(df.complete)

#filter out 'debug' participants!
df.complete = filter(df.complete, !str_detect(df.complete$workerid,"debug"))
nrow(df.complete)

# Structure data ----------------------------------------------------------
#Note: Compile in wide form: 1 row/participant; each trial gets a series of column names, formatted XYFIELD_#
#Also, no extra underscores in the column names, this breaks wideToLong
#df.wide = data.frame(NULL)
df.wide = data.frame(matrix(nrow=nrow(df.complete),ncol=4))
colnames(df.wide) = c("participant","workerId","browser","beginhit") #will dynamically add columns from datastring below

for (i in 1:nrow(df.wide)){
  if (!is.na(df.complete$datastring[i])){
    a = fromJSON(df.complete$datastring[i])
    mylength = length(a$data)
  } else{
    a = data.frame(NULL)
    mylength = 0
  }
  print(mylength)
  if (mylength==27){
    df.wide$participant[i] = i
    df.wide$workerId[i] = a$workerId
    df.wide$browser[i] = df.complete$browser[i]
    df.wide$beginhit[i] = df.complete$beginhit[i]
    #cycle through all the trials, but only record where isTestTrial = 1
    for (j in 1:mylength){
      if(a$data[[j]]$trialdata$isTestTrial == "1"){
        df.wide[[paste("rt_",j, sep="")]][i] = a$data[[j]]$trialdata$rt
        df.wide[[paste("keypress_",j, sep="")]][i] = a$data[[j]]$trialdata$key_press
        df.wide[[paste("stimCondition_",j, sep="")]][i] = a$data[[j]]$trialdata$stimCondition
        df.wide[[paste("stimName_",j, sep="")]][i] = a$data[[j]]$trialdata$stimName
        df.wide[[paste("exposurePath_",j, sep="")]][i] = a$data[[j]]$trialdata$exposure_path
        df.wide[[paste("exposureManner_",j, sep="")]][i] = a$data[[j]]$trialdata$exposure_manner
        df.wide[[paste("condition_",j, sep="")]][i] = a$data[[j]]$trialdata$condition_name
      } #Else just don't make any columns right now!!!
    }
  }

  #And grab the info we need from the last 'trial' (feedback)
  if (is.null(a$data[[mylength-1]]$trialdata$responses)){df.wide$feedback[i] = "none"
  }else{
    df.wide$feedback[i] = a$data[[mylength-1]]$trialdata$responses
  }
} #End of this participant

#Notes: Something up with 1/16/15 subj 71's datastring:it's missing - recorded at end, so presumably lost before that?  Add a check for null datastrings

#Weird behavior! I got those wrong-lenght participants to be assigned a participant no of NA, which is something, anyway.
#Lost 6 people to this.
nrow(df.wide)
df.wide = df.wide[!is.na(df.wide$participant),]
nrow(df.wide)

#OOPS from 1/15/15: I didn't have the first trial (set to show the prototype movie) save the right variables, so record them
#here

df.wide$exposurePath_5 =df.wide$exposurePath_6
df.wide$exposureManner_5 =df.wide$exposureManner_6
df.wide$condition_5 =df.wide$condition_6
  

#Reformat into long form!
df.long = wideToLong(subset(df.wide,select=-feedback),within="trial")

#create factors
df.long = mutate(df.long, participant = as.numeric(participant),
          trial = as.numeric(as.character(trial)),
          rt = as.numeric(as.character(rt)),
          keypress = as.numeric(as.character(keypress))-48, #transform keycodes to numerals!
          stimCondition = factor(stimCondition,levels=c("NoChange","BothChange", "PathChange","MannerChange")),
          condition = factor(condition, levels=c("Noun","Verb")))

df.long = df.long[order(df.long$participant,df.long$trial),]

#Analyze data!--------------------------------------------------

#For each participant, make a score, which is abs(mean(mannerchange)-mean(pathchange))
#(And add some extra descriptive stats for the paper)

Scores = ""

mannerScores = aggregate(df.long[df.long$stimCondition=="MannerChange",]$keypress, by=list(df.long[df.long$stimCondition=="MannerChange",]$participant, df.long[df.long$stimCondition=="MannerChange",]$condition), mean.na.rm)
names(mannerScores) = c("participant", "condition", "mannerscore")
pathScores = aggregate(df.long[df.long$stimCondition=="PathChange",]$keypress, by=list(df.long[df.long$stimCondition=="PathChange",]$participant, df.long[df.long$stimCondition=="PathChange",]$condition), mean.na.rm)
names(pathScores) = c("participant", "condition", "pathscore")
sameScores = aggregate(df.long[df.long$stimCondition=="NoChange",]$keypress, by=list(df.long[df.long$stimCondition=="NoChange",]$participant, df.long[df.long$stimCondition=="NoChange",]$condition), mean.na.rm)
names(sameScores) = c("participant","condition","samescore")
bothScores = aggregate(df.long[df.long$stimCondition=="BothChange",]$keypress, by=list(df.long[df.long$stimCondition=="BothChange",]$participant, df.long[df.long$stimCondition=="BothChange",]$condition), mean.na.rm)
names(bothScores) = c("participant","condition","bothscore")
      
Scores = merge(mannerScores, pathScores, by=c("participant", "condition"))
Scores = merge(Scores, sameScores, by=c("participant", "condition"))
Scores = merge(Scores, bothScores, by=c("participant", "condition"))

#Basic descriptives

mean(Scores$samescore)
mean(Scores$mannerscore)
mean(Scores$pathscore)
mean(Scores$bothscore)

with(Scores, tapply(samescore, list(condition), mean, na.rm=TRUE), drop=TRUE)
t.test(Scores[Scores$condition == "Noun",]$samescore, Scores[Scores$condition == "Verb",]$samescore)

with(Scores, tapply(bothscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
t.test(Scores[Scores$condition == "Noun",]$bothscore, Scores[Scores$condition == "Verb",]$bothscore)

with(Scores, tapply(mannerscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
t.test(Scores[Scores$condition == "Noun",]$mannerscore, Scores[Scores$condition == "Verb",]$mannerscore)

with(Scores, tapply(pathscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
t.test(Scores[Scores$condition == "Noun",]$pathscore, Scores[Scores$condition == "Verb",]$pathscore)

#More interesting measures
Scores$diffscore = abs(Scores$mannerscore - Scores$pathscore)
Scores$ILikeMannerscore = Scores$pathscore - Scores$mannerscore

with(Scores, tapply(diffscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
with(Scores, tapply(diffscore, list(condition), stderr), drop=TRUE)

with(Scores, tapply(ILikeMannerscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
with(Scores, tapply(ILikeMannerscore, list(condition),stderr), drop=TRUE)

#And let's do a dead simple t test on that

t.test(Scores[Scores$condition == "Noun",]$diffscore, Scores[Scores$condition == "Verb",]$diffscore)
cohensD(Scores[Scores$condition == "Noun",]$diffscore, Scores[Scores$condition == "Verb",]$diffscore)


#Time for some regressions
nounScores <- Scores[Scores$condition == 'Noun',]
verbScores <- Scores[Scores$condition == 'Verb',]

noun.lm <- lm(mannerscore ~ pathscore, data=nounScores)
summary(noun.lm)
summary(noun.lm)$r.squared

verb.lm <- lm(mannerscore ~ pathscore, data=verbScores)
summary(verb.lm)
summary(verb.lm)$r.squared

#A post-hoc analysis: do verb or noun people say yes more often?
allScores = aggregate(df.long$keypress, by=list(df.long$participant, df.long$condition), mean.na.rm)
names(allScores) = c("participant", "condition", "allscore")

with(allScores, tapply(allscore, list(condition), mean, na.rm=TRUE), drop=TRUE)
with(allScores, tapply(allscore, list(condition), stderr), drop=TRUE)

t.test(allScores[allScores$condition == "Noun",]$allscore, allScores[allScores$condition == "Verb",]$allscore)
cohensD(allScores[allScores$condition == "Noun",]$allscore, allScores[allScores$condition == "Verb",]$allscore)

#Against the prediction I might have made, Noun categories are slightly SMALLER!  
#So this isn't just verb people making smaller categories - they say yes to about the same # of things, but distribute differently

#Graph data------------------------------------------------

#Bar graph of means----------------

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
png('manydax-barplot-se.png') # Write to PNG
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

#Scatterplot of manner vs. path scores of each partic ---------


png('manydax-noun-scatterplot-95ci.png')
ggplot(nounScores, aes(x=mannerscore, y=pathscore)) +
  geom_point(shape=1) +    # Use hollow circles
  geom_smooth(method=lm)   # Add linear regression line 
#  (by default includes 95% confidence region)
dev.off()

png('manydax-verb-scatterplot-95ci.png')
ggplot(verbScores, aes(x=mannerscore, y=pathscore)) +
  geom_point(shape=1) +    # Use hollow circles
  geom_smooth(method=lm)   # Add linear regression line 
#  (by default includes 95% confidence region)
dev.off()

