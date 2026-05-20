import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_photo_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App shows API key setup when no key is configured', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MathPhotoApp());

    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // After loading completes, should show API key setup
    await tester.pumpAndSettle();
    expect(find.text('设置 API Key'), findsOneWidget);
    expect(find.text('请先设置 API Key 才能使用'), findsOneWidget);
  });
}
