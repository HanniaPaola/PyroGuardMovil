import 'package:flutter_test/flutter_test.dart';
import 'package:pyro/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PyroGuardApp());
    expect(find.byType(PyroGuardApp), findsOneWidget);
  });
}
