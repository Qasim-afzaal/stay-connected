import 'package:flutter_test/flutter_test.dart';

import 'package:stay_connected/main.dart';

void main() {
  testWidgets('MyApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
