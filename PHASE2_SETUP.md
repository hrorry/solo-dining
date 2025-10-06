# 🗺️ Phase 2: 位置情報・検索機能 セットアップガイド

## 📋 実装内容

Phase 2では以下の機能を実装しました：

- ✅ 位置情報取得機能（現在地取得）
- ✅ 手動での場所入力機能
- ✅ Google Places APIとの連携
- ✅ 近隣店舗の基本情報取得
- ✅ 検索画面のUI実装（ナチュラル系デザイン）
- ✅ エラーハンドリング（位置情報許可なし等）

## 🔧 セットアップ手順

### 1. Google Places API キーの取得

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. プロジェクトを選択または新規作成
3. 「APIとサービス」→「ライブラリ」へ移動
4. 以下のAPIを有効化：
   - **Places API**
   - **Geocoding API**
5. 「認証情報」→「認証情報を作成」→「APIキー」を選択
6. APIキーをコピー

### 2. 環境変数の設定

`.env` ファイルに Google Places API キーを追加します：

```env
GEMINI_API_KEY=あなたのGemini APIキー
PLACES_API_KEY=あなたのGoogle Places APIキー
```

### 3. 依存関係のインストール

```bash
flutter pub get
```

### 4. プラットフォーム別の設定

#### iOS の場合

`ios/Runner/Info.plist` に以下を追加（既に追加済みの場合はスキップ）：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>近くの飲食店を検索するために位置情報を使用します</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>近くの飲食店を検索するために位置情報を使用します</string>
```

#### Android の場合

`android/app/src/main/AndroidManifest.xml` に以下を追加（既に追加済みの場合はスキップ）：

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 5. アプリの起動

```bash
flutter run
```

## 📱 使い方

### 現在地から検索

1. アプリを起動
2. 「現在地を取得」ボタンをタップ
3. 位置情報の許可を求められたら「許可」を選択
4. 「お店を探す」ボタンをタップ

### 場所を指定して検索

1. アプリを起動
2. テキストフィールドに場所を入力（駅名、住所、ホテル名など）
3. 「お店を探す」ボタンをタップ

## 🎨 新しいファイル

Phase 2で追加されたファイル：

```
lib/
├── services/
│   ├── location_service.dart    # 位置情報取得サービス
│   └── places_service.dart      # Google Places API連携サービス
└── screens/
    └── search_screen.dart       # 検索画面（位置情報取得＋手動入力）
```

## 🔐 セキュリティに関する注意

- `.env` ファイルは `.gitignore` に含まれており、Gitにコミットされません
- 本番環境（Vercel等）では、環境変数を直接設定してください
- APIキーは絶対に公開リポジトリにコミットしないでください

## 🐛 トラブルシューティング

### 位置情報が取得できない

- デバイスの位置情報サービスがオンになっているか確認
- アプリに位置情報の許可が与えられているか確認
- iOS: 設定 → プライバシー → 位置情報サービス
- Android: 設定 → アプリ → Solo Dining → 権限

### Google Places APIでエラーが発生する

- APIキーが正しく設定されているか確認
- Google Cloud Consoleで Places API と Geocoding API が有効化されているか確認
- APIキーに使用制限がかかっていないか確認
- 無料枠を超えていないか確認

### 検索結果が表示されない

- インターネット接続を確認
- 入力した場所が正しいか確認
- エラーメッセージを確認（画面下部のスナックバーに表示されます）

## 📊 API使用量の管理

Google Places APIは従量課金制です。無料枠は以下の通り：

- **Places API (Nearby Search)**: 月$200分の無料クレジット
- **Geocoding API**: 月$200分の無料クレジット

詳細は [Google Maps Platform 料金](https://mapsplatform.google.com/pricing/) を参照してください。

## 🚀 次のステップ（Phase 3）

Phase 2の実装が完了したら、次は以下の機能を実装予定：

- 🤖 Gemini AIによる口コミ分析
- 📊 一人食事スコアの算出
- 🎯 カウンター席情報の抽出
- ⭐ おすすめ度の表示

## 📝 メモ

- 現在の検索範囲は半径1.5km（1500m）に設定されています
- 変更する場合は `search_screen.dart` の `radius` パラメータを調整してください
- 検索結果は最大20件まで表示されます（Google Places APIの仕様）
