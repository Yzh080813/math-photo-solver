import 'package:flutter_test/flutter_test.dart';
import 'package:math_photo_app/models/record.dart';

void main() {
  group('Record', () {
    test('toMap and fromMap roundtrip', () {
      final record = Record(
        id: 'test-1',
        imagePath: '/path/to/image.jpg',
        answer: 'x = 5',
        steps: ['移项: 2x = 10', '除以2: x = 5'],
        createdAt: DateTime(2026, 5, 20),
      );

      final map = record.toMap();
      final restored = Record.fromMap(map);

      expect(restored.id, record.id);
      expect(restored.imagePath, record.imagePath);
      expect(restored.answer, record.answer);
      expect(restored.steps, record.steps);
      expect(restored.createdAt, record.createdAt);
    });

    test('fromMap handles empty steps', () {
      final map = {
        'id': 'test-2',
        'imagePath': '/path.jpg',
        'answer': '42',
        'steps': '',
        'createdAt': '2026-05-20T00:00:00.000',
      };
      final record = Record.fromMap(map);
      expect(record.steps, ['']);
    });
  });
}
