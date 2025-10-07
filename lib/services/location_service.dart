import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  // 現在地の緯度経度を取得
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効か確認
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('位置情報サービスが無効です。デバイスの設定で有効にしてください。');
    }

    // 位置情報の許可を確認
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置情報の許可が拒否されました');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('位置情報の許可が永久に拒否されています。設定から許可してください。');
    }

    // 現在地を取得
    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      return position;
    } catch (e) {
      throw Exception('現在地の取得に失敗しました: $e');
    }
  }

  // 住所から緯度経度を取得
  Future<Map<String, double>> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return {'latitude': location.latitude, 'longitude': location.longitude};
      } else {
        throw Exception('指定された住所が見つかりませんでした');
      }
    } catch (e) {
      throw Exception('住所から位置情報への変換に失敗しました: $e');
    }
  }

  // 緯度経度から住所を取得
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.administrativeArea ?? ''}${placemark.locality ?? ''}${placemark.thoroughfare ?? ''}';
      } else {
        throw Exception('住所が見つかりませんでした');
      }
    } catch (e) {
      throw Exception('位置情報から住所への変換に失敗しました: $e');
    }
  }
}
