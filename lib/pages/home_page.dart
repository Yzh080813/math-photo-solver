import 'package:flutter/material.dart';
import '../models/record.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import 'camera_page.dart';
import 'result_page.dart';
import 'settings_page.dart';
import '../widgets/record_list_item.dart';

class HomePage extends StatefulWidget {
  final AiService aiService;

  const HomePage({super.key, required this.aiService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = StorageService();
  List<Record> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _storage.loadRecords();
    setState(() => _records = records);
  }

  Future<void> _takePhoto() async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (imagePath == null || !mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          imagePath: imagePath,
          aiService: widget.aiService,
        ),
      ),
    );

    if (result != null && mounted) {
      final aiResult = result as AiResponse;
      final record = Record(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        answer: aiResult.answer,
        steps: aiResult.steps,
        createdAt: DateTime.now(),
      );
      await _storage.saveRecord(record);
      _loadRecords();
    }
  }

  Future<void> _deleteRecord(Record record) async {
    await _storage.deleteRecord(record.id);
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数学拍照解题'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('还没有解题记录', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('开始解题'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('拍照解题'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return RecordListItem(
                        record: record,
                        onTap: () {
                          // 点击查看历史结果
                        },
                        onDelete: () => _deleteRecord(record),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
