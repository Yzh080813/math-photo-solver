import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _controller.text = prefs.getString('api_key') ?? '';
    setState(() {});
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', _controller.text.trim());
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: _SettingsForm(
        controller: _controller,
        saved: _saved,
        onSave: _saveApiKey,
      ),
    );
  }
}

class _SettingsForm extends StatelessWidget {
  final TextEditingController controller;
  final bool saved;
  final VoidCallback onSave;

  const _SettingsForm({
    required this.controller,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('API Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '输入你的 Claude API Key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          const Text('需要 Anthropic API Key。在 console.anthropic.com 获取。', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSave,
            child: Text(saved ? '已保存 ✓' : '保存'),
          ),
        ],
      ),
    );
  }
}
