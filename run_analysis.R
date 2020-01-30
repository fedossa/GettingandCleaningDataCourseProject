
# download file and load packages
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "Data.zip")
unzip(zipfile = "Data.zip")
library(dplyr)


# Load activity labels + features
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = F)
features <- read.table("./UCI HAR Dataset/features.txt", header = F)
featuresWanted <- grep("(mean|std)\\(\\)", features$V2)
measurements <- features %>% 
        slice(featuresWanted) %>% 
        select(V2) %>% 
        rename(features = V2)
measurements$features <- gsub('[()]', '', measurements$features)



# Load train datasets
train <-  read.table("./UCI HAR Dataset/train/X_train.txt", header = F, col.names = features$V2)
train <- train[, featuresWanted]
trainActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = F, col.names = "Activitiy")
trainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = F, col.names = "SubjectNum")
train <- cbind(trainSubjects, trainActivities, train)



# Load test datasets
test <-  read.table("./UCI HAR Dataset/test/X_test.txt", header = F, col.names = features$V2)
test <- test[, featuresWanted]
testActivities <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = F, col.names = "Activitiy")
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = F, col.names = "SubjectNum")
test <- cbind(testSubjects, testActivities, test)


# merge datasets
combined <- rbind(train, test)

# Add activitiy labels
combined$Activitiy <- factor(combined$Activitiy, labels = activityLabels$V2)


# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity
# and each subject.


TidyData <- combined %>% 
        group_by(SubjectNum,Activitiy) %>% 
        summarise_all(mean)

# save tidydataset 
write.table(TidyData, file = "TidyData.txt",
            row.names = FALSE)

# update features code book
write.table(measurements, file = "Codebook Update - features.txt", sep = "\t",
            row.names = FALSE, col.names = FALSE)
