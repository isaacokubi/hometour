import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hometour/main.dart';

void main() {
  testWidgets('Global Tours app renders its initial loading state', (tester) async {
    await tester.pumpWidget(const HomeTourApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
