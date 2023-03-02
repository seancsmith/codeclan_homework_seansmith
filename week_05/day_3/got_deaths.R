library(shiny)
library(tidyverse)
library(bslib)
library(CodeClanData)

got_data <- CodeClanData::all_deaths

# create a vector of team options from olympics medals data
got_books  <- got_data %>%
  distinct(book_of_death) %>%
  drop_na() %>% 
  pull()

# got_books  <- got_pivot %>%
#   distinct(book_of_death) %>%
#   drop_na() %>% 
#   pull()

ui <- fluidPage(
  titlePanel(tags$h1(tags$b("GOT deaths by book"))),
  theme = bs_theme(bootswatch = "lux"),
  
  sidebarPanel(
    # radioButtons(
    #   inputId = "gender_or_all",
    #   label = tags$i("Deaths by Gender"),
    #   choices = c("male", "female", "total")
    # ),
    selectInput(
      inputId = "book_input",
      label = "Which Book?",
      choices = got_books
    )
  ),
  mainPanel(
    plotOutput("deaths_plot")
    #tags$a("Olympics Website", href = "https://www.olympic.org/")
  )
)

server <- function(input, output, session) {
  output$deaths_plot <- renderPlot(expr = {
    deaths_in_each_book <- got_data %>% 
      group_by(allegiances, book_of_death) %>% 
      summarise(no_of_deaths = n()) %>% 
      drop_na() %>% 
      #filter(book_of_death == 4)
      filter(book_of_death == input$book_input) %>% 
      # filter(gender == input$gender_or_all ) %>%
      ggplot() +
      aes(x = reorder(allegiances, -no_of_deaths), y = no_of_deaths) +
      geom_col() +
      coord_flip() +
      labs(x = "Allegiance",
           y = "Number of Deaths") +
      theme_minimal()
  })
}
shinyApp(ui, server)