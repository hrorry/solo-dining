import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  // Google Places APIキーを環境変数から取得
  static String get _apiKey {
    const apiKey = String.fromEnvironment('PLACES_API_KEY');
    if (apiKey.isNotEmpty) {
      return apiKey;
    }
    return dotenv.env['PLACES_API_KEY'] ?? '';
  }

  // 近隣の飲食店を検索
  Future<List<Map<String, dynamic>>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1000, // デフォルト1km
    String type = 'restaurant',
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('PLACES_API_KEYが設定されていません');
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$latitude,$longitude'
      '&radius=$radius'
      '&type=$type'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((place) => _parsePlaceData(place)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('店舗検索に失敗しました: $e');
    }
  }

  // テキスト検索で飲食店を検索
  Future<List<Map<String, dynamic>>> searchRestaurantsByText({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('PLACES_API_KEYが設定されていません');
    }

    var urlString = 'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=$query restaurant'
        '&key=$_apiKey';

    // 位置情報が指定されている場合は追加
    if (latitude != null && longitude != null) {
      urlString += '&location=$latitude,$longitude&radius=5000';
    }

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((place) => _parsePlaceData(place)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('店舗検索に失敗しました: $e');
    }
  }

  // 店舗詳細情報を取得
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    if (_apiKey.isEmpty) {
      throw Exception('PLACES_API_KEYが設定されていません');
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=name,rating,formatted_address,formatted_phone_number,opening_hours,reviews,photos,website,price_level'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return data['result'];
        } else {
          throw Exception('Places API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('店舗詳細の取得に失敗しました: $e');
    }
  }

  // Place Photoを取得するURLを生成
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (_apiKey.isEmpty) {
      return '';
    }

    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photoreference=$photoReference'
        '&key=$_apiKey';
  }

  // Places APIのレスポンスをパース
  Map<String, dynamic> _parsePlaceData(Map<String, dynamic> place) {
    return {
      'place_id': place['place_id'] ?? '',
      'name': place['name'] ?? '不明',
      'address': place['vicinity'] ?? place['formatted_address'] ?? '住所不明',
      'rating': place['rating'] ?? 0.0,
      'user_ratings_total': place['user_ratings_total'] ?? 0,
      'latitude': place['geometry']?['location']?['lat'] ?? 0.0,
      'longitude': place['geometry']?['location']?['lng'] ?? 0.0,
      'photos': place['photos'] ?? [],
      'price_level': place['price_level'] ?? 0,
      'is_open_now': place['opening_hours']?['open_now'] ?? false,
    };
  }
}
