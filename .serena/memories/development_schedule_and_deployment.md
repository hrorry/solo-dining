# Solo Dining App - 開発スケジュールとデプロイ計画

## 開発スケジュール（マイペース版）
期限なしでのんびり開発🌿

### 🚀 Phase 1: 基盤構築（マイペース）
- Flutter Web対応の確認
- プロジェクト環境セットアップ
- Google Maps API & Gemini API の動作確認（Web/Mobile両対応）
- 基本的な画面遷移の実装

### 🗺️ Phase 2: 位置情報・検索機能
- 位置情報取得機能（Web/Mobile対応）
- Google Places API連携
- 基本的な検索画面の実装

### 🤖 Phase 3: Gemini連携
- Google Places データをGeminiに送信
- 一人食事向け抽出ロジックの開発・調整
- 結果表示機能

### 🎨 Phase 4: UI/UX完成
- ナチュラル系デザインの適用（レスポンシブ対応）
- ユーザビリティの向上
- 細かい調整・polish

### 🧪 Phase 5: テスト・デプロイ
- 動作テスト（Web/Mobile）
- 各種APIの制限確認
- デプロイ

## デプロイ先候補
### Webアプリ
- **Firebase Hosting** (簡単・無料枠あり)
- **Vercel** (Flutter Web対応)
- **Netlify** 
- **GitHub Pages**

### モバイルアプリ
- **Google Play Store** (Android)
- **App Store** (iOS) - 後から検討

## Flutter Web対応での注意点
- 位置情報APIの挙動確認
- Google Maps APIのWeb版対応
- レスポンシブデザイン対応
- PWA化も可能（アプリライク）

## メリット
- 1つのコードベースでWeb/Mobile両対応
- WebならApp Store申請不要
- 気軽にシェアできる