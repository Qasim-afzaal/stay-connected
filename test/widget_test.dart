import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stay_connected/main.dart';

void main() {
  testWidgets('MyApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
