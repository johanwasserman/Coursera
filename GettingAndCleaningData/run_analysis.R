library("data.table")
#install.packages("reshape")
library("reshape2")

# url of the source of the data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# to save the data localy 
file <- paste(c(getwd(),"/","GettingAndCleaningData/", "SmartphoneData.zip"), collapse="")
# download the source data
download.file(url, file)
# unzip the data
unzip(file, exdir=paste(c(getwd(),"/","GettingAndCleaningData"), collapse=""))
#-------------------------------------------------------------------
#base directory for data
data_base <- paste(c(getwd(),"/","GettingAndCleaningData/UCI HAR Dataset"), collapse="")

# build subject tables
# Error in fread() : Not positioned correctly after testing format of header row. ch=' '
# need another approach;
test_subj <- data.table(read.table(file.path(data_base, "test", "subject_test.txt")))
train_subj <- data.table(read.table(file.path(data_base, "train", "subject_train.txt")))

# build activity tables
test_act <- data.table(read.table(file.path(data_base, "test", "y_test.txt")))
train_act <- data.table(read.table(file.path(data_base, "train", "y_train.txt")))

# build master tables
test_master <- data.table(read.table(file.path(data_base, "test", "X_test.txt")))
train_master <- data.table(read.table(file.path(data_base, "train", "X_train.txt")))

# Combine data
subject_data <- rbind(test_subj, train_subj)
activity_data <- rbind(test_act, train_act)
master_data <- rbind(test_master, train_master)

# merge
setnames(subject_data, "V1", "subject")
setnames(activity_data, "V1", "activity_number")
master <- cbind(subject_data, activity_data, master_data)
setkey(master, subject, activity_number)

#do a little cleanup
rm(test_subj, train_subj, test_act, train_act, test_master, train_master)
rm(subject_data, activity_data, master_data)

# load features
features <- fread(file.path(data_base, "features.txt"))
setnames(features, names(features), c("feature_number", "feature_name"))
# need only the standard and mean deviations
features <-  features[grepl("std\\(\\)|mean\\(\\)", feature_name)]
# create the match to column names in master
features$feature_code <- features[, paste0("V", feature_number)]

# get the master subset
master <-master[, c(key(master), features$feature_code), with=FALSE]


# and now translate the activities to the values in activity_labels
activities <- fread(file.path(data_base, "activity_labels.txt"))
setnames(activities, names(activities), c("activity_number", "activity_name"))

# merge master with activity names and add the name to keys
master <- merge(master, activities, by="activity_number", all.x=TRUE)
setkey(master, subject, activity_number, activity_name)

# meld and merge
master <- data.table(melt(master, key(master), variable.name="feature_code"))
master <- merge(master, features[, list(feature_number, feature_code, feature_name)], by="feature_code", all.x=TRUE)

# replace activity and feature with their correct values
master$activity <- factor(master$activity_name)
master$feature <- factor(master$feature_name)

#-------------------------------------------------------------------
# parse the feature in to detail columns
# we only have two options here, if it's not time it must be frequency
master$domain <- factor(grepl("^t", master$feature_name), labels=c("Frequency", "Time"))
# only two options, if it's not gyro it must be accelerometer
master$instrument <- factor(grepl("Gyro", master$feature_name), labels=c("Accelerometer", "Gyroscope"))
# found two options, body or gravity
#master$source <- factor(grepl("Body", master$feature_name), labels=c("Gravity", "Body"))
master$source <- factor(grepl("GravityAcc", master$feature_name), labels=c("NA", "Gravity"))
#master[source=="NA"]$source <- factor(grepl("Gravity", master[source=="NA"]$feature_name), labels=c("NA", "Gravity"))
master[source=="NA"]$source <- factor(grepl("BodyAcc", master[source=="NA"]$feature_name), labels=c("NA", "Body"))

# looking for measurement methods mean() and std()
master$measurement <- factor(grepl("mean()", master$feature_name), labels=c("Standard Deviation", "Mean"))
#master[measurement=="NA"]$measurement <- factor(grepl("std()", mastermaster[measurement=="NA"]$feature_name), labels=c("NA", "Standard Deviation"))

# Jerk?
master$jerk <- factor(grepl("Jerk", master$feature_name), labels=c("NA", "Jerk"))

# Magnitude?
master$magnitude <- factor(grepl("Mag", master$feature_name), labels=c("NA", "Magnitude"))

# derctions X, Y & Z
master$direction <- factor(grepl("-X", master$feature_name), labels=c("NA", "X"))
master[direction=="NA"]$direction <- factor(grepl("-Y", master[direction=="NA"]$feature_name), labels=c("NA", "Y"))
master[direction=="NA"]$direction <- factor(grepl("-Z", master[direction=="NA"]$feature_name), labels=c("NA", "Z"))

# set up the master key
setkey(master, subject, activity, domain, instrument, source, measurement, jerk, magnitude, direction)

# make the tidy dataset
tidy <- master[, list(count = .N, average = mean(value)), by=key(master)]

# some last minute cleanup
rm(activities, features) #, master

# write file and print a summary
file <- paste(c(getwd(),"/","GettingAndCleaningData/", "tidyHASmartPhoneData.txt"), collapse="")
write.table(tidy, file, quote = FALSE, sep = "\t", row.names = FALSE)

summary(tidy)
