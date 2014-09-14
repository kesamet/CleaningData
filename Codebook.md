Codebook
========

This codebook describes the variables, the data, and any transformations or work performed to clean up the data


Variables
---------

Variable name     | Description
------------------|------------
subject           | Subject ID who performed the activity for each window sample. Its range is from 1 to 30.
activityName      | Activity name
featureName       | Variable name
average           | Average of each variable for each activity and each subject

Dataset structure
-----------------

```{r}
Classes ‘grouped_df’, ‘tbl_df’, ‘tbl’ and 'data.frame':	11880 obs. of  4 variables:
 $ subject     : int  1 1 1 1 1 1 1 1 1 1 ...
 $ activityName: chr  "LAYING" "LAYING" "LAYING" "LAYING" ...
 $ featureName : Factor w/ 66 levels "tBodyAcc-mean()-X",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ average     : num  0.2216 -0.0405 -0.1132 -0.9281 -0.8368 ...
 - attr(*, "vars")=List of 2
  ..$ : symbol subject
  ..$ : symbol activityName
 - attr(*, "drop")= logi TRUE
```

###Visualizing the data
```{r}
Source: local data frame [11,880 x 4]
Groups: subject, activityName

   subject activityName          featureName     average
1        1       LAYING    tBodyAcc-mean()-X  0.22159824
2        1       LAYING    tBodyAcc-mean()-Y -0.04051395
3        1       LAYING    tBodyAcc-mean()-Z -0.11320355
4        1       LAYING     tBodyAcc-std()-X -0.92805647
5        1       LAYING     tBodyAcc-std()-Y -0.83682741
6        1       LAYING     tBodyAcc-std()-Z -0.82606140
7        1       LAYING tGravityAcc-mean()-X -0.24888180
8        1       LAYING tGravityAcc-mean()-Y  0.70554977
9        1       LAYING tGravityAcc-mean()-Z  0.44581772
10       1       LAYING  tGravityAcc-std()-X -0.89683002
..     ...          ...                  ...         ...
```

###Summary of variables
```{r}
    subject     activityName                  featureName       average        
 Min.   : 1.0   Length:11880       tBodyAcc-mean()-X:  180   Min.   :-0.99767  
 1st Qu.: 8.0   Class :character   tBodyAcc-mean()-Y:  180   1st Qu.:-0.96205  
 Median :15.5   Mode  :character   tBodyAcc-mean()-Z:  180   Median :-0.46989  
 Mean   :15.5                      tBodyAcc-std()-X :  180   Mean   :-0.48436  
 3rd Qu.:23.0                      tBodyAcc-std()-Y :  180   3rd Qu.:-0.07836  
 Max.   :30.0                      tBodyAcc-std()-Z :  180   Max.   : 0.97451  
                                   (Other)          :10800      
```


List of work performed to clean up the data
-------------------------------------------
###Download data
The data can be downloaded from "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


###Load packages
```{r}
library(data.table)
library(reshape2)
library(dplyr)
```


###Read files
Suppose the data has been unzipped into the folder "./UCI HAR Dataset/"

####Load subject files 
```{r}
dtSubjectTrain <- tbl_df(fread("./UCI HAR Dataset/train/subject_train.txt"))
dtSubjectTest <- tbl_df(fread("./UCI HAR Dataset/test/subject_test.txt"))
```
####Load activity files 
```{r}
dtActivityTrain <- tbl_df(fread("./UCI HAR Dataset/train/Y_train.txt"))
dtActivityTest <- tbl_df(fread("./UCI HAR Dataset/test/Y_test.txt"))
```

####Load data files 
```{r}
dtTrain <- tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt"))
dtTest  <- tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt"))
```


###Merge the training and the test sets to create one data set
```{r}
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")

dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityCode")

dt <- rbind(dtTrain, dtTest)
dt <- cbind(dtSubject, dtActivity, dt)
```

###Extracts only the measurements on the mean and standard deviation for each measurement
```{r}
dtFeatures <- tbl_df(fread("./UCI HAR Dataset/features.txt"))
setnames(dtFeatures, c("featureCode", "featureName"))
dtFeatures1 <-
  dtFeatures %>%
  filter(grepl("mean\\(\\)|std\\(\\)", featureName)) %>%
  mutate(featureCode = paste0("V", featureCode))
dt2 <- dt[, c("subject","activityCode",dtFeatures1$featureCode)]
```

###Label the features with descriptive variable names
```{r}
setnames(dt2, names(dt2), c("subject","activityCode",dtFeatures1$featureName))
```

###Label the activities with descriptive activity names
```{r}
dtActivities <- tbl_df(fread("./UCI HAR Dataset/activity_labels.txt"))
setnames(dtActivities, names(dtActivities), c("activityCode", "activityName"))
dt2 <- merge(dt2, dtActivities, by="activityCode", all.x=TRUE)
dt2 <- select(dt2, -activityCode)
```

###Melt the data table to reshape it
```{r}
dt3 <- melt(dt2, id.vars=c("subject", "activityName"), variable.name="featureName")
```

###Create a tidy data set ith the average of each variable for each activity and each subject
```{r}
dtFinal <-
  dt3 %>%
  group_by(subject, activityName, featureName) %>%
  summarize(average = mean(value))
```

###Write tidy data set to a tab-delimited txt file
```{r}
write.table(dtFinal, "tidyData.txt", quote=FALSE, sep="\t", row.names=FALSE)
```
