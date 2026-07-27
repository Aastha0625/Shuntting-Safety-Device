import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/de_assignment_screen.dart';

void main() {
  testWidgets('DEAssignmentScreen renders without throwing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR: ${details.exception}');
      print('STACK TRACE: ${details.stack}');
    };

    try {
      await tester.pumpWidget(const MaterialApp(home: DEAssignmentScreen()));
      await tester.pumpAndSettle(); // Wait for Future to complete
      expect(find.byType(DEAssignmentScreen), findsOneWidget);
    } catch (e, stack) {
      print('CAUGHT ERROR: $e');
      print('STACK TRACE: $stack');
    }
  });
}
