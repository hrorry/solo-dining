import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlacesService {
  // Vercel FunctionのベースURL
  // Web環境では相対パス、モバイルでは絶対URL
  static String get _baseUrl {
    if (kIsWeb) {
      return ''; // 相対パスで/api/placesを呼び出す
    }
    // モバイルアプリの場合はVercelのURL
    return 'https://solo-dining.vercel.app';
  }

  // 近隣の飲食店を検索（Vercel Function経由）
  Future<List<Map<String, dynamic>>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1500,
    String type = 'restaurant',
  }) async {
    final url = Uri.parse(
      '${_baseUrl}/api/places'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&radius=$radius'
      '&type=$type',
    );

    try {
      print('Requesting: $url');
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final results = data['results'] as List;
          return results.map((place) => place as Map<String, dynamic>).toList();
        } else {
          throw Exception('API Error: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchNearbyRestaurants: $e');
      throw Exception('店舗検索に失敗しました: $e');
    }
  }

  // テキスト検索で飲食店を検索（Vercel Function経由）
  Future<List<Map<String, dynamic>>> searchRestaurantsByText({
    required String query,
  }) async {
    final url = Uri.parse(
      '${_baseUrl}/api/places?query=${Uri.encodeComponent(query)}',
    );

    try {
      print('Text search requesting: $url');
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final results = data['results'] as List;
          return results.map((place) => place as Map<String, dynamic>).toList();
        } else {
          throw Exception('API Error: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchRestaurantsByText: $e');
      throw Exception('テキスト検索に失敗しました: $e');
    }
  }
}
