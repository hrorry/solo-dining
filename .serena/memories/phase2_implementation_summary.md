# Phase 2実装完了: 位置情報・検索機能

## 実装日
2025-10-07

## 実装内容

### 1. Vercel Functions（サーバーレス関数）
- **ファイル**: `api/places.js`
- **機能**: Google Places API Nearby Searchを呼び出すサーバーレス関数
- **技術**: Node.js httpsモジュール（fetchではなく）
- **CORS対応**: 完全対応済み
- **環境変数**: `PLACES_API_KEY`をVercel環境変数で設定

### 2. ローカル開発用サーバー
- **ファイル**: `server.js`（.gitignoreに追加済み）
- **ポート**: 3000
- **機能**: 
  - `/api/places` → Vercel Function互換のAPI
  - 静的ファイル配信 → `build/web/`のFlutterアプリ配信
- **起動コマンド**: `node server.js`
- **停止コマンド**: `pkill -f "node server.js"` または `lsof -ti:3000 | xargs kill -9`

### 3. Flutter側の実装

#### PlacesService（lib/services/places_service.dart）
- Vercel Function経由でPlaces APIを呼び出す
- Web/モバイル統一的に動作（kIsWebで分岐なし）
- ベースURL設定:
  - Web: 相対パス `''` → 同一オリジンの`/api/places`
  - モバイル: `https://solo-dining.vercel.app`

#### SearchScreen（lib/screens/search_screen.dart）
- 現在地取得機能（geolocatorパッケージ）
- 手動入力検索（住所→緯度経度変換）
- PlacesService統一利用（places_service_web.dartは削除済み）

#### SearchResultScreen（lib/screens/search_result_screen.dart）
- Places APIの実データ構造に対応
- rating, user_ratings_total, is_open_now表示
- tags/descriptionフィールドは削除（Places APIに存在しないため）

### 4. Vercel設定

#### vercel.json
```json
{
  "outputDirectory": "build/web",
  "framework": null,
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "/api/$1"
    }
  ]
}
```

#### Vercel環境変数
- `PLACES_API_KEY`: production環境に設定済み
- コマンド: `vercel env add PLACES_API_KEY production`

#### Vercel Build設定（Vercelダッシュボード）
- **Install Command**: 
  ```bash
  if cd flutter; then git pull && cd .. ; else git clone -b stable https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter doctor && flutter/bin/flutter clean && flutter/bin/flutter config --enable-web
  ```
- **Build Command**:
  ```bash
  cp .env.production .env && flutter/bin/flutter pub get && flutter/bin/flutter build web --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
  ```

### 5. 解決した問題

#### CORS問題
- **原因**: ブラウザから直接Google Places APIを呼ぶとCORSエラー
- **解決**: Vercel Functions（サーバー経由）で回避

#### JavaScriptのnull型エラー
- **原因**: JavaScript APIのnull値がDartのNull型と互換性なし
- **解決**: HTTP API + Vercel Functions方式に変更して回避

#### Vercelビルドエラー
- **原因**: Vercelにflutterコマンドがない
- **解決**: VercelダッシュボードでFlutter cloneからビルドまで実行

#### Node.js fetch問題
- **原因**: Node.js v18未満でfetchが使えない
- **解決**: httpsモジュール使用（Promiseでラップ）

### 6. デプロイ済みURL
- **Production**: https://solo-dining-mjez7i4ql-horrys-projects-37a7fd22.vercel.app
- **動作確認済み**: 現在地取得→検索→20件表示まで完全動作

### 7. ローカル開発フロー
1. `flutter build web` → Flutterアプリをビルド
2. `node server.js` → ローカルサーバー起動（ポート3000）
3. `http://localhost:3000` → アクセス
4. コード変更時は再ビルド必要

### 8. Git管理
- **コミット済み**:
  - `api/places.js`
  - `vercel.json`
  - `lib/services/places_service.dart`（修正版）
  - `lib/screens/search_screen.dart`（修正版）
  - `lib/screens/search_result_screen.dart`（修正版）
  
- **gitignore追加**:
  - `node_modules/`
  - `server.js`（ローカル開発専用）
  - `docs/`

### 9. 次のステップ（Phase 3）
- Gemini API連携
- Places APIデータをGeminiに送信
- 一人食事向け店舗の抽出・ランキング
- 推奨理由の生成・表示
