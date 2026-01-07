# Yosuke Abe's Page

[R](https://www.r-project.org/)や[Python](https://www.python.org/)に関するTipsや開発したShinyアプリケーションなどについて発信しています。  
このリポジトリは、当サイトのソースコードを管理しています。

📍 ホームページはこちら → https://yo5uke.com/

## 📚 サイトの内容

- [RのTips](https://yo5uke.com/pages/tips/)
- [整備したデータや開発したパッケージ、アプリケーションの紹介](https://yo5uke.com/pages/software/)
- [GISデータの可視化やハンドリング](https://yo5uke.com/pages/gis_in_r/)
- [ブログ](https://yo5uke.com/pages/blog/)

## 🛠️ 使用ツール

- [R](https://www.r-project.org/)
- [Python](https://www.python.org/)
- [Quarto](https://quarto.org/)
- [DVC](https://dvc.org/) - データバージョン管理

## 🚀 開発環境のセットアップ

### Python環境のセットアップ

このプロジェクトは[UV](https://github.com/astral-sh/uv)パッケージマネージャーを使用して依存関係を管理しています。

```bash
# UVのインストール
pip install uv

# 依存関係のインストール
uv sync

# または
uv pip install -e .
```

### R環境のセットアップ

R環境は[renv](https://rstudio.github.io/renv/)で管理されています。

```r
# Rで以下を実行
# renvパッケージのインストール（初回のみ）
install.packages("renv")

# 依存関係の復元
renv::restore()
```

### データの取得

大容量のGISデータはDVCで管理されています。

```bash
# DVCのインストール（必要に応じて）
pip install dvc dvc-gdrive

# データの取得
dvc pull
```

### サイトのビルド

```bash
# サイト全体をビルド
quarto render

# 開発サーバーの起動（プレビュー）
quarto preview
```

## 📜 ライセンス

このサイトのコンテンツは以下のライセンスで提供されています。

**Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)**

自由に利用・改変・再配布可能ですが、出典表示と継承ライセンスが必要です。

## 👤 作成者

**阿部洋輔 (Yosuke Abe)**

- X: [@5uke_y](https://x.com/5uke_y)
- Bluesky: [@5uke.bsky.social](https://bsky.app/profile/5uke.bsky.social)