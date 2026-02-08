# solo_dining

ひとり飯に特化したレストラン検索アプリ（Flutter Web）

## ローカル開発

### 環境変数の設定

`.env` ファイルにAPIキーを設定する。

```
GEMINI_API_KEY=your_gemini_api_key
PLACES_API_KEY=your_places_api_key
```

### 方法1: server.js を使う（Places API含めて確認したい場合）

```bash
# 1. Flutter Webをビルド
flutter build web

# 2. ローカルサーバーを起動
node server.js

# 3. ブラウザで確認
http://localhost:3000
```

`server.js` は Vercel Functions互換のローカルサーバーで、以下を提供する:
- `/api/places` エンドポイント（Places API プロキシ）
- `build/web` の静的ファイル配信
- `.env` の `PLACES_API_KEY` をHTMLに自動注入

### 方法2: flutter run を使う（Flutterのみ確認したい場合）

```bash
flutter run -d chrome
```

ホットリスタート（`R` キー）が使えるので開発中はこちらが便利。
ただし Places API のサーバーサイド処理は動作しない。

### .env を変更した場合

どちらの方法でも再ビルド/再起動が必要。
- 方法1: `flutter build web` → `node server.js`
- 方法2: `flutter run` を再起動

## デプロイ

Vercel にデプロイされる。`api/` ディレクトリが Vercel Functions として動作する。
