---

# ============================================================
# CELLFIE!
# Which Immune Cell Are You?
#
# An interactive immunology quiz built with R Shiny
#
# 10 scientific questions
# 6 possible immune-cell identities
# Weighted biological scoring
# Exactly one final identity
# ============================================================

library(shiny)


# ============================================================
# 1. QUESTION BANK
# ============================================================

questions <- data.frame(
  
  question = c(
    
    "Which immune cell can develop into a plasma cell that secretes antibodies?",
    
    "Which immune cell can directly kill infected cells after recognizing a specific antigen?",
    
    "Which innate immune cell can kill some virus-infected cells without prior antigen-specific sensitization?",
    
    "Which immune cell engulfs microbes and cellular debris by phagocytosis?",
    
    "Which immune cell is especially important for activating naive T cells?",
    
    "Which white blood cell is often rapidly recruited during acute bacterial infections?",
    
    "What is the primary role of antibodies?",
    
    "Which organ is a major site of T-cell maturation?",
    
    "What is the name of the process in which immune cells engulf particles?",
    
    "Which type of immunity develops antigen-specific memory?"
    
  ),
  
  A = c(
    "B cell",
    "Neutrophil",
    "B cell",
    "Macrophage",
    "Platelet",
    "Neutrophil",
    "Transport oxygen",
    "Thymus",
    "Osmosis",
    "Adaptive immunity"
  ),
  
  B = c(
    "Red blood cell",
    "Cytotoxic T cell",
    "Natural killer cell",
    "Red blood cell",
    "Dendritic cell",
    "Red blood cell",
    "Recognize and bind specific antigens",
    "Kidney",
    "Phagocytosis",
    "Innate immunity only"
  ),
  
  C = c(
    "Platelet",
    "B cell",
    "Platelet",
    "Platelet",
    "Red blood cell",
    "Platelet",
    "Produce insulin",
    "Liver",
    "Diffusion",
    "Neither innate nor adaptive immunity"
  ),
  
  D = c(
    "Neutrophil",
    "Red blood cell",
    "Red blood cell",
    "Plasma cell",
    "Erythrocyte",
    "Erythrocyte",
    "Produce haemoglobin",
    "Pancreas",
    "Transcription",
    "Only physical barriers"
  ),
  
  correct = c(
    "A", "B", "B", "A", "B",
    "A", "B", "A", "B", "A"
  ),
  
  explanation = c(
    
    "B lymphocytes can differentiate into plasma cells, which produce and secrete antibodies.",
    
    "CD8+ cytotoxic T cells recognize specific peptides presented by MHC class I molecules and can eliminate infected cells.",
    
    "Natural killer cells are innate lymphocytes that can eliminate certain infected or transformed cells without prior antigen-specific sensitization.",
    
    "Macrophages are phagocytic cells that engulf pathogens, damaged cells and cellular debris.",
    
    "Dendritic cells are professional antigen-presenting cells particularly important for activating naive T lymphocytes.",
    
    "Neutrophils are often among the earliest leukocytes recruited during acute bacterial inflammation.",
    
    "Antibodies bind specific antigens and can neutralize pathogens, promote phagocytosis or activate complement.",
    
    "The thymus is the major site where T lymphocytes mature and undergo selection.",
    
    "Phagocytosis is the cellular process of engulfing particles such as microbes and debris.",
    
    "Adaptive immunity involves antigen-specific B- and T-cell responses and can generate immunological memory."
    
  ),
  
  stringsAsFactors = FALSE
)


# ============================================================
# 2. IMMUNE CELL PROFILES
# ============================================================

