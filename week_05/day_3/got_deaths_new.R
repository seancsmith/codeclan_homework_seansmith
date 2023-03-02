library(shiny)
library(tidyverse)
library(bslib)

got_data <- CodeClanData::all_deaths
# create a vector of team options from olympics medals data
got_books  <- got_data %>%
  distinct(book_of_death) %>%
  drop_na() %>% 
  arrange(book_of_death) %>% 
  pull()

deaths_in_each_book <- got_data %>% 
  group_by(allegiances, book_of_death) %>% 
  summarise(no_of_deaths = n()) %>% 
  drop_na()

ui <- fluidPage(
  titlePanel(tags$h1(tags$b("Game of Thrones - Deaths by book"))),
  theme = bs_theme(bootswatch = "lux"),
  sidebarPanel(
    selectInput(
      inputId = "book_input",
      label = "Which Book?",
      choices = got_books
    )
  ),
  mainPanel(
    plotOutput("got_deaths_plot"),
  )
)
server <- function(input, output, session) {
  output$got_deaths_plot <- renderPlot(expr = {
    deaths_in_each_book %>% 
      filter(book_of_death == input$book_input) %>% 
      ggplot() +
      aes(x = reorder(allegiances, no_of_deaths), y = no_of_deaths) +
      geom_col() +
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