import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/ai_service.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MathPhotoApp());
}

class MathPhotoApp extends StatelessWidget {
  const MathPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数学拍照解题',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _checking = true;
  bool _hasApiKey = false;
  AiService? _aiService;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  @override
  void dispose() {
    _aiService?.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('api_key');
    setState(() {
      _hasApiKey = key != null && key.isNotEmpty;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasApiKey) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置 API Key')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.key, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('请先设置 API Key 才能使用', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                  _checkApiKey();
                },
                child: const Text('前往设置'),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<String>(
      future: _getApiKey(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _aiService ??= AiService(apiKey: snapshot.data!);
        return HomePage(aiService: _aiService!);
      },
    );
  }

  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key') ?? '';
  }
}
