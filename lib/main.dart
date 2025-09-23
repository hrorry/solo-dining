import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/search_result_screen.dart';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .envファイルが存在する場合のみ読み込み（ローカル開発用）
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, using environment variables: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Dining',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _locationController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isTestingGemini = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _searchRestaurants() {
    String location = _locationController.text.trim();
    if (location.isNotEmpty) {
      // 結果画面に遷移
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(location: location),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('場所を入力してください')),
      );
    }
  }

  Future<void> _testGeminiAPI() async {
    setState(() {
      _isTestingGemini = true;
    });

    try {
      final response = await _geminiService.testConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gemini API接続成功: $response'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Gemini API Error: $e'); // デバッグ用
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gemini API接続失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10), // 長めに表示
            action: SnackBarAction(
              label: 'コピー',
              textColor: Colors.white,
              onPressed: () {
                // エラーをコンソールに出力
                print('Error details: $e');
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingGemini = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solo Dining'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              '一人でも安心して行けるお店を見つけよう！',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '場所を入力',
                hintText: '駅名、住所、ホテル名など...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              onSubmitted: (_) => _searchRestaurants(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchRestaurants,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'お店を探す',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Gemini API テストボタン（Phase 1用）
            OutlinedButton.icon(
              onPressed: _isTestingGemini ? null : _testGeminiAPI,
              icon: _isTestingGemini
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.psychology),
              label: Text(_isTestingGemini ? 'テスト中...' : 'Gemini API テスト'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '検索機能',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• 一人でも入りやすいお店を優先\n'
                        '• Google Mapのコメントを分析\n'
                        '• カウンター席のあるお店を重視\n'
                        '• 口コミの雰囲気をAIが判定',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}