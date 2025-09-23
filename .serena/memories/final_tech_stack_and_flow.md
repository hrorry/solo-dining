# Solo Dining App - 最終技術スタックとフロー

## アプリフロー（MVP版）
1. ユーザーが場所を指定（現在地 or 手動入力）
2. Google Maps/Places APIから付近のお店データ取得
3. 取得したお店情報と口コミをGemini APIに送信
4. Gemini AIが一人食事向けお店を分析・抽出・ランキング
5. 結果をリスト表示（お店詳細、理由も表示）

## 技術スタック（超シンプル版）
### Flutter パッケージ
- `google_maps_flutter` - 地図表示
- `geolocator` - 位置情報取得
- `http` / `dio` - API通信
- `google_generative_ai` - Gemini API
- `riverpod` - 状態管理

### API
- **Google Maps API** - 地図表示
- **Google Places API** - お店情報・口コミ取得
- **Gemini API** - 一人食事向け抽出ロジック

## データフロー
```
位置情報 → Google Places → お店リスト + 口コミ → Gemini分析 → フィルタリング済みお店リスト
```

## メリット
- バックエンド不要
- ローカルDB不要  
- 複雑なAIロジック不要（Geminiに丸投げ）
- 開発が超速い
- Google APIとGemini APIの料金のみ

## MVP機能（さらに絞り込み）
1. 位置情報取得
2. お店検索・Gemini抽出
3. お店リスト表示
4. お店詳細画面