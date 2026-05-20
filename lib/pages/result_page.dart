import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final AiService aiService;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.aiService,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _loading = true;
  String? _error;
  AiResponse? _result;

  @override
  void initState() {
    super.initState();
    _solve();
  }

  Future<void> _solve() async {
    try {
      final result = await widget.aiService.solveProblem(widget.imagePath);
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('解题结果')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在解题...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 题目图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(widget.imagePath),
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),

          // 答案
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                const Text('答案', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  _result!.answer,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 解题步骤（可展开）
          if (_result!.steps.isNotEmpty && _result!.steps.first.isNotEmpty)
            ExpansionTile(
              title: const Text('查看解题步骤'),
              childrenPadding: const EdgeInsets.all(16),
              children: _result!.steps.asMap().entries.map((entry) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                ),
              ).toList(),
            ),

          const SizedBox(height: 24),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('重新拍照'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, _result),
                  icon: const Icon(Icons.check),
                  label: const Text('保存结果'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
