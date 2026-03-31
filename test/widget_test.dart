import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:stay_connected/main.dart';

void main() {
  testWidgets('MyApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
