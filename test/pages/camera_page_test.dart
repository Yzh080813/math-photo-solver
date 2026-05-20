import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_photo_app/pages/camera_page.dart';

void main() {
  testWidgets('CameraPage shows two buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CameraPage()),
    );

    expect(find.text('拍照'), findsWidgets);
    expect(find.text('从相册选择'), findsOneWidget);
  });
}
