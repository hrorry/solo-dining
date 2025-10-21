import 'dart:convert';
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

    _model = GenerativeModel(model: 'gemini-flash-latest', apiKey: finalApiKey);
  }

  /// Gemini APIの動作確認用テストメソッド
  Future<String> testConnection() async {
    try {
      print('Testing Gemini API connection...');

      final response = await _model.generateContent([Content.text('Hello! Please respond with a simple greeting.')]);

      final responseText = response.text;
      print('Gemini response: $responseText');

      return responseText ?? 'No response received';
    } catch (e) {
      print('Gemini API detailed error: $e');

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

  /// 一人食事向け店舗分析（Places APIデータ使用）
  Future<List<Map<String, dynamic>>> analyzeSoloFriendlyRestaurants(List<Map<String, dynamic>> restaurants) async {
    try {
      // Places APIのデータを整形
      final restaurantsData = restaurants.map((r) {
        return {
          'place_id': r['place_id'] ?? '',
          'name': r['name'] ?? '不明',
          'address': r['vicinity'] ?? r['formatted_address'] ?? '住所不明',
          'rating': r['rating'] ?? 0.0,
          'user_ratings_total': r['user_ratings_total'] ?? 0,
          'types': r['types'] ?? [],
          'is_open_now': r['opening_hours']?['open_now'] ?? false,
        };
      }).toList();

      // Geminiに送るプロンプト
      final prompt =
          '''
あなたは一人食事の専門家です。以下の店舗情報を分析して、一人食事に適しているかを評価してください。

【分析観点】
1. カウンター席の有無・一人客への対応（店舗タイプから推測）
   - bar, cafe, ramen などはカウンター席が多い → 高評価
   - restaurant で評価が高い → 一人でも入りやすい
2. 店の雰囲気・入りやすさ（評価・レビュー数から推測）
   - 評価4.0以上 → 質が高く安心
   - レビュー数が多い → 人気があり入りやすい
3. 立地・アクセスの良さ
   - 営業中かどうか
4. 価格帯の適正さ（店舗タイプから推測）
   - cafe, bar, ramen, meal_takeaway → 比較的リーズナブル

【店舗データ】
${_formatRestaurantsForPrompt(restaurantsData)}

【出力形式】
各店舗について、以下のJSON配列形式で返してください：
[
  {
    "place_id": "店舗ID",
    "solo_score": 一人食事向けスコア（0-100の整数）,
    "reason": "推奨理由（日本語で1-2文、具体的に）",
    "tags": ["タグ1", "タグ2", "タグ3"]（例: カウンター席あり、一人客歓迎、落ち着いた雰囲気、営業中など）
  }
]

**重要**: 
- JSON配列のみを返してください。他の説明文は不要です。
- 必ず全店舗分のデータを含めてください。
- solo_scoreは必ず0-100の整数にしてください。
''';

      print('Sending to Gemini...');

      final response = await _model.generateContent([Content.text(prompt)]);

      final responseText = response.text ?? '';
      print('Gemini response received');

      // JSON解析
      return _parseGeminiResponse(responseText, restaurants);
    } catch (e) {
      print('Gemini analysis error: $e');
      // エラー時は元のデータにデフォルト値を追加して返す
      return restaurants.map((r) {
        return {...r, 'solo_score': 50, 'reason': '分析データを取得できませんでした', 'tags': []};
      }).toList();
    }
  }

  /// Geminiのみで店舗検索（Places API不使用）
  Future<List<Map<String, dynamic>>> searchRestaurantsByGeminiOnly(String location) async {
    try {
      final prompt =
          '''
あなたは地域の飲食店に詳しい専門家です。

以下のルールに従って「$location周辺のお店」を最小10件、最大20件教えてください。

# 探し方

- Googleマップ検索で「カウンター_$location」で探す
- ファーストインプレッションは店名と写真ふざけてる店名は避けがち（酒ト唄エバ心ナンチャラとか、人生酒場とか）
- 日本語は3～5文字くらいが好みかも
- カウンター、メニュー、料理の写真で全体的に好みか判断
- 気になる感じの店があったら深堀りしていく口コミはGoogleを参照（新着順何個か見る＞低評価の内容）※★の数より口コミの質
- メニュー写真はグルメサイト（食べログ、ホットペッパー）で確認
- 内観、外観、料理の確認補助をインスタでする感じで見てます
- 更に気になる場合は、Googleストリートビューで周辺もちょっと歩いてみる（繁華街すぎると行きにくい）

## 良い条件

- メニューが手書き（風）のページがある
- カウンターとテーブル席の割合が同じくらいかそれ以下（テーブルが多いと大人数向け店な感じする）
- 何か1つでもこだわりがありそうなところ（「映え」へのこだわりは除く）
- 逆にホットペッパー、食べログに載ってない（Googleのみ）
- 創作しすぎてない料理
- 客の投稿写真がちょっとヘタ
- 照明が眩しくない
- クッション性のあるカウンター椅子
- 歩いて行ける範囲だったら最高。タクシーなら1メーターが理想

## 除外条件

- 即席な作りの店舗
- インスタの投稿が多い（＝映えるので味が疎かになっている可能性が高い、客層が若い、PR）
- 外観張り切りすぎてる
- コンクリート打ちっぱなし系
- メニューより外観内観の投稿が多い
- 最近できた店（客層未知、情報少ない→開拓タイプには良いかも）
- 店舗が狭すぎると常連客との絡みが濃そう（15～20坪くらい？）それを良しとする場合もある

## NG条件

- フリーWi－Fiないのに自分の携帯からオーダーするタイプ
- LINE友達追加しないと注文できない仕様
- トイレが汚い

# 出力形式
以下のJSON配列形式で返してください：
[
  {
    "name": "店舗名",
    "address": "住所",
    "solo_score": 一人食事向けスコア（0-100の整数）,
    "reason": "推奨理由（日本語で1-2文、具体的に）",
    "tags": ["タグ1", "タグ2", "タグ3"]（例: カウンター席あり、一人客歓迎、落ち着いた雰囲気など）,
    "rating": 予想評価（3.5-5.0の小数）,
    "types": ["店舗タイプ"]（例: bar, cafe, ramen, restaurant など）
  }
]

**重要**: 
- JSON配列のみを返してください。他の説明文は不要です。
- 必ず10件のデータを含めてください。
- 実在する店舗を優先してください。
- solo_scoreは必ず0-100の整数にしてください。
''';

      print('Sending Gemini-only search request...');

      final response = await _model.generateContent([Content.text(prompt)]);

      final responseText = response.text ?? '';
      print('Gemini-only search response received');

      // JSON解析
      return _parseGeminiOnlyResponse(responseText);
    } catch (e) {
      print('Gemini-only search error: $e');
      throw Exception('Gemini検索に失敗しました: $e');
    }
  }

  /// 店舗データをプロンプト用にフォーマット
  String _formatRestaurantsForPrompt(List<Map<String, dynamic>> restaurants) {
    return restaurants
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key + 1;
          final r = entry.value;
          return '''
店舗$index:
- place_id: ${r['place_id']}
- 店名: ${r['name']}
- 住所: ${r['address']}
- 評価: ${r['rating']} (${r['user_ratings_total']}件)
- タイプ: ${(r['types'] as List).join(', ')}
- 営業状態: ${r['is_open_now'] ? '営業中' : '営業時間外'}
''';
        })
        .join('\n');
  }

  /// Geminiの応答をパース（Places APIデータ使用時）
  List<Map<String, dynamic>> _parseGeminiResponse(String responseText, List<Map<String, dynamic>> originalRestaurants) {
    try {
      // JSONブロックを抽出（```json ... ``` で囲まれている場合に対応）
      String jsonText = responseText.trim();

      // マークダウンのコードブロックを除去
      if (jsonText.contains('```json')) {
        final start = jsonText.indexOf('```json') + 7;
        final end = jsonText.lastIndexOf('```');
        if (end > start) {
          jsonText = jsonText.substring(start, end).trim();
        }
      } else if (jsonText.contains('```')) {
        final start = jsonText.indexOf('```') + 3;
        final end = jsonText.lastIndexOf('```');
        if (end > start) {
          jsonText = jsonText.substring(start, end).trim();
        }
      }

      // JSON配列をパース
      final List<dynamic> analysisResults = json.decode(jsonText);

      // 元のrestaurantsデータに解析結果をマージ
      return originalRestaurants.map((restaurant) {
        final placeId = restaurant['place_id'];

        // 対応する解析結果を探す
        final analysis = analysisResults.firstWhere((a) => a['place_id'] == placeId, orElse: () => {'solo_score': 50, 'reason': '分析結果がありません', 'tags': []});

        return {
          ...restaurant,
          'solo_score': analysis['solo_score'] ?? 50,
          'reason': analysis['reason'] ?? '分析結果がありません',
          'tags': List<String>.from(analysis['tags'] ?? []),
        };
      }).toList();
    } catch (e) {
      print('JSON parse error: $e');
      print('Response text: $responseText');

      // パースエラー時はデフォルト値を返す
      return originalRestaurants.map((r) {
        return {...r, 'solo_score': 50, 'reason': 'JSON解析エラー', 'tags': []};
      }).toList();
    }
  }

  /// Geminiのみの応答をパース
  List<Map<String, dynamic>> _parseGeminiOnlyResponse(String responseText) {
    try {
      // JSONブロックを抽出
      String jsonText = responseText.trim();

      // マークダウンのコードブロックを除去
      if (jsonText.contains('```json')) {
        final start = jsonText.indexOf('```json') + 7;
        final end = jsonText.lastIndexOf('```');
        if (end > start) {
          jsonText = jsonText.substring(start, end).trim();
        }
      } else if (jsonText.contains('```')) {
        final start = jsonText.indexOf('```') + 3;
        final end = jsonText.lastIndexOf('```');
        if (end > start) {
          jsonText = jsonText.substring(start, end).trim();
        }
      }

      // JSON配列をパース
      final List<dynamic> results = json.decode(jsonText);

      // データ整形
      return results.map((r) {
        return {
          'place_id': 'gemini_${r['name']?.hashCode ?? 0}', // 仮のID
          'name': r['name'] ?? '不明',
          'vicinity': r['address'] ?? '住所不明',
          'formatted_address': r['address'] ?? '住所不明',
          'solo_score': r['solo_score'] ?? 50,
          'reason': r['reason'] ?? '情報なし',
          'tags': List<String>.from(r['tags'] ?? []),
          'rating': (r['rating'] as num?)?.toDouble() ?? 4.0,
          'user_ratings_total': 0,
          'types': List<String>.from(r['types'] ?? ['restaurant']),
          'opening_hours': null,
        };
      }).toList();
    } catch (e) {
      print('Gemini-only JSON parse error: $e');
      print('Response text: $responseText');
      throw Exception('Gemini応答のJSON解析に失敗しました');
    }
  }
}
