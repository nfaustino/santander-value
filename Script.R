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

# Fread is crashing with test.csv
#tr <- fread("input/train.csv", drop = "ID", header = T, showProgress = F)
#te <- fread("input/test.csv", drop = "ID", header = T, showProgress = F)
train <- readr::read_csv("input/train.csv")
test  <- readr::read_csv("input/test.csv")

# Removing ID
train$ID <- NULL
test.id <- test$ID
test$ID <- NULL

##### Extracting TARGET
train.y <- train$target
train$target <- NULL



##### Removing constant features
cat("\n## Removing the constants features.\n")
for (f in names(train)) {
  if (length(unique(train[[f]])) == 1) {
    cat(f, "is constant in train. We delete it.\n")
    train[[f]] <- NULL
    test[[f]] <- NULL
  }
}


## Removing incomplete cases (6)
cat("\n## Removing the incomplete oservations\n")
train <- train[complete.cases(train),]


#Removing correlated columns 0.9
corMatrix <- cor(train)
toRemove <- findCorrelation(corMatrix, cutoff = .90, verbose = T)
toRemove <- sort(toRemove)

train <- train[,-c(toRemove)]
test <- test[,-c(toRemove)]
