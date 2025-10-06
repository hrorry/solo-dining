import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  final Location _location = Location();

  // 現在地の緯度経度を取得
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 位置情報サービスが有効か確認
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('位置情報サービスが無効です');
      }
    }

    // 位置情報の許可を確認
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('位置情報の許可が得られませんでした');
      }
    }

    // 現在地を取得
    try {
      final locationData = await _location.getLocation();
      return locationData;
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
        return {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
      } else {
        throw Exception('指定された住所が見つかりませんでした');
      }
    } catch (e) {
      throw Exception('住所から位置情報への変換に失敗しました: $e');
    }
  }

  // 緯度経度から住所を取得
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
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
