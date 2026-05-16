# Claude Code DevContainer

Visual Studio Code の DevContainer で [Claude Code](https://docs.anthropic.com/ja/docs/claude-code) を利用するための環境です。  
バックエンドとして **Amazon Bedrock** または **Azure AI Foundry** を使用できます。

## 前提条件

| ソフトウェア | 用途 |
|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | コンテナの実行 |
| [Visual Studio Code](https://code.visualstudio.com/) | エディタ |
| VS Code 拡張: [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) | DevContainer のサポート |

## ファイル構成

```
claudecode-devcontainer/
├── .gitignore                   # .env / 会話履歴を git 管理対象外に設定
├── .claude/                     # Claude Code ランタイムデータ（コンテナにbind mount）
│   ├── settings.json            #   ユーザー設定（セッションをまたいで保持）
│   ├── skills/                  #   使用中のスキル（セッションで追加したものも保持）
│   ├── plugins/                 #   プラグイン設定
│   ├── memory/                  #   自動メモリ
│   ├── plans/                   #   プランファイル
│   └── projects/                #   会話履歴（git 管理対象外）
└── .devcontainer/
    ├── Dockerfile               # Node.js 22 ベース + Claude Code インストール
    ├── devcontainer.json        # DevContainer 設定
    ├── init-claude.sh           # コンテナ起動時の初期化スクリプト
    ├── .env                     # 認証情報（★要編集・git 管理対象外）
    ├── .env.example             # .env のテンプレート
    └── claude/                  # デフォルトSkills/Pluginsのテンプレート（git管理）
        ├── settings.json        #   初期設定（初回起動時のみ .claude/ へコピー）
        ├── skills/              #   デフォルトスキル（起動時に未追加分を .claude/ へ追加）
        └── plugins/             #   プラグイン設定（初回起動時のみ .claude/ へコピー）
```

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <このリポジトリのURL>
cd claudecode-devcontainer
```

### 2. `.env` ファイルの作成

`.devcontainer/.env.example` をコピーして `.env` を作成します。

```powershell
Copy-Item .devcontainer\.env.example .devcontainer\.env
```

`.devcontainer\.env` を開いて使用するバックエンドのセクションを編集します。

#### オプション A: Amazon Bedrock を使う場合

```env
CLAUDE_CODE_USE_BEDROCK=1
AWS_REGION=us-east-1
AWS_BEARER_TOKEN_BEDROCK=（実際のBearer Tokenを入力）
```

Foundry のセクション（オプション B）はコメントアウトのままにしてください。

#### オプション B: Azure AI Foundry を使う場合

Bedrock のセクション（オプション A）をコメントアウトし、Foundry のセクションを有効にします。

```env
# CLAUDE_CODE_USE_BEDROCK=1
# AWS_REGION=us-east-1
# AWS_BEARER_TOKEN_BEDROCK=...

CLAUDE_CODE_USE_FOUNDRY=1
ANTHROPIC_FOUNDRY_RESOURCE=claudecode-nerina
ANTHROPIC_FOUNDRY_API_KEY=（実際のAPIキーを入力）
ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6
ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5
ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-7
```

> **注意**: `.env` はシークレット情報を含むため、`.gitignore` によって git 管理対象外になっています。リポジトリにコミットしないでください。

### 3. 作業フォルダ `work/` の確認

リポジトリ直下の `work/` フォルダがコンテナ内 `/work` にマウントされます。存在しない場合は作成してください。

```powershell
if (-not (Test-Path "work")) {
    New-Item -ItemType Directory "work"
}
```

### 4. DevContainer の起動

VS Code でフォルダを開き、コマンドパレット (`Ctrl+Shift+P`) から実行:

```
Dev Containers: Reopen in Container
```

初回はイメージのビルドが行われるため数分かかります。

## バックエンドの切り替え

`.devcontainer/.env` を編集して使用するバックエンドを切り替えられます。切り替え後はコンテナを再起動してください。

```
Dev Containers: Rebuild Container
```

## Claude Code の使用

コンテナ起動後、VS Code の統合ターミナルで以下を実行します。

```bash
claude
```

インタラクティブモードで Claude Code が起動します。

## 動作の仕組み

```
VS Code (ホスト)
  └── DevContainer 起動
        ├── .devcontainer/.env を読み込み（バックエンド設定・認証情報）
        ├── .claude/ を /home/vscode/.claude/ にbind mount（会話履歴・設定を永続化）
        ├── work/ を /work にマウント（作業用フォルダ）
        └── init-claude.sh を実行
              ├── 初回: .devcontainer/claude/ のテンプレートを .claude/ へコピー
              └── 2回目以降: 未追加のデフォルトSkillのみ追加（既存データは保持）
```

### Skills/Plugins の管理

| 目的 | 追加・編集場所 |
|---|---|
| チーム全員に配布するデフォルトSkill | `.devcontainer/claude/skills/` |
| 自分のカスタムSkill（セッションで作成） | `.claude/skills/` に自動保存・リビルド後も保持 |
| デフォルトSkillを更新して反映 | `.devcontainer/claude/` を編集 → Rebuild → 未追加分が自動追加 |

## VSCode 拡張機能の追加

DevContainer に VSCode 拡張機能を追加するには、`.devcontainer/devcontainer.json` の `customizations.vscode.extensions` にマーケットプレイスの拡張機能 ID を追記します。

### 拡張機能 ID の確認方法

VS Code の拡張機能パネルで対象の拡張機能を右クリックし「**Copy Extension ID**」を選択するか、[Visual Studio Marketplace](https://marketplace.visualstudio.com/) の拡張機能ページ右側に表示されている ID（例: `ms-python.python`）を使用します。

### 追記例

```jsonc
"customizations": {
    "vscode": {
        "extensions": [
            "anthropic.claude-code",
            "mhutchie.git-graph",
            "ms-python.python",
            "追加したい拡張機能のID"  // ← ここに追記
        ]
    }
}
```

### 反映方法

追記後、コンテナを再ビルドすると拡張機能がインストールされます。

```
Dev Containers: Rebuild Container
```

## トラブルシューティング

| 症状 | 対処法 |
|---|---|
| コンテナが起動しない | Docker Desktop が起動しているか確認 |
| `claude` コマンドが見つからない | コンテナを Rebuild する: `Dev Containers: Rebuild Container` |
| Bedrock 認証エラー | `.env` の `AWS_BEARER_TOKEN_BEDROCK` の値と `AWS_REGION` を確認 |
| Foundry 認証エラー | `.env` の `ANTHROPIC_FOUNDRY_API_KEY` と `ANTHROPIC_FOUNDRY_RESOURCE` を確認 |
| トークン期限切れ | `.env` の認証情報を更新後、コンテナを再起動 |

## Amazon Bedrock の有効化

AWS マネジメントコンソール → **Amazon Bedrock** → **Model access** で Claude モデルへのアクセスを有効化してください。  
利用可能なリージョン例: `us-east-1`, `us-west-2`
