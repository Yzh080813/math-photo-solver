import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_photo_app/models/record.dart';
import 'package:math_photo_app/services/storage_service.dart';

void main() {
  group('StorageService', () {
    late StorageService storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
    });

    test('loadRecords returns empty list initially', () async {
      final records = await storage.loadRecords();
      expect(records, isEmpty);
    });

    test('save and load records roundtrip', () async {
      final record = Record(
        id: '1',
        imagePath: '/path.jpg',
        answer: '42',
        steps: [],
        createdAt: DateTime(2026, 5, 20),
      );

      await storage.saveRecord(record);
      final records = await storage.loadRecords();
      expect(records.length, 1);
      expect(records.first.id, '1');
      expect(records.first.answer, '42');
    });

    test('deleteRecord removes record', () async {
      final record = Record(
        id: '1',
        imagePath: '/path.jpg',
        answer: '42',
        steps: [],
        createdAt: DateTime(2026, 5, 20),
      );

      await storage.saveRecord(record);
      await storage.deleteRecord('1');
      final records = await storage.loadRecords();
      expect(records, isEmpty);
    });

    test('records are sorted newest first', () async {
      final r1 = Record(id: '1', imagePath: '', answer: 'a', steps: [], createdAt: DateTime(2026, 5, 19));
      final r2 = Record(id: '2', imagePath: '', answer: 'b', steps: [], createdAt: DateTime(2026, 5, 20));

      await storage.saveRecord(r1);
      await storage.saveRecord(r2);
      final records = await storage.loadRecords();
      expect(records.first.id, '2');
    });
  });
}
