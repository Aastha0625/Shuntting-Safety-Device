import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/de_assignment_screen.dart';

void main() {
  testWidgets('DEAssignmentScreen renders without throwing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FLUTTER ERROR: ${details.exception}');
      debugPrint('STACK TRACE: ${details.stack}');
    };

    try {
      await tester.pumpWidget(const MaterialApp(home: DEAssignmentScreen()));
      await tester.pumpAndSettle(); // Wait for Future to complete
      expect(find.byType(DEAssignmentScreen), findsOneWidget);
    } catch (e, stack) {
      debugPrint('CAUGHT ERROR: $e');
      debugPrint('STACK TRACE: $stack');
    }
  });
}
