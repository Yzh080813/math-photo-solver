import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_photo_app/pages/result_page.dart';
import 'package:math_photo_app/services/ai_service.dart';

void main() {
  testWidgets('ResultPage shows loading state initially', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(
          imagePath: '/fake/path.jpg',
          aiService: AiService(apiKey: 'test'),
        ),
      ),
    );

    expect(find.text('正在解题...'), findsOneWidget);
  });
}
