import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  // Google Mapsで店舗位置を開く
  Future<void> _openGoogleMaps() async {
    final latitude = restaurant['latitude'];
    final longitude = restaurant['longitude'];
    final placeId = restaurant['place_id'];

    if (latitude == null || longitude == null) {
      throw Exception('位置情報が取得できませんでした');
    }

    // Google Maps URLを生成（place_idがあればより正確）
    final Uri mapsUrl;
    if (placeId != null && placeId.toString().isNotEmpty) {
      mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$placeId',
      );
    } else {
      mapsUrl = Uri.parse('https://maps.google.com/?q=$latitude,$longitude');
    }

    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('地図アプリを開けませんでした');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant['name'] as String? ?? '店舗詳細'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('お気に入りに追加しました')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー情報
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            '${restaurant['rating'] ?? 0.0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant['name'] as String? ?? '不明',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant['vicinity'] as String? ??
                                    restaurant['formatted_address']
                                        as String? ??
                                    '住所不明',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      restaurant['reason'] as String? ??
                          restaurant['vicinity'] as String? ??
                          '店舗情報',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // タグ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('特徴', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (restaurant['tags'] as List<dynamic>? ?? [])
                          .map(
                            (tag) => Chip(
                              label: Text(tag.toString()),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 一人食事向けの分析（Phase 3で実装予定）
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI分析結果',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '【Phase 3で実装予定】\n'
                        'このお店は一人食事に最適です：\n'
                        '• カウンター席が充実\n'
                        '• 一人客の利用者が多く、入りやすい雰囲気\n'
                        '• 口コミからも一人食事の満足度が高い\n'
                        '\nおすすめ度: ★★★★☆',
                        style: TextStyle(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // アクションボタン
            // 緯度経度がある場合のみ地図ボタンを表示
            if (restaurant['latitude'] != null &&
                restaurant['longitude'] != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _openGoogleMaps();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('エラーが発生しました: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('地図で見る'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('電話アプリを開きます（Phase 2で実装予定）')),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('電話する'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
