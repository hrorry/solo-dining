# コードスタイル・規約

## Dartコーディング規約
- **Linter**: flutter_lints 5.0.0使用
- **分析設定**: analysis_options.yamlで設定済み
- **命名規則**: 
  - クラス名: PascalCase (例: MyHomePage)
  - 変数名・関数名: camelCase (例: _incrementCounter)
  - 定数: lowerCamelCase (例: seedColor)
  - プライベート変数: アンダースコア始まり (例: _counter)

## Flutterベストプラクティス
- **Widget命名**: 意味のある名前を使用
- **State管理**: StatefulWidget使用時はプライベートStateクラス
- **Key使用**: コンストラクタでsuperキー指定 (例: {super.key})
- **const使用**: 可能な限りconstコンストラクタ使用

## ファイル構成
```
lib/
  main.dart          # エントリーポイント
  screens/           # 画面ウィジェット
  widgets/           # 再利用可能ウィジェット  
  models/            # データモデル
  services/          # API・外部サービス
  utils/             # ユーティリティ
```

## コメント規約
- クラス・関数に適切なドキュメントコメント
- TODO使用時は理由と担当者明記
- 複雑なロジックには説明コメント