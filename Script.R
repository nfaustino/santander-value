# Initial file

#setwd("/Users/faustnun/Desktop/Projects/_Tests/OutLending")

packages <- c(
  "data.table",
  "GGally",
  "ggplot2",
  "glmnet",
  "pROC",
  "caret",
  "xgboost",
  "readr"
  
)

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# Warning this will install the packages you don't have
ipak(packages)


#tr <- fread("input/train.csv", drop = "ID", header = T, showProgress = F)
#te <- fread("input/test.csv", drop = "ID", header = T, showProgress = F)
train <- readr::read_csv("input/train.csv")
test  <- readr::read_csv("input/test.csv")
                                                                                                                     