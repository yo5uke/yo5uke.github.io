---
trigger: always_on
---

# yo5uke.com

[yo5uke.com](https://yo5uke.com)は個人のウェブサイトであり、GitHub Pagesを利用して公開されている。リポジトリは[yo5uke/yo5uke.github.io](https://github.com/yo5uke/yo5uke.github.io)であり、Quartoを用いて構築されている。

## R環境について

Rはrenvを使って構築されており、プロジェクトごとのライブラリは `renv/library/` に配置されている。依存関係は `renv.lock` で管理する。

- 依存関係の復元(他環境からのセットアップ・クローン直後など): `renv::restore()`
- 新規パッケージの追加: `pak::pkg_install("パッケージ名")` を使用する
- パッケージを追加・更新した後は、必ず `renv::snapshot()` を実行して `renv.lock` に反映すること
- 環境の状態確認: `renv::status()`(lockfileとライブラリの差分をチェックできる)

**注意**:
- `install.packages()` は直接使用しない。
- `renv.lock` を手動で編集しない。
- Rセッションはプロジェクトルート(`.Rprofile` が存在する場所)から起動すること。renvは `.Rprofile` 経由で自動的にactivateされる。

## Python環境について

Pythonはuvを使って構築されており、仮想環境は `.venv/` に配置されている。依存関係は `pyproject.toml` および `uv.lock` で管理する。

- 依存関係のインストール・同期: `uv sync`
- パッケージの追加: `uv add <package>`
- 仮想環境を経由したコマンド実行: `uv run <command>`（例: `uv run script.py`）
- venvを直接activateする場合: `source .venv/bin/activate`

**注意**: 依存関係の追加・変更は `pip install` ではなく `uv add` / `uv sync` を通じて行うこと。`.venv/` を直接編集したり、別の方法で仮想環境を作り直したりしない。

## 作業時のルール

- `.Renviron` ファイルおよび `.secrets` フォルダは**絶対に**削除しない。
- 作業時は新しいブランチを作成して作業する。mainブランチで直接作業を行わない。

## ページのパブリッシュ時のルール

- 「ページをパブリッシュして」という趣旨の依頼を受けたときは、Quartoのコマンド `quarto publish gh-pages --no-render` を実行してGitHub Pagesに反映する。
- 明示的にレンダリングすることを指示された場合は `quarto publish gh-pages` を実行することで、レンダリングしつつGitHub Pagesに反映する。
- 依頼がない場合はパブリッシュを行わない。

## コミット時のルール

- コミットおよびプッシュは明示的に指示されたとき以外は行わない。
- コミットメッセージは英語で書き、AIのサインは記載しない。
