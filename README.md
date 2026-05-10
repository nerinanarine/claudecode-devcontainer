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
├── .gitignore                   # .env を git 管理対象外に設定
└── .devcontainer/
    ├── Dockerfile               # Node.js 22 ベース + Claude Code インストール
    ├── devcontainer.json        # DevContainer 設定
    ├── .env                     # 認証情報（★要編集・git 管理対象外）
    └── .env.example             # .env のテンプレート
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

### 3. `~/.claude` ディレクトリの確認

Claude Code の設定・セッション情報を保持するディレクトリです。存在しない場合は作成してください。

```powershell
if (-not (Test-Path "$env:USERPROFILE\.claude")) {
    New-Item -ItemType Directory "$env:USERPROFILE\.claude"
}
```

### 4. 作業フォルダ `%USERPROFILE%/work` の確認

ホスト側の `%USERPROFILE%/work` はコンテナ内 `/work` にマウントされます。存在しない場合は作成してください。

```powershell
if (-not (Test-Path "$env:USERPROFILE\work")) {
    New-Item -ItemType Directory "$env:USERPROFILE\work"
}
```

### 5. DevContainer の起動

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
        ├── ~/.claude をマウント（認証情報・設定の永続化）
        └── %USERPROFILE%/work を /work にマウント（作業用フォルダ）
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
