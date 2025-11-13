source("renv/activate.R")

cran_pkgs <- c("pak", "languageserver")
for (pkg in cran_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing ", pkg, "...")
    install.packages(pkg)
  }
}

if (!requireNamespace("httpgd", quietly = TRUE)) {
  message("Installing httpgd from GitHub...")
  pak::pak("nx10/httpgd")
}
