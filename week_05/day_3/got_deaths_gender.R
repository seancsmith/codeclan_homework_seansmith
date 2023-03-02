library(shiny)
library(tidyverse)
library(bslib)

got_data <- CodeClanData::all_deaths
# create a vector of team options from olympics medals data
got_books  <- got_data %>%
  distinct(book_of_death) %>%
  drop_na() %>% 
  pull()

# deaths_in_each_book <- got_data %>% 
#   group_by(allegiances, book_of_death) %>% 
#   summarise(no_of_deaths = n()) %>% 
#   drop_na()

got_pivot <- got_data %>%
  group_by(allegiances, book_of_death) %>%
  summarise(total = n(),
            male = sum(gender),
            female = total - male) %>%
  drop_na() %>%
  pivot_longer(cols = ("total":"female"),
               names_to = "gender_or_all" ,
               values_to = "no_of_deaths")

got_gender <- got_data %>% 
  group_by(allegiances, book_of_death, gender) %>% 
  summarise(no_of_deaths = n(),
            female_deaths = (n() - sum(gender)),
            male_deaths = sum(gender)) %>% 
  drop_na() %>% 
  pivot_longer(cols = no_of_deaths:male_deaths,
               names_to = "gender_or_all",
               values_to = "deaths") %>%
  group_by(gender_or_all) %>% 
  distinct(gender_or_all) %>% 
  pull()

ui <- fluidPage(
  titlePanel(tags$h1(tags$b("Game of Thrones - Deaths by book"))),
  theme = bs_theme(bootswatch = "lux"),
  sidebarPanel(
    radioButtons(
      inputId = "gender_input",
      label = tags$i("Deaths by Gender"),
      choices = got_gender
    ),
    selectInput(
      inputId = "book_input",
      label = "Which Book?",
      choices = got_books
    )
  ),
  mainPanel(
    plotOutput("got_deaths_plot"),
    #tags$a("Olympics Website", href = "https://www.olympic.org/")
  )
)
server <- function(input, output, session) {
  output$got_deaths_plot <- renderPlot(expr = {
    got_pivot %>%  
      filter(book_of_death == input$book_input) %>%
      filter(gender_or_all == input$gender_input) %>% 
      ggplot() +
      aes(x = reorder(allegiances, -no_of_deaths),
          y = no_of_deaths) +
      geom_bar() +
      coord_flip() +
      labs(x = "Allegiance",
           y = "Number of Deaths") +
      theme_minimal()
  })
}
shinyApp(ui, server)