profiles <- list(
  
  B = list(
    name = "B Cell",
    title = "The Antibody Specialist",
    fact = paste(
      "B cells contribute to humoral immunity",
      "by producing antibodies through plasma cells",
      "and generating memory B cells."
    )
  ),
  
  T = list(
    name = "Cytotoxic T Cell",
    title = "The Precision Defender",
    fact = paste(
      "CD8+ cytotoxic T cells recognize specific",
      "antigenic peptides on MHC class I",
      "and can eliminate infected or abnormal cells."
    )
  ),
  
  NK = list(
    name = "Natural Killer Cell",
    title = "The Innate Defender",
    fact = paste(
      "NK cells are innate lymphocytes that detect",
      "cellular abnormalities through activating",
      "and inhibitory receptors."
    )
  ),
  
  M = list(
    name = "Macrophage",
    title = "The Phagocytic Guardian",
    fact = paste(
      "Macrophages engulf microbes and debris,",
      "coordinate inflammatory responses",
      "and participate in tissue repair."
    )
  ),
  
  D = list(
    name = "Dendritic Cell",
    title = "The Antigen Presenter",
    fact = paste(
      "Dendritic cells link innate and adaptive",
      "immunity by processing antigens",
      "and activating T lymphocytes."
    )
  ),
  
  N = list(
    name = "Neutrophil",
    title = "The Rapid Responder",
    fact = paste(
      "Neutrophils are rapidly recruited to many",
      "sites of infection and use phagocytosis",
      "and antimicrobial mechanisms."
    )
  )
  
)


# ============================================================
# 3. WEIGHTED IMMUNE CELL SCORING
# ============================================================

# Each question contributes to biologically related cells.
#
# 3 = strong biological connection
# 2 = moderate biological connection
# 1 = supporting biological connection
# 0 = not used for scoring
#
# Columns:
# B  = B Cell
# T  = Cytotoxic T Cell
# NK = Natural Killer Cell
# M  = Macrophage
# D  = Dendritic Cell
# N  = Neutrophil

cell_weights <- matrix(
  
  c(
    
    # B  T  NK M  D  N
    
    3, 0, 0, 0, 1, 0,  # Q1
    0, 3, 1, 0, 0, 0,  # Q2
    0, 1, 3, 0, 0, 0,  # Q3
    0, 0, 0, 3, 0, 1,  # Q4
    0, 1, 0, 0, 3, 0,  # Q5
    0, 0, 0, 1, 0, 3,  # Q6
    3, 0, 0, 1, 0, 0,  # Q7
    0, 2, 0, 0, 2, 0,  # Q8
    0, 0, 0, 2, 0, 2,  # Q9
    1, 1, 1, 0, 1, 0   # Q10
    
  ),
  
  nrow = 10,
  ncol = 6,
  byrow = TRUE,
  
  dimnames = list(
    paste0("Q", 1:10),
    c("B", "T", "NK", "M", "D", "N")
  )
  
)


# ------------------------------------------------------------
# Calculate final immune-cell identity
# ------------------------------------------------------------

get_identity <- function(records) {
  
  stopifnot(
    length(records) == nrow(cell_weights)
  )
  
  correct_answers <- vapply(
    records,
    function(r) isTRUE(r$correct),
    logical(1)
  )
  
  # Weighted points earned by each cell
  raw_scores <- colSums(
    sweep(
      cell_weights,
      1,
      as.integer(correct_answers),
      "*"
    )
  )
  
  # Maximum available points per cell
  maximum_scores <- colSums(cell_weights)
  
  # Normalize so all cells are compared fairly
  normalized_scores <- (
    raw_scores / maximum_scores
  ) * 100
  
  # Find the highest-scoring cell(s)
  highest_score <- max(normalized_scores)
  
  tied_cells <- names(normalized_scores)[
    abs(normalized_scores - highest_score) < 1e-8
  ]
  
  # If there is one winner, return it
  if (length(tied_cells) == 1) {
    return(tied_cells[1])
  }
  
  # Tie-break 1:
  # Prefer higher raw weighted score
  tied_raw <- raw_scores[tied_cells]
  
  tied_cells <- tied_cells[
    tied_raw == max(tied_raw)
  ]
  
  if (length(tied_cells) == 1) {
    return(tied_cells[1])
  }
  
  # Tie-break 2:
  # Prefer more strongly associated correct answers
  strong_scores <- sapply(
    tied_cells,
    function(cell) {
      sum(
        correct_answers &
          cell_weights[, cell] == 3
      )
    }
  )
  
  tied_cells <- tied_cells[
    strong_scores == max(strong_scores)
  ]
  
  if (length(tied_cells) == 1) {
    return(tied_cells[1])
  }
  
  # Final deterministic tie-break
  priority <- c(
    "B", "T", "NK", "M", "D", "N"
  )
  
  priority[priority %in% tied_cells][1]
  
}


# ============================================================
# 4. USER INTERFACE
# ============================================================

