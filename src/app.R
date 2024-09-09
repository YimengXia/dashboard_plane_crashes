options(shiny.port = 8050, shiny.autoreload = TRUE)

library(shiny)
library(shinydashboard)
library(ggplot2)
library(DT)
library(dplyr)
library(lubridate)
library(stringr)
library(shinythemes)

last_updated <- paste("Last Updated:", Sys.Date())
author_name <- "Author: Yimeng Xia"

data <- read.csv("../data/raw/Plane Crashes.csv")
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")
data$Year <- year(data$Date)
data <- data |> filter(`Flight.phase` != "NA")
data <- data |> filter(`Flight.type` != "NA")
data <- data |> mutate(`Flight.type` = ifelse(`Flight.type` == "Scheduled Revenue Flight", 
                                              "Commercial Flight", 
                                              `Flight.type`))
data <- data |> filter(`Crash.site` != "NA")

# Layout
ui <- navbarPage(
  title = "Plane Crash Analysis",
  theme = shinytheme("flatly"),
  tabPanel("Dashboard",
           fluidPage(
             tags$head(tags$style(HTML("
        .navbar {margin-bottom: 10px;}
        .container-fluid {padding-top: 20px;}
        .plot-row {margin-bottom: 20px;}
        .info-text {margin-top: 300px; font-size: 0.8em; text-align: left;}
      "))),
             fluidRow(
               column(3,
                      selectInput("FlightPhase", "Select Flight Phase:", 
                                  choices = unique(as.character(data$`Flight.phase`)),
                                  multiple = TRUE),
                      selectInput("Survivors", "Any Survivors?",
                                  choices = c("Yes", "No")),
                      selectInput("FlightType", "Select Flight Type:",
                                  choices = unique(data$`Flight.type`),
                                  selected = c("Commercial Flight", "Cargo", "Military"),
                                  multiple = TRUE),
                      sliderInput("Year", "Select Year Range:",
                                  min = min(data$Year), max = max(data$Year), 
                                  value = c(min(data$Year), max(data$Year)),
                                  step = 1,
                                  sep = "",
                                  ticks = FALSE
                      ),
                      div(class = "info-text", 
                          HTML(paste(last_updated, author_name, sep = " | ")))
               ),
               column(9,
                      fluidRow(
                        class = "plot-row",
                        column(6, plotOutput("plot1", height = "300px")),
                        column(6, plotOutput("plot2", height = "300px"))
                      ),
                      fluidRow(
                        class = "plot-row",
                        column(6, plotOutput("plot3", height = "300px")),
                        column(6, plotOutput("plot4", height = "300px"))
                      )
               )
             )
           )
  )
)



# Server side callbacks
server <- function(input, output, session) {
  filtered_data <- reactive({
    temp_data <- data
    
    if (length(input$FlightPhase) > 0) {
      temp_data <- temp_data[temp_data$`Flight.phase` %in% input$FlightPhase, ]
    }
    
    if (input$Survivors == "Yes") {
      temp_data <- temp_data[temp_data$Survivors == "Yes", ]
    } else if (input$Survivors == "No") {
      temp_data <- temp_data[temp_data$Survivors == "No", ]
    }
    
    if (length(input$FlightType) > 0) {
      temp_data <- temp_data[temp_data$`Flight.type` %in% input$FlightType, ]
    }
    
    temp_data <- temp_data[temp_data$Year >= input$Year[1] & temp_data$Year <= input$Year[2], ]
    temp_data
  })
  
  # 1st plot
  output$plot1 <- renderPlot({
    ggplot(filtered_data(), aes(x = Year, group = `Flight.phase`, color = `Flight.phase`)) +
      geom_line(stat = "count") +
      scale_x_continuous(breaks = function(x) unique(floor(pretty(x)))) +
      labs(title = "Number of Crushes by Year and Flight Phase", 
           x = "Year", y = "Number of Crushes", color = "Flight Phase") +
      theme_minimal() +
      theme(plot.title = element_text(face = "bold", hjust = 0.5),
            legend.position = "bottom") +
      guides(color = guide_legend(nrow = 2))
  })
  
  # 2nd plot
  output$plot2 <- renderPlot({
    aggregated_data <- filtered_data() |> group_by(`Flight.type`) |> summarise(Count = n(), .groups = 'drop')
    
    ggplot(aggregated_data, aes(x = `Flight.type`, y = Count, fill = `Flight.type`)) +
      geom_bar(stat = "identity") +
      labs(title = "Total Crushess by Flight Type", 
           x = "Flight Type", y = "Number of Crushes", fill = "Flight Type") +
      theme_minimal() +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
  })
  
  # 3rd plot
  output$plot3 <- renderPlot({
    current_data <- filtered_data() |> count(`Crash.site`, sort = TRUE) |> arrange(desc(n))
    current_data$`Crash.site` <- str_wrap(current_data$`Crash.site`, width = 10)
    ggplot(current_data, aes(x = reorder(`Crash.site`, n), y = n)) +
      geom_bar(stat = "identity", fill = "skyblue") +
      coord_flip() + 
      labs(title = "Most Frequently Crashed Sites", 
           x = "Crashed Sites", y = "Number of Crashes") +
      theme_minimal() +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
  })
  
  #4th plot
  output$plot4 <- renderPlot({
    valid_data <- filtered_data() |> 
      filter(!is.na(`Crew.on.board`), !is.na(`Crew.fatalities`), `Crew.on.board` > 0) |> 
      mutate(FatalityRate = `Crew.fatalities` / `Crew.on.board`)
    valid_data$`Crash.site` <- str_wrap(valid_data$`Crash.site`, width = 20)
    
    ggplot(valid_data, aes(x = FatalityRate, color = `Crash.site`)) +
      geom_density(alpha = 0.75) +
      labs(title = "Fatality Rate Distribution by Crash Site",
           x = "Fatality Rate", y = "Density", color = "Crash Site") +
      theme_minimal() +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
  })
}

# Run the app 
shinyApp(ui, server)