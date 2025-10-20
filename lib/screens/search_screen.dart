import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../services/gemini_service.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _locationController = TextEditingController();
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();
  final GeminiService _geminiService = GeminiService();

  bool _isLoadingLocation = false;
  bool _isSearching = false;
  Position? _currentLocation;
  String? _currentAddress;
  String _searchMode = 'gemini_only'; // 'places_gemini' or 'gemini_only'

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // 現在地を取得
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
        });

        // 緯度経度から住所を取得（Web環境では失敗する可能性があるので try-catch）
        String address = '現在地 (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';

        try {
          final geocodedAddress = await _locationService.getAddressFromCoordinates(location.latitude, location.longitude);
          if (geocodedAddress.isNotEmpty) {
            address = geocodedAddress;
          }
        } catch (e) {
          // 住所変換に失敗しても、緯度経度表示で続行
          print('住所変換失敗（緯度経度で続行）: $e');
        }

        if (mounted) {
          setState(() {
            _currentAddress = address;
            _locationController.text = address;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('現在地を取得しました'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('現在地の取得に失敗しました: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // 店舗を検索
  Future<void> _searchRestaurants() async {
    final query = _locationController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('場所を入力するか、現在地を取得してください'), duration: Duration(seconds: 2)));
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Map<String, dynamic>> restaurants = [];

      if (_searchMode == 'gemini_only') {
        // Geminiのみで検索
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gemini AIで店舗を検索中...'), duration: Duration(seconds: 2)));

        restaurants = await _geminiService.searchRestaurantsByGeminiOnly(query);
      } else {
        // Places API + Gemini分析
        // Vercel Function経由で統一的にPlaces APIを呼び出す
        if (_currentLocation != null) {
          // 現在地を使って検索（Nearby Search）
          restaurants = await _placesService.searchNearbyRestaurants(
            latitude: _currentLocation!.latitude,
            longitude: _currentLocation!.longitude,
            radius: 1500,
          );
        } else {
          // テキスト検索を使用（住所、駅名、店名など）
          restaurants = await _placesService.searchRestaurantsByText(query: query);
        }

        if (restaurants.isNotEmpty) {
          // Gemini AIで一人食事向け分析
          try {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AIで分析中...'), duration: Duration(seconds: 2)));
            restaurants = await _geminiService.analyzeSoloFriendlyRestaurants(restaurants);
          } catch (e) {
            print('Gemini analysis failed, using original data: $e');
          }
        }
      }

      if (mounted) {
        if (restaurants.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('該当する店舗が見つかりませんでした'), duration: Duration(seconds: 2)));
        } else {
          // 検索結果画面へ遷移
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SearchResultScreen(location: query, restaurants: restaurants),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('検索に失敗しました: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solo Dining'),
        backgroundColor: const Color(0xFFF5E6D3), // ナチュラル系ベージュ
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // タイトル
              Text(
                '一人でも安心して\n行けるお店を見つけよう',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF8B7355), // ナチュラルなブラウン
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 現在地ボタン
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8DCC8), width: 1),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.my_location,
                    color: _isLoadingLocation ? Colors.grey : const Color(0xFF6B8E23), // オリーブグリーン
                  ),
                  title: Text(_currentAddress ?? '現在地を取得', style: TextStyle(color: _currentAddress != null ? const Color(0xFF5D4E37) : Colors.grey[600])),
                  trailing: _isLoadingLocation
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  onTap: _isLoadingLocation ? null : _getCurrentLocation,
                ),
              ),

              const SizedBox(height: 20),

              // 区切り線
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('または', style: TextStyle(color: Colors.grey[600])),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 20),

              // 場所入力フィールド
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: '場所を入力',
                  hintText: '駅名、住所、ホテル名など...',
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF8B7355)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B7355), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F3),
                ),
                onSubmitted: (_) => _searchRestaurants(),
              ),

              const SizedBox(height: 20),

              // 検索モード切り替え
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8DCC8), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '検索モード',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B7355)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Places API + AI分析', style: TextStyle(fontSize: 12)),
                            selected: _searchMode == 'places_gemini',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _searchMode = 'places_gemini';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Geminiのみ', style: TextStyle(fontSize: 12)),
                            selected: _searchMode == 'gemini_only',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _searchMode = 'gemini_only';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchMode == 'places_gemini' ? '✓ Google Mapsの実データ + AI分析' : '✓ Gemini AIが店舗を提案',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 検索ボタン
              ElevatedButton(
                onPressed: _isSearching ? null : _searchRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7355),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Text('お店を探す', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),

              // 機能説明カード
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DCC8), width: 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 48, color: const Color(0xFF8B7355)),
                    const SizedBox(height: 16),
                    Text(
                      '検索機能',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF5D4E37), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 一人でも入りやすいお店を優先\n'
                      '• Google Mapのコメントを分析\n'
                      '• カウンター席のあるお店を重視\n'
                      '• 口コミの雰囲気をAIが判定',
                      style: TextStyle(color: const Color(0xFF6B5D4F), height: 1.8),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
