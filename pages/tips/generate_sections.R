# Pre-render script: categorize tip articles into sections
# Generates pages/tips/sections/{r,python,docs,env,gis}.yml
# Each YAML file contains paths relative to pages/tips/

library(yaml)
library(here)

tips_dir <- here("pages/tips")
sections_dir <- file.path(tips_dir, "sections")
dir.create(sections_dir, showWarnings = FALSE)

# Find all article index.qmd files (year-based paths only, not demo dirs)
all_qmds <- list.files(
  tips_dir,
  pattern = "index\\.qmd$",
  recursive = TRUE,
  full.names = TRUE
)
qmds <- all_qmds[grepl("/[0-9]{4}/", all_qmds)]

# Score each article against sections
# Priority tiebreaker (highest to lowest): gis > env > docs > python > r
score_sections <- function(cats) {
  scores <- c(gis = 0, docs = 0, env = 0, python = 0, r = 0)
  for (cat in cats) {
    if (cat == "GIS") {
      scores["gis"] <- scores["gis"] + 4
    }
    if (cat %in% c("Quarto", "LaTeX", "Typst", "R Markdown")) {
      scores["docs"] <- scores["docs"] + 3
    }
    if (cat %in% c("WSL", "Docker", "Positron", "RStudio", "DVC")) {
      scores["env"] <- scores["env"] + 3
    }
    if (
      cat %in% c("VSCode", "GitHub", "Windows", "Mac", "Ubuntu", "PowerToys")
    ) {
      scores["env"] <- scores["env"] + 2
    }
    if (cat %in% c("Python", "AI")) {
      scores["python"] <- scores["python"] + 3
    }
    if (cat == "SQL") {
      scores["python"] <- scores["python"] + 2
    }
    if (cat == "R") {
      scores["r"] <- scores["r"] + 2
    }
    if (cat %in% c("データ処理", "備忘録")) {
      scores["r"] <- scores["r"] + 1
    }
  }
  priority <- c("gis", "env", "docs", "python", "r")
  max_score <- max(scores)
  if (max_score == 0) {
    return("r")
  }
  for (p in priority) {
    if (scores[p] == max_score) return(p)
  }
  return("r")
}

sections <- list(r = c(), python = c(), docs = c(), env = c(), gis = c())

for (qmd in qmds) {
  tryCatch(
    {
      lines <- readLines(qmd, warn = FALSE)
      delims <- which(trimws(lines) == "---")
      if (length(delims) < 2) {
        return(NULL)
      }

      fm_text <- paste(lines[(delims[1] + 1):(delims[2] - 1)], collapse = "\n")
      fm <- yaml.load(fm_text)

      cats <- fm$categories
      if (is.null(cats)) {
        cats <- character(0)
      }
      cats <- as.character(unlist(cats))
      # Remove alias-like entries (contain "/") and whitespace-only
      cats <- cats[!grepl("/", cats) & nzchar(trimws(cats))]

      section <- score_sections(cats)
      rel_path <- sub(paste0(tips_dir, "/"), "", qmd)
      sections[[section]] <- c(sections[[section]], rel_path)
    },
    error = function(e) {
      message("Skipping ", basename(dirname(qmd)), ": ", e$message)
    }
  )
}

# Write YAML files as listing item objects (required by Quarto)
for (s in names(sections)) {
  paths <- sort(sections[[s]], decreasing = TRUE)
  write(
    paste0("- path: ../", paths, collapse = "\n"),
    file = file.path(sections_dir, paste0(s, ".yml"))
  )
}

message("Tips sections generated:")
for (s in c("r", "python", "docs", "env", "gis")) {
  message(sprintf("  %-8s %d articles", s, length(sections[[s]])))
}
