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
#te <- fread("input/test.csv", header = T, showProgress = T, collapse="\n")
train <- readr::read_csv("input/train.csv")
test  <- readr::read_csv("input/test.csv")

# Removing ID
train$ID <- NULL
test.id <- test$ID
test$ID <- NULL


## Removing incomplete cases (6)
cat("\n## Removing the incomplete osbservations\n")
train <- train[complete.cases(train),]


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


#Removing correlated columns 0.9
corMatrix <- cor(train)
toRemove <- findCorrelation(corMatrix, cutoff = .90, verbose = T)
toRemove <- sort(toRemove)

train <- train[,-c(toRemove)]
test <- test[,-c(toRemove)]

train$TARGET <- train.y


train_m <- sparse.model.matrix(TARGET ~ ., data = data.frame(train))

dtrain <- xgb.DMatrix(data=train_m, label=train.y)
watchlist <- list(train_m=dtrain)

param <- list(  objective           = "binary:logistic", 
                booster             = "gbtree",
                eval_metric         = "auc",
                eta                 = 0.0202048,
                max_depth           = 5,
                subsample           = 0.6815,
                colsample_bytree    = 0.701
)

clf <- xgb.train(   params              = param, 
                    data                = dtrain, 
                    nrounds             = 560, 
                    verbose             = 1,
                    watchlist           = watchlist,
                    maximize            = FALSE
)


test$TARGET <- -1

test_m <- sparse.model.matrix(TARGET ~ ., data = test)

preds <- predict(clf, test_m)
submission_xgb <- data.frame(ID=test.id, TARGET=preds)

xgbpred <- predict(clf,train_m)
roccurve_xgb <- roc(train$TARGET~xgbpred)

## optimal cut-off point 
cutoff_xgb <- roccurve_xgb$thresholds[which.max(roccurve_xgb$sensitivities + roccurve_xgb$specificities)]

xgbpred <- data.frame(xgbpred)
xgbpred$pred[xgbpred$xgbpred>cutoff_xgb]  <- 1
xgbpred$pred[xgbpred$xgbpred<=cutoff_xgb] <- 0

plot(roccurve_xgb)

