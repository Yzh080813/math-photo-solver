import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_photo_app/pages/home_page.dart';
import 'package:math_photo_app/services/ai_service.dart';

void main() {
  testWidgets('HomePage shows empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(aiService: AiService(apiKey: 'test')),
      ),
    );

    expect(find.text('还没有解题记录'), findsOneWidget);
    expect(find.text('开始解题'), findsOneWidget);
  });
}
