import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    // ビルド時の環境変数をチェック（Vercel用）
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');

    // ローカル開発用の.envファイルもチェック（安全にアクセス）
    String? envApiKey;
    try {
      envApiKey = dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      print('dotenv not available, using dart-define only');
      envApiKey = null;
    }

    final finalApiKey = apiKey.isNotEmpty ? apiKey : (envApiKey ?? '');

    if (finalApiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found. Set it in .env file or build environment');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',  // 最新モデルに変更
      apiKey: finalApiKey,
    );
  }

  /// Gemini APIの動作確認用テストメソッド
  Future<String> testConnection() async {
    try {
      print('Testing Gemini API connection...');
      print('API Key exists: ${dotenv.env['GEMINI_API_KEY'] != null}');

      final response = await _model.generateContent([
        Content.text('Hello! Please respond with a simple greeting.')
      ]);

      final responseText = response.text;
      print('Gemini response: $responseText');

      return responseText ?? 'No response received';
    } catch (e) {
      print('Gemini API detailed error: $e');
      print('Error type: ${e.runtimeType}');

      // エラーの詳細を分析
      if (e.toString().contains('API_KEY')) {
        throw Exception('APIキーの問題: $e');
      } else if (e.toString().contains('quota')) {
        throw Exception('API利用制限: $e');
      } else if (e.toString().contains('network')) {
        throw Exception('ネットワークエラー: $e');
      } else {
        throw Exception('Gemini API接続失敗: $e');
      }
    }
  }

  /// 一人食事向け店舗分析（Phase 3で本格実装予定）
  Future<String> analyzeSoloFriendlyRestaurants(List<Map<String, dynamic>> restaurants) async {
    try {
      const prompt = '''
あなたは一人食事の専門家です。以下の店舗情報を分析して、一人食事に適した店舗を評価してください：

【分析観点】
- カウンター席の有無・一人客への対応
- 店の雰囲気・入りやすさ
- 立地・アクセスの良さ
- 価格帯の適正さ

【Phase 3で実装予定のプロンプト】
今はテスト用の簡単な応答を返してください。
''';

      final response = await _model.generateContent([
        Content.text(prompt)
      ]);

      return response.text ?? 'Analysis not available';
    } catch (e) {
      throw Exception('Gemini analysis failed: $e');
    }
  }
}