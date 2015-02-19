# Packages ----------------------------------------------------------------

rm(list=ls())
library(lsr)
library(dplyr)
library(rjson)
library(RSQLite)

# Read data ---------------------------------------------------------------

con = dbConnect(SQLite(),dbname = "participants.db");
df.complete = dbReadTable(con,"almost") #change the name of the database here (mine was called "almost")
dbDisconnect(con)

#filter out incompletes 
df.complete = subset(df.complete,status %in% c(3,4)) 

#save data of different experiments in separate data frames 
df.complete.experiment_1 = subset(df.complete,codeversion == "experiment_1")
df.complete.experiment_2 = subset(df.complete,codeversion == "experiment_2")
df.complete.experiment_3 = subset(df.complete,codeversion == "experiment_3")

# EXP1: Structure data ----------------------------------------------------------
df.wide = data.frame(matrix(nrow=nrow(df.complete.experiment_1),ncol=8))
colnames(df.wide) = c("experiment","participant","id","gender","age","condition","counterbalance","feedback")

for (i in 1:nrow(df.wide)){
  a = fromJSON(df.complete.experiment_1$datastring[i])
  df.wide$experiment[i] = df.complete.experiment_1$codeversion[i]
  df.wide$participant[i] = i
  df.wide$id[i] = a$workerId
  if (is.null(a$questiondata$gender)){df.wide$gender[i] = NA
  }else{
    df.wide$gender[i] = a$questiondata$gender
  }
  df.wide$age[i] = a$questiondata$age
  df.wide$condition[i] = a$condition
  df.wide$counterbalance[i] = a$counterbalance
  #cycles through the trials
  for (j in 1:8){
    df.wide[[paste("question_",j-1,sep="")]][i] = 
    a$data[[j]]$trialdata[[1]]
    df.wide[[paste("rating_",j-1,sep="")]][i] = 
      a$data[[j]]$trialdata[[2]]
    df.wide[[paste("throw_",j-1,sep="")]][i] = 
      a$data[[j]]$trialdata[[4]]
    df.wide[[paste("grass_",j-1,sep="")]][i] = 
      a$data[[j]]$trialdata[[6]]
    df.wide[[paste("distance_",j-1,sep="")]][i] = 
      a$data[[j]]$trialdata[[8]]
    df.wide[[paste("wall_",j-1,sep="")]][i] = 
      a$data[[j]]$trialdata[[10]]
  }
  df.wide$feedback[i] = a$questiondata$feedback
}

df.long = wideToLong(subset(df.wide,select=-feedback),within="trial")

#create factors
df.long = mutate(df.long, question = as.factor(question),
          throw = factor(throw,levels=c("low","high")),
          grass = factor(grass,levels=c("low","high")),
          distance = factor(distance,levels=c("short","long")),
          wall = factor(wall,levels=c("no","yes")),
          gender = factor(gender,levels=c("female","male","NA")),
          age = as.numeric(age))

df.long = df.long[order(df.long$participant,df.long$question),]