ui <- fluidPage(
  
  tags$head(
    
    tags$title(
      "Cellfie! | Which Immune Cell Are You?"
    ),
    
    tags$meta(
      name = "viewport",
      content = "width=device-width, initial-scale=1"
    ),
    
    tags$style(HTML("

      body {
        background:
          radial-gradient(
            circle at 15% 20%,
            rgba(107,76,196,0.45),
            transparent 40%
          ),
          radial-gradient(
            circle at 85% 75%,
            rgba(16,171,191,0.30),
            transparent 40%
          ),
          linear-gradient(
            135deg,
            #0b1230,
            #181d4c,
            #101d3b
          );

        background-attachment: fixed;
        min-height: 100vh;
        font-family: Arial, sans-serif;
        color: #f4f3ff;
      }

      .container-fluid {
        max-width: 820px;
        padding: 25px 18px 45px;
      }

      .brand {
        color: #9ceaf0;
        font-size: 25px;
        font-weight: 800;
        letter-spacing: 2px;
        margin-bottom: 28px;
      }

      .welcome {
        text-align: center;
        padding: 30px 0;
      }

      .welcome h1 {
        color: white;
        font-size: 43px;
        font-weight: 800;
        line-height: 1.2;
      }

      .welcome p {
        color: #d2d5ef;
        font-size: 17px;
        line-height: 1.7;
      }

      .game-card {
        background: #f8f8ff;
        color: #192144;
        padding: 30px;
        border-radius: 20px;
        margin-top: 20px;
        box-shadow:
          0 15px 45px rgba(0,0,0,0.25);
      }

      .game-card h2 {
        color: #192144;
        font-size: 24px;
        font-weight: 750;
        line-height: 1.4;
      }

      .label-pill {
        display: inline-block;
        background: #e7e5ff;
        color: #5144a5;
        padding: 7px 13px;
        border-radius: 30px;
        font-size: 12px;
        font-weight: bold;
      }

      .muted {
        color: #626b85;
        font-size: 14px;
        line-height: 1.6;
      }

      .btn-primary {
        background: #6654cc;
        border-color: #6654cc;
        padding: 12px 24px;
        border-radius: 11px;
        font-weight: bold;
        margin-top: 12px;
      }

      .btn-primary:hover {
        background: #5140b1;
        border-color: #5140b1;
      }

      .progress-track {
        height: 9px;
        background: #e5e7f3;
        border-radius: 10px;
        overflow: hidden;
        margin: 18px 0 25px;
      }

      .progress-fill {
        height: 100%;
        background:
          linear-gradient(
            90deg,
            #6551c7,
            #26b6c2
          );
      }

      .radio label {
        display: block;
        background: white;
        border: 1px solid #d9ddef;
        border-radius: 12px;
        padding: 12px 15px;
        margin: 10px 0;
        cursor: pointer;
        font-weight: normal;
        transition: 0.15s;
      }

      .radio label:hover {
        background: #efedff;
        border-color: #6654cc;
      }

      .feedback {
        padding: 17px;
        border-radius: 12px;
        margin-top: 20px;
        background: #e6f5ef;
        color: #185a42;
      }

      .feedback.incorrect {
        background: #fff0e9;
        color: #8c422b;
      }

      .certificate {
        background:
          linear-gradient(
            145deg,
            #f2edff,
            #e4f9fa
          );
        border: 4px double #9683d7;
        border-radius: 18px;
        padding: 35px 22px;
        text-align: center;
      }

      .certificate h1 {
        color: #342b84;
        font-size: 38px;
        font-weight: 800;
        margin: 18px 0;
      }

      .certificate h3 {
        color: #167f91;
        font-weight: 700;
      }

      .certificate p {
        color: #4f5874;
        line-height: 1.7;
      }

      .science {
        background: #e9f5f8;
        color: #254b59;
        padding: 18px;
        border-radius: 12px;
        margin-top: 20px;
        text-align: left;
      }

      .science h4 {
        color: #167f91;
        font-weight: 800;
      }

      .final-score {
        color: #342b84;
        font-size: 32px;
        font-weight: 800;
        margin-top: 18px;
      }

      @media(max-width:600px) {

        .welcome h1 {
          font-size: 32px;
        }

        .game-card {
          padding: 20px;
        }

        .game-card h2 {
          font-size: 21px;
        }

        .certificate h1 {
          font-size: 31px;
        }
      }

      @media print {

        body {
          background: white !important;
        }

        .brand,
        .no-print {
          display: none !important;
        }

        .game-card {
          box-shadow: none;
          margin: 0;
          padding: 0;
        }

        .certificate {
          break-inside: avoid;
        }
      }

    "))
  ),
  
  div(
    class = "brand",
    "CELLFIE!"
  ),
  
  uiOutput("screen")
  
)


# ============================================================
# 5. SERVER
# ============================================================

server <- function(input, output, session) {
  
  # Current game state
  stage <- reactiveVal("welcome")
  
  question_number <- reactiveVal(1L)
  
  answer_checked <- reactiveVal(FALSE)
  
  selected_answer <- reactiveVal(NULL)
  
  answer_records <- reactiveVal(list())
  
  shuffled_options <- reactiveVal(NULL)
  
  
  # ----------------------------------------------------------
  # START GAME
  # ----------------------------------------------------------
  
  observeEvent(input$start_game, {
    
    # Shuffle choices independently for every question
    shuffled_options(
      lapply(
        seq_len(nrow(questions)),
        function(i) {
          sample(c("A", "B", "C", "D"))
        }
      )
    )
    
    question_number(1L)
    
    answer_checked(FALSE)
    
    selected_answer(NULL)
    
    answer_records(list())
    
    stage("quiz")
    
  })
  
  
  # ----------------------------------------------------------
  # CHECK ANSWER
  # ----------------------------------------------------------
  
  observeEvent(input$check_answer, {
    
    req(stage() == "quiz")
    
    req(!answer_checked())
    
    i <- question_number()
    
    # Unique input ID for every question
    answer_id <- paste0("answer_", i)
    
    answer <- input[[answer_id]]
    
    if (
      is.null(answer) ||
      length(answer) == 0 ||
      !nzchar(answer)
    ) {
      
      showNotification(
        "Please select an answer before continuing.",
        type = "warning"
      )
      
      return()
    }
    
    is_correct <- identical(
      answer,
      questions$correct[i]
    )
    
    # Store the result for scoring
    current_records <- answer_records()
    
    current_records[[length(current_records) + 1L]] <- list(
      question = i,
      correct = is_correct
    )
    
    answer_records(current_records)
    
    selected_answer(answer)
    
    answer_checked(TRUE)
    
  })
  
  
  # ----------------------------------------------------------
  # NEXT QUESTION
  # ----------------------------------------------------------
  
  observeEvent(input$next_question, {
    
    req(stage() == "quiz")
    
    req(answer_checked())
    
    if (question_number() >= nrow(questions)) {
      
      stage("results")
      
    } else {
      
      question_number(
        question_number() + 1L
      )
      
      selected_answer(NULL)
      
      answer_checked(FALSE)
      
    }
    
  })
  
  
  # ----------------------------------------------------------
  # RESTART GAME
  # ----------------------------------------------------------
  
  observeEvent(input$restart_game, {
    
    stage("welcome")
    
    question_number(1L)
    
    answer_checked(FALSE)
    
    selected_answer(NULL)
    
    answer_records(list())
    
    shuffled_options(NULL)
    
  })
  
  
  # ==========================================================
  # 6. RENDER SCREENS
  # ==========================================================
  
  output$screen <- renderUI({
    
    # --------------------------------------------------------
    # WELCOME SCREEN
    # --------------------------------------------------------
    
    if (stage() == "welcome") {
      
      return(
        tagList(
          
          div(
            class = "welcome",
            
            h1(
              "Which Immune Cell Are You?"
            ),
            
            p(
              "10 questions. One immune identity."
            )
          ),
          
          div(
            class = "game-card",
            style = "text-align:center;",
            
            span(
              class = "label-pill",
              "BEGINNER IMMUNOLOGY QUIZ"
            ),
            
            h2(
              "Small quiz. Big immune energy."
            ),
            
            p(
              class = "muted",
              paste(
                "Test your knowledge of immune cells,",
                "antibodies and host defence."
              )
            ),
            
            p(
              class = "muted",
              "10 questions | 3-5 minutes"
            ),
            
            actionButton(
              "start_game",
              "Let's Play!",
              class = "btn-primary"
            )
          )
          
        )
      )
      
    }
    
    
    # --------------------------------------------------------
    # QUESTION SCREEN
    # --------------------------------------------------------
    
    if (stage() == "quiz") {
      
      i <- question_number()
      
      q <- questions[i, ]
      
      option_keys <- shuffled_options()[[i]]
      
      option_text <- vapply(
        option_keys,
        function(key) {
          as.character(q[[key]])
        },
        character(1)
      )
      
      # Display text as labels and A/B/C/D as values
      choices <- setNames(
        option_keys,
        option_text
      )
      
      progress <- round(
        i / nrow(questions) * 100
      )
      
      return(
        div(
          class = "game-card",
          
          div(
            style = paste0(
              "display:flex;",
              "justify-content:space-between;",
              "align-items:center;"
            ),
            
            span(
              class = "label-pill",
              "BEGINNER"
            ),
            
            span(
              class = "muted",
              paste(
                "QUESTION",
                i,
                "/",
                nrow(questions)
              )
            )
          ),
          
          div(
            class = "progress-track",
            
            div(
              class = "progress-fill",
              style = paste0(
                "width:",
                progress,
                "%;"
              )
            )
          ),
          
          h2(q$question),
          
          radioButtons(
            inputId = paste0("answer_", i),
            label = NULL,
            choices = choices,
            selected = if (answer_checked()) {
              selected_answer()
            } else {
              character(0)
            }
          ),
          
          # Feedback after submitting an answer
          if (answer_checked()) {
            
            div(
              class = if (
                identical(
                  selected_answer(),
                  q$correct
                )
              ) {
                "feedback"
              } else {
                "feedback incorrect"
              },
              
              strong(
                if (
                  identical(
                    selected_answer(),
                    q$correct
                  )
                ) {
                  "Correct!"
                } else {
                  paste(
                    "Correct answer:",
                    q[[q$correct]]
                  )
                }
              ),
              
              p(q$explanation)
            )
            
          },
          
          # Show the appropriate button
          if (!answer_checked()) {
            
            actionButton(
              "check_answer",
              "Check Answer",
              class = "btn-primary"
            )
            
          } else {
            
            actionButton(
              "next_question",
              
              if (i == nrow(questions)) {
                "Reveal My Cellfie!"
              } else {
                "Next Question"
              },
              
              class = "btn-primary"
            )
            
          }
          
        )
      )
      
    }
    
    
    # --------------------------------------------------------
    # FINAL RESULT SCREEN
    # --------------------------------------------------------
    
    records <- answer_records()
    
    req(
      length(records) == nrow(questions)
    )
    
    # Calculate total correct answers
    total_correct <- sum(
      vapply(
        records,
        function(r) {
          isTRUE(r$correct)
        },
        logical(1)
      )
    )
    
    # Calculate weighted immune-cell identity
    identity_key <- get_identity(records)
    
    # Retrieve corresponding profile
    profile <- profiles[[identity_key]]
    
    # Calculate overall accuracy
    accuracy <- round(
      total_correct / nrow(questions) * 100
    )
    
    return(
      div(
        class = "game-card",
        
        div(
          class = "certificate",
          
          span(
            class = "label-pill",
            "CELLFIE! - IMMUNE IDENTITY AWARD"
          ),
          
          h2(
            "Your immune-cell identity is"
          ),
          
          h1(
            profile$name
          ),
          
          h3(
            profile$title
          ),
          
          div(
            class = "final-score",
            paste(
              total_correct,
              "/",
              nrow(questions),
              "correct"
            )
          ),
          
          p(
            class = "muted",
            paste0(
              accuracy,
              "% accuracy"
            )
          ),
          
          div(
            class = "science",
            
            h4(
              "Meet Your Immune Cell"
            ),
            
            p(
              profile$fact
            )
          ),
          
          p(
            class = "muted",
            style = "margin-top:20px;",
            
            paste(
              "Your Cellfie! identity is a playful",
              "educational reward based on your",
              "immunology quiz performance."
            )
          )
          
        ),
        
        div(
          class = "no-print",
          style = "text-align:center;",
          
          actionButton(
            "restart_game",
            "Play Again",
            class = "btn-primary"
          ),
          
          tags$button(
            type = "button",
            class = "btn btn-default",
            style = "margin:12px;",
            onclick = "window.print();",
            "Print Certificate"
          )
        )
        
      )
    )
    
  })
  
}


# ============================================================
# 7. LAUNCH APPLICATION
# ============================================================

shinyApp(
  ui = ui,
  server = server
)
