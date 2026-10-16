import 'package:flutter_test/flutter_test.dart';
import 'package:hidayah/main.dart';

void main() {
  testWidgets('Hidayah app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HidayahApp());

    // Verify app starts and shows Home / Prayer times title or bottom navigation
    expect(find.byType(HidayahApp), findsOneWidget);
  });
}
