# 起動時のロックファイル同期チェックを無効化（プロジェクトが大きくなり数秒かかるため）
# 依存関係の確認は必要に応じて手動で renv::status() を実行する
options(renv.config.synchronized.check = FALSE)

source("renv/activate.R")

# vscode-R 連携（session watcher）のセットアップ
# プロジェクトに .Rprofile があると ~/.Rprofile が読まれないため、ここで行う。
# 拡張機能が自動管理するスタブ（~/.vscode-R/init.R）が常に現行バージョンの
# init.R を指すので、バージョン探索は不要。
if (interactive() && nchar(Sys.getenv("VSCODE_IPC_HOOK_CLI")) > 0) {
  local({
    init_file <- file.path(Sys.getenv("HOME"), ".vscode-R", "init.R")
    if (file.exists(init_file)) {
      # WSL のターミナルでは TERM_PROGRAM が設定されないことがあり、
      # init.R 内の VS Code 判定を通すためにここで補う
      if (Sys.getenv("TERM_PROGRAM") == "") Sys.setenv(TERM_PROGRAM = "vscode")
      source(init_file)
      # init.R は初期化本体を .First.sys フックとして globalenv に仕込むが、
      # この環境では起動シーケンスがそれを呼ばないため、ここで直接実行する
      # （VS Code セッションと判定された場合のみ定義される。実行後は自動で消える）
      fs <- globalenv()$.First.sys
      if (is.function(fs)) fs()
    }
  })
}
