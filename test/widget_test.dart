import 'package:flutter_test/flutter_test.dart';

import 'package:hometour/main.dart';

void main() {
  testWidgets('Global Tours app starts', (tester) async {
    await tester.pumpWidget(const HomeTourApp());
    expect(find.text('Global Tours'), findsOneWidget);
  });
}
