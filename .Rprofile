source("renv/activate.R")

if (nchar(Sys.getenv("VSCODE_IPC_HOOK_CLI")) > 0 && interactive()) {
  init_files <- list.files(
    path.expand("~/.vscode-server/extensions"),
    pattern = "init\\.R$",
    recursive = TRUE,
    full.names = TRUE
  )
  init_files <- init_files[grepl("reditorsupport\\.r", init_files)]
  if (length(init_files) > 0) {
    source(tail(init_files, 1), chdir = TRUE)
    init_last()
  }
}
