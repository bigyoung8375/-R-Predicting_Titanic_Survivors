library(rpart)
library(rpart.plot)
library(randomForest)
library(ggplot2)

# https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=bestinall&logNo=221507507813
# https://www.kaggle.com/c/titanic

getwd()
setwd("C:/Users/Samsung/Desktop/빅분기실기준비/타이타닉 생존자 예측")
list.files()

test_df <- read.csv("test.csv")
train_df <- read.csv("train.csv")

# 성별, 생존, Embarked(승선한 곳) facotr형으로 변환.
train_df$Sex <- as.factor(train_df$Sex)
train_df$Embarked <- as.factor(train_df$Embarked)
train_df$Pclass <- as.factor(train_df$Pclass)
train_df$Survived <- as.factor(train_df$Survived)
str(train_df)


test_df$Pclass <- as.factor(test_df$Pclass)
test_df$Embarked <- as.factor((test_df$Embarked))
test_df$Sex <- as.factor((test_df$Sex))
str(test_df)


# 결측값이 있는지 확인
sapply(test_df, FUN = function(x) {
  sum(is.na(x))
})

sapply(train_df, FUN = function(x) {
  sum(is.na(x))
}) 


# 결측값은 평균대치법을 활용
test_df$Age <- ifelse(is.na(test_df$Age) == TRUE, mean(test_df$Age, na.rm = TRUE), test_df$Age)
train_df$Age <- ifelse(is.na(train_df$Age) == TRUE, mean(train_df$Age, na.rm = TRUE), train_df$Age)

# 성별에 따른 생존여부

ggplot_sex <- ggplot(train_df, aes(x = Survived,fill = Sex)) + geom_bar(size = 10, width= .6) +
  theme_bw() + coord_fixed(ratio=1/210)
ggplot_sex


# 랜덤포레스트
randomfor <- randomForest(Survived ~ Pclass + Age + Sex, data = train_df)
randomfor_info <- randomForest(Survived ~ Sex + Age + Pclass, data = train_df, importance = T)
importance(randomfor_info)

randomfor_pre <- predict(randomfor, newdata = test_df, type="response")
Titanic_randomFor <- data.frame(PassengerId = test_df$PassengerId, Survived = randomfor_pre)
head(Titanic_randomFor)

varImpPlot(randomfor_info)


refer_df <- read.csv("gender_submission.csv")
refer_df$Survived <- as.factor(refer_df$Survived)
caret::confusionMatrix(data = Titanic_randomFor$Survived, reference = refer_df[,2])

write.csv(Titanic_randomFor, file="Titanic_randomFor.csv", row.names = FALSE)

# 로지스틱 회귀
df_glm = glm(Survived ~ ., family = binomial, data = train_df)

step_model = step(df_glm, direction = "backward")
summary(step_model)


pred = predict(step_model, newdata = test_df, type="response")







































































































































































