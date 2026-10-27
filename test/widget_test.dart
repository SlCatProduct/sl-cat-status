import 'package:flutter_test/flutter_test.dart';
import 'package:sl_cat_status/main.dart';

void main() {
  testWidgets('SL CAT app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SlCatApp());
    expect(find.byType(SlCatApp), findsOneWidget);
  });
}
