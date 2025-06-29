# 🏢 Atlassian Enterprise User Manager

Atlassian Cloud Enterprise統合ユーザー管理システム - Jira, Confluence, Bitbucket対応

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)
[![PowerShell](https://img.shields.io/badge/powershell-compatible-blue.svg)](https://docs.microsoft.com/en-us/powershell/)

## 🎯 概要

Atlassian Cloud Enterprise環境でのユーザー管理を効率化するWebアプリケーションです。登録申請の承認から未ログインユーザーの管理まで、包括的な管理機能を提供します。

## ✨ 主要機能

### 📊 ダッシュボード
- リアルタイム統計情報の表示
- アクティビティ履歴の監視
- システム全体の健康状態確認

### 📝 登録申請管理
- 新規ユーザー申請の承認ワークフロー
- 部門・製品別フィルタリング
- ワンクリック承認・却下機能
- Jira・Confluence・Bitbucket製品別アクセス権設定

### 👥 ユーザー管理
- 全ユーザーの一覧表示と検索
- 製品アクセス権の可視化
- ユーザー情報の編集・削除
- ステータス・製品別フィルタリング

### ⚙️ 権限プリセット設定
- 職種別権限プリセット（開発者、営業、管理職、閲覧専用）
- カスタムプリセット作成機能
- 製品アクセス権の視覚的設定

### ⏰ 未ログイン管理
- 3ヶ月未ログインユーザーの自動検出
- 一括選択・無効化機能
- セキュリティ警告システム
- ユーザー通知機能

## 🔧 技術仕様

### フロントエンド
- **HTML5** - セマンティックマークアップ
- **CSS3** - グラスモーフィズムデザイン、レスポンシブ対応
- **JavaScript (ES6+)** - モダンなJavaScript構文
- **アニメーション** - CSS3アニメーション、スムーズトランジション

### Atlassian API統合
```javascript
// User Provisioning API
POST https://api.atlassian.com/scim/directory/{directoryId}/Users

// Organization API
GET https://api.atlassian.com/admin/v1/orgs/{orgId}/users

// User Management API
DELETE https://api.atlassian.com/scim/directory/{directoryId}/Users/{userId}
```

### 認証
- **Directory Token Authentication** - SCIMプロトコル対応
- **Organization API Token** - 管理API認証

## 🚀 セットアップ

### Windows ユーザー (推奨)

#### 方法1: バッチファイル（最も簡単）
```cmd
# リポジトリをクローン
git clone https://github.com/chnmotoTmz/atlassian-enterprise-user-manager.git
cd atlassian-enterprise-user-manager

# バッチファイルをダブルクリックまたは実行
setup.bat
```

#### 方法2: PowerShell
```powershell
# PowerShellを管理者として実行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# セットアップスクリプト実行
.\scripts\setup.ps1

# カスタムセットアップ（オプション選択）
.\scripts\setup.ps1 -SkipNodeJS -SkipMongoDB  # Node.jsとMongoDBをスキップ
.\scripts\setup.ps1 -QuietMode                # 非対話モード
```

### Linux/macOS ユーザー

```bash
# リポジトリをクローン
git clone https://github.com/chnmotoTmz/atlassian-enterprise-user-manager.git
cd atlassian-enterprise-user-manager

# セットアップスクリプト実行
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Docker使用（全プラットフォーム対応）

```bash
# リポジトリをクローン
git clone https://github.com/chnmotoTmz/atlassian-enterprise-user-manager.git
cd atlassian-enterprise-user-manager

# 環境変数設定
cp config/env.example .env
# .envファイルを編集してAtlassian APIクレデンシャルを設定

# Docker Compose起動
docker-compose up -d

# ブラウザでアクセス
# http://localhost:3000
```

## 🔐 Atlassian API設定

### Directory Token の取得
1. [admin.atlassian.com](https://admin.atlassian.com/) にアクセス
2. **Security** → **Identity providers** を選択
3. 対象ディレクトリの **User Provisioning** セクションで **Regenerate API key**
4. Directory base URL と API key をコピー

### Organization API Token の取得
1. [admin.atlassian.com](https://admin.atlassian.com/) にアクセス
2. **Settings** → **API keys** を選択
3. **Create API key** で新しいキーを生成
4. Organization ID と API key をコピー

### 環境変数の設定
```bash
# .env ファイルを編集
ATLASSIAN_DIRECTORY_ID=your_directory_id_here
ATLASSIAN_DIRECTORY_TOKEN=your_directory_token_here
ATLASSIAN_ORG_ID=your_org_id_here
ATLASSIAN_ORG_TOKEN=your_org_token_here
```

## 📱 UI/UX特徴

### デザインシステム
- **カラーパレット**: Atlassianブランドカラー準拠
- **タイポグラフィ**: システムフォントスタック
- **アイコン**: 絵文字ベースの直感的表示
- **レスポンシブ**: モバイル・タブレット対応

### アクセシビリティ
- **キーボードナビゲーション**: 全機能キーボード操作対応
- **コントラスト**: WCAG 2.1 AA準拠
- **スクリーンリーダー**: セマンティックマークアップ

## 🔄 API統合例

### ユーザー作成
```javascript
const atlassianAPI = new AtlassianAPI(apiKey, orgId);

const newUser = await atlassianAPI.createUser('user@company.com', {
    name: {
        givenName: '太郎',
        familyName: '田中'
    },
    department: '開発部',
    groups: ['developers', 'confluence-users']
});
```

### 未ログインユーザー取得
```javascript
const inactiveUsers = await atlassianAPI.getInactiveUsers(90); // 90日
console.log(`${inactiveUsers.length}名の未ログインユーザーを検出`);
```

### ユーザー削除
```javascript
const result = await atlassianAPI.deleteUser(userId);
if (result) {
    console.log('ユーザーが正常に削除されました');
}
```

## 🛡️ セキュリティ機能

### 操作確認
- 削除・無効化前の確認モーダル
- 一括操作の安全確認
- 取り消し不可操作の明確な警告

### 監査ログ
- 全ユーザー操作の記録
- タイムスタンプ付きアクティビティログ
- 管理者アクション追跡

### 権限管理
- プリセットベースの権限設定
- 最小権限の原則
- 職種別アクセス制御

## 📋 制限事項

### Atlassian API制限
- ディレクトリあたり150,000ユーザーまで
- グループあたり35,000ユーザーまで（サポート要請で50,000まで可能）
- ユーザー削除 = アカウント無効化（完全削除不可）

### レート制限
- API呼び出し頻度制限あり
- バッチ処理での最適化が必要

## 🐳 デプロイメント

### 本番環境用Docker
```bash
# 本番環境設定
docker-compose -f docker-compose.yml up -d
```

### 開発環境用Docker
```bash
# 開発環境設定（ホットリロード有効）
docker-compose -f docker-compose.dev.yml up -d
```

### Kubernetes
```bash
# Kubernetes用設定ファイル適用
kubectl apply -f k8s/
```

## 🧪 開発環境

### 必要な要件
- Node.js 18.x以上
- MongoDB 5.0以上 または PostgreSQL 13以上
- Redis 6.x以上（セッション管理用）
- Docker（推奨）

### 開発用コマンド
```bash
npm run dev          # 開発サーバー起動
npm test             # テスト実行
npm run build        # 本番用ビルド
npm run lint         # コード品質チェック
npm run format       # コードフォーマット
```

### Windows開発環境
```powershell
# Visual Studio Code起動
code .

# PowerShell開発サーバー
npm run dev

# Windows Service管理
net start MongoDB
redis-server
```

## 🚧 開発ロードマップ

### v1.1 予定機能
- [ ] 実際のAtlassian API統合
- [ ] データベース接続（SQLite/PostgreSQL）
- [ ] ユーザー認証システム
- [ ] 監査ログの永続化

### v1.2 予定機能
- [ ] CSV一括インポート/エクスポート
- [ ] 高度なフィルタリング機能
- [ ] ダッシュボードカスタマイズ
- [ ] 通知システム（メール/Slack）

### v2.0 予定機能
- [ ] ワークフロー自動化
- [ ] 多言語対応
- [ ] プラグインシステム
- [ ] モバイルアプリ

## 🤝 コントリビューション

### 開発環境
```bash
# 開発用サーバー起動
npm run dev

# テスト実行
npm test

# ビルド
npm run build
```

### コーディング規約
- **JavaScript**: ESLint + Prettier
- **CSS**: BEM命名規則
- **コミットメッセージ**: Conventional Commits

### プルリクエスト
1. フィーチャーブランチを作成
2. 変更を実装
3. テストを追加/更新
4. プルリクエストを作成

## 📊 モニタリング

### ヘルスチェック
```bash
# アプリケーション稼働確認
curl http://localhost:3000/api/health

# データベース接続確認
npm run health
```

### ログ確認
```bash
# アプリケーションログ
tail -f logs/application.log

# Docker ログ
docker-compose logs -f

# Windows Event Log
Get-EventLog -LogName Application -Source "Atlassian User Manager"
```

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照

## 📞 サポート

### 問題報告
- [Issues](https://github.com/chnmotoTmz/atlassian-enterprise-user-manager/issues)
- セキュリティ問題: security@yourcompany.com

### ドキュメント
- [Atlassian Developer Documentation](https://developer.atlassian.com/)
- [SCIM Protocol Specification](https://tools.ietf.org/html/rfc7644)

### Windows固有のサポート
- [PowerShellドキュメント](https://docs.microsoft.com/en-us/powershell/)
- [Chocolateyパッケージマネージャー](https://chocolatey.org/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)

## 🌟 システム要件

### 最小要件
- **Windows**: Windows 10/11, Windows Server 2019+
- **macOS**: macOS 10.15+
- **Linux**: Ubuntu 18.04+, CentOS 7+
- **メモリ**: 4GB RAM
- **ストレージ**: 2GB空き容量
- **ネットワーク**: インターネット接続

### 推奨要件
- **メモリ**: 8GB RAM以上
- **ストレージ**: 10GB空き容量以上
- **CPU**: マルチコア（4コア以上）
- **Docker**: Docker Desktop 4.0以上

---

**🏢 Atlassian Enterprise User Manager** - 効率的なユーザー管理でチームの生産性を向上させます

[![GitHub Stars](https://img.shields.io/github/stars/chnmotoTmz/atlassian-enterprise-user-manager?style=social)](https://github.com/chnmotoTmz/atlassian-enterprise-user-manager/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/chnmotoTmz/atlassian-enterprise-user-manager?style=social)](https://github.com/chnmotoTmz/atlassian-enterprise-user-manager/network/members)
