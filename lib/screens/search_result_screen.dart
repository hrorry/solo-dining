import 'package:flutter/material.dart';
import 'restaurant_detail_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String location;
  final List<Map<String, dynamic>>? restaurants;

  const SearchResultScreen({
    super.key,
    required this.location,
    this.restaurants,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  String _sortBy = 'solo_score'; // デフォルトは一人食事向けスコア順
  List<Map<String, dynamic>> _sortedRestaurants = [];

  @override
  void initState() {
    super.initState();
    _updateSortedList();
  }

  void _updateSortedList() {
    final restaurants = widget.restaurants ?? [];
    
    setState(() {
      _sortedRestaurants = List.from(restaurants);
      
      // ソート処理
      switch (_sortBy) {
        case 'solo_score':
          _sortedRestaurants.sort((a, b) {
            final scoreA = a['solo_score'] ?? 50;
            final scoreB = b['solo_score'] ?? 50;
            return scoreB.compareTo(scoreA); // 降順
          });
          break;
        case 'rating':
          _sortedRestaurants.sort((a, b) {
            final ratingA = a['rating'] ?? 0.0;
            final ratingB = b['rating'] ?? 0.0;
            return ratingB.compareTo(ratingA); // 降順
          });
          break;
        case 'reviews':
          _sortedRestaurants.sort((a, b) {
            final reviewsA = a['user_ratings_total'] ?? 0;
            final reviewsB = b['user_ratings_total'] ?? 0;
            return reviewsB.compareTo(reviewsA); // 降順
          });
          break;
      }
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final restaurantList = _sortedRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.location}周辺のお店'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // ヘッダー情報とソート切り替え
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              children: [
                Text(
                  '一人食事におすすめのお店 ${restaurantList.length}件',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // ソート切り替えボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('並び順: ', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('おすすめ順', style: TextStyle(fontSize: 12)),
                      selected: _sortBy == 'solo_score',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = 'solo_score';
                            _updateSortedList();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('評価順', style: TextStyle(fontSize: 12)),
                      selected: _sortBy == 'rating',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = 'rating';
                            _updateSortedList();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('口コミ数順', style: TextStyle(fontSize: 12)),
                      selected: _sortBy == 'reviews',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = 'reviews';
                            _updateSortedList();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 店舗リスト
          Expanded(
            child: ListView.builder(
              itemCount: restaurantList.length,
              itemBuilder: (context, index) {
                final restaurant = restaurantList[index];
                final soloScore = restaurant['solo_score'] ?? 50;
                final reason = restaurant['reason'] as String? ?? '';
                final tags = restaurant['tags'] as List<dynamic>? ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailScreen(
                            restaurant: restaurant,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ヘッダー行（店名とスコア）
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant['name'] as String? ?? '不明',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 一人食事向けスコア
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(soloScore),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$soloScore',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // 住所
                          Text(
                            restaurant['vicinity'] ?? restaurant['formatted_address'] ?? restaurant['address'] ?? '住所不明',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // 評価と営業状態
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                '${restaurant['rating'] ?? 0.0}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${restaurant['user_ratings_total'] ?? 0}件)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (restaurant['opening_hours']?['open_now'] == true) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '営業中',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          // AI分析による推奨理由
                          if (reason.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.auto_awesome, size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          // タグ表示
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          
                          // 詳細を見るアイコン
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '詳細を見る',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
