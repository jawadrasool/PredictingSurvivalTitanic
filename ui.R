#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(markdown)

shinyUI(
    navbarPage("",
               tabPanel("App",
                        # Application title
                        titlePanel("Predicting your Chances of Survival in Titanic Crash"),
                        
                        sidebarPanel(
                            selectInput("Sex", "Select your Gender:", choices = list("male", "female"), selected = "male"),
                            selectInput("Pclass", "Select your Passenger Class:", choices = list("1", "2", "3"), selected = "2"),
                            selectInput("Embarked", "Select the place of embarkment on the ship (C - Cherbourg, S - Southampton, Q = Queenstown);",
                                        choices = list("C", "S", "Q"), selected = "S"),
                            sliderInput("Age", "Select your Age:", min = 0, max = 80, value = 30),
                            sliderInput("Fare", "Select your Fare (Dollars):", min = 0, max = 250, value = 30),
                            sliderInput("Relatives", "Number of Family Members (spouse, children, parents, siblings) travelling with you:", min = 0, max = 10, value = 1),
                            submitButton("Predict")
                        ),
                        mainPanel(
                            tabsetPanel(
                                tabPanel("Prediction",                             
                                         img(src='titanic1.png', align = "center", height = 250, width = 600),
                                         h3(""),
                                         h4("Make your selection and click Predict!"),
                                         h3(""),
                                         p("(The model will take some time to run for the first time after you click Predict.)"),                         
                                         h2("Predicting your chances:"),
                                         h3(""),
                                         h3(""),               
                                         h2(htmlOutput("pred"))
                                ),
                                tabPanel("Visualization",      
                                         h4(""),
                                         p("(The graphs will take some time to appear.)"),
                                         h4(""),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     h3("Gender vs. Survival"),
                                                     h3("Passenger Class vs. Survival")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     p("Female's survival rate was greater than the average survival rate (38.38%)."),
                                                     p("First class passengers had the highest survival rate. Third class passengers had the lowest survival rate, even lower than the average survival rate of 38.38%.")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     plotOutput("plotGender", height = "300px", width="300px"),
                                                     plotOutput("plotPclass", height = "300px", width="300px")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     h3("Family vs. Survival"),
                                                     h3("Place of Embarkment vs. Survival")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     p("People with fewer family members had higher chance of survival. This might be due to the fact that they didn't need to take care of too many people."),
                                                     p("People who embarked from Cherbourg had a higher chance of survival. Their cabins might be in higher decks or were closer to the exits.")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     plotOutput("plotFamily", height = "300px", width="300px"),
                                                     plotOutput("plotEmbarked", height = "300px", width="300px")                                 
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     h3("Age vs. Survival"),
                                                     h3("Fare vs. Survival")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     p("Young people had a higher chance of survival"),
                                                     p("People with low fares had lower chance of survival.")
                                         ),
                                         splitLayout(cellWidths = c("50%", "50%"),
                                                     plotOutput("plotAge", height = "300px", width="300px"),
                                                     plotOutput("plotFare", height = "300px", width="300px")
                                         )
                                )
                            )
                        )
               ),     
               tabPanel("Info",
                        mainPanel(
                            includeMarkdown("info.Rmd"))
               )
    )
)
