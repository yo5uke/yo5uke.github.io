source("renv/activate.R")

cran_pkgs <- c("pak", "remotes", "languageserver")
for (pkg in cran_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing ", pkg, "...")
    install.packages(pkg)
  }
}

if (!requireNamespace("unigd", quietly = TRUE)) {
  message("Installing unigd from GitHub...")
  remotes::install_github("nx10/unigd")
}

if (!requireNamespace("httpgd", quietly = TRUE)) {
  message("Installing httpgd from GitHub...")
  remotes::install_github("nx10/httpgd")
}
