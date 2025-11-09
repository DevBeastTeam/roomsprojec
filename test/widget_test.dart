import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomsprojec/user/home_page.dart';

void main() {
  testWidgets('HomePage displays rooms and title', (WidgetTester tester) async {
    // Create a sample model and an empty callback for the test.
    void onUpdate() {}

    // Build our app and trigger a frame.
    // We wrap HomePage in a MaterialApp to provide necessary context like
    // theming and navigation.
    await tester.pumpWidget(MaterialApp());

    // Verify that the AppBar title is displayed.
    expect(find.text('Rooms — find your next stay'), findsOneWidget);
    // Verify that the first sample room is displayed.
    expect(find.text('Modern Studio'), findsOneWidget);
  });
}
