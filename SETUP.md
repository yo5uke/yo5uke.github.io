# Ubuntu開発環境セットアップ手順

## 概要

Ubuntu 24.04 LTSでR/Python開発環境を構築するための手順。
主にデータ分析、GIS、統計モデリング、Quartoによる文書作成を想定。

---

## 1. システムアップデート
```bash
sudo apt update
sudo apt upgrade -y
```

---

## 2. 基本ビルドツール

Rパッケージをソースからコンパイルするために必要。
```bash
sudo apt install -y \
  build-essential \
  gfortran \
  r-base-dev
```

**対応パッケージ:** すべてのソースコンパイルが必要なRパッケージ

---

## 3. 基本開発ツール
```bash
sudo apt install -y \
  git \
  curl \
  wget \
  xclip
```

- `git`: バージョン管理
- `curl`: ダウンロード・API通信
- `xclip`: クリップボード操作

---

## 4. R基本パッケージ用ライブラリ

### ネットワーク・暗号化関連
```bash
sudo apt install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev
```

**対応Rパッケージ:** `curl`, `httr`, `httr2`, `openssl`, `xml2`, `rvest`

### グラフィック・フォント関連
```bash
sudo apt install -y \
  libcairo2-dev \
  libxt-dev \
  libpng-dev \
  libjpeg-dev \
  libtiff5-dev \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev
```

**対応Rパッケージ:** `httpgd`, `Cairo`, `ragg`, `systemfonts`, `textshaping`, `ggplot2`

---

## 5. データベース関連
```bash
sudo apt install -y \
  libpq-dev
```

**対応Rパッケージ:** `RPostgres`, `RPostgreSQL`

**PostgreSQL本体のインストール（必要な場合）:**
```bash
sudo apt install -y postgresql postgresql-contrib postgis
```

---

## 6. GIS関連ライブラリ

空間データ分析に必須。
```bash
sudo apt install -y \
  libgdal-dev \
  libproj-dev \
  libgeos-dev \
  libudunits2-dev
```

**対応Rパッケージ:** `sf`, `terra`, `stars`, `raster`, `rgdal`, `units`

---

## 7. 画像処理
```bash
sudo apt install -y \
  libmagick++-dev
```

**対応Rパッケージ:** `magick`

---

## 8. R本体のインストール（最新版）

CRAN公式リポジトリから最新版をインストール。
```bash
# 依存関係
sudo apt install -y --no-install-recommends software-properties-common dirmngr

# CRAN公開鍵の追加
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/r-project.gpg

# CRANリポジトリの追加
echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | \
  sudo tee /etc/apt/sources.list.d/cran-r.list

# Rのインストール
sudo apt update
sudo apt install -y r-base r-base-dev

# 確認
R --version
```

---

## 9. Python環境（uv）
```bash
# uvのインストール
curl -LsSf https://astral.sh/uv/install.sh | sh

# 確認
uv --version
```

---

## 10. Rust（polars等に必要）
```bash
# rustupのインストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# デフォルト設定で進める（1を選択）

# 確認
rustc --version
```

**対応Rパッケージ:** `polars`

**注意:** polarsのビルドには時間がかかる場合があります。

---

## 11. VSCode
```bash
# 公式debパッケージをダウンロード
cd ~/ダウンロード
wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'

# インストール
sudo apt install ./code.deb

# インストーラー削除
rm code.deb

# 確認
code --version
```

**または snap版:**
```bash
sudo snap install code --classic
```

---

## 12. Quarto
```bash
# 最新版をダウンロード（バージョンは適宜更新）
cd ~/ダウンロード
QUARTO_VERSION=1.9.19
wget https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb

# インストール
sudo apt install ./quarto-${QUARTO_VERSION}-linux-amd64.deb

# インストーラー削除
rm quarto-${QUARTO_VERSION}-linux-amd64.deb

# 確認
quarto --version
```

### TinyTeXのインストール
```bash
# TinyTeXのインストール
quarto install tinytex
```

---

## 13. 日本語フォント（Quarto PDF出力用）
```bash
# IPAフォントとNotoフォント
sudo apt install -y \
  fonts-ipaexfont \
  fonts-ipafont \
  fonts-noto-cjk \
  fonts-noto-cjk-extra

# フォントキャッシュ更新
fc-cache -fv

# 確認
fc-list | grep -i ipa
```

### TinyTeX日本語パッケージ
```bash
# LaTeX日本語パッケージ
tlmgr install \
  collection-langjapanese \
  bxjscls \
  zxjatype \
  xecjk
```

---

## 14. 日本語入力（Mozc）
```bash
sudo apt install -y ibus-mozc
```

インストール後、以下の設定を行う：
1. 設定 → 地域と言語 → 入力ソース
2. 「+」をクリック → 日本語 → 日本語（Mozc）を追加
3. `Ctrl + Space` で切り替え可能

---

## 一括インストールスクリプト

### すべての依存関係を一度にインストール
```bash
#!/bin/bash

# システムアップデート
sudo apt update && sudo apt upgrade -y

# ビルドツール
sudo apt install -y build-essential gfortran r-base-dev

# 基本ツール
sudo apt install -y git curl wget xclip

# R基本パッケージ用ライブラリ
sudo apt install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libcairo2-dev \
  libxt-dev \
  libpng-dev \
  libjpeg-dev \
  libtiff5-dev \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev

# データベース
sudo apt install -y libpq-dev

# GIS
sudo apt install -y \
  libgdal-dev \
  libproj-dev \
  libgeos-dev \
  libudunits2-dev

# 画像処理
sudo apt install -y libmagick++-dev

# 日本語フォント
sudo apt install -y \
  fonts-ipaexfont \
  fonts-ipafont \
  fonts-noto-cjk \
  fonts-noto-cjk-extra

# フォントキャッシュ更新
fc-cache -fv

# 日本語入力
sudo apt install -y ibus-mozc

echo "システムパッケージのインストール完了！"
echo "次に手動でインストールが必要なもの："
echo "- R (CRAN最新版)"
echo "- Python (uv)"
echo "- Rust (rustup)"
echo "- VSCode"
echo "- Quarto"
```

---

## トラブルシューティング

### Rパッケージインストールでエラーが出た場合

**エラーメッセージから必要なライブラリを特定:**

| エラーメッセージ | 必要なパッケージ |
|---|---|
| `libpq.so.5` が見つからない | `libpq-dev` |
| `libproj.so` が見つからない | `libproj-dev` |
| `libMagick++` が見つからない | `libmagick++-dev` |
| `cargo` が見つからない | Rust（rustup） |
| コンパイルツールがない | `build-essential` |

### renvのキャッシュクリア
```r
# 特定のパッケージ
renv::purge("パッケージ名")

# 全体
renv::clean()
```

---

## 参考情報

- Ubuntu: 24.04 LTS
- R: 4.5.2 (CRAN最新版)
- Python: uv経由で管理
- 主な用途: データ分析、GIS、統計モデリング、文書作成（Quarto）

---

## 更新履歴

- 2026-02-09: 初版作成