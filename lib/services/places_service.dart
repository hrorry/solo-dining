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

  // テキスト検索で飲食店を検索
  // 現状はsearchNearbyRestaurantsを使うように実装
  Future<List<Map<String, dynamic>>> searchRestaurantsByText({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    // TODO: テキスト検索用のエンドポイントを別途実装
    // 今は近隣検索で代用
    if (latitude != null && longitude != null) {
      return searchNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radius: 5000,
      );
    } else {
      throw Exception('位置情報が必要です');
    }
  }
}
