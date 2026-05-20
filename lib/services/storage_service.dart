import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';

class StorageService {
  static const String _key = 'records';

  Future<List<Record>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Record.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveRecord(Record record) async {
    final records = await loadRecords();
    records.insert(0, record);
    await _persist(records);
  }

  Future<void> deleteRecord(String id) async {
    final records = await loadRecords();
    records.removeWhere((r) => r.id == id);
    await _persist(records);
  }

  Future<void> _persist(List<Record> records) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(records.map((r) => r.toMap()).toList());
    await prefs.setString(_key, data);
  }
}
