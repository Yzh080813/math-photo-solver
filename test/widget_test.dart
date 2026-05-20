import 'package:flutter_test/flutter_test.dart';
import 'package:math_photo_app/main.dart';

void main() {
  testWidgets('App displays welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MathPhotoApp());

    expect(find.text('Math Photo Solver'), findsOneWidget);
    expect(find.text('Welcome to Math Photo Solver!'), findsOneWidget);
  });
}
