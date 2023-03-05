library(shiny)
library(tidyverse)
library(bslib)

got_data <- CodeClanData::all_deaths

got_books  <- got_data %>%
  distinct(book_of_death) %>%
  drop_na() %>% 
  arrange(book_of_death) %>% 
  pull()

got_pivot <- got_data %>%
  group_by(allegiances, book_of_death) %>%
  summarise(total = n(),
            male = sum(gender),
            female = total - male) %>%
  ungroup() %>% 
  drop_na() %>%
  pivot_longer(cols = ("total":"female"),
               names_to = "gender_or_all",
               values_to = "no_of_deaths")

got_gender <- got_pivot %>% 
  distinct(gender_or_all) %>% 
  pull()

got_genders <- got_data %>% 
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
  
  sidebarLayout(
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
      plotOutput("got_deaths_plot")
    )
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
      geom_bar(stat = "identity") +
      coord_flip() +
      labs(x = "Allegiance",
           y = "Number of Deaths") +
      ylim(0, 30) +
      theme_minimal() +
      theme(
        text = element_text(size = 16, face = "bold")
      )
  })
}
shinyApp(ui, server)