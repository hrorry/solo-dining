import 'package:flutter/material.dart';
import 'restaurant_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final String location;
  final List<Map<String, dynamic>>? restaurants;

  const SearchResultScreen({
    super.key,
    required this.location,
    this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    // 実際のAPIデータを使用（渡されなかった場合はダミーデータ）
    final restaurantList = restaurants ?? [
      {
        'name': 'カフェ・ド・ソロ',
        'address': '東京都渋谷区1-1-1',
        'rating': 4.2,
        'tags': ['カウンター席', '一人客歓迎', 'WiFi'],
        'description': 'カウンター席メインのおしゃれなカフェ',
      },
      {
        'name': 'ひとり焼肉 はなれ',
        'address': '東京都渋谷区2-2-2',
        'rating': 4.5,
        'tags': ['一人焼肉', '個室', '深夜営業'],
        'description': '一人でも気軽に焼肉が楽しめる',
      },
      {
        'name': 'ラーメン横丁',
        'address': '東京都渋谷区3-3-3',
        'rating': 4.0,
        'tags': ['カウンター席', '深夜営業', '一人客多数'],
        'description': '地元に愛される老舗ラーメン店',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$location周辺のお店'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              '一人食事におすすめのお店 ${restaurantList.length}件',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: restaurantList.length,
              itemBuilder: (context, index) {
                final restaurant = restaurantList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${restaurant['rating']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      restaurant['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(restaurant['address'] as String),
                        const SizedBox(height: 8),
                        Text(
                          restaurant['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: (restaurant['tags'] as List<String>)
                              .map((tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailScreen(
                            restaurant: restaurant,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}