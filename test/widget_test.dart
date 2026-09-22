import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hometour/main.dart';

void main() {
  testWidgets('Global Tours app renders its loading state', (tester) async {
    await tester.pumpWidget(const HomeTourApp(autoBootstrap: false));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
