# Cellfie-immune-quiz
An interactive immunology quiz built using R Shiny
# Cellfie! — Which Immune Cell Are You?

**10 questions. One immune identity.**

Cellfie! is an interactive, beginner-friendly immunology quiz developed using **R and Shiny**. It combines scientific questions, immediate feedback, and a weighted scoring algorithm to make introductory immunology engaging and accessible.

## Features

- 10 multiple-choice immunology questions
- Randomized answer options
- Immediate correct/incorrect feedback
- Scientific explanations for every question
- Final score out of 10
- Weighted immune-cell identity assignment
- Six possible immune-cell identities
- Printable result certificate
- Responsive user interface

## Immune Cells Featured

- B Cell
- Cytotoxic T Cell
- Natural Killer Cell
- Macrophage
- Dendritic Cell
- Neutrophil

## How the Scoring Works

Each correct answer contributes weighted points to biologically relevant immune-cell categories. Scores are normalized, and a deterministic tie-breaking system assigns exactly one final identity.

The identity is a playful educational reward based on immunology knowledge, not a biological or psychological classification.

## Technologies

- R
- Shiny
- HTML and CSS embedded within R Shiny

## Run Locally

Install Shiny in R:

```r
install.packages("shiny")
```

Launch the application from the project directory:

```r
shiny::runApp()
```

## Live Application

Coming soon!

## Author

Adya Shreya

## Disclaimer

Cellfie! is an educational project. Immune-cell identity results are intended for entertainment and scientific engagement rather than clinical or psychological interpretation.
