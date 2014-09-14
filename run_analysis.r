library(data.table)
library(reshape2)
library(dplyr)


#Load data
#---------
dtSubjectTrain <- tbl_df(fread("./UCI HAR Dataset/train/subject_train.txt"))
dtSubjectTest <- tbl_df(fread("./UCI HAR Dataset/test/subject_test.txt"))
dtActivityTrain <- tbl_df(fread("./UCI HAR Dataset/train/Y_train.txt"))
dtActivityTest <- tbl_df(fread("./UCI HAR Dataset/test/Y_test.txt"))
dtTrain <- tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt"))
dtTest  <- tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt"))


#Merge the training and the test sets to create one data set
#-----------------------------------------------------------
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")

dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityCode")

dt <- rbind(dtTrain, dtTest)
dt <- cbind(dtSubject, dtActivity, dt)


#Extracts only the measurements on the mean and standard deviation for each measurement
#--------------------------------------------------------------------------------------
dtFeatures <- tbl_df(fread("./UCI HAR Dataset/features.txt"))
setnames(dtFeatures, c("featureCode", "featureName"))
dtFeatures1 <-
  dtFeatures %>%
  filter(grepl("mean\\(\\)|std\\(\\)", featureName)) %>%
  mutate(featureCode = paste0("V", featureCode))
dt2 <- dt[, c("subject","activityCode",dtFeatures1$featureCode)]


#Label the features with descriptive variable names
#--------------------------------------------------
setnames(dt2, names(dt2), c("subject","activityCode",dtFeatures1$featureName))


#Label the activities with descriptive activity names
#----------------------------------------------------
dtActivities <- tbl_df(fread("./UCI HAR Dataset/activity_labels.txt"))
setnames(dtActivities, names(dtActivities), c("activityCode", "activityName"))
dt2 <- merge(dt2, dtActivities, by="activityCode", all.x=TRUE)
dt2 <- select(dt2, -activityCode)


#Melt the data table to reshape it
#----------------------------------
dt3 <- melt(dt2, id.vars=c("subject", "activityName"), variable.name="featureName")


#Create a tidy data set ith the average of each variable for each activity and each subject
#------------------------------------------------------------------------------------------
dtFinal <-
  dt3 %>%
  group_by(subject, activityName, featureName) %>%
  summarize(average = mean(value))


#Write tidy data set to a tab-delimited txt file
#-----------------------------------------------
write.table(dtFinal, "tidyData.txt", quote=FALSE, sep="\t", row.names=FALSE)
