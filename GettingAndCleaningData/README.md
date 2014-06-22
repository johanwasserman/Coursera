Reproducing:
-----------

Run the run_analysis.R script

What the script does:
--------------------

The script will use the environment working directory, retrieved with getwd()

It will create a subdirectory called GettingAndCleaningData in the working directory, all files downloaded and manipulated by the script will be contained in this directory.
The script will then download the zip file located at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
For details of the data contained in the zip file, see http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The script will then format and clean the data from the zip file in to a tidy dataset, and save it to the file tidyHASmartPhoneData.txt

See codebook.md for a description of the tidy dataset and its columns.
