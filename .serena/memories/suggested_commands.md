# 推奨コマンド集

## 開発関連コマンド
```bash
# アプリ実行
flutter run

# デバッグモードで実行
flutter run --debug

# リリースモードで実行  
flutter run --release

# 依存関係の取得
flutter pub get

# 依存関係のアップデート
flutter pub upgrade

# パッケージ分析
flutter analyze

# テスト実行
flutter test

# ビルド（Android）
flutter build apk

# ビルド（iOS）
flutter build ios

# クリーンビルド
flutter clean && flutter pub get
```

## システムコマンド (macOS)
```bash
# ファイル操作
ls -la        # ファイル一覧表示
find . -name  # ファイル検索
grep -r       # テキスト検索

# Git操作  
git status
git add .
git commit -m "message"
git push
```

## トラブルシューティング
```bash
# Flutter doctor（環境確認）
flutter doctor

# Flutter doctor（詳細）
flutter doctor -v

# キャッシュクリア
flutter clean
```