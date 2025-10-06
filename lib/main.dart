import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .envファイルが存在する場合のみ読み込み（ローカル開発用）
  try {
    await dotenv.load(fileName: ".env");
    print('Loaded .env file successfully');
  } catch (e) {
    print('No .env file found, using dart-define environment variables');
    // Vercel環境では.envファイルが存在しないため、これは正常
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
          seedColor: const Color(0xFF8B7355), // ナチュラルなブラウン
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}