getwd()
setwd("C:/Users/Samsung/Desktop/빅분기실기준비/타이타닉 생존자 예측")

library(dplyr)
train_df <- read.csv("train.csv")
test_df <- read.csv("test.csv")
full_df <- dplyr::bind_rows(train_df, test_df)

sapply(test_df, FUN = function(x) {
    sum(is.na(x))
})

# Age 결측값은 평균 값으로 대체
train_df$Age <- ifelse(is.na(train_df$Age) == TRUE, mean(train_df$Age, na.rm = TRUE), train_df$Age)
test_df$Age <- ifelse(is.na(test_df$Age) == TRUE, mean(test_df$Age, na.rm = TRUE), test_df$Age)

#Survived 결측치는 없는 것이 당연함.
# test_df에는 Survived 변수가 없다.

nonvars = c("PassengerId", "Name", "Ticket", "Cabin", "Embarked")
train_df <- train_df[, !(names(train_df) %in% nonvars)]

glm1 <- glm(Survived ~ ., data = train_df, family = binomial)
summary(glm1)

# Fare와 Parch의 p-value가  0.05를 넘어서므로 제거를 하는게 나음.
glm2 <- glm(Survived ~ . - Parch - Fare, data = train_df, family = binomial)
summary(glm2)

logistic_pred <- predict(glm2, type = "response")
table(train_df$Survived, logistic_pred >= 0.5)
predictTest = predict(glm2, type = "response", newdata = test_df)
test_df$Survived = as.numeric(predictTest >= 0.5)
table(test_df$Survived)

predictions = data.frame(test_df[c("PassengerId", "Survived")])

refer_df <- read.csv("gender_submission.csv")
refer_df$Survived <- as.factor(refer_df$Survived)
levels(refer_df$Survived)
predictions$Survived <- as.factor(predictions$Survived)

library(caret)
caret::confusionMatrix(predictions$Survived, refer_df$Survived )


write.csv(file = "logistic_pred.csv", predictions, row.names = FALSE)
