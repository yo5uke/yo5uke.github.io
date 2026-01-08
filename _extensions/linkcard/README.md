# Link Card Extension for Quarto

リンクカード拡張機能は、URLから自動的にメタデータ（タイトル、説明、サムネイル画像）を取得し、美しいリンクカードとして表示するQuartoのショートコードです。

## 特徴

- ✨ **自動メタデータ取得**: Open Graph、Twitter Card、標準HTMLタグから自動的にメタデータを抽出
- 🎨 **ブランド統合**: `_brand.yml`で定義されたカラーとフォントを自動的に使用
- 📱 **レスポンシブデザイン**: モバイルデバイスで自動的にレイアウトが変更
- ⚡ **キャッシング**: 同じURLへの複数の呼び出しを効率的に処理
- 🌙 **ダークモード対応**: ライトモードとダークモードの両方をサポート
- 🔧 **カスタマイズ可能**: タイトル、説明、画像を手動で上書き可能

## インストール

この拡張機能は既にプロジェクトに含まれています。追加のインストールは不要です。

## 基本的な使用方法

### 最もシンプルな形式（外部URL）

```markdown
{{< linkcard url="https://quarto.org" >}}
```

これにより、指定されたURLから自動的にメタデータが取得され、リンクカードが表示されます。

### 内部リンク（Quartoプロジェクト内のファイル）

```markdown
{{< linkcard url="pages/tips/2025/12/251201_env/index.qmd" >}}
```

または、ルートからの絶対パス：

```markdown
{{< linkcard url="/pages/tips/2025/09/250919_duckdb/index.qmd" >}}
```

内部リンクの場合、ファイルのYAML frontmatterから`title`、`description`、`image`が自動的に抽出されます。

## パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|------|---------|-------------|
| `url` | String (必須) | - | リンク先のURL |
| `title` | String (任意) | 自動取得 | カードのタイトル（自動取得を上書き） |
| `description` | String (任意) | 自動取得 | カードの説明（自動取得を上書き） |
| `image` | String (任意) | 自動取得 | カードの画像URL（自動取得を上書き） |
| `target` | String (任意) | `"_self"` | リンクのターゲット（`_blank`または`_self`） |
| `no-image` | Boolean (任意) | `false` | 画像を非表示にする |
| `manual` | Boolean (任意) | `false` | 手動モード（メタデータを自動取得しない） |

## 使用例

### カスタムタイトル

```markdown
{{< linkcard url="https://github.com"
             title="GitHub" >}}
```

説明と画像は自動的に取得されますが、タイトルは"GitHub"に上書きされます。

### 新しいタブで開く

```markdown
{{< linkcard url="https://example.com"
             target="_blank" >}}
```

### 画像なし

```markdown
{{< linkcard url="https://wikipedia.org"
             no-image=true >}}
```

### 完全に手動で指定

```markdown
{{< linkcard url="https://example.com"
             title="Example Domain"
             description="これは手動で指定した説明です"
             image="https://example.com/image.jpg"
             manual=true >}}
```

`manual=true`を指定すると、ネットワーク呼び出しをスキップし、提供されたパラメータのみを使用します。

### すべてのパラメータを使用

```markdown
{{< linkcard url="https://example.com"
             title="カスタムタイトル"
             description="カスタム説明"
             image="https://example.com/custom-image.jpg"
             target="_blank"
             no-image=false >}}
```

## メタデータ取得の優先順位

### 外部URL

拡張機能は以下の順序でメタデータを探します:

1. **Open Graphタグ** (`og:title`, `og:description`, `og:image`)
2. **Twitter Cardタグ** (`twitter:title`, `twitter:description`, `twitter:image`)
3. **標準HTMLタグ** (`<title>`, `<meta name="description">`)
4. **フォールバック** (URLのドメイン名)

### 内部リンク

Quartoプロジェクト内のQMDファイルの場合、YAML frontmatterから以下のフィールドを抽出します:

- `title`: カードのタイトル
- `description`: カードの説明
- `image`: カードの画像（相対パスは自動的に絶対URLに変換されます）

#### 内部リンクの例

QMDファイル（`pages/tips/example.qmd`）:
```yaml
---
title: "素晴らしいTips"
description: |
  これはとても役立つTipsです。
image: image/thumbnail.png
---
```

使用方法:
```markdown
{{< linkcard url="pages/tips/example.qmd" >}}
```

画像のパスは自動的に`https://yo5uke.com/pages/tips/image/thumbnail.png`に解決されます。

## キャッシング

同じURLに対する複数の呼び出しは自動的にキャッシュされます。これにより、同じURLを複数回使用しても、メタデータの取得は一度だけ行われます。

```markdown
<!-- 最初の呼び出し: メタデータを取得 -->
{{< linkcard url="https://quarto.org" >}}

<!-- 2回目の呼び出し: キャッシュから取得（高速） -->
{{< linkcard url="https://quarto.org" >}}
```

ビルドログで`Cache hit`と`Cache miss`を確認できます。

## スタイルのカスタマイズ

リンクカードのスタイルは`_brand.yml`の`defaults.bootstrap.rules`セクションで定義されています。ブランドカラーを変更すると、リンクカードの見た目も自動的に更新されます。

ダークモード用のスタイルは`styles/html/dark-custom.scss`で定義されています。

## トラブルシューティング

### メタデータが取得できない

- URLが正しいか確認してください
- ウェブサイトがOpen GraphまたはTwitter Cardタグを持っているか確認してください
- 手動モードを使用してメタデータを明示的に指定してください

```markdown
{{< linkcard url="https://example.com"
             title="手動タイトル"
             description="手動説明"
             manual=true >}}
```

### 画像が表示されない

- `no-image=true`が設定されていないか確認してください
- ウェブサイトが画像メタデータを提供しているか確認してください
- 手動で画像URLを指定してください

```markdown
{{< linkcard url="https://example.com"
             image="https://example.com/custom-image.jpg" >}}
```

### ビルドが遅い

- 多数のリンクカードを使用している場合、初回ビルドには時間がかかる場合があります
- 2回目以降のビルドでは、キャッシュが使用されるため高速になります
- パフォーマンス重視の場合は`manual=true`を使用してください

## 技術詳細

### ファイル構造

```
_extensions/linkcard/
├── _extension.yml          # 拡張機能の定義
├── linkcard.lua            # メインのショートコード実装
├── fetch-metadata.lua      # メタデータ取得モジュール
└── README.md               # このファイル
```

### 使用技術

- **Lua**: ショートコード実装
- **pandoc.mediabag.fetch()**: HTTP リクエスト
- **HTML解析**: 正規表現によるメタタグ抽出
- **SCSS**: スタイリング（`_brand.yml`と`dark-custom.scss`）

## ライセンス

このプロジェクトのライセンスに従います。

## 作者

Yosuke Abe

## バージョン

1.0.0

## 変更履歴

- **1.0.0** (2026-01-07): 初回リリース
  - 自動メタデータ取得
  - キャッシング機能
  - レスポンシブデザイン
  - ダークモード対応
  - 手動モード
