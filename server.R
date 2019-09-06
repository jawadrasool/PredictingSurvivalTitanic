library(shiny)
library(caret)
library(dplyr)

set.seed(123)
df <- read.csv("train.csv", stringsAsFactors = FALSE)

#converting categorical variables to factors
categorical_variables <- c('Survived', 'Pclass', 'Sex', 'Embarked')
df[categorical_variables] <- lapply(df[categorical_variables], function(x) as.factor(x))

# Adding relatives in one columns
df$Relatives <- df$SibSp + df$Parch

# removing unimportant columns
df <- subset(df, select = -c(PassengerId, Name, Cabin, Ticket, SibSp, Parch))

#fill in missing embarkment
df$Embarked[df$Embarked==''] <- 'C'
df_original <- df

#Use stepwise selection for predictors for the linear model
AgeLM <- lm(Age~Pclass+Sex+Fare+Embarked+Relatives, data=df)
simplifiedAgeLM <- step(AgeLM, trace=0)
predictedAge <- df$Age
predictedAge[is.na(predictedAge)] <- predict(simplifiedAgeLM, df[is.na(df$Age),])
#fill in missing ages
df$Age <- predictedAge

# correct the imbalace
df <- rbind(df, df[df$Sex == "male" & df$Survived == 1,], df[df$Sex == "male" & df$Survived == 1,])

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    # model
    fitControl <- trainControl(method = "cv", number = 5)
    model <- train(Survived ~ ., data = df, method = "rf", trControl = fitControl)
    
    #prediction
    modelPred <- reactive({
        Sex <- input$Sex
        Pclass <- input$Pclass
        Embarked <- input$Embarked
        Age <- input$Age
        Fare <- input$Fare
        Relatives <- input$Relatives
        
        newData <- data.frame(Sex, Pclass, Embarked, Age, Fare, Relatives)
        predict(model, newdata = newData, type = "prob", predict.all = TRUE)    
    })
    
    # render prediction
    output$pred <- renderText({
        if (as.numeric(modelPred()[,1]) > as.numeric(modelPred()[,2])) {
            paste('<span style=\"color:red\">There is a ', as.numeric(modelPred()[,1])*100, 
                  '% chance that you will not survive!</span>', sep="")
        } else {
            paste('<span style=\"color:green\">There is a ', as.numeric(modelPred()[,2])*100, 
                  '% chance that you will survive!</span>', sep="")
        }
    })
    
    #Gender vs Survival
    output$plotGender <- renderPlot({
        genderImpact <- data.frame(table(df_original[, "Sex"], df_original$Survived))
        names(genderImpact) <- c("Sex","Survived","Freq")
        d <- genderImpact %>% 
            group_by(Sex, Survived) %>% 
            summarise(count=Freq) %>% 
            mutate(Percentage=count/sum(count)*100)
        ggplot(d, aes(x = Sex, y = Percentage, fill = Survived)) + geom_bar(stat="identity")
    })
    
    #Pclass vs Survived
    output$plotPclass <- renderPlot({
        pclassImpact <- data.frame(table(df_original[, "Pclass"], df_original$Survived))
        names(pclassImpact) <- c("Pclass","Survived","Freq")
        d <- pclassImpact %>% 
            group_by(Pclass, Survived) %>% 
            summarise(count=Freq) %>% 
            mutate(Percentage=count/sum(count)*100)
        ggplot(d, aes(x = Pclass, y = Percentage, fill = Survived)) + geom_bar(stat="identity")
    })
    
    #Family vs Survived
    output$plotFamily <- renderPlot({
        familyImpact <- data.frame(table(df[, "Relatives"], df$Survived))
        names(familyImpact) <- c("Family","Survived","Freq")
        d <- familyImpact %>% 
            group_by(Family, Survived) %>% 
            summarise(count=Freq) %>% 
            mutate(Percentage=count/sum(count)*100)
        ggplot(d, aes(x = Family, y = Percentage, fill = Survived)) + geom_bar(stat="identity")
    })
    
    #Embarked vs Survived
    output$plotEmbarked <- renderPlot({
        EmbarkedImpact <- data.frame(table(df_original[, "Embarked"], df_original$Survived))
        names(EmbarkedImpact) <- c("Embarked","Survived","Freq")
        d <- EmbarkedImpact %>% 
            group_by(Embarked, Survived) %>% 
            summarise(count=Freq) %>% 
            mutate(Percentage=count/sum(count)*100)
        ggplot(d, aes(x = Embarked, y = Percentage, fill = Survived)) + geom_bar(stat="identity")
    })
    
    #Age vs Survived
    output$plotAge <- renderPlot({
        AgeImpact <- data.frame(df_original[, "Age"], df_original$Survived)
        AgeImpact[,1] <- cut(AgeImpact[,1], 8)
        AgeImpact <- data.frame(table(AgeImpact))
        names(AgeImpact) <- c("Age","Survived","Freq")
        d <- AgeImpact %>% 
            group_by(Age, Survived) %>% 
            summarise(count=Freq) %>% 
            mutate(Percentage=count/sum(count)*100)
        ggplot(d, aes(x = Age, y = Percentage, fill = Survived)) + geom_bar(stat="identity") +
            theme(axis.text.x = element_text(angle = 90))
    })
    
    #Fare vs Survived
    output$plotFare <- renderPlot({
        tmp <- df_original[df_original$Fare < 350,]
        FareImpact <- data.frame(tmp[,"Fare"], tmp$Survived)
        FareImpact[,1] <- cut(FareImpact[,1], 10)
        FareImpact <- data.frame(table(FareImpact))
        names(FareImpact) <- c("Fare","Survived","Freq")
        d <- FareImpact %>% 
            group_by(Fare, Survived) %>% 
            summarise(count=Freq) %>% 
            mutate(Percentage=count/sum(count)*100)
        ggplot(d, aes(x = Fare, y = Percentage, fill = Survived)) + geom_bar(stat="identity") +
            theme(axis.text.x = element_text(angle = 90))
    })
})
