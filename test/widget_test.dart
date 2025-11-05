import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomsprojec/home_page.dart';
import 'package:roomsprojec/room_model.dart';

void main() {
  testWidgets('HomePage displays rooms and title', (WidgetTester tester) async {
    // Create a sample model and an empty callback for the test.
    final roomsModel = RoomsModel.sample();
    void onUpdate() {}

    // Build our app and trigger a frame.
    // We wrap HomePage in a MaterialApp to provide necessary context like
    // theming and navigation.
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(roomsModel: roomsModel, onUpdate: onUpdate),
      ),
    );

    // Verify that the AppBar title is displayed.
    expect(find.text('Rooms — find your next stay'), findsOneWidget);
    // Verify that the first sample room is displayed.
    expect(find.text('Modern Studio'), findsOneWidget);
  });
}
